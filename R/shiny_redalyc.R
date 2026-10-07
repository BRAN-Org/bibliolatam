#' Redalyc UI Component for Biblioshiny
#'
#' Renders the Redalyc / AmeliCA collection import panel compatible with the biblioshiny layout.
#'
#' @return A Shiny tagList containing UI elements.
#' @keywords internal
#' @export
redalycUI <- function() {
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::wellPanel(
          id = "redalycPanel",
          style = "background-color: #ffffff; border-top: 3px solid #d35400; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",

          # Header
          shiny::div(
            style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;",
            shiny::div(
              shiny::h3(
                "Redalyc & AmeliCA Collection",
                style = "font-weight: bold; margin: 0; color: #2c3e50; display: inline-block;"
              ),
              shiny::tags$span(
                "Diamond Open Access (Ibero-America)",
                class = "label label-danger",
                style = "margin-left: 10px; font-size: 12px; vertical-align: middle; background-color: #d35400;"
              )
            ),
            shiny::actionButton(
              "redalycTogglePanel",
              shiny::icon("chevron-up"),
              class = "btn-sm btn-default",
              style = "padding: 5px 10px;",
              title = "Collapse/Expand"
            )
          ),

          # Info banner
          shiny::div(
            style = "margin-bottom: 20px; padding: 12px 15px; background-color: #fbeee6; border-radius: 4px; border-left: 4px solid #d35400; color: #78281f;",
            shiny::icon("book-open", style = "margin-right: 8px; font-size: 16px;"),
            shiny::strong("Ibero-American Diamond Open Access Journals: "),
            "Upload bibliographic export files from Redalyc or AmeliCA in BibTeX (.bib), RIS (.ris), or CSV format. Standardizes Hispanic compound author surnames, journal sources, and keywords."
          ),

          # Main Content
          shiny::div(
            id = "redalycContent",
            shiny::div(
              style = "padding: 15px; background-color: #fafbfc; border: 1px solid #e1e4e8; border-radius: 4px;",
              shiny::fluidRow(
                shiny::column(
                  width = 8,
                  shiny::fileInput(
                    "redalycFile",
                    "Select Redalyc Export File (.bib, .ris, or .csv):",
                    multiple = FALSE,
                    accept = c(".bib", ".ris", ".txt", ".csv"),
                    width = "100%"
                  )
                ),
                shiny::column(
                  width = 4,
                  shiny::div(
                    style = "margin-top: 25px;",
                    shiny::checkboxInput(
                      "redalycNormalizeAuthors",
                      "Normalize Hispanic compound surnames",
                      value = TRUE
                    )
                  )
                )
              ),
              shiny::div(
                style = "margin-top: 10px; display: flex; justify-content: flex-end;",
                shiny::actionButton(
                  "redalycProcessFile",
                  "Process Redalyc File",
                  icon = shiny::icon("cogs"),
                  class = "btn-danger",
                  style = "font-weight: bold; background-color: #d35400; border-color: #ba4a00;"
                )
              )
            )
          )
        )
      )
    ),

    # Results & Preview Section
    shiny::conditionalPanel(
      condition = "output.redalycDataAvailable",
      shiny::fluidRow(
        shiny::column(
          width = 12,
          shiny::wellPanel(
            style = "background-color: #ffffff; border-top: 3px solid #00a65a; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",
            shiny::div(
              style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;",
              shiny::h4("Redalyc Collection Preview & Metrics", style = "font-weight: bold; margin: 0; color: #2c3e50;"),
              shiny::div(
                shiny::downloadButton("redalycDownloadCSV", "Export CSV", class = "btn-sm btn-default"),
                shiny::downloadButton("redalycDownloadRData", "Export .RData", class = "btn-sm btn-info", style = "margin-left: 5px;"),
                shiny::actionButton("redalycLoadToApp", "Load into Biblioshiny", icon = shiny::icon("play"), class = "btn-sm btn-success", style = "margin-left: 10px; font-weight: bold;")
              )
            ),
            shiny::uiOutput("redalycSummaryBoxes"),
            shiny::div(
              style = "margin-top: 15px;",
              shiny::uiOutput("redalycPreviewTable")
            )
          )
        )
      )
    ),

    # JavaScript toggle
    shiny::tags$script(shiny::HTML(
      "$(document).ready(function() {
         var redalycCollapsed = false;
         $('#redalycTogglePanel').on('click', function() {
           redalycCollapsed = !redalycCollapsed;
           $('#redalycContent').slideToggle(300);
           if (redalycCollapsed) {
             $(this).html('<i class=\"fa fa-chevron-down\"></i>');
           } else {
             $(this).html('<i class=\"fa fa-chevron-up\"></i>');
           }
         });
       });"
    ))
  )
}

