#' SPELL UI Component for Biblioshiny
#'
#' Renders the SPELL / ANPAD (Scientific Periodicals Electronic Library)
#' upload, parsing, and preview panel compatible with biblioshiny.
#'
#' @param lang Character. Interface language: "en", "pt", or "es". Default is "en".
#' @return A Shiny tag list (\code{shiny.tag.list}) containing the UI elements and controls for the SPELL panel.
#' @keywords internal
#' @export
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(spellUI())
#'   server <- function(input, output, session) {
#'     spellServer(input, output, session)
#'   }
#'   shinyApp(ui, server)
#' }
spellUI <- function(lang = "en") {
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::wellPanel(
          id = "spellPanel",
          style = "background-color: #ffffff; border-top: 3px solid #16a085; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",

          # Header
          shiny::div(
            style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;",
            shiny::div(
              shiny::tags$h3(
                bl_i18n("spell_title", lang),
                `data-i18n` = "spell_title",
                style = "font-weight: bold; margin: 0; color: #2c3e50; display: inline-block;"
              ),
              shiny::tags$span(
                bl_i18n("spell_badge", lang),
                `data-i18n` = "spell_badge",
                class = "label label-info",
                style = "margin-left: 10px; font-size: 12px; vertical-align: middle; background-color: #16a085;"
              )
            ),
            shiny::actionButton(
              "spellTogglePanel",
              shiny::icon("chevron-up"),
              class = "btn-sm btn-default",
              style = "padding: 5px 10px;",
              title = bl_i18n("btn_collapse", lang),
              `data-i18n-title` = "btn_collapse"
            )
          ),

          # Info banner
          shiny::div(
            style = "margin-bottom: 20px; padding: 12px 15px; background-color: #e8f8f5; border-radius: 4px; border-left: 4px solid #16a085; color: #0e6251;",
            shiny::icon("briefcase", style = "margin-right: 8px; font-size: 16px;"),
            shiny::tags$span(
              bl_i18n("spell_banner", lang),
              `data-i18n` = "spell_banner"
            )
          ),

          # Main Content
          shiny::div(
            id = "spellContent",
            shiny::div(
              style = "padding: 15px; background-color: #fafbfc; border: 1px solid #e1e4e8; border-radius: 4px;",
              shiny::fluidRow(
                shiny::column(
                  width = 8,
                  shiny::fileInput(
                    "spellFile",
                    label = shiny::tags$span(bl_i18n("spell_upload_label", lang), `data-i18n` = "spell_upload_label"),
                    multiple = FALSE,
                    accept = c(".csv", ".tsv", ".txt"),
                    width = "100%"
                  )
                ),
                shiny::column(
                  width = 2,
                  shiny::tags$label(
                    bl_i18n("omni_year_start", lang),
                    `data-i18n` = "omni_year_start",
                    `for` = "spellYearStart",
                    style = "font-weight: 600; color: #34495e; margin-bottom: 5px; display: block;"
                  ),
                  shiny::numericInput(
                    "spellYearStart",
                    label = NULL,
                    value = NA,
                    min = 1900,
                    max = 2030,
                    width = "100%"
                  )
                ),
                shiny::column(
                  width = 2,
                  shiny::tags$label(
                    bl_i18n("omni_year_end", lang),
                    `data-i18n` = "omni_year_end",
                    `for` = "spellYearEnd",
                    style = "font-weight: 600; color: #34495e; margin-bottom: 5px; display: block;"
                  ),
                  shiny::numericInput(
                    "spellYearEnd",
                    label = NULL,
                    value = NA,
                    min = 1900,
                    max = 2030,
                    width = "100%"
                  )
                )
              ),
              shiny::div(
                style = "margin-top: 10px; display: flex; justify-content: flex-end;",
                shiny::actionButton(
                  "spellProcessFile",
                  label = shiny::tags$span(bl_i18n("spell_process_btn", lang), `data-i18n` = "spell_process_btn"),
                  icon = shiny::icon("cogs"),
                  class = "btn-info",
                  style = "font-weight: bold; background-color: #16a085; border-color: #117a65; color: #ffffff;"
                )
              )
            )
          )
        )
      )
    ),

    # Results & Preview Section
    shiny::conditionalPanel(
      condition = "output.spellDataAvailable",
      shiny::fluidRow(
        shiny::column(
          width = 12,
          shiny::wellPanel(
            style = "background-color: #ffffff; border-top: 3px solid #00a65a; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",
            shiny::div(
              style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;",
              shiny::h4(bl_i18n("spell_preview_title", lang), `data-i18n` = "spell_preview_title", style = "font-weight: bold; margin: 0; color: #2c3e50;"),
              shiny::div(
                shiny::downloadButton("spellDownloadCSV", label = shiny::tags$span(bl_i18n("export_csv_btn", lang), `data-i18n` = "export_csv_btn"), class = "btn-sm btn-default"),
                shiny::downloadButton("spellDownloadRData", label = shiny::tags$span(bl_i18n("export_rdata_btn", lang), `data-i18n` = "export_rdata_btn"), class = "btn-sm btn-info", style = "margin-left: 5px;"),
                shiny::actionButton("spellLoadToApp", label = shiny::tags$span(bl_i18n("load_biblioshiny_btn", lang), `data-i18n` = "load_biblioshiny_btn"), icon = shiny::icon("play"), class = "btn-sm btn-success", style = "margin-left: 10px; font-weight: bold;")
              )
            ),
            shiny::uiOutput("spellSummaryBoxes"),
            shiny::div(
              style = "margin-top: 15px;",
              shiny::uiOutput("spellPreviewTable")
            )
          )
        )
      )
    ),

    # JavaScript toggle
    shiny::tags$script(shiny::HTML(
      "$(document).ready(function() {
         var spellCollapsed = false;
         $('#spellTogglePanel').on('click', function() {
           spellCollapsed = !spellCollapsed;
           $('#spellContent').slideToggle(300);
           if (spellCollapsed) {
             $(this).html('<i class=\"fa fa-chevron-down\"></i>');
           } else {
             $(this).html('<i class=\"fa fa-chevron-up\"></i>');
           }
         });
       });"
    ))
  )
}

