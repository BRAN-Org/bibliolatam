#' BDTD & Oasisbr UI Component for Biblioshiny
#'
#' Renders the BDTD / Oasisbr (IBICT) thesis and dissertation collection panel
#' compatible with the biblioshiny AdminLTE layout.
#'
#' @return A Shiny tagList containing the UI elements.
#' @keywords internal
#' @export
bdtdUI <- function() {
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::wellPanel(
          id = "bdtdPanel",
          style = "background-color: #ffffff; border-top: 3px solid #0073b7; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",

          # Header with branding and collapse button
          shiny::div(
            style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;",
            shiny::div(
              shiny::h3(
                "BDTD / Oasisbr Collection",
                style = "font-weight: bold; margin: 0; color: #2c3e50; display: inline-block;"
              ),
              shiny::tags$span(
                "IBICT (Brazilian Theses & Dissertations)",
                class = "label label-primary",
                style = "margin-left: 10px; font-size: 12px; vertical-align: middle;"
              )
            ),
            shiny::actionButton(
              "bdtdTogglePanel",
              shiny::icon("chevron-up"),
              class = "btn-sm btn-default",
              style = "padding: 5px 10px;",
              title = "Collapse/Expand"
            )
          ),

          # Info banner
          shiny::div(
            style = "margin-bottom: 20px; padding: 12px 15px; background-color: #ebf5fb; border-radius: 4px; border-left: 4px solid #0073b7; color: #1b4f72;",
            shiny::icon("university", style = "margin-right: 8px; font-size: 16px;"),
            shiny::strong("National Graduate Research Repository: "),
            "Import tabular exports (CSV, TSV) from the BDTD or Oasisbr portals. Maps graduate programs and universities to Source (SO), advisors to Corresponding Author (RP), and classifies degrees into Theses and Dissertations."
          ),

          # Main Content
          shiny::div(
            id = "bdtdContent",
            shiny::div(
              style = "padding: 15px; background-color: #fafbfc; border: 1px solid #e1e4e8; border-radius: 4px;",
              shiny::fluidRow(
                shiny::column(
                  width = 6,
                  shiny::fileInput(
                    "bdtdFile",
                    "Select BDTD / Oasisbr Export File (CSV or TSV):",
                    multiple = FALSE,
                    accept = c(".csv", ".tsv", ".txt"),
                    width = "100%"
                  )
                ),
                shiny::column(
                  width = 6,
                  shiny::radioButtons(
                    "bdtdDegreeFilter",
                    "Filter Degree / Document Type:",
                    choices = c(
                      "All (Theses & Dissertations)" = "all",
                      "Only Theses (Doutorado)" = "thesis",
                      "Only Dissertations (Mestrado)" = "dissertation"
                    ),
                    selected = "all",
                    inline = TRUE
                  )
                )
              ),
              shiny::div(
                style = "margin-top: 10px; display: flex; justify-content: space-between; align-items: center;",
                shiny::div(
                  shiny::checkboxInput(
                    "bdtdNormalizeAuthors",
                    "Normalize Brazilian author and advisor names (suffixes like Filho, Neto, Junior)",
                    value = TRUE
                  )
                ),
                shiny::actionButton(
                  "bdtdProcessFile",
                  "Process BDTD File",
                  icon = shiny::icon("cogs"),
                  class = "btn-primary",
                  style = "font-weight: bold;"
                )
              )
            )
          )
        )
      )
    ),

    # Results & Preview Section
    shiny::conditionalPanel(
      condition = "output.bdtdDataAvailable",
      shiny::fluidRow(
        shiny::column(
          width = 12,
          shiny::wellPanel(
            style = "background-color: #ffffff; border-top: 3px solid #00a65a; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",
            shiny::div(
              style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;",
              shiny::h4("BDTD Collection Preview & Metrics", style = "font-weight: bold; margin: 0; color: #2c3e50;"),
              shiny::div(
                shiny::downloadButton("bdtdDownloadCSV", "Export CSV", class = "btn-sm btn-default"),
                shiny::downloadButton("bdtdDownloadRData", "Export .RData", class = "btn-sm btn-info", style = "margin-left: 5px;"),
                shiny::actionButton("bdtdLoadToApp", "Load into Biblioshiny", icon = shiny::icon("play"), class = "btn-sm btn-success", style = "margin-left: 10px; font-weight: bold;")
              )
            ),
            shiny::uiOutput("bdtdSummaryBoxes"),
            shiny::div(
              style = "margin-top: 15px;",
              shiny::uiOutput("bdtdPreviewTable")
            )
          )
        )
      )
    ),

    # JavaScript for toggle collapse
    shiny::tags$script(shiny::HTML(
      "$(document).ready(function() {
         var bdtdCollapsed = false;
         $('#bdtdTogglePanel').on('click', function() {
           bdtdCollapsed = !bdtdCollapsed;
           $('#bdtdContent').slideToggle(300);
           if (bdtdCollapsed) {
             $(this).html('<i class=\"fa fa-chevron-down\"></i>');
           } else {
             $(this).html('<i class=\"fa fa-chevron-up\"></i>');
           }
         });
       });"
    ))
  )
}

