test_that("oasisbrUI returns valid Shiny UI structure", {
  skip_if_not_installed("shiny")

  ui <- oasisbrUI()
  expect_s3_class(ui, "shiny.tag.list")

  ui_char <- as.character(ui)
  expect_true(grepl("Oasisbr Collection", ui_char))
  expect_true(grepl("oasisbrSearchQuery", ui_char))
  expect_true(grepl("oasisbrFetchOnline", ui_char))
  expect_true(grepl("oasisbrFile", ui_char))
  expect_true(grepl("oasisbrDocTypeFilter", ui_char))
  expect_true(grepl("oasisbrProcessFile", ui_char))
  expect_true(grepl("oasisbrLoadToApp", ui_char))
})