#' Redalyc Server Logic for Biblioshiny
#'
#' @param input Shiny input.
#' @param output Shiny output.
#' @param session Shiny session.
#' @param values ReactiveValues global state.
#' @keywords internal
#' @export
redalycServer <- function(input, output, session, values) {
  redalyc_data <- shiny::reactiveVal(NULL)

  output$redalycDataAvailable <- shiny::reactive({
    !is.null(redalyc_data()) && nrow(redalyc_data()) > 0
  })
  shiny::outputOptions(output, "redalycDataAvailable", suspendWhenHidden = FALSE)

  shiny::observeEvent(input$redalycProcessFile, {
    file_info <- input$redalycFile
    if (is.null(file_info)) {
      shiny::showModal(shiny::modalDialog(
        title = "No File Selected",
        "Please choose a Redalyc / AmeliCA export file (.bib, .ris, or .csv) to upload.",
        easyClose = TRUE,
        footer = shiny::modalButton("OK")
      ))
      return()
    }

    shiny::withProgress(message = "Processing Redalyc file...", value = 0.5, {
      tryCatch({
        df <- read_redalyc(file_info$datapath, convert = TRUE)

        redalyc_data(df)

        shiny::showNotification(
          sprintf("Successfully parsed %d Redalyc records.", nrow(df)),
          type = "message",
          duration = 5
        )
      }, error = function(e) {
        shiny::showModal(shiny::modalDialog(
          title = "Parsing Error",
          paste("Error processing Redalyc file:", e$message),
          easyClose = TRUE,
          footer = shiny::modalButton("OK")
        ))
      })
    })
  })

  # Render Summary Boxes
  output$redalycSummaryBoxes <- shiny::renderUI({
    df <- redalyc_data()
    shiny::req(df)

    n_docs <- nrow(df)
    unique_authors <- length(unique(unlist(strsplit(df$AU, ";\\s*"))))
    unique_journals <- length(unique(df$SO))

    py_vals <- df$PY[!is.na(df$PY)]
    timespan <- if (length(py_vals) > 0) paste(min(py_vals), "-", max(py_vals)) else "N/A"

    shiny::fluidRow(
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-red",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "TOTAL ARTICLES"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", n_docs)
          )
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-maroon",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "AUTHORS"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", unique_authors)
          )
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-orange",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "JOURNALS"),
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
            shiny::span(class = "info-box-text", "TIMESPAN"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", timespan)
          )
        )
      )
    )
  })

  # Render Preview Table
  output$redalycPreviewTable <- shiny::renderUI({
    df <- redalyc_data()
    shiny::req(df)

    preview_cols <- intersect(c("AU", "TI", "SO", "PY", "DI", "SN", "LA"), names(df))
    preview_df <- utils::head(df[, preview_cols, drop = FALSE], 5)

    shiny::tags$div(
      style = "overflow-x: auto; font-size: 13px;",
      shiny::renderTable(preview_df, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%")
    )
  })

  # Load Dataset Directly into Biblioshiny Global State
  shiny::observeEvent(input$redalycLoadToApp, {
    df <- redalyc_data()
    shiny::req(df)

    initial_fn <- get0("initial", envir = parent.frame(), mode = "function")
    if (is.function(initial_fn)) {
      values <- initial_fn(values)
    }

    M <- df
    merge_fn <- get0("mergeKeywords", envir = parent.frame(), mode = "function")
    if (is.function(merge_fn)) {
      M <- merge_fn(M, force = FALSE)
    }

    values$data_source <- "Redalyc"
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
      "Redalyc collection loaded into Biblioshiny! Analysis menus are now unlocked.",
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
  output$redalycDownloadCSV <- shiny::downloadHandler(
    filename = function() {
      paste0("redalyc_collection_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      shiny::req(redalyc_data())
      utils::write.csv(redalyc_data(), file = file, row.names = FALSE)
    }
  )

  # Export RData
  output$redalycDownloadRData <- shiny::downloadHandler(
    filename = function() {
      paste0("redalyc_collection_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".RData")
    },
    content = function(file) {
      shiny::req(redalyc_data())
      export_biblioshiny(redalyc_data(), file = file)
    }
  )
}