#' BDTD Server Logic for Biblioshiny
#'
#' Connects BDTD UI events with package parsers and the biblioshiny reactive state.
#'
#' @param input Shiny input object.
#' @param output Shiny output object.
#' @param session Shiny session object.
#' @param values ReactiveValues object from biblioshiny containing global state.
#' @keywords internal
#' @export
bdtdServer <- function(input, output, session, values) {
  bdtd_data <- shiny::reactiveVal(NULL)

  # Check if data is available for preview
  output$bdtdDataAvailable <- shiny::reactive({
    !is.null(bdtd_data()) && nrow(bdtd_data()) > 0
  })
  shiny::outputOptions(output, "bdtdDataAvailable", suspendWhenHidden = FALSE)

  # Handle Local File Processing
  shiny::observeEvent(input$bdtdProcessFile, {
    file_info <- input$bdtdFile
    if (is.null(file_info)) {
      shiny::showModal(shiny::modalDialog(
        title = "No File Selected",
        "Please choose a BDTD or Oasisbr CSV/TSV export file to upload.",
        easyClose = TRUE,
        footer = shiny::modalButton("OK")
      ))
      return()
    }

    degree_filter <- input$bdtdDegreeFilter

    shiny::withProgress(message = "Processing BDTD / Oasisbr export...", value = 0.5, {
      tryCatch({
        df <- read_bdtd(file_info$datapath, convert = TRUE)

        # Apply degree filter if requested
        if (identical(degree_filter, "thesis")) {
          df <- df[df$DT == "THESIS", , drop = FALSE]
        } else if (identical(degree_filter, "dissertation")) {
          df <- df[df$DT == "DISSERTATION", , drop = FALSE]
        }

        if (nrow(df) == 0L) {
          shiny::showModal(shiny::modalDialog(
            title = "No Matching Records",
            "No records matched the selected degree filter.",
            easyClose = TRUE,
            footer = shiny::modalButton("OK")
          ))
          return()
        }

        bdtd_data(df)

        shiny::showNotification(
          sprintf("Successfully parsed %d thesis/dissertation records.", nrow(df)),
          type = "message",
          duration = 5
        )
      }, error = function(e) {
        shiny::showModal(shiny::modalDialog(
          title = "Parsing Error",
          paste("Error processing BDTD file:", e$message),
          easyClose = TRUE,
          footer = shiny::modalButton("OK")
        ))
      })
    })
  })

  # Render Summary Stat Boxes
  output$bdtdSummaryBoxes <- shiny::renderUI({
    df <- bdtd_data()
    shiny::req(df)

    n_docs <- nrow(df)
    n_thesis <- sum(df$DT == "THESIS", na.rm = TRUE)
    n_diss <- sum(df$DT == "DISSERTATION", na.rm = TRUE)

    py_vals <- df$PY[!is.na(df$PY)]
    timespan <- if (length(py_vals) > 0) paste(min(py_vals), "-", max(py_vals)) else "N/A"

    unique_institutions <- length(unique(gsub("\\..*$", "", df$SO)))

    shiny::fluidRow(
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-blue",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "TOTAL WORKS"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", n_docs)
          )
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-green",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "THESES / DISSERTATIONS"),
            shiny::span(class = "info-box-number", style = "font-size: 16px; font-weight: bold;", sprintf("T: %d | D: %d", n_thesis, n_diss))
          )
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-teal",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "INSTITUTIONS"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", unique_institutions)
          )
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-purple",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "TIMESPAN"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", timespan)
          )
        )
      )
    )
  })

  # Render Preview Table
  output$bdtdPreviewTable <- shiny::renderUI({
    df <- bdtd_data()
    shiny::req(df)

    preview_cols <- intersect(c("AU", "TI", "SO", "RP", "PY", "DT"), names(df))
    preview_df <- utils::head(df[, preview_cols, drop = FALSE], 5)

    # Rename RP to ADVISOR for clearer user comprehension
    if ("RP" %in% names(preview_df)) {
      names(preview_df)[names(preview_df) == "RP"] <- "ADVISOR"
    }

    shiny::tags$div(
      style = "overflow-x: auto; font-size: 13px;",
      shiny::renderTable(preview_df, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%")
    )
  })

  # Load Dataset Directly into Biblioshiny Global State
  shiny::observeEvent(input$bdtdLoadToApp, {
    df <- bdtd_data()
    shiny::req(df)

    # Initialize biblioshiny global values
    initial_fn <- get0("initial", envir = parent.frame(), mode = "function")
    if (is.function(initial_fn)) {
      values <- initial_fn(values)
    }

    M <- df
    merge_fn <- get0("mergeKeywords", envir = parent.frame(), mode = "function")
    if (is.function(merge_fn)) {
      M <- merge_fn(M, force = FALSE)
    }

    values$data_source <- "BDTD"
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
      "BDTD collection loaded into Biblioshiny! Analysis menus are now unlocked.",
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
  })

  # Export CSV
  output$bdtdDownloadCSV <- shiny::downloadHandler(
    filename = function() {
      paste0("bdtd_collection_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      shiny::req(bdtd_data())
      utils::write.csv(bdtd_data(), file = file, row.names = FALSE)
    }
  )

  # Export RData
  output$bdtdDownloadRData <- shiny::downloadHandler(
    filename = function() {
      paste0("bdtd_collection_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".RData")
    },
    content = function(file) {
      shiny::req(bdtd_data())
      export_biblioshiny(bdtd_data(), file = file)
    }
  )
}
