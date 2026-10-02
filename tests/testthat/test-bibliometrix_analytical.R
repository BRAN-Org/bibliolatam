test_that("biblioAnalysis runs cleanly on real SciELO JATS dataset", {
  skip_if_not_installed("bibliometrix")

  real_dir <- system.file("extdata", "real_scielo_samples", package = "bibliolatam")
  if (!nzchar(real_dir)) {
    real_dir <- "../../inst/extdata/real_scielo_samples"
  }

  df <- read_scielo_jats(real_dir, convert = TRUE)
  expect_s3_class(df, "bibliometrixDB")

  # 1. Analise bibliometrica principal
  res <- suppressMessages(bibliometrix::biblioAnalysis(df))
  expect_s3_class(res, "bibliometrix")
  expect_equal(res$Articles, 5L)
  expect_gt(res$nAuthors, 0L)
  expect_true(all(res$Years >= 1990 & res$Years <= 2030))

  # 2. Resumo estatistico
  s <- suppressMessages(summary(res, k = 5, pause = FALSE))
  expect_type(s, "list")
  expect_true("MainInformation" %in% names(s) || "MainInformationData" %in% names(s) || length(s) > 0)

  # 3. Rede de co-citacao via Cited References (CR)
  net_cocit <- suppressMessages(
    bibliometrix::biblioNetwork(df, analysis = "co-citation", network = "references")
  )
  expect_true(inherits(net_cocit, "Matrix") || inherits(net_cocit, "matrix") || inherits(net_cocit, "igraph"))
  expect_gt(nrow(net_cocit), 0L)
  expect_equal(nrow(net_cocit), ncol(net_cocit))

  # 4. Rede de colaboracao de autores (AU)
  net_collab <- suppressMessages(
    bibliometrix::biblioNetwork(df, analysis = "collaboration", network = "authors")
  )
  expect_true(inherits(net_collab, "Matrix") || inherits(net_collab, "matrix") || inherits(net_collab, "igraph"))
  expect_gt(nrow(net_collab), 0L)
  expect_equal(nrow(net_collab), ncol(net_collab))

  # 5. Rede de co-ocorrencia de palavras-chave (DE)
  net_kwd <- suppressMessages(
    bibliometrix::biblioNetwork(df, analysis = "co-occurrences", network = "keywords")
  )
  expect_true(inherits(net_kwd, "Matrix") || inherits(net_kwd, "matrix") || inherits(net_kwd, "igraph"))
  expect_gt(nrow(net_kwd), 0L)
  expect_equal(nrow(net_kwd), ncol(net_kwd))

  # 6. Acoplamento bibliografico de autores via CR
  net_coup <- suppressMessages(
    bibliometrix::biblioNetwork(df, analysis = "coupling", network = "authors")
  )
  expect_true(inherits(net_coup, "Matrix") || inherits(net_coup, "matrix") || inherits(net_coup, "igraph"))
  expect_gt(nrow(net_coup), 0L)
})

test_that("biblioAnalysis runs cleanly on real OpenAlex-harvested tabular dataset", {
  skip_if_not_installed("bibliometrix")

  csv_path <- system.file("extdata", "real_scielo_openalex.csv", package = "bibliolatam")
  if (!nzchar(csv_path)) {
    csv_path <- "../../inst/extdata/real_scielo_openalex.csv"
  }

  df_oa <- read_scielo(csv_path, convert = TRUE)
  expect_s3_class(df_oa, "bibliometrixDB")

  res_oa <- suppressMessages(bibliometrix::biblioAnalysis(df_oa))
  expect_s3_class(res_oa, "bibliometrix")
  expect_gte(res_oa$Articles, 20L)

  net_oa_collab <- suppressMessages(
    bibliometrix::biblioNetwork(df_oa, analysis = "collaboration", network = "authors")
  )
  expect_true(inherits(net_oa_collab, "Matrix") || inherits(net_oa_collab, "matrix") || inherits(net_oa_collab, "igraph"))
  expect_gt(nrow(net_oa_collab), 0L)
})

test_that("biblioAnalysis and biblioNetwork tolerate edge cases and institutional authors", {
  skip_if_not_installed("bibliometrix")

  edge_dir <- system.file("extdata", "scielo_edge_cases", package = "bibliolatam")
  if (!nzchar(edge_dir)) {
    edge_dir <- "../../inst/extdata/scielo_edge_cases"
  }

  df_edges <- read_scielo_jats(edge_dir, convert = TRUE)
  expect_s3_class(df_edges, "bibliometrixDB")

  # Artigo sem CR e entidades devem processar sem interrupcao
  res_edges <- suppressMessages(bibliometrix::biblioAnalysis(df_edges))
  expect_s3_class(res_edges, "bibliometrix")
  expect_equal(res_edges$Articles, 4L)

  # Redes de colaboracao com autores institucionais (<collab>)
  net_edges_collab <- suppressMessages(
    bibliometrix::biblioNetwork(df_edges, analysis = "collaboration", network = "authors")
  )
  expect_true(inherits(net_edges_collab, "Matrix") || inherits(net_edges_collab, "matrix") || inherits(net_edges_collab, "igraph"))
  # Valida presenca do autor institucional como vertice da rede
  collab_names <- rownames(net_edges_collab)
  expect_true(any(grepl("MINISTERIO DA SAUDE DO BRASIL", collab_names)))
})
