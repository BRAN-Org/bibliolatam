test_that("run_app constructs a valid shiny.appobj", {
  skip_if_not_installed("shiny")

  app <- run_app(launch.browser = FALSE)
  expect_s3_class(app, "shiny.appobj")
  expect_true(is.list(app))
  expect_true("httpHandler" %in% names(app) || "server" %in% names(app) || "ui" %in% names(app))
})
