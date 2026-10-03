#' SciELO UI Component for Biblioshiny
#'
#' Renders the SciELO data collection and import panel compatible with
#' biblioshiny AdminLTE layout.
#'
#' @return A Shiny tagList containing the UI elements.
#' @keywords internal
#' @export
scieloUI <- function() {
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::wellPanel(
          id = "scieloPanel",
          style = "background-color: #ffffff; border-top: 3px solid #00a65a; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",

          # Header with branding and collapse button
          shiny::div(
            style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;",
            shiny::div(
              shiny::h3(
                "SciELO Data Collection",
                style = "font-weight: bold; margin: 0; color: #2c3e50; display: inline-block;"
              ),
              shiny::tags$span(
                "Diamond Open Access (Latin America & Caribbean)",
                class = "label label-success",
                style = "margin-left: 10px; font-size: 12px; vertical-align: middle;"
              )
            ),
            shiny::actionButton(
              "scieloTogglePanel",
              shiny::icon("chevron-up"),
              class = "btn-sm btn-default",
              style = "padding: 5px 10px;",
              title = "Collapse/Expand"
            )
          ),

          # Info banner
          shiny::div(
            style = "margin-bottom: 20px; padding: 12px 15px; background-color: #e8f8f5; border-radius: 4px; border-left: 4px solid #00a65a; color: #165b4c;",
            shiny::icon("info-circle", style = "margin-right: 8px; font-size: 16px;"),
            shiny::strong("Full JATS XML & Cited References (CR): "),
            "Retrieve or upload full-text NLM/JATS XML articles from SciELO. Reconstructs cited references for bibliographic coupling and co-citation networks."
          ),

          # Main Content
          shiny::div(
            id = "scieloContent",
            shiny::tabsetPanel(
              id = "scieloModeTabs",
              type = "pills",

              # TAB 1: Online Retrieval by Identifiers
              shiny::tabPanel(
                title = shiny::tagList(shiny::icon("cloud-download-alt"), " Online Retrieval (DOIs / PIDs)"),
                value = "mode_download",
                shiny::div(
                  style = "margin-top: 15px; padding: 15px; background-color: #fafbfc; border: 1px solid #e1e4e8; border-radius: 4px;",
                  shiny::tags$label(
                    "SciELO DOIs, PIDs or URLs (one per line or comma-separated):",
                    style = "font-weight: 600; color: #34495e; margin-bottom: 8px; display: block;"
                  ),
                  shiny::textAreaInput(
                    "scieloInputIds",
                    label = NULL,
                    rows = 6,
                    placeholder = "Ex:\n10.1590/S0034-8910.2014048004911\n10.1590/S0034-8910.2014048004965\n10.1590/1518-8345.2927.3231",
                    width = "100%"
                  ),
                  shiny::div(
                    style = "margin-top: 10px; display: flex; justify-content: space-between; align-items: center;",
                    shiny::div(
                      shiny::checkboxInput(
                        "scieloNormalizeAuthors",
                        "Normalize Brazilian & Hispanic author names (generational suffixes & particles)",
                        value = TRUE
                      )
                    ),
                    shiny::div(
                      shiny::actionButton(
                        "scieloClearIds",
                        "Clear",
                        icon = shiny::icon("times"),
                        class = "btn-default"
                      ),
                      shiny::actionButton(
                        "scieloFetchData",
                        "Download & Process",
                        icon = shiny::icon("download"),
                        class = "btn-success",
                        style = "margin-left: 8px; font-weight: bold;"
                      )
                    )
                  )
                )
              ),

              # TAB 2: Offline File Upload
              shiny::tabPanel(
                title = shiny::tagList(shiny::icon("file-upload"), " Local File Upload"),
                value = "mode_upload",
                shiny::div(
                  style = "margin-top: 15px; padding: 15px; background-color: #fafbfc; border: 1px solid #e1e4e8; border-radius: 4px;",
                  shiny::radioButtons(
                    "scieloUploadType",
                    "Select file format:",
                    choices = c(
                      "Full-text JATS XML package (.zip or .xml)" = "jats",
                      "Tabular metadata export (.csv)" = "csv"
                    ),
                    inline = TRUE
                  ),
                  shiny::fileInput(
                    "scieloFile",
                    "Upload SciELO File(s):",
                    multiple = FALSE,
                    accept = c(".xml", ".zip", ".csv"),
                    width = "100%"
                  ),
                  shiny::div(
                    style = "text-align: right; margin-top: 10px;",
                    shiny::actionButton(
                      "scieloProcessFile",
                      "Process Local File",
                      icon = shiny::icon("cogs"),
                      class = "btn-primary",
                      style = "font-weight: bold;"
                    )
                  )
                )
              )
            )
          )
        )
      )
    ),

    # Results & Preview Section
    shiny::conditionalPanel(
      condition = "output.scieloDataAvailable",
      shiny::fluidRow(
        shiny::column(
          width = 12,
          shiny::wellPanel(
            style = "background-color: #ffffff; border-top: 3px solid #3c8dbc; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",
            shiny::div(
              style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;",
              shiny::h4("Dataset Preview & Quality Summary", style = "font-weight: bold; margin: 0; color: #2c3e50;"),
              shiny::div(
                shiny::downloadButton("scieloDownloadExcel", "Export Excel", class = "btn-sm btn-default"),
                shiny::downloadButton("scieloDownloadRData", "Export .RData", class = "btn-sm btn-info", style = "margin-left: 5px;"),
                shiny::actionButton("scieloLoadToApp", "Load into Biblioshiny", icon = shiny::icon("play"), class = "btn-sm btn-success", style = "margin-left: 10px; font-weight: bold;")
              )
            ),
            shiny::uiOutput("scieloSummaryBoxes"),
            shiny::div(
              style = "margin-top: 15px;",
              shiny::uiOutput("scieloPreviewTable")
            )
          )
        )
      )
    ),

    # JavaScript for toggle collapse
    shiny::tags$script(shiny::HTML(
      "$(document).ready(function() {
         var collapsed = false;
         $('#scieloTogglePanel').on('click', function() {
           collapsed = !collapsed;
           $('#scieloContent').slideToggle(300);
           if (collapsed) {
             $(this).html('<i class=\"fa fa-chevron-down\"></i>');
           } else {
             $(this).html('<i class=\"fa fa-chevron-up\"></i>');
           }
         });
       });"
    ))
  )
}

