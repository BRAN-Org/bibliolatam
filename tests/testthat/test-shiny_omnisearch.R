test_that("omnisearchUI returns valid Shiny tags, clean title, Advanced Settings drawer, and reversible collapse script", {
  skip_if_not_installed("shiny")

  ui <- omnisearchUI()
  expect_s3_class(ui, "shiny.tag.list")
  ui_str <- as.character(ui)

  # Clean heading without "Latin American" (kept only in the description banner)
  expect_true(grepl(">Omnisearch Engine<", ui_str, fixed = TRUE))
  expect_false(grepl(">Latin American Omnisearch Engine<", ui_str, fixed = TRUE))
  expect_true(grepl("Unified Latin American Search", ui_str, fixed = TRUE))

  # Core controls
  expect_true(grepl("omniQuery", ui_str))
  expect_true(grepl("omniYearStart", ui_str))
  expect_true(grepl("omniYearEnd", ui_str))
  expect_true(grepl("omniLimit", ui_str))
  expect_true(grepl("omniSources", ui_str))
  expect_true(grepl("omniDeduplicate", ui_str))
  expect_true(grepl("omniEnrichCR", ui_str))
  expect_true(grepl("omniSearchBtn", ui_str))
  expect_true(grepl("omniMetricsCards", ui_str))
  expect_true(grepl("omniPreviewTable", ui_str))
  expect_true(grepl("omniLoadSection", ui_str))

  # Advanced Settings drawer (hidden by default) and all advanced inputs
  expect_true(grepl("omniToggleAdvanced", ui_str, fixed = TRUE))
  expect_true(grepl("omniAdvancedPanel", ui_str, fixed = TRUE))
  expect_true(grepl("display: none;", ui_str, fixed = TRUE))
  expect_true(grepl("omniAdvancedChevron", ui_str, fixed = TRUE))
  expect_true(grepl("slideToggle(250)", ui_str, fixed = TRUE))
  expect_true(grepl("omniMatchBy", ui_str, fixed = TRUE))
  expect_true(grepl("omniSimilarityThreshold", ui_str, fixed = TRUE))
  expect_true(grepl("omniNormalizeAuthors", ui_str, fixed = TRUE))
  expect_true(grepl("omniDocTypeFilter", ui_str, fixed = TRUE))
  expect_true(grepl("omniLanguageFilter", ui_str, fixed = TRUE))
  expect_true(grepl("omniRequireDoi", ui_str, fixed = TRUE))
  expect_true(grepl("omniRequireAbstract", ui_str, fixed = TRUE))
  expect_true(grepl("omniScieloCollections", ui_str, fixed = TRUE))
  expect_true(grepl("10.4067", ui_str, fixed = TRUE))
  expect_true(grepl("10.4321", ui_str, fixed = TRUE))
  expect_true(grepl("10.15517", ui_str, fixed = TRUE))
  expect_true(grepl("10.17843", ui_str, fixed = TRUE))
  expect_true(grepl("10.26461", ui_str, fixed = TRUE))
  expect_true(grepl("omniTimeout", ui_str, fixed = TRUE))
  expect_true(grepl("omniCsvSep", ui_str, fixed = TRUE))
  expect_true(grepl("omniCsvBom", ui_str, fixed = TRUE))
  expect_true(grepl("omniResetAdvancedBtn", ui_str, fixed = TRUE))

  # Reversible collapse toggle contract (matches other bibliolatam Shiny modules)
  expect_true(grepl("omnisearchTogglePanel", ui_str))
  expect_true(grepl("omnisearchContent", ui_str))
  expect_true(grepl('data-i18n-title="btn_collapse"', ui_str, fixed = TRUE))
  expect_true(grepl("slideToggle(300)", ui_str, fixed = TRUE))
  expect_true(grepl("fa-chevron-down", ui_str, fixed = TRUE))
  expect_true(grepl("fa-chevron-up", ui_str, fixed = TRUE))
})

test_that("omnisearchServer hides preview empty-match message before any search is run", {
  skip_if_not_installed("shiny")

  shiny::testServer(omnisearchServer, {
    # Before any search, all preview/metrics/load outputs must be NULL (no misleading 'No records match' box)
    expect_null(output$omniMetricsCards)
    expect_null(output$omniPreviewHeader)
    expect_null(output$omniPreviewControls)
    expect_null(output$omniPreviewTable)
    expect_null(output$omniLoadSection)
  })
})

