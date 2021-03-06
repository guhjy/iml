context("FeatureImp()")

#set.seed(42)

expectedColnames = c("feature", "original.error", "permutation.error", "importance")

test_that("FeatureImp works for single output", {
  
  var.imp = FeatureImp$new(predictor1, loss = "mse")
  dat = var.imp$results
  expect_class(dat, "data.frame")
  expect_false("data.table" %in% class(dat))
  expect_equal(colnames(dat), expectedColnames)
  expect_equal(nrow(dat), ncol(X))  
  p = plot(var.imp)
  expect_s3_class(p, c("gg", "ggplot"))
  p
  
  var.imp = FeatureImp$new(predictor1,  loss = "mse", method = "cartesian")
  dat = var.imp$results
  # Making sure the result is sorted by decreasing importance
  expect_class(dat, "data.frame")
  expect_equal(dat$importance, dat[order(dat$importance, decreasing = TRUE),]$importance)
  expect_equal(colnames(dat), expectedColnames)
  expect_equal(nrow(dat), ncol(X))  
  p = plot(var.imp)
  expect_s3_class(p, c("gg", "ggplot"))
  p
  
  X.exact = data.frame(x1 = c(1,2,3), x2 = c(9,4,2))
  y.exact = c(2,3,4)
  f.exact = Predictor$new(predict.fun = function(newdata) newdata[["x1"]], data = X.exact, y = y.exact)
  # creates a problem on win builder
  # model.error = Metrics::mse(y.exact, f.exact$predict(X.exact))
  model.error = 1
  cart.indices = c(1, 1, 1, 2, 2, 2, 3, 3, 3)
  cartesian.error = Metrics::mse(y.exact[cart.indices], c(1, 2, 3, 1, 2, 3, 1, 2, 3))
  
  # TODO: Check where the error comes from. Maybe something with that the predictor does not give correct results
  # n.repetitions should be ignored
  var.imp = FeatureImp$new(f.exact, loss = "mse", method = "cartesian")
  dat = var.imp$results
  expect_class(dat, "data.frame")
  expect_equal(dat$importance, c(cartesian.error, 1))
  expect_equal(colnames(dat), expectedColnames)
  expect_equal(model.error, var.imp$original.error)
  expect_equal(nrow(dat), ncol(X.exact))  
  p = plot(var.imp)
  expect_s3_class(p, c("gg", "ggplot"))
  p
  
  p = plot(var.imp, sort = FALSE)
  expect_s3_class(p, c("gg", "ggplot"))
  p
  
  p = var.imp$plot()
  expect_s3_class(p, c("gg", "ggplot"))
  p

})

test_that("FeatureImp works for single output and function as loss", {
    
  var.imp = FeatureImp$new(predictor1, loss = Metrics::mse)
  dat = var.imp$results
  expect_class(dat, "data.frame")
  # Making sure the result is sorted by decreasing importance
  expect_equal(dat$importance, dat[order(dat$importance, decreasing = TRUE),]$importance)
  expect_equal(colnames(dat), expectedColnames)
  expect_equal(nrow(dat), ncol(X))  
  p = plot(var.imp)
  expect_s3_class(p, c("gg", "ggplot"))
  p
  
})

test_that("FeatureImp works for multiple output",{
  var.imp = FeatureImp$new(predictor2, loss = "ce")
  dat = var.imp$results
  expect_class(dat, "data.frame")
  expect_equal(colnames(dat), expectedColnames)
  expect_equal(nrow(dat), ncol(X))  
  p = plot(var.imp)
  expect_s3_class(p, c("gg", "ggplot"))
  p
})


test_that("FeatureImp fails without target vector",{
  predictor2 = Predictor$new(f, data = X, predict.fun = predict.fun)
  expect_error(FeatureImp$new(predictor2, loss = "ce"))
})

test_that("Works for different repetitions.",{
  var.imp = FeatureImp$new(predictor1, loss = "mse", n.repetitions = 2)
  dat = var.imp$results
  expect_class(dat, "data.frame")
})


test_that("Model receives data.frame without additional columns", {
  # https://stackoverflow.com/questions/51980808/r-plotting-importance-feature-using-featureimpnew
  library(mlr)
  library(ranger)
  data("iris")
  tsk = mlr::makeClassifTask(data = iris, target = "Species")
  lrn = mlr::makeLearner("classif.ranger",predict.type = "prob")
  mod = mlr:::train(lrn, tsk)
  X = iris[which(names(iris) != "Species")]
  predictor = Predictor$new(mod, data = X, y = iris$Species)
  imp = FeatureImp$new(predictor, loss = "ce")
  expect_r6(imp)
})

