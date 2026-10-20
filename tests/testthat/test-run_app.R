test_that("run_app constructs a valid shiny.appobj across configurations", {
  skip_if_not_installed("shiny")

  # Default English
  app_en <- run_app(launch.browser = FALSE)
  expect_s3_class(app_en, "shiny.appobj")
  expect_true(is.list(app_en))
  expect_true("httpHandler" %in% names(app_en) || "server" %in% names(app_en) || "ui" %in% names(app_en))

  # Portuguese default
  app_pt <- run_app(default_lang = "pt", launch.browser = FALSE)
  expect_s3_class(app_pt, "shiny.appobj")

  # Spanish default
  app_es <- run_app(default_lang = "es", launch.browser = FALSE)
  expect_s3_class(app_es, "shiny.appobj")

  # Custom host and port options
  app_custom <- run_app(port = 8888, host = "0.0.0.0", launch.browser = FALSE)
  expect_s3_class(app_custom, "shiny.appobj")

  # Invalid language rejection
  expect_error(run_app(default_lang = "fr", launch.browser = FALSE))
})
