test_that("scieloUI returns valid Shiny UI structure", {
  skip_if_not_installed("shiny")

  ui <- scieloUI()
  expect_s3_class(ui, "shiny.tag.list")

  ui_char <- as.character(ui)
  expect_true(grepl("SciELO Data Collection", ui_char))
  expect_true(grepl("scieloInputIds", ui_char))
  expect_true(grepl("scieloFetchData", ui_char))
  expect_true(grepl("scieloProcessFile", ui_char))
  expect_true(grepl("scieloLoadToApp", ui_char))
})
