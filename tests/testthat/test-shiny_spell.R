test_that("spellUI renders valid Shiny tags and supports EN, PT, ES", {
  skip_if_not_installed("shiny")

  ui_en <- spellUI(lang = "en")
  expect_s3_class(ui_en, "shiny.tag.list")
  str_en <- as.character(ui_en)
  expect_true(grepl("SPELL / ANPAD Collection", str_en, fixed = TRUE))
  expect_true(grepl("spellFile", str_en, fixed = TRUE))
  expect_true(grepl("spellYearStart", str_en, fixed = TRUE))
  expect_true(grepl("spellYearEnd", str_en, fixed = TRUE))
  expect_true(grepl("spellProcessFile", str_en, fixed = TRUE))
  expect_true(grepl("spellLoadToApp", str_en, fixed = TRUE))

  expect_true(grepl("Coleta SPELL / ANPAD", as.character(spellUI("pt")), fixed = TRUE))
  expect_true(grepl("Recoleccion SPELL / ANPAD", as.character(spellUI("es")), fixed = TRUE))
})

test_that("spellServer parses SPELL CSV, filters years, localizes KPIs, and loads into session", {
  skip_if_not_installed("shiny")

  sample_csv <- system.file("extdata", "spell_sample.csv", package = "bibliolatam")
  if (!nzchar(sample_csv)) {
    sample_csv <- testthat::test_path("..", "..", "inst", "extdata", "spell_sample.csv")
  }
  skip_if_not(file.exists(sample_csv))

  vals <- shiny::reactiveValues(M = NULL, Morig = NULL)
  shiny::testServer(
    function(input, output, session) spellServer(input, output, session, vals),
    {
      # Missing file guard
      session$setInputs(spellProcessFile = 1L)
      expect_error(output$spellSummaryBoxes)

      # Upload valid SPELL CSV
      session$setInputs(
        spellFile = data.frame(name = "spell_sample.csv", size = 1800, type = "text/csv", datapath = sample_csv, stringsAsFactors = FALSE),
        spellYearStart = NA,
        spellYearEnd = NA,
        current_lang = "pt"
      )
      session$setInputs(spellProcessFile = 2L)

      boxes_pt <- as.character(output$spellSummaryBoxes$html)
      expect_true(grepl("TOTAL DE ARTIGOS", boxes_pt, fixed = TRUE))
      expect_true(grepl("PERIODICOS", boxes_pt, fixed = TRUE))

      session$setInputs(current_lang = "es")
      boxes_es <- as.character(output$spellSummaryBoxes$html)
      expect_true(grepl("TOTAL DE ARTICULOS", boxes_es, fixed = TRUE))
      expect_true(grepl("REVISTAS", boxes_es, fixed = TRUE))

      session$setInputs(spellLoadToApp = 1L)
      expect_s3_class(vals$M, "bibliometrixDB")
      expect_gt(nrow(vals$M), 0L)
    }
  )
})

test_that("secondary servers (BDTD, Oasisbr, Redalyc, Merge) localize KPI summary boxes across languages", {
  skip_if_not_installed("shiny")

  bdtd_csv <- system.file("extdata", "bdtd_sample.csv", package = "bibliolatam")
  if (!nzchar(bdtd_csv)) bdtd_csv <- testthat::test_path("..", "..", "inst", "extdata", "bdtd_sample.csv")
  red_bib <- system.file("extdata", "redalyc_sample.bib", package = "bibliolatam")
  if (!nzchar(red_bib)) red_bib <- testthat::test_path("..", "..", "inst", "extdata", "redalyc_sample.bib")
  spell_csv <- system.file("extdata", "spell_sample.csv", package = "bibliolatam")
  if (!nzchar(spell_csv)) spell_csv <- testthat::test_path("..", "..", "inst", "extdata", "spell_sample.csv")

  # BDTD KPI localization
  shiny::testServer(
    function(input, output, session) bdtdServer(input, output, session, NULL),
    {
      session$setInputs(
        bdtdFile = data.frame(name = "bdtd.csv", size = 2000, type = "text/csv", datapath = bdtd_csv, stringsAsFactors = FALSE),
        bdtdDegreeFilter = "all",
        current_lang = "pt"
      )
      session$setInputs(bdtdProcessFile = 1L)
      expect_true(grepl("TESES / DISSERTACOES", as.character(output$bdtdSummaryBoxes$html), fixed = TRUE))
    }
  )

  # Oasisbr KPI localization
  shiny::testServer(
    function(input, output, session) oasisbrServer(input, output, session, NULL),
    {
      session$setInputs(
        oasisbrFile = data.frame(name = "oasis.csv", size = 2000, type = "text/csv", datapath = bdtd_csv, stringsAsFactors = FALSE),
        oasisbrDocTypeFilter = "all",
        current_lang = "es"
      )
      session$setInputs(oasisbrProcessFile = 1L)
      expect_true(grepl("FUENTES / REPOSITORIOS", as.character(output$oasisbrSummaryBoxes$html), fixed = TRUE))
    }
  )

  # Redalyc KPI localization
  shiny::testServer(
    function(input, output, session) redalycServer(input, output, session, NULL),
    {
      session$setInputs(
        redalycFile = data.frame(name = "red.bib", size = 500, type = "text/plain", datapath = red_bib, stringsAsFactors = FALSE),
        current_lang = "pt"
      )
      session$setInputs(redalycProcessFile = 1L)
      expect_true(grepl("TOTAL DE ARTIGOS", as.character(output$redalycSummaryBoxes$html), fixed = TRUE))
    }
  )

  # Merge KPI localization (merging active collection + SPELL file)
  active_df <- read_spell(spell_csv, convert = TRUE)
  vals <- shiny::reactiveValues(M = active_df, Morig = active_df)
  shiny::testServer(
    function(input, output, session) bibliolatamMergeServer(input, output, session, vals),
    {
      session$setInputs(
        mergeSource1 = "active",
        mergeFile2 = data.frame(name = "spell.csv", size = 1800, type = "text/csv", datapath = spell_csv, stringsAsFactors = FALSE),
        mergeMatchCriteria = c("doi", "title"),
        mergeSimilarityThreshold = 0.90,
        current_lang = "pt"
      )
      session$setInputs(mergeRunAction = 1L)
      mrg_html <- as.character(output$bibliolatamMergeSummaryBoxes$html)
      expect_true(grepl("DUPLICATAS RESOLVIDAS", mrg_html, fixed = TRUE))
      expect_true(grepl("FONTES FUNDIDAS", mrg_html, fixed = TRUE))
    }
  )
})
