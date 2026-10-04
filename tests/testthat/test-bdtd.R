test_that("read_bdtd rejeita arquivo inexistente ou invalido", {
  expect_error(read_bdtd("arquivo_fantasma.csv"), "Arquivo nao encontrado")
  expect_error(read_bdtd(123), "Arquivo nao encontrado")
})

test_that("read_bdtd le fixture da BDTD/Oasisbr e normaliza colunas", {
  sample_file <- testthat::test_path("../../inst/extdata/bdtd_sample.csv")

  if (!file.exists(sample_file)) {
    sample_file <- system.file("extdata", "bdtd_sample.csv", package = "bibliolatam")
  }

  expect_true(file.exists(sample_file))

  M <- read_bdtd(sample_file, convert = TRUE)

  expect_s3_class(M, "bibliometrixDB")
  expect_equal(attr(M, "dbsource"), "bdtd")
  expect_equal(nrow(M), 4L)
  expect_type(M$PY, "double")
  expect_equal(M$PY[1], 2022)
  expect_equal(M$PY[2], 2021)
  expect_equal(M$PY[3], 2023)
  expect_equal(M$PY[4], 2020)

  # tipos de documento (tese vs dissertacao)
  expect_equal(M$DT[1], "THESIS")
  expect_equal(M$DT[2], "DISSERTATION")
  expect_equal(M$DT[3], "THESIS")
  expect_equal(M$DT[4], "DISSERTATION")

  # normalizacao de autoria
  expect_equal(M$AU[1], "SILVA MA; SANTOS MC")
  expect_equal(M$AU[2], "ALMEIDA NETO LF")
  expect_equal(M$AU[3], "LIMA FILHO JR; SOUZA CP")
  expect_equal(M$AU[4], "RIBEIRO GG; OLIVEIRA AR")

  # orientadores em RP
  expect_equal(M$RP[1], "FERREIRA RC")
  expect_equal(M$RP[2], "MORAES BN")

  # SO estruturado com instituicao e programa
  expect_true(grepl("UNIVERSIDADE DE SAO PAULO", M$SO[1]))
  expect_true(grepl("COMPUTACAO", M$SO[1]))

  # idioma
  expect_equal(M$LA[1], "PORTUGUESE")
  expect_equal(M$LA[4], "ENGLISH")

  # identificador UT mapeado da URI
  expect_true(grepl("bdtd.ibict.br", M$UT[1]))

  # compatibilidade com alias read_oasisbr
  O <- read_oasisbr(sample_file, convert = TRUE)
  expect_equal(nrow(O), 4L)
  expect_equal(O$AU, M$AU)

  # teste com convert = FALSE
  df_raw <- read_bdtd(sample_file, convert = FALSE)
  expect_false("bibliometrixDB" %in% class(df_raw))
  expect_true(is.data.frame(df_raw))
})

test_that("read_bdtd funciona com bibliometrix::biblioAnalysis", {
  skip_if_not_installed("bibliometrix")

  sample_file <- testthat::test_path("../../inst/extdata/bdtd_sample.csv")
  if (!file.exists(sample_file)) {
    sample_file <- system.file("extdata", "bdtd_sample.csv", package = "bibliolatam")
  }

  M <- read_bdtd(sample_file, convert = TRUE)
  results <- bibliometrix::biblioAnalysis(M, sep = ";")

  expect_s3_class(results, "bibliometrix")
  expect_equal(results$Articles, 4)
  expect_true(length(results$Authors) > 0)
})
