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

  # Fallback
  expect_equal(bibliolatam:::bl_i18n("tab_about", "invalid_lang"), "About")
  expect_equal(bibliolatam:::bl_i18n("non_existent_key", "en"), "non_existent_key")
})

test_that("UI functions accept lang parameter and render localized text", {
  skip_if_not_installed("shiny")

  ui_en <- omnisearchUI(lang = "en")
  ui_pt <- omnisearchUI(lang = "pt")
  ui_es <- omnisearchUI(lang = "es")

  expect_true(grepl("Latin American Omnisearch Engine", as.character(ui_en)))
  expect_true(grepl("Mecanismo Omnisearch Latino-Americano", as.character(ui_pt)))
  expect_true(grepl("Motor Omnisearch Latinoamericano", as.character(ui_es)))

  info_pt <- bibliolatamInfoUI(lang = "pt")
  info_es <- bibliolatamInfoUI(lang = "es")
  expect_true(grepl("Por que o bibliolatam?", as.character(info_pt)))
  expect_true(grepl("Por que bibliolatam?", as.character(info_es)))
})

test_that("bl_i18n_script generates valid script tag containing dictionary", {
  skip_if_not_installed("shiny")

  script <- bibliolatam:::bl_i18n_script()
  expect_s3_class(script, "shiny.tag")
  script_str <- as.character(script)
  expect_true(grepl("window.bibliolatam_dict", script_str))
  expect_true(grepl("setBibliolatamLang", script_str))
})
