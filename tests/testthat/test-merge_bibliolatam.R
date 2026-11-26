test_that("merge_bibliolatam validates inputs", {
  expect_error(merge_bibliolatam("nao sou df", data.frame()), "data frames")
  expect_error(merge_bibliolatam(data.frame(), data.frame()), "Ambos os data frames estao vazios")
})

test_that("merge_bibliolatam handles empty single inputs gracefully", {
  df_sample <- data.frame(
    AU = "SILVA J",
    TI = "Artigo Exemplo",
    SO = "Revista Exemplo",
    PY = 2023,
    DI = "10.1590/exemplo",
    stringsAsFactors = FALSE
  )
  df_sample <- as_bibliometrix(df_sample, dbsource = "scielo")

  # df1 is empty, df2 has data
  res1 <- merge_bibliolatam(data.frame(), df_sample)
  expect_s3_class(res1, "bibliometrixDB")
  expect_equal(nrow(res1), 1L)

  # df2 is empty, df1 has data
  res2 <- merge_bibliolatam(df_sample, data.frame())
  expect_s3_class(res2, "bibliometrixDB")
  expect_equal(nrow(res2), 1L)
})

test_that("merge_bibliolatam deduplicates by exact DOI and fuses metadata", {
  df1 <- data.frame(
    AU = c("SILVA J", "GAMA G"),
    TI = c("Artigo Um sobre Bibliometria", "Artigo Dois"),
    SO = c("Revista Brasileira de Pos-Graduacao", "Ciencia da Informacao"),
    PY = c(2021, 2022),
    DI = c("10.1590/01", "10.1590/02"),
    AB = c("Resumo original 1", NA),
    DE = c("bibliometria; scielo", "ciencia aberta"),
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
    DE = c("scielo; producao cientifica", "acesso aberto"),
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
  # Palavras-chave fundidas
  expect_true(grepl("bibliometria", row_silva$DE))
  expect_true(grepl("producao cientifica", row_silva$DE))
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

test_that("merge_bibliolatam preserves extra non-standard columns", {
  df1 <- data.frame(
    AU = "ALMEIDA R",
    TI = "Estudo de Caso 1",
    SO = "Revista Exemplo",
    PY = 2022,
    DI = "10.1590/extra1",
    CUSTOM_COL1 = "valor_especial_1",
    stringsAsFactors = FALSE
  )
  df1 <- as_bibliometrix(df1, dbsource = "scielo")

  df2 <- data.frame(
    AU = "ALMEIDA R",
    TI = "Estudo de Caso 1",
    SO = "Revista Exemplo",
    PY = 2022,
    DI = "10.1590/extra1",
    CUSTOM_COL2 = "valor_especial_2",
    stringsAsFactors = FALSE
  )
  df2 <- as_bibliometrix(df2, dbsource = "bdtd")

  merged <- merge_bibliolatam(df1, df2, match_by = "doi")
  expect_equal(nrow(merged), 1L)
  expect_true("CUSTOM_COL1" %in% names(merged) || "CUSTOM_COL2" %in% names(merged))
})

test_that("merge_bibliolatam prevents false positives between series parts (Parte I vs Parte II)", {
  # Dois artigos distintos de uma mesma serie, mesmo autor, mesmo ano, sem DOI
  df1 <- data.frame(
    AU = "SILVA J",
    TI = "Avaliacao da producao cientifica na pos graduacao brasileira: Parte I",
    SO = "Revista Brasileira de Pos-Graduacao",
    PY = 2022,
    DI = NA_character_,
    stringsAsFactors = FALSE
  )
  df1 <- as_bibliometrix(df1, dbsource = "scielo")

  df2 <- data.frame(
    AU = "SILVA J",
    TI = "Avaliacao da producao cientifica na pos graduacao brasileira: Parte II",
    SO = "Revista Brasileira de Pos-Graduacao",
    PY = 2022,
    DI = NA_character_,
    stringsAsFactors = FALSE
  )
  df2 <- as_bibliometrix(df2, dbsource = "oasisbr")

  # Mesmo com similaridade de titulo > 95%, o guardrail de partes DEVE impedir a fusao!
  merged <- merge_bibliolatam(df1, df2, match_by = "title", similarity_threshold = 0.90)
  expect_equal(nrow(merged), 2L)

  # Tambem testa com algarismos arabicos ("Parte 1" vs "Parte 2")
  df1$TI <- "Estudo Cienciometrico Regional: Parte 1"
  df2$TI <- "Estudo Cienciometrico Regional: Parte 2"
  merged_num <- merge_bibliolatam(df1, df2, match_by = "title", similarity_threshold = 0.90)
  expect_equal(nrow(merged_num), 2L)

  # Porem, o mesmo artigo com representacao romana em uma base e arabica na outra DEVE fundir
  df1$TI <- "Estudo Cienciometrico Regional: Parte 1"
  df2$TI <- "Estudo Cienciometrico Regional: Parte I"
  merged_same <- merge_bibliolatam(df1, df2, match_by = "title", similarity_threshold = 0.90)
  expect_equal(nrow(merged_same), 1L)
})

test_that("merge_bibliolatam prevents false positives between distinct authors with similar/identical titles", {
  # Dois editoriais com titulos identicos em periodicos diferentes publicados por pessoas distintas
  df1 <- data.frame(
    AU = "SILVA J",
    TI = "Editorial: Os desafios da pesquisa cientifica na America Latina em tempos de crise",
    SO = "Ciencia da Informacao",
    PY = 2021,
    DI = NA_character_,
    stringsAsFactors = FALSE
  )
  df1 <- as_bibliometrix(df1, dbsource = "scielo")

  df2 <- data.frame(
    AU = "GAMA G; SANTOS M",
    TI = "Editorial: Os desafios da pesquisa cientifica na America Latina em tempos de crise",
    SO = "Perspectivas em Ciencia da Informacao",
    PY = 2021,
    DI = NA_character_,
    stringsAsFactors = FALSE
  )
  df2 <- as_bibliometrix(df2, dbsource = "oasisbr")

  # Titulo identico (100% similaridade), mas autores completamente disjuntos -> NAO deve fundir!
  merged <- merge_bibliolatam(df1, df2, match_by = "title", similarity_threshold = 0.90)
  expect_equal(nrow(merged), 2L)
})

test_that("merge_bibliolatam allows merge when author has minor phonetic spelling variation", {
  # Mesmo artigo onde o autor esta como Sousa em uma base e Souza na outra
  df1 <- data.frame(
    AU = "SOUSA J",
    TI = "Acesso aberto diamante e infraestruturas comunitarias na ciencia contemporanea",
    SO = "Encontros Bibli",
    PY = 2023,
    DI = NA_character_,
    stringsAsFactors = FALSE
  )
  df1 <- as_bibliometrix(df1, dbsource = "scielo")

  df2 <- data.frame(
    AU = "SOUZA J",
    TI = "Acesso aberto diamante e infraestruturas comunitárias na ciência contemporânea",
    SO = "Encontros Bibli",
    PY = 2023,
    DI = NA_character_,
    stringsAsFactors = FALSE
  )
  df2 <- as_bibliometrix(df2, dbsource = "oasisbr")

  merged <- merge_bibliolatam(df1, df2, match_by = "title", similarity_threshold = 0.90)
  expect_equal(nrow(merged), 1L)
})

test_that("merge_bibliolatam bloqueia fusao por titulo quando ha conflito explicito de DOIs distintos (Achado #1)", {
  # Artigo e Errata/Comentario com titulo rigorosamente identico e mesmo autor/ano, mas DOIs diferentes
  df1 <- data.frame(
    AU = "SILVA J",
    TI = "Estudo sobre acesso aberto na America Latina: analise cienciometrica",
    SO = "Revista de Ciencia da Informacao",
    PY = 2023,
    DI = "10.1590/rci.v50i1.001",
    stringsAsFactors = FALSE
  )
  df1 <- as_bibliometrix(df1, dbsource = "scielo")

  df2 <- data.frame(
    AU = "SILVA J",
    TI = "Estudo sobre acesso aberto na America Latina: analise cienciometrica",
    SO = "Revista de Ciencia da Informacao",
    PY = 2023,
    DI = "10.1590/rci.v50i1.001.errata", # DOI diferente
    stringsAsFactors = FALSE
  )
  df2 <- as_bibliometrix(df2, dbsource = "oasisbr")

  merged <- merge_bibliolatam(df1, df2, match_by = c("doi", "title"), similarity_threshold = 0.85)
  expect_equal(nrow(merged), 2L)
  expect_equal(attr(merged, "merge_stats")$total_duplicates, 0L)
})

test_that("merge_bibliolatam bloqueia fusao por titulo entre THESIS e ARTICLE homonimos sem DOI compartilhado (Achado #3)", {
  # Tese/dissertacao homonima a artigo publicado do mesmo autor sem DOI comum
  df_thesis <- data.frame(
    AU = "ALMEIDA R",
    TI = "Politicas publicas de ciencia aberta no Brasil: trajetorias e desafios",
    SO = "Universidade de Sao Paulo (USP)",
    PY = 2022,
    DT = "THESIS",
    DI = NA_character_,
    stringsAsFactors = FALSE
  )
  df_thesis <- as_bibliometrix(df_thesis, dbsource = "bdtd")

  df_article <- data.frame(
    AU = "ALMEIDA R",
    TI = "Politicas publicas de ciencia aberta no Brasil: trajetorias e desafios",
    SO = "Perspectivas em Ciencia da Informacao",
    PY = 2023,
    DT = "ARTICLE",
    DI = NA_character_,
    stringsAsFactors = FALSE
  )
  df_article <- as_bibliometrix(df_article, dbsource = "scielo")

  merged <- merge_bibliolatam(df_thesis, df_article, match_by = c("doi", "title"), similarity_threshold = 0.90)
  expect_equal(nrow(merged), 2L)
  expect_equal(attr(merged, "merge_stats")$total_duplicates, 0L)
})

test_that("merge_bibliolatam deduplica internamente um unico dataset (intra-fonte) (Achado #3)", {
  # Registros duplicados vindos de uma mesma fonte (ex: espelhamento no Oasisbr)
  df_single <- data.frame(
    AU = c("SANTOS M", "SANTOS M", "OLIVEIRA P"),
    TI = c(
      "Acesso aberto e soberania de dados no Sul Global",
      "Acesso aberto e soberania de dados no Sul Global",
      "Outro estudo cienciometrico regional"
    ),
    SO = c("Repositorio USP", "Repositorio UNESP", "Revista Iberoamericana"),
    PY = c(2022, 2022, 2023),
    DI = c("10.1111/repo.001", "10.1111/repo.001", "10.1111/repo.002"),
    CR = c("REF A", NA_character_, "REF C"),
    AB = c(NA_character_, "Resumo detalhado no segundo repositorio", "Resumo C"),
    stringsAsFactors = FALSE
  )
  df_single <- as_bibliometrix(df_single, dbsource = "oasisbr")

  deduped <- merge_bibliolatam(df_single, match_by = c("doi", "title"))
  expect_equal(nrow(deduped), 2L)
  expect_equal(attr(deduped, "merge_stats")$total_duplicates, 1L)

  # Valida que fundiu metadados complementares (CR de 1 e AB de 2)
  merged_rec <- deduped[grepl("SANTOS M", deduped$AU), ]
  expect_equal(merged_rec$CR, "REF A")
  expect_equal(merged_rec$AB, "Resumo detalhado no segundo repositorio")
})

test_that("merge_bibliolatam resolve sobrenomes compostos hispanicos entre bases com/sem virgula (Achado #4)", {
  df1 <- data.frame(
    AU = "GARCIA MARQUEZ G",
    TI = "Cien anos de soledad cientifica en las publicaciones iberoamericanas",
    SO = "Revista Mexicana de Sociologia",
    PY = 2021,
    DI = NA_character_,
    stringsAsFactors = FALSE
  )
  df1 <- as_bibliometrix(df1, dbsource = "scielo")

  df2 <- data.frame(
    AU = "MARQUEZ G",
    TI = "Cien anos de soledad cientifica en las publicaciones iberoamericanas",
    SO = "Revista Mexicana de Sociologia",
    PY = 2021,
    DI = NA_character_,
    stringsAsFactors = FALSE
  )
  df2 <- as_bibliometrix(df2, dbsource = "redalyc")

  merged <- merge_bibliolatam(df1, df2, match_by = "title", similarity_threshold = 0.90)
  expect_equal(nrow(merged), 1L)
})


test_that("merge_bibliolatam respeita janela temporal de PY (+- 1 ano) e bloqueia titulos recorrentes distantes", {
  df_2022 <- as_bibliometrix(data.frame(
    AU = "OLIVEIRA M; COSTA P",
    TI = "Indicadores anuais de ciencia tecnologia e inovacao nas universidades federais",
    SO = "Avaliacao (Campinas)",
    PY = 2022,
    DI = NA_character_,
    stringsAsFactors = FALSE
  ), "scielo")

  # Ahead-of-print / atraso de indexacao (+1 ano): DEVE fundir
  df_2023 <- df_2022
  df_2023$PY <- 2023
  expect_equal(nrow(merge_bibliolatam(df_2022, df_2023, match_by = "title")), 1L)

  # Relatorio/artigo recorrente homonimo 4 anos antes (2018 vs 2022): NAO deve fundir
  df_2018 <- df_2022
  df_2018$PY <- 2018
  expect_equal(nrow(merge_bibliolatam(df_2022, df_2018, match_by = "title")), 2L)
})

test_that("merge_bibliolatam eleva threshold adaptativamente para 0.95 quando falta autoria (AU = NA)", {
  # Similaridade ~ 0.92 (acima de 0.90, mas abaixo de 0.95) sem autor: deve bloquear
  df1 <- as_bibliometrix(data.frame(
    AU = NA_character_,
    TI = "Avaliacao da producao cientifica em saude coletiva nas regioes norte",
    SO = "Cadernos de Saude Publica",
    PY = 2022,
    DI = NA_character_,
    stringsAsFactors = FALSE
  ), "scielo")

  df2_92 <- as_bibliometrix(data.frame(
    AU = "BARROS F",
    TI = "Avaliacao da producao cientifica em saude coletiva nos estados sul",
    SO = "Cadernos de Saude Publica",
    PY = 2022,
    DI = NA_character_,
    stringsAsFactors = FALSE
  ), "oasisbr")

  expect_equal(nrow(merge_bibliolatam(df1, df2_92, match_by = "title", similarity_threshold = 0.90)), 2L)

  # Similaridade >= 0.97 (apenas 1 caractere de ruido tipografico) mesmo sem autor: deve fundir
  df2_98 <- df2_92
  df2_98$TI <- "Avaliacao da producao cientifica em saude coletiva nas regioes nortes"
  expect_equal(nrow(merge_bibliolatam(df1, df2_98, match_by = "title", similarity_threshold = 0.90)), 1L)
})

test_that("merge_bibliolatam ignora titulos genericos curtos (< 15 caracteres) sem DOI", {
  df1 <- as_bibliometrix(data.frame(
    AU = c("MENEGHINI R", "PACKER A"),
    TI = c("Editorial", "Apresentação"),
    SO = c("SciELO em Perspectiva", "Ciencia da Informacao"),
    PY = c(2021, 2021),
    DI = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  ), "scielo")

  df2 <- as_bibliometrix(data.frame(
    AU = c("MENEGHINI R", "PACKER A"),
    TI = c("Editorial", "Apresentacao"),
    SO = c("Outro Fasciculo", "Outro Fasciculo"),
    PY = c(2021, 2021),
    DI = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  ), "oasisbr")

  expect_equal(nrow(merge_bibliolatam(df1, df2, match_by = "title")), 4L)
})

test_that("merge_bibliolatam protege sufixos agnaticos brasileiros (FILHO/JUNIOR/NETO) e prefixos hispanicos (SAN/SANTA)", {
  # 1. Mesmo autor com sufixo agnatico em formatos diferentes deve fundir
  df_a1 <- as_bibliometrix(data.frame(
    AU = "MOREIRA FILHO, CARLOS ALBERTO",
    TI = "Determinantes sociais e epidemiologia clinica na atencao primaria",
    SO = "Revista de Saude Publica", PY = 2022, DI = NA_character_, stringsAsFactors = FALSE
  ), "scielo")
  df_a2 <- as_bibliometrix(data.frame(
    AU = "MOREIRA FILHO C",
    TI = "Determinantes sociais e epidemiologia clinica na atencao primaria",
    SO = "Revista de Saude Publica", PY = 2022, DI = NA_character_, stringsAsFactors = FALSE
  ), "oasisbr")
  expect_equal(nrow(merge_bibliolatam(df_a1, df_a2, match_by = "title")), 1L)

  # 2. Dois autores diferentes com sufixo FILHO mal formatado ou prefixo SAN/SANTA NAO devem colidir
  df_b1 <- as_bibliometrix(data.frame(
    AU = c("FILHO, JOAO", "SAN MARTIN J", "SANTA CRUZ R"),
    TI = c(
      "Politicas publicas de financiamento da educacao basica e superior",
      "Reformas institucionales y educacion publica en America Latina",
      "Salud comunitaria y participacion ciudadana en zonas rurales"
    ),
    SO = "Revista A", PY = 2022, DI = NA_character_, stringsAsFactors = FALSE
  ), "scielo")

  df_b2 <- as_bibliometrix(data.frame(
    AU = c("OLIVEIRA FILHO M", "SAN ROMAN F", "SANTA MARIA T"),
    TI = df_b1$TI,
    SO = "Revista B", PY = 2022, DI = NA_character_, stringsAsFactors = FALSE
  ), "oasisbr")

  expect_equal(nrow(merge_bibliolatam(df_b1, df_b2, match_by = "title")), 6L)
})

test_that("merge_bibliolatam bloqueia series assimetricas e marcadores espanhois (Volumen/Seccion/Tomo com subtitulo)", {
  # Assimetria: titulo base sem parte vs Parte 2 deve bloquear
  df_base <- as_bibliometrix(data.frame(
    AU = "DELGADO E", TI = "Comunicacion cientifica y acceso abierto en Iberoamerica",
    SO = "El Profesional de la Informacion", PY = 2021, DI = NA_character_, stringsAsFactors = FALSE
  ), "scielo")
  df_p2 <- df_base
  df_p2$TI <- "Comunicacion cientifica y acceso abierto en Iberoamerica: Parte 2"
  expect_equal(nrow(merge_bibliolatam(df_base, df_p2, match_by = "title", similarity_threshold = 0.85)), 2L)

  # Series em espanhol com subtitulo identico posterior
  df_es1 <- as_bibliometrix(data.frame(
    AU = c("RUIZ PEREZ R", "LOPEZ COZAR E", "JIMENEZ CONTRERAS E"),
    TI = c(
      "Historia social de la salud publica en Mexico, Volumen I: analisis regional",
      "Evaluacion de revistas cientificas iberoamericanas, Sección 1: marco teorico",
      "Estudios sobre educacion superior autonoma, Tomo I: epoca contemporanea"
    ),
    SO = "Salud Publica de Mexico", PY = 2022, DI = NA_character_, stringsAsFactors = FALSE
  ), "scielo")
  df_es2 <- df_es1
  df_es2$TI <- c(
    "Historia social de la salud publica en Mexico, Volumen II: analisis regional",
    "Evaluacion de revistas cientificas iberoamericanas, Sección 2: marco teorico",
    "Estudios sobre educacion superior autonoma, Tomo II: epoca contemporanea"
  )
  expect_equal(nrow(merge_bibliolatam(df_es1, df_es2, match_by = "title", similarity_threshold = 0.85)), 6L)
})

test_that("merge_bibliolatam aplica todos os guardrails no modo intra-fonte (df2 = NULL) e em cascata Reduce", {
  # Intra-fonte: 1 duplicata verdadeira por titulo + 1 conflito DT + 1 conflito DOI + 1 serie Parte 1/2
  df_intra <- as_bibliometrix(data.frame(
    AU = c(
      "VARGAS L", "VARGAS L",
      "MENDES C", "MENDES C",
      "ROCHA D", "ROCHA D",
      "TORRES P", "TORRES P"
    ),
    TI = c(
      "Governanca de dados de pesquisa em universidades publicas brasileiras",
      "Governança de dados de pesquisa em universidades públicas brasileiras",
      "Arquitetura de repositorios digitais federados na ciencia aberta",
      "Arquitetura de repositorios digitais federados na ciencia aberta",
      "Impacto cienciometrico de periodicos diamante na saude coletiva",
      "Impacto cienciometrico de periodicos diamante na saude coletiva",
      "Diretrizes de curadoria digital em acervos cientificos: Parte 1",
      "Diretrizes de curadoria digital em acervos cientificos: Parte 2"
    ),
    SO = rep("Transinformacao", 8),
    PY = rep(2023, 8),
    DT = c("ARTICLE", "ARTICLE", "THESIS", "ARTICLE", "ARTICLE", "ARTICLE", "ARTICLE", "ARTICLE"),
    DI = c(NA, NA, NA, NA, "10.1590/r1", "10.1590/r1.errata", NA, NA),
    stringsAsFactors = FALSE
  ), "oasisbr")

  res_intra <- merge_bibliolatam(df_intra, match_by = c("doi", "title"), similarity_threshold = 0.90)
  # Apenas o primeiro par (VARGAS L) deve fundir; os outros 3 pares sao bloqueados -> 7 registros finais
  expect_equal(nrow(res_intra), 7L)
  expect_equal(attr(res_intra, "merge_stats")$total_duplicates, 1L)

  # Cascata Reduce entre 3 bases (SciELO + Oasisbr + Redalyc) preservando CR e rastreando DB
  b1 <- as_bibliometrix(data.frame(
    AU = "GARCIA MARQUEZ G", TI = "Cienciometria regional y soberania cientifica en America Latina",
    SO = "Investigacion Bibliotecologica", PY = 2022, DI = NA_character_,
    CR = "REF_SCIELO_1", DE = "cienciometria", DB = "scielo", stringsAsFactors = FALSE
  ), "scielo")
  b2 <- as_bibliometrix(data.frame(
    AU = "MARQUEZ G", TI = "Cienciometria regional y soberania cientifica en America Latina",
    SO = "Investigacion Bibliotecologica", PY = 2022, DI = "10.22201/iibi.2022.01",
    CR = "REF_OASIS_2", DE = "acceso abierto", DB = "oasisbr", stringsAsFactors = FALSE
  ), "oasisbr")
  b3 <- as_bibliometrix(data.frame(
    AU = "GARCIA-MARQUEZ, G", TI = "Cienciometria regional y soberania cientifica en America Latina",
    SO = "Investigacion Bibliotecologica", PY = 2022, DI = "10.22201/iibi.2022.01",
    CR = "REF_REDALYC_3", DE = "america latina", DB = "redalyc", stringsAsFactors = FALSE
  ), "redalyc")

  cascaded <- Reduce(function(x, y) merge_bibliolatam(x, y, match_by = c("doi", "title")), list(b1, b2, b3))
  expect_equal(nrow(cascaded), 1L)
  expect_equal(cascaded$DB, "scielo+oasisbr+redalyc")
  expect_true(all(sapply(c("REF_SCIELO_1", "REF_OASIS_2", "REF_REDALYC_3"), grepl, cascaded$CR)))
  expect_equal(length(unique(cascaded$SR)), 1L)
})

test_that("merge_bibliolatam handles DOI separator variants safely while blocking digit-boundary shifts (Kara et al. 2025)", {
  # 1. Mesmo artigo com troca de separador '_' vs '-' no sufixo do DOI: libera veto e funde por titulo+autor
  d1 <- as_bibliometrix(data.frame(
    AU = "ALMEIDA R; COSTA M",
    TI = "Epidemiologia social e acesso aberto na saude coletiva latino-americana",
    SO = "Revista de Saude Publica",
    PY = 2023,
    DI = "10.7189/jogh.12_05057",
    stringsAsFactors = FALSE
  ), "scielo")
  d2 <- d1
  d2$DI <- "10.7189/jogh.12-05057"
  res_var <- merge_bibliolatam(d1, d2, match_by = c("doi", "title"))
  expect_equal(nrow(res_var), 1L)
  expect_equal(attr(res_var, "merge_stats")$title_duplicates, 1L)

  # 2. Troca de fronteira entre digitos (ex: volume 5 pag 350 vs volume 53 pag 50): DEVE BLOQUEAR!
  p1 <- as_bibliometrix(data.frame(
    AU = "SILVA J",
    TI = "Estudo experimental sobre espalhamento de particulas em redes",
    SO = "Physical Review C",
    PY = 2022,
    DI = "10.1103/physrevc.5.350",
    stringsAsFactors = FALSE
  ), "scielo")
  p2 <- p1
  p2$DI <- "10.1103/physrevc.53.50"
  res_shift <- merge_bibliolatam(p1, p2, match_by = c("doi", "title"))
  expect_equal(nrow(res_shift), 2L)
})

test_that("merge_bibliolatam resolves translated non-DOI editions via structural SO+VL+BP+AU fallback safely", {
  # 1. Mesmo artigo publicado em Portugues no Oasisbr e em Ingles no SciELO SEM DOI, mas mesmo SO/VL/BP/AU
  pt_ed <- as_bibliometrix(data.frame(
    AU = "FERREIRA L; SANTOS M",
    TI = "Determinantes sociais da saude mental na atencao primaria brasileira",
    SO = "Cadernos de Saude Publica",
    PY = 2022,
    VL = "38",
    BP = "15",
    DI = NA_character_,
    CR = "REF_PT_1",
    stringsAsFactors = FALSE
  ), "oasisbr")
  en_ed <- as_bibliometrix(data.frame(
    AU = "FERREIRA L; SANTOS M",
    TI = "Social determinants of mental health in Brazilian primary care",
    SO = "Cadernos de Saúde Pública",
    PY = 2022,
    VL = "38.0",
    BP = "15-29",
    DI = NA_character_,
    CR = "REF_EN_2",
    stringsAsFactors = FALSE
  ), "scielo")

  merged_tr <- merge_bibliolatam(pt_ed, en_ed, match_by = c("doi", "title"))
  expect_equal(nrow(merged_tr), 1L)
  expect_equal(attr(merged_tr, "merge_stats")$structural_duplicates, 1L)
  expect_true(grepl("REF_PT_1", merged_tr$CR) && grepl("REF_EN_2", merged_tr$CR))

  # 2. Artigo diferente na mesma revista/volume/ano mas pagina inicial diferente: NAO deve fundir
  other_pg <- en_ed
  other_pg$BP <- "42"
  expect_equal(nrow(merge_bibliolatam(pt_ed, other_pg, match_by = c("doi", "title"))), 2L)

  # 3. Autores disjuntos na mesma revista/volume/pagina: NAO deve fundir
  other_au <- en_ed
  other_au$AU <- "ZIMMERMANN K"
  expect_equal(nrow(merge_bibliolatam(pt_ed, other_au, match_by = c("doi", "title"))), 2L)

  # 4. Conflito explicito de DOIs reais bloqueia ate o fallback estrutural
  diff_doi_1 <- pt_ed; diff_doi_1$DI <- "10.1590/csp.2022.001"
  diff_doi_2 <- en_ed; diff_doi_2$DI <- "10.1590/csp.2022.002"
  expect_equal(nrow(merge_bibliolatam(diff_doi_1, diff_doi_2, match_by = c("doi", "title"))), 2L)
})

test_that("merge_bibliolatam resolves bilingual concatenated OAI-PMH titles without DOI safely", {
  # 1. Titulo monolingue PT vs titulo bilingue concatenado com " / " (~2x comprimento, sem DOI)
  mono_pt <- as_bibliometrix(data.frame(
    AU = "ALMEIDA C; COSTA R",
    TI = "Determinantes sociais da saude mental na atencao primaria brasileira",
    SO = "Cadernos de Saude Publica",
    PY = 2023,
    DI = NA_character_,
    CR = "REF_SCIELO_1",
    stringsAsFactors = FALSE
  ), "scielo")
  biling_slash <- as_bibliometrix(data.frame(
    AU = "ALMEIDA C; COSTA R",
    TI = "Determinantes sociais da saude mental na atencao primaria brasileira / Social determinants of mental health in Brazilian primary care",
    SO = "Oasisbr Repository",
    PY = 2023,
    DI = NA_character_,
    CR = "REF_OASIS_2",
    stringsAsFactors = FALSE
  ), "oasisbr")

  m_slash <- merge_bibliolatam(mono_pt, biling_slash, match_by = c("doi", "title"))
  expect_equal(nrow(m_slash), 1L)
  expect_true(grepl("REF_SCIELO_1", m_slash$CR) && grepl("REF_OASIS_2", m_slash$CR))

  # 2. Titulo monolingue EN vs titulo bilingue concatenado com " = "
  mono_en <- as_bibliometrix(data.frame(
    AU = "ALMEIDA C; COSTA R",
    TI = "Social determinants of mental health in Brazilian primary care",
    SO = "Public Health Reports",
    PY = 2023,
    DI = NA_character_,
    stringsAsFactors = FALSE
  ), "scielo")
  biling_eq <- biling_slash
  biling_eq$TI <- "Determinantes sociais da saude mental na atencao primaria brasileira = Social determinants of mental health in Brazilian primary care"
  expect_equal(nrow(merge_bibliolatam(mono_en, biling_eq, match_by = c("doi", "title"))), 1L)

  # 3. Autores disjuntos continuam bloqueando mesmo com segmento bilingue identico
  biling_diff_au <- biling_slash
  biling_diff_au$AU <- "ZIMMERMANN K"
  expect_equal(nrow(merge_bibliolatam(mono_pt, biling_diff_au, match_by = c("doi", "title"))), 2L)

  # 4. Deduplicacao intra-fonte tambem resolve titulo bilingue concatenado
  intra_df <- rbind(mono_pt, biling_slash)
  intra_dedup <- deduplicate_internal(intra_df, match_by = c("doi", "title"))
  expect_equal(nrow(intra_dedup), 1L)
})

test_that("merge_bibliolatam blocks PT<->ES cross-lingual cognate collisions without DOI", {
  # 1. Artigos distintos PT vs ES sobre tema cognato com sobrenomes ibericos irmaos (sem LA, sem DOI)
  art_pt <- as_bibliometrix(data.frame(
    AU = "RODRIGUES M; GOMES A",
    TI = "Analise epidemiologica da vacinacao infantil na atencao primaria de saude",
    SO = "Revista Brasileira de Epidemiologia",
    PY = 2023,
    DI = NA_character_,
    LA = NA_character_,
    stringsAsFactors = FALSE
  ), "scielo")
  art_es <- as_bibliometrix(data.frame(
    AU = "RODRIGUEZ M; GOMEZ A",
    TI = "Analisis epidemiologico de la vacunacion infantil en la atencion primaria de salud",
    SO = "Revista Espanola de Salud Publica",
    PY = 2023,
    DI = NA_character_,
    LA = NA_character_,
    stringsAsFactors = FALSE
  ), "redalyc")
  expect_equal(nrow(merge_bibliolatam(art_pt, art_es, match_by = c("doi", "title"))), 2L)

  # 2. Mesmo bloqueio quando LA explicita "pt" vs "es"
  art_pt_la <- art_pt; art_pt_la$LA <- "pt"
  art_es_la <- art_es; art_es_la$LA <- "es"
  expect_equal(nrow(merge_bibliolatam(art_pt_la, art_es_la, match_by = c("doi", "title"))), 2L)

  # 3. Nao deve gerar falso negativo quando o titulo normalizado e exatamente identico (ex.: titulo EN com LA divergente)
  en_1 <- as_bibliometrix(data.frame(
    AU = "SILVA J",
    TI = "Machine learning approaches for tropical forest monitoring",
    SO = "Journal A",
    PY = 2023,
    LA = "pt",
    stringsAsFactors = FALSE
  ), "oasisbr")
  en_2 <- en_1; en_2$LA <- "es"; en_2$DB <- "REDALYC"
  expect_equal(nrow(merge_bibliolatam(en_1, en_2, match_by = c("doi", "title"))), 1L)

  # 4. Duplicata real no mesmo idioma (PT com vs sem acento) continua sendo fundida
  art_pt_acc <- art_pt
  art_pt_acc$TI <- "An\u00e1lise epidemiol\u00f3gica da vacina\u00e7\u00e3o infantil na aten\u00e7\u00e3o prim\u00e1ria de sa\u00fade"
  expect_equal(nrow(merge_bibliolatam(art_pt, art_pt_acc, match_by = c("doi", "title"))), 1L)
})
