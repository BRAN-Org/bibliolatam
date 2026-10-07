test_that("omnisearch_bibliolatam validates input arguments correctly", {
  expect_error(omnisearch_bibliolatam(""), "deve ser uma string de busca nao vazia")
  expect_error(omnisearch_bibliolatam(c("a", "b")), "deve ser uma string de busca nao vazia")
  expect_error(omnisearch_bibliolatam(123), "deve ser uma string de busca nao vazia")
  expect_error(omnisearch_bibliolatam("dengue", limit_per_source = 0), "deve ser um inteiro positivo")
  expect_error(omnisearch_bibliolatam("dengue", sources = "invalid_db"), "Nenhuma fonte valida especificada")
})

test_that("omnisearch_bibliolatam handles single source and empty fallbacks cleanly", {
  skip_on_cran()

  # Test single source
  df_single <- tryCatch(
    omnisearch_bibliolatam("dengue", sources = "scielo", limit_per_source = 2L, progress = FALSE),
    error = function(e) {
      skip(paste("API SciELO offline:", e$message))
    }
  )

  if (nrow(df_single) > 0L) {
    expect_s3_class(df_single, "bibliometrixDB")
    expect_true(nrow(df_single) <= 2L)
    expect_true("TI" %in% names(df_single))
  }
})

test_that("omnisearch_bibliolatam merges and deduplicates multi-source datasets", {
  df1 <- data.frame(
    TI = c("Estudo do Dengue no Brasil", "Tratamento de Zika"),
    AU = c("SILVA J", "SANTOS M"),
    SO = c("REV SAUDE PUBLICA", "REV MED"),
    PY = c(2020, 2021),
    DI = c("10.1590/test.1", "10.1590/test.2"),
    AB = c("Resumo completo", NA),
    DB = c("SCIELO", "SCIELO"),
    stringsAsFactors = FALSE
  )
  df1 <- as_bibliometrix(df1, dbsource = "scielo")

  df2 <- data.frame(
    TI = c("Estudo do Dengue no Brasil", "Outro trabalho"),
    AU = c("SILVA J", "OLIVEIRA P"),
    SO = c("BDTD/IBICT", "BDTD/IBICT"),
    PY = c(2020, 2019),
    DI = c("10.1590/test.1", NA),
    AB = c(NA, "Resumo tese"),
    DB = c("BDTD", "BDTD"),
    stringsAsFactors = FALSE
  )
  df2 <- as_bibliometrix(df2, dbsource = "bdtd")

  merged <- merge_bibliolatam(df1, df2, match_by = c("doi", "title"))
  expect_s3_class(merged, "bibliometrixDB")
  expect_equal(nrow(merged), 3L)
  # Duplicate record 10.1590/test.1 should have abstract preserved from df1
  match_rec <- merged[!is.na(merged$DI) & merged$DI == "10.1590/test.1", ]
  expect_equal(nrow(match_rec), 1L)
  expect_equal(match_rec$AB, "Resumo completo")
  expect_true(grepl("scielo", match_rec$DB, ignore.case = TRUE) && grepl("bdtd", match_rec$DB, ignore.case = TRUE))
})

test_that("omnisearch_bibliolatam forwards years and enrich_references parameters", {
  passed_years <- NULL
  passed_enrich <- NULL

  testthat::with_mocked_bindings(
    download_scielo_search = function(query, limit, years, enrich_references, ...) {
      passed_years <<- years
      passed_enrich <<- enrich_references
      df <- data.frame(TI = "Artigo Teste", AU = "A", SO = "J", PY = 2022, DI = "10.1590/1", DB = "scielo", stringsAsFactors = FALSE)
      as_bibliometrix(df, dbsource = "scielo")
    },
    .package = "bibliolatam",
    {
      res <- omnisearch_bibliolatam(
        "teste",
        sources = "scielo",
        limit_per_source = 5L,
        years = c(2021, 2024),
        enrich_references = TRUE,
        deduplicate = FALSE,
        progress = FALSE
      )
      expect_equal(passed_years, c(2021, 2024))
      expect_true(passed_enrich)
      expect_equal(nrow(res), 1L)
    }
  )
})
