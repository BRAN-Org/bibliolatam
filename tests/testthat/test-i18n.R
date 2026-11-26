test_that("bl_i18n returns translations across EN, PT, and ES", {
  # English
  expect_equal(bibliolatam:::bl_i18n("tab_about", "en"), "About")
  expect_equal(bibliolatam:::bl_i18n("omni_stat_total", "en"), "Harmonized Total")

  # Portuguese
  expect_equal(bibliolatam:::bl_i18n("tab_about", "pt"), "Sobre")
  expect_equal(bibliolatam:::bl_i18n("omni_stat_total", "pt"), "Total Harmonizado")

  # Spanish
  expect_equal(bibliolatam:::bl_i18n("tab_about", "es"), "Acerca de")
  expect_equal(bibliolatam:::bl_i18n("omni_stat_total", "es"), "Total Armonizado")

  # Fallback & Edge cases
  expect_equal(bibliolatam:::bl_i18n("tab_about", "invalid_lang"), "About")
  expect_equal(bibliolatam:::bl_i18n("non_existent_key", "en"), "non_existent_key")
  expect_equal(bibliolatam:::bl_i18n("", "en"), "")
  expect_equal(bibliolatam:::bl_i18n(NULL, "en"), NULL)
})

test_that("BL_I18N_DICT has complete translations for all entries", {
  dict <- bibliolatam:::BL_I18N_DICT
  expect_true(is.list(dict))
  expect_true(length(dict) >= 30)

  required_langs <- c("en", "pt", "es")
  for (key_name in names(dict)) {
    entry <- dict[[key_name]]
    expect_true(is.list(entry), info = paste("Key is list:", key_name))
    for (lng in required_langs) {
      expect_true(lng %in% names(entry), info = paste("Missing lang", lng, "in", key_name))
      expect_true(is.character(entry[[lng]]), info = paste("Value is char in", key_name, lng))
      expect_true(nzchar(entry[[lng]]), info = paste("Value non-empty in", key_name, lng))
    }
  }
})

test_that("UI functions accept lang parameter and render localized text across all 3 languages", {
  skip_if_not_installed("shiny")

  # Omnisearch
  ui_omni_en <- omnisearchUI(lang = "en")
  ui_omni_pt <- omnisearchUI(lang = "pt")
  ui_omni_es <- omnisearchUI(lang = "es")

  expect_true(grepl(">Omnisearch Engine<", as.character(ui_omni_en), fixed = TRUE))
  expect_true(grepl(">Mecanismo Omnisearch<", as.character(ui_omni_pt), fixed = TRUE))
  expect_true(grepl(">Motor Omnisearch<", as.character(ui_omni_es), fixed = TRUE))
  expect_true(grepl("Advanced Settings", as.character(ui_omni_en), fixed = TRUE))
  expect_true(grepl("Configuracoes Avancadas", as.character(ui_omni_pt), fixed = TRUE))
  expect_true(grepl("Configuracion Avanzada", as.character(ui_omni_es), fixed = TRUE))

  # SciELO
  ui_scielo_en <- scieloUI(lang = "en")
  ui_scielo_pt <- scieloUI(lang = "pt")
  ui_scielo_es <- scieloUI(lang = "es")

  expect_true(grepl("SciELO Data Collection", as.character(ui_scielo_en)))
  expect_true(grepl("Coleta de Dados SciELO", as.character(ui_scielo_pt)))
  expect_true(grepl("Recoleccion de Datos SciELO", as.character(ui_scielo_es)))

  # BDTD
  ui_bdtd_en <- bdtdUI(lang = "en")
  ui_bdtd_pt <- bdtdUI(lang = "pt")
  ui_bdtd_es <- bdtdUI(lang = "es")

  expect_true(grepl("BDTD Collection", as.character(ui_bdtd_en)))
  expect_true(grepl("Coleta BDTD", as.character(ui_bdtd_pt)))
  expect_true(grepl("Recoleccion BDTD", as.character(ui_bdtd_es)))

  # Oasisbr
  ui_oasisbr_en <- oasisbrUI(lang = "en")
  ui_oasisbr_pt <- oasisbrUI(lang = "pt")
  ui_oasisbr_es <- oasisbrUI(lang = "es")

  expect_true(grepl("Oasisbr Collection", as.character(ui_oasisbr_en)))
  expect_true(grepl("Coleta Oasisbr", as.character(ui_oasisbr_pt)))
  expect_true(grepl("Recoleccion Oasisbr", as.character(ui_oasisbr_es)))

  # Redalyc
  ui_redalyc_en <- redalycUI(lang = "en")
  ui_redalyc_pt <- redalycUI(lang = "pt")
  ui_redalyc_es <- redalycUI(lang = "es")

  expect_true(grepl("Redalyc &amp; AmeliCA Collection", as.character(ui_redalyc_en)))
  expect_true(grepl("Coleta Redalyc e AmeliCA", as.character(ui_redalyc_pt)))
  expect_true(grepl("Recoleccion Redalyc y AmeliCA", as.character(ui_redalyc_es)))

  # Merge
  ui_merge_en <- bibliolatamMergeUI(lang = "en")
  ui_merge_pt <- bibliolatamMergeUI(lang = "pt")
  ui_merge_es <- bibliolatamMergeUI(lang = "es")

  expect_true(grepl("Cross-Database Merge &amp; Deduplication", as.character(ui_merge_en)))
  expect_true(grepl("Unificacao e Deduplicacao Entre Bases", as.character(ui_merge_pt)))
  expect_true(grepl("Fusion y Deduplicacion Entre Bases", as.character(ui_merge_es)))

  # Info (About)
  info_en <- bibliolatamInfoUI(lang = "en")
  info_pt <- bibliolatamInfoUI(lang = "pt")
  info_es <- bibliolatamInfoUI(lang = "es")
  expect_true(grepl("Why bibliolatam?", as.character(info_en)))
  expect_true(grepl("Por que o bibliolatam?", as.character(info_pt)))
  expect_true(grepl("Por que bibliolatam?", as.character(info_es)))
  expect_true(grepl("Supported &amp; Planned Regional Repositories", as.character(info_en)))
  expect_true(grepl("Repositorios Regionais Suportados e Planejados", as.character(info_pt)))
  expect_true(grepl("Repositorios Regionales Soportados y Planificados", as.character(info_es)))
  expect_true(grepl("data-i18n-html", as.character(info_pt)))
})