test_that("omnisearchServer does not use destructive removeUI on toggle and preserves state", {
  skip_if_not_installed("shiny")

  server_src <- paste(deparse(body(omnisearchServer)), collapse = "\n")
  expect_false(grepl("removeUI", server_src, fixed = TRUE))

  mock_df <- as_bibliometrix(
    data.frame(
      TI = c("Artigo Toggle 1", "Artigo Toggle 2"),
      AU = c("SILVA J", "GAMA G"),
      SO = c("REV A", "REV B"),
      PY = c(2022, 2023),
      DI = c("10.1590/tog1", "10.1590/tog2"),
      stringsAsFactors = FALSE
    ),
    dbsource = "scielo"
  )

  shiny::testServer(omnisearchServer, {
    omni_data(mock_df)
    omni_stats(list(total = 2L, sources = "scielo: 2", timespan = "2022 - 2023", unique_authors = 2L))
    session$flushReact()

    # Simulate collapsing and expanding repeatedly
    session$setInputs(omnisearchTogglePanel = 1L)
    session$setInputs(omnisearchTogglePanel = 2L)
    session$setInputs(omnisearchTogglePanel = 3L)
    session$flushReact()

    expect_equal(nrow(omni_data()), 2L)
    expect_equal(preview_filtered_data()$TI, c("Artigo Toggle 1", "Artigo Toggle 2"))
    expect_false(is.null(output$omniPreviewTable))
    expect_true(grepl("overflow-x: auto", output$omniPreviewTable$html, fixed = TRUE))
    expect_false(is.null(output$omniMetricsCards))
    expect_true(grepl("2022 - 2023", output$omniMetricsCards$html, fixed = TRUE))
  })
})

