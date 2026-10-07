test_that("omnisearchUI returns valid Shiny tags and expected inputs", {
  skip_if_not_installed("shiny")

  ui <- omnisearchUI()
  expect_s3_class(ui, "shiny.tag.list")
  ui_str <- as.character(ui)

  expect_true(grepl("Latin American Omnisearch Engine", ui_str))
  expect_true(grepl("omniQuery", ui_str))
  expect_true(grepl("omniLimit", ui_str))
  expect_true(grepl("omniSources", ui_str))
  expect_true(grepl("omniDeduplicate", ui_str))
  expect_true(grepl("omniSearchBtn", ui_str))
  expect_true(grepl("omniMetricsCards", ui_str))
  expect_true(grepl("omniPreviewTable", ui_str))
})
