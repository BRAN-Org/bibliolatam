test_that("merge_bibliolatam validates inputs", {
  expect_error(merge_bibliolatam("nao sou df", data.frame()), "data frames")
  expect_error(merge_bibliolatam(data.frame(), data.frame()), "Ambos os data frames estao vazios")
})

test_that("merge_bibliolatam deduplicates by exact DOI and fuses metadata", {
  df1 <- data.frame(
    AU = c("SILVA J", "GAMA G"),
    TI = c("Artigo Um sobre Bibliometria", "Artigo Dois"),
    SO = c("Revista Brasileira de Pos-Graduacao", "Ciencia da Informacao"),
    PY = c(2021, 2022),
    DI = c("10.1590/01", "10.1590/02"),
    AB = c("Resumo original 1", NA),
    CR = c("REF A; REF B", NA),
    stringsAsFactors = FALSE
  )
  df1 <- as_bibliometrix(df1, dbsource = "scielo")

  df2 <- data.frame(
    AU = c("SILVA J", "OLIVEIRA M"),
    TI = c("Artigo Um sobre Bibliometria", "Artigo Tres"),
    SO = c("Revista Brasileira de Pos-Graduacao", "Perspectivas"),
    PY = c(2021, 2023),
    DI = c("https://doi.org/10.1590/01", "10.1590/03"),
    AB = c(NA, "Resumo 3"),
    CR = c("REF B; REF C", NA),
    stringsAsFactors = FALSE
  )
  df2 <- as_bibliometrix(df2, dbsource = "oasisbr")

  merged <- merge_bibliolatam(df1, df2, match_by = "doi")
  expect_s3_class(merged, "bibliometrixDB")
  # Total de artigos unicos esperados: 3 (SILVA J duplicado fundido, GAMA G, OLIVEIRA M)
  expect_equal(nrow(merged), 3L)

  # Registro fundido de SILVA J
  row_silva <- merged[merged$AU == "SILVA J", ]
  expect_equal(nrow(row_silva), 1L)
  expect_equal(row_silva$AB, "Resumo original 1") # Preservou resumo
  # Referencias citadas combinadas e deduplicadas
  expect_true(grepl("REF A", row_silva$CR))
  expect_true(grepl("REF B", row_silva$CR))
  expect_true(grepl("REF C", row_silva$CR))
  expect_equal(row_silva$DB, "scielo+oasisbr")
})

test_that("merge_bibliolatam deduplicates by fuzzy title when DOI is missing", {
  df1 <- data.frame(
    AU = c("SILVA J"),
    TI = c("Analise bibliometrica da producao cientifica latino-americana"),
    SO = c("Revista Latino-Americana"),
    PY = c(2020),
    DI = c(NA),
    stringsAsFactors = FALSE
  )
  df1 <- as_bibliometrix(df1, dbsource = "scielo")

  # Titulo com diferenca de pontuacao/espacos
  df2 <- data.frame(
    AU = c("SILVA JOAO"),
    TI = c("Análise bibliométrica da produção científica latino americana"),
    SO = c("Revista Latino-Americana"),
    PY = c(2020),
    DI = c(NA),
    stringsAsFactors = FALSE
  )
  df2 <- as_bibliometrix(df2, dbsource = "oasisbr")

  merged <- merge_bibliolatam(df1, df2, match_by = "title", similarity_threshold = 0.85)
  expect_equal(nrow(merged), 1L)
})
