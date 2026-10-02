test_that("read_scielo valida caminhos invalidos", {
  expect_error(read_scielo("arquivo_inexistente.csv"), "Arquivo nao encontrado")
  expect_error(read_scielo(123), "Arquivo nao encontrado")
})

test_that("read_scielo le fixture do scielo e mapeia tags wos", {
  sample_file <- testthat::test_path("../../inst/extdata/scielo_sample.csv")
  if (!file.exists(sample_file)) {
    sample_file <- system.file("extdata", "scielo_sample.csv", package = "bibliolatam")
  }

  expect_true(file.exists(sample_file))

  # testa com convert = TRUE
  M <- read_scielo(sample_file, convert = TRUE)

  expect_s3_class(M, "bibliometrixDB")
  expect_equal(attr(M, "dbsource"), "scielo")
  expect_equal(nrow(M), 5L)
  expect_type(M$PY, "double")
  expect_equal(M$PY[1], 2021)
  expect_equal(M$DT[1], "ARTICLE")

  # normalizacao de autoria
  expect_equal(M$AU[1], "SOUZA AP; SANTOS MR; OLIVEIRA JM")
  expect_equal(M$AU[4], "GOMEZ S; PEREZ V")

  # sanitizacao de doi
  expect_true(!grepl("^https?://", M$DI[1]))
  expect_equal(M$DI[1], "10.11606/s1518-8787.2021055002934")

  # colunas opcionais
  expect_true("SN" %in% names(M))
  expect_equal(M$SN[1], "0034-8910")

  # testa com convert = FALSE
  raw_df <- read_scielo(sample_file, convert = FALSE)
  expect_false("bibliometrixDB" %in% class(raw_df))
  expect_true(is.data.frame(raw_df))

  # testa pipeline de export para biblioshiny com dados do scielo
  tmp_rdata <- tempfile(fileext = ".RData")
  export_path <- export_biblioshiny(M, tmp_rdata)
  expect_true(file.exists(export_path))
  unlink(export_path)
})
