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
    strings_as_factors = FALSE
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
