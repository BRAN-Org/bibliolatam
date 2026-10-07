test_that("omnisearchUI returns valid Shiny tags and expected inputs", {
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
