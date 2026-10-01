test_that("read_spell rejeita arquivo invalido", {
  expect_error(read_spell("arquivo_fantasma.csv"), "Arquivo nao encontrado")
  expect_error(read_spell(123), "Arquivo nao encontrado")
})

test_that("read_spell le fixture da anpad e normaliza colunas", {
  sample_file <- testthat::test_path("../../inst/extdata/spell_sample.csv")
  
  # se rodar via R CMD check, pega direto do pacote instalado
  if (!file.exists(sample_file)) {
    sample_file <- system.file("extdata", "spell_sample.csv", package = "bibliolatam")
  }
  
  expect_true(file.exists(sample_file))

  # testa conversao automatica ativada
  M <- read_spell(sample_file, convert = TRUE)

  expect_s3_class(M, "bibliometrixDB")
  expect_equal(attr(M, "dbsource"), "spell")
  expect_equal(nrow(M), 5L)
  expect_type(M$PY, "double")
  expect_equal(M$PY[1], 2022)
  expect_equal(M$DT[1], "ARTICLE")

  # testa normalizacao de autoria estilo wos
  expect_equal(M$AU[1], "SILVA CA; FERREIRA MC")
  expect_equal(M$AU[2], "GAMA G; OLIVEIRA LH")

  # testa limpeza de doi
  expect_true(!grepl("^https?://", M$DI[1]))
  expect_equal(M$DI[1], "10.1590/1982-7849rac2022210045")

  # testa com convert = FALSE
  df_raw <- read_spell(sample_file, convert = FALSE)
  expect_false("bibliometrixDB" %in% class(df_raw))
  expect_true(is.data.frame(df_raw))
})
