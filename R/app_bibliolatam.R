#' Run the standalone bibliolatam Shiny application
#'
#' Launches an interactive Shiny application integrating all Latin American
#' bibliographic data collectors, parsers, and merging tools.
#'
#' @param port Integer. The TCP port that the application should listen on. Default is NULL.
#' @param host Character. The IPv4 address that the application should listen on. Default is "127.0.0.1".
#' @param launch.browser Logical. If TRUE, the system's default web browser will be launched. Default is interactive().
#' @return A Shiny app object.
#' @export
#' @examples
#' if (interactive()) {
#'   run_app()
#' }
run_app <- function(port = getOption("shiny.port"),
                    host = getOption("shiny.host", "127.0.0.1"),
                    launch.browser = interactive()) {
  if (!requireNamespace("shiny", quietly = TRUE)) {
    stop("Package 'shiny' is required to run the application. Please install with install.packages('shiny').", call. = FALSE)
  }

  ui <- shiny::navbarPage(
    title = "bibliolatam",
    id = "bibliolatamNavbar",
    shiny::tabPanel("Omnisearch", omnisearchUI()),
    shiny::tabPanel("SciELO", scieloUI()),
    shiny::tabPanel("BDTD", bdtdUI()),
    shiny::tabPanel("Oasisbr", oasisbrUI()),
    shiny::tabPanel("Redalyc", redalycUI()),
    shiny::tabPanel("Merge & Deduplicate", bibliolatamMergeUI()),
    shiny::tabPanel("About", bibliolatamInfoUI())
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
