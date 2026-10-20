test_that("as_bibliometrix rejeita entradas invalidas", {
  expect_error(as_bibliometrix("nao sou df"), "precisa ser um data.frame")
  expect_error(as_bibliometrix(data.frame()), "df esta vazio")
  expect_error(
    as_bibliometrix(data.frame(TI = "Artigo 1", PY = 2024)),
    "Faltam colunas essenciais"
  )
})

test_that("as_bibliometrix converte com sucesso e bate no contrato", {
  raw_df <- data.frame(
    AU = c("SILVA, J; SANTOS, M", "GAMA, G"),
    TI = c("Estudo Bibliometrico", "Ciencia Aberta"),
    SO = c("Revista XPTO", "Revista ABC"),
    PY = c("2023", "2024"),
    stringsAsFactors = FALSE
  )

  res <- as_bibliometrix(raw_df, dbsource = "spell")

  expect_s3_class(res, "bibliometrixDB")
  expect_equal(attr(res, "dbsource"), "spell")
  expect_type(res$PY, "double")
  expect_type(res$TC, "double")
  expect_equal(res$TC, c(0, 0))
  expect_true("CR" %in% names(res))
  expect_true(is.na(res$CR[1]))
  expect_equal(res$DB[1], "spell")
  expect_true(all(c("SR", "SR_FULL", "JI", "J9") %in% names(res)))
  expect_true(!is.na(res$SR[1]) && nzchar(res$SR[1]))
  expect_equal(res$SR[1], "SILVA, J, 2023, REVISTA XPTO")
})

test_that("as_bibliometrix preserva TC e CR quando ja existentes", {
  raw_df <- data.frame(
    AU = "ALMEIDA R",
    TI = "Impacto da Ciencia",
    SO = "Revista Cientifica",
    PY = 2021,
    TC = 15,
    CR = "REF 1; REF 2",
    DI = "10.1590/test",
    stringsAsFactors = FALSE
  )

  res <- as_bibliometrix(raw_df, dbsource = "scielo")
  expect_equal(res$TC, 15)
  expect_equal(res$CR, "REF 1; REF 2")
  expect_equal(res$DI, "10.1590/test")
})

test_that("as_bibliometrix trata fatores e anos ausentes defensivamente", {
  raw_df <- data.frame(
    AU = factor("COSTA L"),
    TI = factor("Titulo em Fator"),
    SO = factor("Revista Fator"),
    PY = factor("s.d.")
  )

  res <- as_bibliometrix(raw_df, dbsource = "oasisbr")
  expect_s3_class(res, "bibliometrixDB")
  expect_type(res$TI, "character")
  expect_type(res$AU, "character")
  expect_true(is.na(res$PY[1]))
})

test_that("as_bibliometrix idempotencia quando objeto ja e bibliometrixDB", {
  raw_df <- data.frame(
    AU = "SILVA J",
    TI = "Artigo Idempotente",
    SO = "Revista",
    PY = 2022,
    stringsAsFactors = FALSE
  )
  res1 <- as_bibliometrix(raw_df, dbsource = "scielo")
  res2 <- as_bibliometrix(res1, dbsource = "scielo")
  expect_s3_class(res2, "bibliometrixDB")
  expect_equal(nrow(res1), nrow(res2))
})
