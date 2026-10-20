#' Run the standalone bibliolatam Shiny application
#'
#' Launches an interactive Shiny application integrating all Latin American
#' bibliographic data collectors, parsers, and merging tools with full
#' trilingual support (English, Portuguese, Spanish).
#'
#' @param port Integer. The TCP port that the application should listen on. Default is NULL.
#' @param host Character. The IPv4 address that the application should listen on. Default is "127.0.0.1".
#' @param launch.browser Logical. If TRUE, the system's default web browser will be launched. Default is interactive().
#' @param default_lang Character. Default interface language: "en" (English), "pt" (Portuguese), or "es" (Spanish). Default is "en".
#' @return A Shiny app object.
#' @export
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
run_app <- function(port = getOption("shiny.port"),
                    host = getOption("shiny.host", "127.0.0.1"),
                    launch.browser = interactive(),
                    default_lang = c("en", "pt", "es")) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required to run the application. Please install with install.packages('shiny').", call. = FALSE)
  }

  default_lang <- match.arg(default_lang)

  ui <- shiny::navbarPage(
    title = shiny::div(
      style = "display: flex; align-items: center; gap: 8px;",
      shiny::strong("bibliolatam"),
      shiny::tags$span("v1.0.0", class = "label label-success", style = "font-size: 11px;")
    ),
    id = "bibliolatamNavbar",
    header = shiny::tagList(
      bl_i18n_script(),
      shiny::div(
        style = "background-color: #f8f9fa; border-bottom: 1px solid #e7e7e7; padding: 6px 20px; display: flex; justify-content: flex-end; align-items: center; gap: 10px;",
        shiny::tags$span(shiny::icon("language"), style = "color: #555; font-size: 14px;"),
        shiny::tags$span("Language / Idioma:", style = "font-weight: 600; color: #555; font-size: 13px;"),
        shiny::tags$div(
          class = "btn-group btn-group-sm",
          role = "group",
          shiny::tags$button(type = "button", class = "btn btn-default active", id = "btn_lang_en", onclick = "setBibliolatamLang('en')", "\ud83c\uddec\ud83c\udde7 English"),
          shiny::tags$button(type = "button", class = "btn btn-default", id = "btn_lang_pt", onclick = "setBibliolatamLang('pt')", "\ud83c\udde7\ud83c\uddf7 Portugu\u00eas"),
          shiny::tags$button(type = "button", class = "btn btn-default", id = "btn_lang_es", onclick = "setBibliolatamLang('es')", "\ud83c\uddea\ud83c\uddf8 Espa\u00f1ol")
        )
      )
    ),
    shiny::tabPanel("Omnisearch", omnisearchUI(lang = default_lang)),
    shiny::tabPanel("SciELO", scieloUI(lang = default_lang)),
    shiny::tabPanel("BDTD", bdtdUI(lang = default_lang)),
    shiny::tabPanel("Oasisbr", oasisbrUI(lang = default_lang)),
    shiny::tabPanel("Redalyc", redalycUI(lang = default_lang)),
    shiny::tabPanel("Merge & Deduplicate", bibliolatamMergeUI(lang = default_lang)),
    shiny::tabPanel("About", bibliolatamInfoUI(lang = default_lang))
  )

  server <- function(input, output, session) {
    values <- shiny::reactiveValues(M = NULL, Morig = NULL)
    omnisearchServer(input, output, session, values)
    scieloServer(input, output, session, values)
    bdtdServer(input, output, session, values)
    oasisbrServer(input, output, session, values)
    redalycServer(input, output, session, values)
    bibliolatamMergeServer(input, output, session, values)
  }

  shiny::shinyApp(
    ui = ui,
    server = server,
    options = list(port = port, host = host, launch.browser = launch.browser)
  )
}
