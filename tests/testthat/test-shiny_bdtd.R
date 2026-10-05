test_that("bdtdUI returns valid Shiny UI structure", {
  skip_if_not_installed("shiny")

  ui <- bdtdUI()
  expect_s3_class(ui, "shiny.tag.list")

  ui_char <- as.character(ui)
  expect_true(grepl("BDTD / Oasisbr Collection", ui_char))
  expect_true(grepl("bdtdFile", ui_char))
  expect_true(grepl("bdtdDegreeFilter", ui_char))
  expect_true(grepl("bdtdProcessFile", ui_char))
  expect_true(grepl("bdtdLoadToApp", ui_char))
})
