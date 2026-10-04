test_that("read_scielo_jats parses real SciELO journal XMLs without corruption", {
  real_dir <- system.file("extdata", "real_scielo_samples", package = "bibliolatam")
  if (!nzchar(real_dir)) {
    real_dir <- "../../inst/extdata/real_scielo_samples"
  }

  df <- read_scielo_jats(real_dir, convert = TRUE)

  expect_s3_class(df, "bibliometrixDB")
  expect_equal(attr(df, "dbsource"), "scielo")
  expect_equal(nrow(df), 5L)

  # Nenhuma linha deve ter titulo ou periodico vazio
  expect_true(all(!is.na(df$TI) & nzchar(df$TI)))
  expect_true(all(!is.na(df$SO) & nzchar(df$SO)))
  expect_true(all(!is.na(df$PY) & df$PY >= 1990 & df$PY <= 2030))

  # Autores devem estar no formato WOS (caixa alta com iniciais)
  expect_true(all(!is.na(df$AU) & nzchar(df$AU)))
  for (au in df$AU) {
    expect_match(au, "^[A-ZÀ-ÿ' -]+ [A-Z]+", perl = TRUE)
  }

  # Cited References (CR) deve conter dezenas de referencias reais
  expect_true(all(!is.na(df$CR) & nzchar(df$CR)))
  for (cr in df$CR) {
    # Cada artigo do SciELO tem multiplas referencias separadas por ;
    refs <- unlist(strsplit(cr, ";", fixed = TRUE))
    expect_gte(length(refs), 15L)
  }
})

test_that("read_scielo_jats parses real 500KB+ zip bundle directly", {
  zip_path <- system.file("extdata", "real_scielo_bundle.zip", package = "bibliolatam")
  if (!nzchar(zip_path)) {
    zip_path <- "../../inst/extdata/real_scielo_bundle.zip"
  }

  df_zip <- read_scielo_jats(zip_path, convert = TRUE)
  expect_s3_class(df_zip, "bibliometrixDB")
  expect_equal(nrow(df_zip), 5L)
})

test_that("read_scielo parses real OpenAlex-harvested tabular dataset with 25 works", {
  csv_path <- system.file("extdata", "real_scielo_openalex.csv", package = "bibliolatam")
  if (!nzchar(csv_path)) {
    csv_path <- "../../inst/extdata/real_scielo_openalex.csv"
  }

  df_oa <- read_scielo(csv_path, convert = TRUE)
  expect_s3_class(df_oa, "bibliometrixDB")
  expect_equal(attr(df_oa, "dbsource"), "scielo")
  expect_gte(nrow(df_oa), 20L)

  # Valida que todos os DOIs foram limpos de prefixo http
  valid_dois <- df_oa$DI[!is.na(df_oa$DI)]
  expect_true(all(!grepl("^https?://", valid_dois)))
  expect_true(any(grepl("^10\\.", valid_dois)))

  # Exportacao para biblioshiny de dataset real
  tmp_rdata <- tempfile(fileext = ".RData")
  export_biblioshiny(df_oa, tmp_rdata)
  expect_true(file.exists(tmp_rdata))
  expect_gt(file.info(tmp_rdata)$size, 1000)
  unlink(tmp_rdata)
})

test_that("read_scielo_jats handles extreme edge cases (entities, no refs, sub-articles, collab)", {
  edge_dir <- system.file("extdata", "scielo_edge_cases", package = "bibliolatam")
  if (!nzchar(edge_dir)) {
    edge_dir <- "../../inst/extdata/scielo_edge_cases"
  }

  df_edges <- read_scielo_jats(edge_dir, convert = TRUE)
  expect_s3_class(df_edges, "bibliometrixDB")
  expect_equal(nrow(df_edges), 4L)

  # 1. Checa decodificacao de entidades XML (&quot;, &amp;, &lt;, &gt;, &#39;)
  ent_row <- df_edges[grepl("test-entities", df_edges$DI), ]
  expect_equal(nrow(ent_row), 1L)
  expect_match(ent_row$TI, '"Inteligência Artificial" & Mineração <Textual>', fixed = TRUE)
  expect_match(ent_row$SO, "Revista Brasileira de & Informação <Especial>", fixed = TRUE)
  expect_match(ent_row$AU, "D'ÁVILA NETO J; O'CONNOR MP", fixed = TRUE)
  expect_match(ent_row$CR, "D'ÁVILA NETO J", fixed = TRUE)
  expect_match(ent_row$CR, "NATURE & SCIENCE", fixed = TRUE)

  # 2. Artigo sem referencias citadas nao deve crashear, mas ter CR como NA
  no_ref_row <- df_edges[grepl("without-references", df_edges$DI), ]
  expect_equal(nrow(no_ref_row), 1L)
  expect_true(is.na(no_ref_row$CR) || !nzchar(no_ref_row$CR))

  # 3. Artigo com sub-article (traducao em ingles embutida): o titulo principal em PT nao deve ser sobrescrito pelo ingles
  sub_row <- df_edges[grepl("main-article-doi", df_edges$DI), ]
  expect_equal(nrow(sub_row), 1L)
  expect_equal(sub_row$TI, "Artigo Principal em Portugues")
  expect_equal(sub_row$AU, "MACHADO DE ASSIS JM")

  # 4. Autor institucional (<collab>) sem surname/given-names
  org_row <- df_edges[grepl("relatorio-institucional", df_edges$DI), ]
  expect_equal(nrow(org_row), 1L)
  expect_match(org_row$AU, "MINISTERIO DA SAUDE DO BRASIL", fixed = TRUE)
  expect_match(org_row$AU, "FIOCRUZ", fixed = TRUE)
})

test_that("Stress test: combined multi-format pipeline and factor/null safety", {
  # Gera 100 linhas sinteticas com misturas de nulos, caracteres bizarros e tipos
  dirty_df <- data.frame(
    AU = rep(c("Silva, Jose Junior", "Gama, G.", "Machado de Assis, Joaquim Maria; Santos, A. B. Filho", "UNESCO"), 25),
    TI = paste("Artigo Estresse", 1:100, "sobre Ciência e Métricas"),
    SO = rep(c("Revista A", "Revista B", "Revista C"), length.out = 100),
    PY = as.character(sample(1995:2024, 100, replace = TRUE)),
    TC = sample(c(NA, 0:500), 100, replace = TRUE),
    stringsAsFactors = TRUE # testa fator explicitamente
  )

  M <- as_bibliometrix(dirty_df, dbsource = "scielo")
  expect_s3_class(M, "bibliometrixDB")
  expect_type(M$PY, "double")
  expect_type(M$TC, "double")
  expect_false(any(is.na(M$TC))) # NAs devem ter virado 0
  expect_type(M$AU, "character")
  expect_type(M$TI, "character")
})