#' SciELO Server Logic for Biblioshiny
#'
#' Connects SciELO UI events with package parsers and the biblioshiny reactive state.
#'
#' @param input Shiny input object.
#' @param output Shiny output object.
#' @param session Shiny session object.
#' @param values ReactiveValues object from biblioshiny containing global state.
#' @keywords internal
#' @export
scieloServer <- function(input, output, session, values) {
  scielo_data <- shiny::reactiveVal(NULL)

  # Check if data is available for preview
  output$scieloDataAvailable <- shiny::reactive({
    !is.null(scielo_data()) && nrow(scielo_data()) > 0
  })
  shiny::outputOptions(output, "scieloDataAvailable", suspendWhenHidden = FALSE)

  # Clear inputs
  shiny::observeEvent(input$scieloClearIds, {
    shiny::updateTextAreaInput(session, "scieloInputIds", value = "")
  })

  # Handle Online Retrieval
  shiny::observeEvent(input$scieloFetchData, {
    raw_text <- trimws(input$scieloInputIds)
    if (!nzchar(raw_text)) {
      shiny::showModal(shiny::modalDialog(
        title = "Empty Query",
        "Please enter at least one SciELO DOI, PID, or landing URL.",
        easyClose = TRUE,
        footer = shiny::modalButton("OK")
      ))
      return()
    }

    # Split lines and commas
    ids <- unlist(strsplit(raw_text, "[\r\n,]+"))
    ids <- trimws(ids)
    ids <- ids[nzchar(ids)]

    if (length(ids) == 0) return()

    shiny::withProgress(message = "Fetching SciELO articles...", value = 0, {
      tryCatch({
        df <- download_scielo_jats(
          ids = ids,
          parse = TRUE,
          convert = TRUE,
          progress = FALSE
        )

        scielo_data(df)

        shiny::showNotification(
          sprintf("Successfully downloaded and processed %d SciELO articles.", nrow(df)),
          type = "message",
          duration = 5
        )
      }, error = function(e) {
        shiny::showModal(shiny::modalDialog(
          title = "SciELO Download Error",
          paste("Failed to download or parse articles:", e$message),
          easyClose = TRUE,
          footer = shiny::modalButton("OK")
        ))
      })
    })
  })

  # Handle Local File Upload
  shiny::observeEvent(input$scieloProcessFile, {
    file_info <- input$scieloFile
    if (is.null(file_info)) {
      shiny::showModal(shiny::modalDialog(
        title = "No File Selected",
        "Please choose a SciELO XML, ZIP, or CSV file to upload.",
        easyClose = TRUE,
        footer = shiny::modalButton("OK")
      ))
      return()
    }

    upload_type <- input$scieloUploadType

    shiny::withProgress(message = "Processing local SciELO file...", value = 0.5, {
      tryCatch({
        if (identical(upload_type, "csv")) {
          df <- read_scielo(file_info$datapath, convert = TRUE)
        } else {
          df <- read_scielo_jats(file_info$datapath, convert = TRUE)
        }

        scielo_data(df)

        shiny::showNotification(
          sprintf("Successfully parsed %d records from %s.", nrow(df), file_info$name),
          type = "message",
          duration = 5
        )
      }, error = function(e) {
        shiny::showModal(shiny::modalDialog(
          title = "Parsing Error",
          paste("Error processing file:", e$message),
          easyClose = TRUE,
          footer = shiny::modalButton("OK")
        ))
      })
    })
  })

  # Render Summary Stat Boxes
  output$scieloSummaryBoxes <- shiny::renderUI({
    df <- scielo_data()
    shiny::req(df)

    n_docs <- nrow(df)
    n_cr <- sum(!is.na(df$CR) & nzchar(df$CR))
    pct_cr <- round((n_cr / n_docs) * 100, 1)

    py_vals <- df$PY[!is.na(df$PY)]
    timespan <- if (length(py_vals) > 0) paste(min(py_vals), "-", max(py_vals)) else "N/A"

    langs <- table(df$LA)
    lang_str <- if (length(langs) > 0) paste(paste0(names(langs), ": ", langs), collapse = " | ") else "N/A"

    shiny::fluidRow(
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-aqua",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "DOCUMENTS"),
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
            shiny::span(class = "info-box-text", "TIMESPAN"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", timespan)
          )
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-yellow",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "CITED REFS (CR)"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", sprintf("%s%%", pct_cr))
          )
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-purple",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "LANGUAGES"),
            shiny::span(class = "info-box-number", style = "font-size: 13px;", lang_str)
          )
        )
      )
    )
  })

  # Render Data Table Preview
  output$scieloPreviewTable <- shiny::renderUI({
    df <- scielo_data()
    shiny::req(df)

    preview_cols <- intersect(c("AU", "TI", "SO", "PY", "LA", "DI"), names(df))
    preview_df <- utils::head(df[, preview_cols, drop = FALSE], 5)

    shiny::tags$div(
      style = "overflow-x: auto; font-size: 13px;",
      shiny::renderTable(preview_df, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%")
    )
  })

  # Load Dataset Directly into Biblioshiny Global State
  shiny::observeEvent(input$scieloLoadToApp, {
    df <- scielo_data()
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

    values$data_source <- "SciELO"
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
      "SciELO collection loaded into Biblioshiny! Analysis menus are now unlocked.",
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
  output$scieloDownloadExcel <- shiny::downloadHandler(
    filename = function() {
      paste0("scielo_collection_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      shiny::req(scielo_data())
      utils::write.csv(scielo_data(), file = file, row.names = FALSE)
    }
  )

  # Export RData
  output$scieloDownloadRData <- shiny::downloadHandler(
    filename = function() {
      paste0("scielo_collection_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".RData")
    },
    content = function(file) {
      shiny::req(scielo_data())
      export_biblioshiny(scielo_data(), file = file)
    }
  )
}

