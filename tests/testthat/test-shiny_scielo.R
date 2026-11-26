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

test_that("scieloUI includes trilingual online keyword search mode and scieloServer executes keyword search", {
  skip_if_not_installed("shiny")

  ui_en <- as.character(scieloUI(lang = "en"))
  ui_pt <- as.character(scieloUI(lang = "pt"))
  ui_es <- as.character(scieloUI(lang = "es"))

  expect_true(grepl("scieloSearchQuery", ui_en, fixed = TRUE))
  expect_true(grepl("scieloSearchCollections", ui_en, fixed = TRUE))
  expect_true(grepl("scieloSearchEnrichCR", ui_en, fixed = TRUE))
  expect_true(grepl("scieloSearchBtn", ui_en, fixed = TRUE))
  expect_true(grepl("Online Search (Keywords)", ui_en, fixed = TRUE))
  expect_true(grepl("Busca Online (Palavras-chave)", ui_pt, fixed = TRUE))
  expect_true(grepl("Busqueda en Linea (Palabras clave)", ui_es, fixed = TRUE))

  captured_args <- NULL
  mock_df <- as_bibliometrix(data.frame(
    AU = c("PACKER A; MENEGHINI R", "SILVA J"),
    TI = c("SciELO 25 years of open science in Latin America", "Epidemiologia e saude coletiva no Brasil"),
    SO = c("Scientometrics", "Cadernos de Saude Publica"),
    PY = c(2022, 2023),
    LA = c("English", "Portuguese"),
    DI = c("10.1590/s1", "10.1590/s2"),
    CR = c("REF1; REF2", NA_character_),
    stringsAsFactors = FALSE
  ), "scielo")

  with_mocked_bindings(
    download_scielo_search = function(query, limit, years, enrich_references, convert, progress, normalize_authors, collections, ...) {
      captured_args <<- list(
        query = query, limit = limit, years = years,
        enrich = enrich_references, collections = collections
      )
      mock_df
    },
    {
      vals <- shiny::reactiveValues(M = NULL, Morig = NULL)
      shiny::testServer(
        function(input, output, session) scieloServer(input, output, session, vals),
        {
          # Empty query should not populate data
          session$setInputs(
            scieloSearchQuery = "   ",
            scieloSearchCollections = c("br", "cl"),
            scieloSearchLimit = 25,
            scieloYearStart = 2021,
            scieloYearEnd = 2023,
            scieloSearchEnrichCR = FALSE,
            scieloSearchNormalizeAuthors = TRUE
          )
          session$setInputs(scieloSearchBtn = 1L)
          expect_error(output$scieloSummaryBoxes)

          # Valid keyword search populates data, KPI boxes, and loads into values$M
          session$setInputs(scieloSearchQuery = "saude coletiva", current_lang = "pt")
          session$setInputs(scieloSearchBtn = 2L)
          expect_equal(captured_args$query, "saude coletiva")
          expect_equal(captured_args$limit, 25L)
          expect_equal(captured_args$years, c(2021L, 2023L))
          expect_equal(captured_args$collections, c("br", "cl"))

          boxes_html <- as.character(output$scieloSummaryBoxes$html)
          expect_true(grepl("DOCUMENTOS", boxes_html, fixed = TRUE))
          expect_true(grepl("PERIODO", boxes_html, fixed = TRUE))

          session$setInputs(scieloLoadToApp = 1L)
          expect_s3_class(vals$M, "bibliometrixDB")
          expect_equal(nrow(vals$M), 2L)
        }
      )
    }
  )
})
