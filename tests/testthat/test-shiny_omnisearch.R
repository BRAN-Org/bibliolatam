test_that("omnisearchUI returns valid Shiny tags, expected inputs, and reversible collapse script", {
  skip_if_not_installed("shiny")

  ui <- omnisearchUI()
  expect_s3_class(ui, "shiny.tag.list")
  ui_str <- as.character(ui)

  expect_true(grepl("Latin American Omnisearch Engine", ui_str))
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

  # Reversible collapse toggle contract (matches other bibliolatam Shiny modules)
  expect_true(grepl("omnisearchTogglePanel", ui_str))
  expect_true(grepl("omnisearchContent", ui_str))
  expect_true(grepl('data-i18n-title="btn_collapse"', ui_str, fixed = TRUE))
  expect_true(grepl("slideToggle(300)", ui_str, fixed = TRUE))
  expect_true(grepl("fa-chevron-down", ui_str, fixed = TRUE))
  expect_true(grepl("fa-chevron-up", ui_str, fixed = TRUE))
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

test_that("omnisearchServer handles export handlers correctly", {
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
    # Initially null
    expect_null(output$omniLoadSection)

    # Set mock data
    omni_data(mock_df)
    omni_stats(list(total = 2, sources = "scielo: 1 | bdtd: 1", timespan = "2021 - 2022", unique_authors = 2))
    session$flushReact()

    load_sec <- output$omniLoadSection$html
    expect_true(grepl("omniDownloadCSV", load_sec))
    expect_true(grepl("omniDownloadRData", load_sec))
    expect_true(grepl("omniReloadBiblioshinyBtn", load_sec))

    # Test CSV export handler
    csv_file <- output$omniDownloadCSV
    expect_true(file.exists(csv_file))
    csv_read <- utils::read.csv(csv_file, stringsAsFactors = FALSE)
    expect_equal(nrow(csv_read), 2L)
    expect_true("TI" %in% names(csv_read))

    # Test RData export handler
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

    # Default page 1 of 2 (page size 10)
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

    # Non-matching search renders empty-match message cleanly
    session$setInputs(omniPreviewSearchInput = "zzz_no_match_xyz")
    expect_equal(nrow(preview_filtered_data()), 0L)
    expect_true(grepl("No records match the current preview filter", output$omniPreviewTable$html))

    # Resetting filters restores full dataset
    session$setInputs(omniPreviewSourceFilter = "all", omniPreviewSearchInput = "")
    expect_equal(nrow(preview_filtered_data()), 12L)
  })
})

test_that("omnisearchServer manual reload pushes dataset to values$M", {
  skip_if_not_installed("shiny")

  mock_df <- as_bibliometrix(
    data.frame(
      TI = "Manual Push Study",
      AU = "GAMA G",
      SO = "R JOURNAL",
      PY = 2026,
      stringsAsFactors = FALSE
    ),
    dbsource = "omnisearch"
  )

  shared_values <- shiny::reactiveValues(M = NULL)
  wrapped_server <- function(input, output, session) {
    omnisearchServer(input, output, session, values = shared_values)
  }

  testthat::with_mocked_bindings(
    omnisearch_bibliolatam = function(...) mock_df,
    .package = "bibliolatam",
    {
      shiny::testServer(wrapped_server, {
        session$setInputs(
          current_lang = "pt",
          omniQuery = "manual push",
          omniSources = c("scielo"),
          omniLimit = 10L,
          omniYearStart = NA,
          omniYearEnd = NA,
          omniDeduplicate = TRUE,
          omniEnrichCR = FALSE,
          omniSearchBtn = 1L
        )
        session$flushReact()

        expect_false(is.null(shared_values$M))
        expect_equal(nrow(shared_values$M), 1L)
        expect_equal(shared_values$M$TI[1], "Manual Push Study")

        # Clear shared_values$M and verify manual reload button pushes it back
        shared_values$M <- NULL
        session$setInputs(omniReloadBiblioshinyBtn = 1L)
        session$flushReact()

        expect_false(is.null(shared_values$M))
        expect_equal(nrow(shared_values$M), 1L)
        expect_equal(shared_values$M$TI[1], "Manual Push Study")
      })
    }
  )
})