test_that("omnisearchServer handles CSV (comma, semicolon, UTF-8 BOM) and RData export handlers", {
  skip_if_not_installed("shiny")

  mock_df <- data.frame(
    TI = c("Estudo Omnisearch 1", "Estudo Omnisearch 2"),
    AU = c("SILVA J", "SANTOS M"),
    SO = c("REV TEST", "REV TEST"),
    PY = c(2021, 2022),
    DI = c("10.1590/t1", "10.1590/t2"),
    DB = c("scielo", "bdtd"),
    stringsAsFactors = FALSE
  )
  mock_df <- as_bibliometrix(mock_df, dbsource = "scielo")

  shiny::testServer(omnisearchServer, {
    expect_null(output$omniLoadSection)

    omni_data(mock_df)
    omni_stats(list(total = 2, sources = "scielo: 1 | bdtd: 1", timespan = "2021 - 2022", unique_authors = 2))
    session$setInputs(omniCsvSep = ",", omniCsvBom = FALSE)
    session$flushReact()

    load_sec <- output$omniLoadSection$html
    expect_true(grepl("omniDownloadCSV", load_sec))
    expect_true(grepl("omniDownloadRData", load_sec))
    expect_true(grepl("omniReloadBiblioshinyBtn", load_sec))

    # Default comma CSV without BOM
    csv_file <- output$omniDownloadCSV
    expect_true(file.exists(csv_file))
    csv_read <- utils::read.csv(csv_file, stringsAsFactors = FALSE)
    expect_equal(nrow(csv_read), 2L)
    expect_true("TI" %in% names(csv_read))

    # Semicolon CSV with UTF-8 BOM (Excel PT/ES compatibility)
    session$setInputs(omniCsvSep = ";", omniCsvBom = TRUE)
    session$flushReact()
    csv_bom_file <- output$omniDownloadCSV
    expect_true(file.exists(csv_bom_file))
    first_bytes <- readBin(csv_bom_file, what = "raw", n = 3L)
    expect_equal(first_bytes, as.raw(c(0xef, 0xbb, 0xbf)))
    csv_semi <- utils::read.csv2(csv_bom_file, stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM")
    expect_equal(nrow(csv_semi), 2L)
    expect_true("TI" %in% names(csv_semi))

    # RData export handler
    rdata_file <- output$omniDownloadRData
    expect_true(file.exists(rdata_file))
    env <- new.env()
    load(rdata_file, envir = env)
    expect_true(exists("M", envir = env))
    expect_equal(nrow(env$M), 2L)
  })
})

test_that("omnisearchServer preview filtering, search, pagination, and bounds work cleanly", {
  skip_if_not_installed("shiny")

  n <- 12L
  mock_df <- as_bibliometrix(
    data.frame(
      TI = paste("Open Science Study", sprintf("%02d", seq_len(n))),
      AU = paste0("AUTHOR", seq_len(n), " A"),
      SO = rep(c("Revista SciELO", "BDTD USP"), length.out = n),
      PY = rep(2020:2023, length.out = n),
      DI = paste0("10.1590/test", seq_len(n)),
      stringsAsFactors = FALSE
    ),
    dbsource = "omnisearch"
  )
  mock_df$DB <- rep(c("scielo", "bdtd"), each = 6L)

  shiny::testServer(omnisearchServer, {
    omni_data(mock_df)
    omni_stats(list(total = n, sources = "scielo: 6 | bdtd: 6", timespan = "2020 - 2023", unique_authors = n))
    session$flushReact()

    expect_equal(nrow(preview_filtered_data()), 12L)
    expect_equal(omni_preview_page(), 1L)
    expect_true(grepl("Page 1 of 2 \\(12 items\\)", output$omniPreviewPageInfoText$html))

    # Previous on page 1 stays at page 1
    session$setInputs(omniPreviewPrevBtn = 1L)
    expect_equal(omni_preview_page(), 1L)

    # Next advances to page 2 and does not exceed total pages
    session$setInputs(omniPreviewNextBtn = 1L)
    expect_equal(omni_preview_page(), 2L)
    expect_true(grepl("Page 2 of 2 \\(12 items\\)", output$omniPreviewPageInfoText$html))

    session$setInputs(omniPreviewNextBtn = 2L)
    expect_equal(omni_preview_page(), 2L)

    # Changing page size to 5 resets page to 1 (3 pages total)
    session$setInputs(omniPreviewPageSizeSelect = "5")
    expect_equal(omni_preview_page(), 1L)
    expect_equal(omni_preview_page_size(), 5L)
    expect_true(grepl("Page 1 of 3 \\(12 items\\)", output$omniPreviewPageInfoText$html))

    # Filtering by source resets page to 1 and keeps only matching DB
    session$setInputs(omniPreviewNextBtn = 3L)
    expect_equal(omni_preview_page(), 2L)
    session$setInputs(omniPreviewSourceFilter = "bdtd")
    expect_equal(omni_preview_page(), 1L)
    expect_equal(nrow(preview_filtered_data()), 6L)
    expect_true(all(preview_filtered_data()$DB == "bdtd"))

    # Live text search narrows results further
    session$setInputs(omniPreviewSearchInput = "Study 09")
    expect_equal(nrow(preview_filtered_data()), 1L)
    expect_equal(preview_filtered_data()$TI[1], "Open Science Study 09")

    # Non-matching search renders empty-match message cleanly (only because omni_data() is non-empty)
    session$setInputs(omniPreviewSearchInput = "zzz_no_match_xyz")
    expect_equal(nrow(preview_filtered_data()), 0L)
    expect_true(grepl("No records match the current preview filter", output$omniPreviewTable$html))

    # Resetting filters restores full dataset
    session$setInputs(omniPreviewSourceFilter = "all", omniPreviewSearchInput = "")
    expect_equal(nrow(preview_filtered_data()), 12L)
  })
})

test_that("omnisearchServer forwards all Advanced Settings to omnisearch_bibliolatam and supports reset", {
  skip_if_not_installed("shiny")

  captured_args <- NULL
  mock_df <- as_bibliometrix(
    data.frame(
      TI = "Manual Push Study",
      AU = "GAMA G",
      SO = "R JOURNAL",
      PY = 2026,
      DI = "10.4067/adv1",
      AB = "Full abstract text.",
      DT = "ARTICLE",
      LA = "SPANISH",
      stringsAsFactors = FALSE
    ),
    dbsource = "omnisearch"
  )

  shared_values <- shiny::reactiveValues(M = NULL)
  wrapped_server <- function(input, output, session) {
    omnisearchServer(input, output, session, values = shared_values)
  }

  testthat::with_mocked_bindings(
    omnisearch_bibliolatam = function(...) {
      captured_args <<- list(...)
      mock_df
    },
    .package = "bibliolatam",
    {
      shiny::testServer(wrapped_server, {
        session$setInputs(
          current_lang = "pt",
          omniQuery = "ciencia abierta",
          omniSources = c("scielo", "lareferencia"),
          omniLimit = 25L,
          omniYearStart = 2020,
          omniYearEnd = 2026,
          omniDeduplicate = TRUE,
          omniEnrichCR = TRUE,
          omniMatchBy = c("doi"),
          omniSimilarityThreshold = 0.94,
          omniNormalizeAuthors = FALSE,
          omniScieloCollections = c("cl", "es", "pe"),
          omniTimeout = 60,
          omniDocTypeFilter = c("ARTICLE"),
          omniLanguageFilter = c("SPANISH"),
          omniRequireDoi = TRUE,
          omniRequireAbstract = TRUE,
          omniSearchBtn = 1L
        )
        session$flushReact()

        expect_equal(captured_args$query, "ciencia abierta")
        expect_equal(captured_args$sources, c("scielo", "lareferencia"))
        expect_equal(captured_args$limit_per_source, 25L)
        expect_equal(captured_args$years, c(2020L, 2026L))
        expect_true(captured_args$enrich_references)
        expect_equal(captured_args$match_by, "doi")
        expect_equal(captured_args$similarity_threshold, 0.94)
        expect_false(captured_args$normalize_authors)
        expect_equal(captured_args$scielo_collections, c("cl", "es", "pe"))
        expect_equal(captured_args$timeout, 60)
        expect_equal(captured_args$doc_types, "ARTICLE")
        expect_equal(captured_args$languages, "SPANISH")
        expect_true(captured_args$require_doi)
        expect_true(captured_args$require_abstract)

        expect_false(is.null(shared_values$M))
        expect_equal(nrow(shared_values$M), 1L)
        expect_equal(shared_values$M$TI[1], "Manual Push Study")

        # Clear shared_values$M and verify manual reload button pushes it back
        shared_values$M <- NULL
        session$setInputs(omniReloadBiblioshinyBtn = 1L)
        session$flushReact()
        expect_false(is.null(shared_values$M))
        expect_equal(nrow(shared_values$M), 1L)

        # Trigger Reset Defaults cleanly without errors
        expect_no_error({
          session$setInputs(omniResetAdvancedBtn = 1L)
          session$flushReact()
        })
      })
    }
  )
})