#' SPELL Server Logic for Biblioshiny
#'
#' Connects SPELL / ANPAD UI events with \code{read_spell()} and the biblioshiny reactive state.
#'
#' @param input Shiny input.
#' @param output Shiny output.
#' @param session Shiny session.
#' @param values ReactiveValues global state. Default is NULL.
#' @return No return value, called for side effects (registers reactive observers and renders upload status, summary boxes, and preview tables for SPELL CSV exports within the Shiny session).
#' @keywords internal
#' @export
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(spellUI())
#'   server <- function(input, output, session) {
#'     spellServer(input, output, session)
#'   }
#'   shinyApp(ui, server)
#' }
spellServer <- function(input, output, session, values = NULL) {
  spell_data <- shiny::reactiveVal(NULL)

  output$spellDataAvailable <- shiny::reactive({
    !is.null(spell_data()) && nrow(spell_data()) > 0
  })
  shiny::outputOptions(output, "spellDataAvailable", suspendWhenHidden = FALSE)

  shiny::observeEvent(input$spellProcessFile, {
    file_info <- input$spellFile
    if (is.null(file_info)) {
      shiny::showModal(shiny::modalDialog(
        title = "No File Selected",
        "Please choose a SPELL / ANPAD export file (.csv or .tsv) to upload.",
        easyClose = TRUE,
        footer = shiny::modalButton("OK")
      ))
      return()
    }

    y_start <- suppressWarnings(as.integer(input$spellYearStart))
    y_end <- suppressWarnings(as.integer(input$spellYearEnd))

    shiny::withProgress(message = "Processing SPELL export...", value = 0.5, {
      tryCatch({
        df <- read_spell(file_info$datapath, convert = TRUE)

        if (!is.na(y_start)) {
          df <- df[is.na(df$PY) | df$PY >= y_start, , drop = FALSE]
        }
        if (!is.na(y_end)) {
          df <- df[is.na(df$PY) | df$PY <= y_end, , drop = FALSE]
        }

        if (nrow(df) == 0L) {
          shiny::showModal(shiny::modalDialog(
            title = "No Matching Records",
            "No SPELL records matched the selected year range.",
            easyClose = TRUE,
            footer = shiny::modalButton("OK")
          ))
          return()
        }

        spell_data(df)

        shiny::showNotification(
          sprintf("Successfully parsed %d SPELL records.", nrow(df)),
          type = "message",
          duration = 5
        )
      }, error = function(e) {
        shiny::showModal(shiny::modalDialog(
          title = "Parsing Error",
          paste("Error processing SPELL file:", e$message),
          easyClose = TRUE,
          footer = shiny::modalButton("OK")
        ))
      })
    })
  })

  # Render Summary Boxes
  output$spellSummaryBoxes <- shiny::renderUI({
    df <- spell_data()
    shiny::req(df)
    lang <- if (!is.null(input$current_lang) && nzchar(input$current_lang)) tolower(input$current_lang) else "en"

    n_docs <- nrow(df)
    unique_authors <- length(unique(unlist(strsplit(df$AU, ";\\s*"))))
    unique_journals <- length(unique(df$SO))

    py_vals <- df$PY[!is.na(df$PY)]
    timespan <- if (length(py_vals) > 0) paste(min(py_vals), "-", max(py_vals)) else "N/A"

    shiny::fluidRow(
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-teal",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::tags$span(class = "info-box-text", bl_i18n("kpi_total_articles", lang), `data-i18n` = "kpi_total_articles"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", n_docs)
          )
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-aqua",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::tags$span(class = "info-box-text", bl_i18n("kpi_authors", lang), `data-i18n` = "kpi_authors"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", unique_authors)
          )
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-green",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::tags$span(class = "info-box-text", bl_i18n("kpi_journals", lang), `data-i18n` = "kpi_journals"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", unique_journals)
          )
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-purple",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::tags$span(class = "info-box-text", bl_i18n("kpi_timespan", lang), `data-i18n` = "kpi_timespan"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", timespan)
          )
        )
      )
    )
  })

  # Render Preview Table
  output$spellPreviewTable <- shiny::renderUI({
    df <- spell_data()
    shiny::req(df)

    preview_cols <- intersect(c("AU", "TI", "SO", "PY", "DI", "DE"), names(df))
    preview_df <- utils::head(df[, preview_cols, drop = FALSE], 5)

    shiny::tags$div(
      style = "overflow-x: auto; font-size: 13px;",
      shiny::renderTable(preview_df, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%")
    )
  })

  # Load Dataset Directly into Biblioshiny Global State
  shiny::observeEvent(input$spellLoadToApp, {
    df <- spell_data()
    shiny::req(df)

    is_biblioshiny <- is.function(get0("initial", envir = parent.frame(), mode = "function")) ||
                      is.function(get0("mergeKeywords", envir = parent.frame(), mode = "function"))

    if (is_biblioshiny && !is.null(values)) {
      initial_fn <- get0("initial", envir = parent.frame(), mode = "function")
      if (is.function(initial_fn)) {
        values <- initial_fn(values)
      }

      M <- df
      merge_fn <- get0("mergeKeywords", envir = parent.frame(), mode = "function")
      if (is.function(merge_fn)) {
        M <- merge_fn(M, force = FALSE)
      }

      values$data_source <- "SPELL"
      values$M <- M
      values$Morig <- M

      wc_fn <- get0("wcTable", envir = parent.frame(), mode = "function")
      if (is.function(wc_fn)) {
        values$SCdf <- wc_fn(M)
      }
      co_fn <- get0("countryTable", envir = parent.frame(), mode = "function")
      if (is.function(co_fn)) {
        values$COdf <- co_fn(M)
      }

      values$Histfield <- "NA"
      values$results <- list("NA")

      if (ncol(values$M) > 1) {
        values$rest_sidebar <- TRUE
      }

      shiny::showNotification(
        "SPELL collection loaded into Biblioshiny! Analysis menus are now unlocked.",
        type = "message",
        duration = 6
      )

      modal_api <- get0("missingModalAPI", envir = parent.frame(), mode = "function")
      modal_std <- get0("missingModal", envir = parent.frame(), mode = "function")
      if (is.function(modal_api)) {
        shiny::showModal(modal_api(session))
      } else if (is.function(modal_std)) {
        shiny::showModal(modal_std(session))
      }
    } else {
      if (!is.null(values) && (is.environment(values) || inherits(values, "reactivevalues"))) {
        values$M <- df
        values$Morig <- df
      }
      shiny::showNotification(
        "SPELL collection processed and ready! Use the export buttons below to save .RData or .CSV.",
        type = "message",
        duration = 5
      )
    }
  })

  # Export CSV
  output$spellDownloadCSV <- shiny::downloadHandler(
    filename = function() {
      paste0("spell_collection_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      shiny::req(spell_data())
      utils::write.csv(spell_data(), file = file, row.names = FALSE)
    }
  )

  # Export RData
  output$spellDownloadRData <- shiny::downloadHandler(
    filename = function() {
      paste0("spell_collection_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".RData")
    },
    content = function(file) {
      shiny::req(spell_data())
      export_biblioshiny(spell_data(), file = file)
    }
  )
}
