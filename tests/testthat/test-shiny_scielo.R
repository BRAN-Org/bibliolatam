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

test_that("bibliolatamInfoUI returns valid Shiny UI structure with documentation", {
  skip_if_not_installed("shiny")

  ui <- bibliolatamInfoUI()
  expect_s3_class(ui, "shiny.tag.list")

  ui_char <- as.character(ui)
  expect_true(grepl("bibliolatam", ui_char))
  expect_true(grepl("Why bibliolatam?", ui_char))
  expect_true(grepl("SciELO", ui_char))
  expect_true(grepl("BDTD", ui_char))
  expect_true(grepl("Oasisbr", ui_char))
  expect_true(grepl("FAIR Principles", ui_char))
  expect_true(grepl("data-i18n-html", ui_char))
})

test_that("bibliolatamInfoUI supports Portuguese and Spanish localization", {
  skip_if_not_installed("shiny")

  # Portuguese
  ui_pt <- as.character(bibliolatamInfoUI(lang = "pt"))
  expect_true(grepl("bibliolatam", ui_pt))
  expect_true(grepl("Por que o bibliolatam?", ui_pt))
  expect_true(grepl("Repositorios Regionais", ui_pt))
  expect_true(grepl("Principios FAIR", ui_pt))
  expect_true(grepl("Adesao a BOAI", ui_pt))
  expect_true(grepl("data-i18n-html", ui_pt))

  # Spanish
  ui_es <- as.character(bibliolatamInfoUI(lang = "es"))
  expect_true(grepl("bibliolatam", ui_es))
  expect_true(grepl("Por que bibliolatam?", ui_es))
  expect_true(grepl("Repositorios Regionales", ui_es))
  expect_true(grepl("Principios FAIR", ui_es))
  expect_true(grepl("Adhesion a BOAI", ui_es))
  expect_true(grepl("data-i18n-html", ui_es))
})