test_that("bl_i18n_script generates valid script tag containing dictionary", {
  skip_if_not_installed("shiny")

  script <- bibliolatam:::bl_i18n_script()
  expect_s3_class(script, "shiny.tag")
  script_str <- as.character(script)
  expect_true(grepl("window.bibliolatam_dict", script_str))
  expect_true(grepl("setBibliolatamLang", script_str))
  expect_true(grepl("localStorage", script_str))
  expect_true(grepl("data-i18n-html", script_str))
})

test_that("secondary tabs and SPELL render complete trilingual internal labels, options, and buttons", {
  skip_if_not_installed("shiny")

  # BDTD internal options & buttons
  bdtd_pt <- as.character(bdtdUI(lang = "pt"))
  bdtd_es <- as.character(bdtdUI(lang = "es"))
  expect_true(grepl("Apenas Teses (Doutorado)", bdtd_pt, fixed = TRUE))
  expect_true(grepl("Solo Tesis (Doctorado)", bdtd_es, fixed = TRUE))
  expect_true(grepl("Exportar CSV", bdtd_pt, fixed = TRUE))
  expect_true(grepl("Carregar no Biblioshiny", bdtd_pt, fixed = TRUE))
  expect_true(grepl("Cargar en Biblioshiny", bdtd_es, fixed = TRUE))

  # Oasisbr internal select options & labels
  oasis_pt <- as.character(oasisbrUI(lang = "pt"))
  oasis_es <- as.character(oasisbrUI(lang = "es"))
  expect_true(grepl("Limite Maximo de Registros:", oasis_pt, fixed = TRUE))
  expect_true(grepl("Apenas Artigos de Periodicos", oasis_pt, fixed = TRUE))
  expect_true(grepl("Solo Articulos de Revistas", oasis_es, fixed = TRUE))
  expect_true(grepl("Anais de Eventos", oasis_pt, fixed = TRUE))
  expect_true(grepl("Memorias de Congresos", oasis_es, fixed = TRUE))

  # Redalyc banner & checkbox
  red_pt <- as.character(redalycUI(lang = "pt"))
  red_es <- as.character(redalycUI(lang = "es"))
  expect_true(grepl("Periodicos Ibero-Americanos de Acesso Aberto Diamante", red_pt, fixed = TRUE))
  expect_true(grepl("Revistas Iberoamericanas de Acceso Abierto Diamante", red_es, fixed = TRUE))
  expect_true(grepl("Normalizar sobrenomes compostos hispanicos", red_pt, fixed = TRUE))
  expect_true(grepl("Normalizar apellidos compuestos hispanos", red_es, fixed = TRUE))

  # Merge banner, radio choices, criteria & slider
  mrg_pt <- as.character(bibliolatamMergeUI(lang = "pt"))
  mrg_es <- as.character(bibliolatamMergeUI(lang = "es"))
  expect_true(grepl("Harmonize e Funda Colecoes Latino-Americanas", mrg_pt, fixed = TRUE))
  expect_true(grepl("Armonice y Fusione Colecciones Latinoamericanas", mrg_es, fixed = TRUE))
  expect_true(grepl("Colecao Atualmente Carregada no App", mrg_pt, fixed = TRUE))
  expect_true(grepl("DOI Canonico Higienizado", mrg_pt, fixed = TRUE))
  expect_true(grepl("Limiar de Similaridade de Titulo:", mrg_pt, fixed = TRUE))
  expect_true(grepl("Umbral de Similitud de Titulo:", mrg_es, fixed = TRUE))

  # SPELL UI across EN, PT, ES
  sp_en <- as.character(spellUI(lang = "en"))
  sp_pt <- as.character(spellUI(lang = "pt"))
  sp_es <- as.character(spellUI(lang = "es"))
  expect_true(grepl("SPELL / ANPAD Collection", sp_en, fixed = TRUE))
  expect_true(grepl("Coleta SPELL / ANPAD", sp_pt, fixed = TRUE))
  expect_true(grepl("Recoleccion SPELL / ANPAD", sp_es, fixed = TRUE))
})
