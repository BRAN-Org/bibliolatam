test_that("export_biblioshiny valida parametros de entrada", {
  expect_error(export_biblioshiny("nao_sou_df", "teste.RData"), "data precisa ser um data.frame")
  expect_error(export_biblioshiny(data.frame(), ""), "Caminho de arquivo invalido")
  expect_error(export_biblioshiny(data.frame(), 123), "Caminho de arquivo invalido")
})

test_that("export_biblioshiny salva RData compativel e le variavel M", {
  sample_file <- testthat::test_path("../../inst/extdata/spell_sample.csv")
  if (!file.exists(sample_file)) {
    sample_file <- system.file("extdata", "spell_sample.csv", package = "bibliolatam")
  }
  
  M_orig <- read_spell(sample_file, convert = TRUE)

  tmp_file <- tempfile(fileext = "")
  # passa sem extensao pra testar adicao automatica de .RData
  res_path <- export_biblioshiny(M_orig, tmp_file)

  expect_true(grepl("\\.RData$", res_path))
  expect_true(file.exists(res_path))

  # carrega em ambiente isolado pra validar como o biblioshiny faz
  test_env <- new.env()
  load(res_path, envir = test_env)

  expect_true("M" %in% names(test_env))
  expect_s3_class(test_env$M, "bibliometrixDB")
  expect_equal(attr(test_env$M, "dbsource"), "spell")
  expect_equal(nrow(test_env$M), nrow(M_orig))
  expect_equal(test_env$M$AU, M_orig$AU)

  # limpa arquivo temporario
  unlink(res_path)
})
