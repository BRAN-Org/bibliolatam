#' Oasisbr UI Component for Biblioshiny
#'
#' Renders the Oasisbr (IBICT) open-access collection panel
#' compatible with the biblioshiny AdminLTE layout.
#'
#' @return A Shiny tagList containing the UI elements.
#' @keywords internal
#' @export
oasisbrUI <- function() {
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::wellPanel(
          id = "oasisbrPanel",
          style = "background-color: #ffffff; border-top: 3px solid #e67e22; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",

          # Header with branding and collapse button
          shiny::div(
            style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;",
            shiny::div(
              shiny::h3(
                "Oasisbr Collection",
                style = "font-weight: bold; margin: 0; color: #2c3e50; display: inline-block;"
              ),
              shiny::tags$span(
                "IBICT (Brazilian Open Access Portal)",
                class = "label label-warning",
                style = "margin-left: 10px; font-size: 12px; vertical-align: middle; background-color: #e67e22;"
              )
            ),
            shiny::actionButton(
              "oasisbrTogglePanel",
              shiny::icon("chevron-up"),
              class = "btn-sm btn-default",
              style = "padding: 5px 10px;",
              title = "Collapse/Expand"
            )
          ),

          # Info banner
          shiny::div(
            style = "margin-bottom: 20px; padding: 12px 15px; background-color: #fef5e7; border-radius: 4px; border-left: 4px solid #e67e22; color: #7d440b;",
            shiny::icon("globe-americas", style = "margin-right: 8px; font-size: 16px;"),
            shiny::strong("National Open Access Aggregator: "),
            "Search online via the official Oasisbr VuFind API or upload tabular export files (CSV, TSV). Aggregates multidisciplinary production across Brazilian institutional repositories, including articles, theses, dissertations, books, and conference proceedings."
          ),

          # Main Content with Pills
          shiny::div(
            id = "oasisbrContent",
            shiny::tabsetPanel(
              id = "oasisbrModeTabs",
              type = "pills",

              # TAB 1: Online Search & Retrieval
              shiny::tabPanel(
                title = shiny::tagList(shiny::icon("cloud-download-alt"), " Online Search & Retrieval"),
                value = "mode_download",
                shiny::div(
                  style = "margin-top: 15px; padding: 15px; background-color: #fafbfc; border: 1px solid #e1e4e8; border-radius: 4px;",
                  shiny::fluidRow(
                    shiny::column(
                      width = 8,
                      shiny::textInput(
                        "oasisbrSearchQuery",
                        "Search Query (Keywords, Title, Author, or Subject):",
                        placeholder = "Ex: biotecnologia, transicao energetica, saude coletiva",
                        width = "100%"
                      )
                    ),
                    shiny::column(
                      width = 4,
                      shiny::numericInput(
                        "oasisbrSearchLimit",
                        "Max Records to Retrieve:",
                        value = 50,
                        min = 10,
                        max = 500,
                        step = 10,
                        width = "100%"
                      )
                    )
                  ),
                  shiny::fluidRow(
                    shiny::column(
                      width = 6,
                      shiny::selectInput(
                        "oasisbrOnlineDocTypeFilter",
                        "Filter Document Type (DT):",
                        choices = c(
                          "All Types" = "all",
                          "Journal Articles" = "ARTICLE",
                          "Theses & Dissertations" = "THESIS_DISSERTATION",
                          "Books & Chapters" = "BOOK",
                          "Conference Proceedings" = "CONFERENCE"
                        ),
                        selected = "all",
                        width = "100%"
                      )
                    ),
                    shiny::column(
                      width = 6,
                      shiny::div(
                        style = "margin-top: 25px;",
                        shiny::checkboxInput(
                          "oasisbrOnlineNormalizeAuthors",
                          "Normalize Brazilian author names (generational suffixes & particles)",
                          value = TRUE
                        )
                      )
                    )
                  ),
                  shiny::div(
                    style = "margin-top: 10px; display: flex; justify-content: flex-end;",
                    shiny::actionButton(
                      "oasisbrFetchOnline",
                      "Search & Retrieve from Oasisbr",
                      icon = shiny::icon("search"),
                      class = "btn-warning",
                      style = "font-weight: bold; color: #fff; background-color: #e67e22; border-color: #d35400;"
                    )
                  )
                )
              ),

              # TAB 2: Local File Upload
              shiny::tabPanel(
                title = shiny::tagList(shiny::icon("folder-open"), " Local File Upload"),
                value = "mode_upload",
                shiny::div(
                  style = "margin-top: 15px; padding: 15px; background-color: #fafbfc; border: 1px solid #e1e4e8; border-radius: 4px;",
                  shiny::fluidRow(
                    shiny::column(
                      width = 6,
                      shiny::fileInput(
                        "oasisbrFile",
                        "Select Oasisbr Export File (CSV or TSV):",
                        multiple = FALSE,
                        accept = c(".csv", ".tsv", ".txt"),
                        width = "100%"
                      )
                    ),
                    shiny::column(
                      width = 6,
                      shiny::selectInput(
                        "oasisbrDocTypeFilter",
                        "Filter Document Type:",
                        choices = c(
                          "All Types" = "all",
                          "Theses & Dissertations" = "THESIS_DISSERTATION",
                          "Only Theses (Doutorado)" = "THESIS",
                          "Only Dissertations (Mestrado)" = "DISSERTATION"
                        ),
                        selected = "all",
                        width = "100%"
                      )
                    )
                  ),
                  shiny::div(
                    style = "margin-top: 10px; display: flex; justify-content: space-between; align-items: center;",
                    shiny::div(
                      shiny::checkboxInput(
                        "oasisbrNormalizeAuthors",
                        "Normalize Brazilian author names",
                        value = TRUE
                      )
                    ),
                    shiny::actionButton(
                      "oasisbrProcessFile",
                      "Process Oasisbr File",
                      icon = shiny::icon("cogs"),
                      class = "btn-warning",
                      style = "font-weight: bold; color: #fff; background-color: #e67e22; border-color: #d35400;"
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
      condition = "output.oasisbrDataAvailable",
      shiny::fluidRow(
        shiny::column(
          width = 12,
          shiny::wellPanel(
            style = "background-color: #ffffff; border-top: 3px solid #00a65a; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",
            shiny::div(
              style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;",
              shiny::h4("Oasisbr Collection Preview & Metrics", style = "font-weight: bold; margin: 0; color: #2c3e50;"),
              shiny::div(
                shiny::downloadButton("oasisbrDownloadCSV", "Export CSV", class = "btn-sm btn-default"),
                shiny::downloadButton("oasisbrDownloadRData", "Export .RData", class = "btn-sm btn-info", style = "margin-left: 5px;"),
                shiny::actionButton("oasisbrLoadToApp", "Load into Biblioshiny", icon = shiny::icon("play"), class = "btn-sm btn-success", style = "margin-left: 10px; font-weight: bold;")
              )
            ),
            shiny::uiOutput("oasisbrSummaryBoxes"),
            shiny::div(
              style = "margin-top: 15px;",
              shiny::uiOutput("oasisbrPreviewTable")
            )
          )
        )
      )
    ),

    # JavaScript for toggle collapse
    shiny::tags$script(shiny::HTML(
      "$(document).ready(function() {
         var oasisbrCollapsed = false;
         $('#oasisbrTogglePanel').on('click', function() {
           oasisbrCollapsed = !oasisbrCollapsed;
           $('#oasisbrContent').slideToggle(300);
           if (oasisbrCollapsed) {
             $(this).html('<i class=\"fa fa-chevron-down\"></i>');
           } else {
             $(this).html('<i class=\"fa fa-chevron-up\"></i>');
           }
         });
       });"
    ))
  )
}

#' Oasisbr Server Logic for Biblioshiny
#'
#' Connects Oasisbr UI events with package parsers and the biblioshiny reactive state.
#'
#' @param input Shiny input object.
#' @param output Shiny output object.
#' @param session Shiny session object.
#' @param values ReactiveValues object from biblioshiny containing global state.
#' @keywords internal
#' @export
oasisbrServer <- function(input, output, session, values) {
  oasisbr_data <- shiny::reactiveVal(NULL)

  # Check if data is available for preview
  output$oasisbrDataAvailable <- shiny::reactive({
    !is.null(oasisbr_data()) && nrow(oasisbr_data()) > 0
  })
  shiny::outputOptions(output, "oasisbrDataAvailable", suspendWhenHidden = FALSE)

  # Filter helper
  filter_by_dt <- function(df, filter_val) {
    if (identical(filter_val, "all") || !nzchar(filter_val)) return(df)
    if (identical(filter_val, "THESIS_DISSERTATION")) {
      return(df[df$DT %in% c("THESIS", "DISSERTATION"), , drop = FALSE])
    }
    df[df$DT == filter_val, , drop = FALSE]
  }

  # Handle Online Search & Download
  shiny::observeEvent(input$oasisbrFetchOnline, {
    query <- trimws(input$oasisbrSearchQuery)
    if (!nzchar(query)) {
      shiny::showModal(shiny::modalDialog(
        title = "Empty Query",
        "Please enter keywords or a search query to search Oasisbr.",
        easyClose = TRUE,
        footer = shiny::modalButton("OK")
      ))
      return()
    }

    limit <- input$oasisbrSearchLimit
    if (is.null(limit) || is.na(limit) || limit <= 0) {
      limit <- 50L
    }

    dt_filter <- input$oasisbrOnlineDocTypeFilter

    shiny::withProgress(message = "Searching and downloading Oasisbr records...", value = 0.2, {
      tryCatch({
        df <- download_oasisbr(
          query = query,
          limit = limit,
          convert = TRUE,
          progress = FALSE,
          normalize_authors = isTRUE(input$oasisbrOnlineNormalizeAuthors)
        )

        if (nrow(df) == 0L) {
          shiny::showModal(shiny::modalDialog(
            title = "No Records Found",
            "No records matched your search query in Oasisbr.",
            easyClose = TRUE,
            footer = shiny::modalButton("OK")
          ))
          return()
        }

        df <- filter_by_dt(df, dt_filter)

        if (nrow(df) == 0L) {
          shiny::showModal(shiny::modalDialog(
            title = "No Matching Records",
            "Records were found, but none matched the selected document type filter.",
            easyClose = TRUE,
            footer = shiny::modalButton("OK")
          ))
          return()
        }

        oasisbr_data(df)

        shiny::showNotification(
          sprintf("Successfully retrieved and parsed %d Oasisbr records.", nrow(df)),
          type = "message",
          duration = 5
        )
      }, error = function(e) {
        shiny::showModal(shiny::modalDialog(
          title = "Oasisbr Search Error",
          paste("Failed to retrieve records from Oasisbr API:", e$message),
          easyClose = TRUE,
          footer = shiny::modalButton("OK")
        ))
      })
    })
  })

  # Handle Local File Processing
  shiny::observeEvent(input$oasisbrProcessFile, {
    file_info <- input$oasisbrFile
    if (is.null(file_info)) {
      shiny::showModal(shiny::modalDialog(
        title = "No File Selected",
        "Please choose an Oasisbr CSV/TSV export file to upload.",
        easyClose = TRUE,
        footer = shiny::modalButton("OK")
      ))
      return()
    }

    dt_filter <- input$oasisbrDocTypeFilter

    shiny::withProgress(message = "Processing Oasisbr export...", value = 0.5, {
      tryCatch({
        df <- read_oasisbr(file_info$datapath, convert = TRUE)
        df <- filter_by_dt(df, dt_filter)

        if (nrow(df) == 0L) {
          shiny::showModal(shiny::modalDialog(
            title = "No Matching Records",
            "No records matched the selected document type filter.",
            easyClose = TRUE,
            footer = shiny::modalButton("OK")
          ))
          return()
        }

        oasisbr_data(df)

        shiny::showNotification(
          sprintf("Successfully parsed %d Oasisbr records.", nrow(df)),
          type = "message",
          duration = 5
        )
      }, error = function(e) {
        shiny::showModal(shiny::modalDialog(
          title = "Parsing Error",
          paste("Error processing Oasisbr file:", e$message),
          easyClose = TRUE,
          footer = shiny::modalButton("OK")
        ))
      })
    })
  })

  # Render Summary Stat Boxes
  output$oasisbrSummaryBoxes <- shiny::renderUI({
    df <- oasisbr_data()
    shiny::req(df)

    n_docs <- nrow(df)
    unique_authors <- length(unique(unlist(strsplit(df$AU, ";\\s*"))))

    py_vals <- df$PY[!is.na(df$PY)]
    timespan <- if (length(py_vals) > 0) paste(min(py_vals), "-", max(py_vals)) else "N/A"

    unique_sources <- length(unique(df$SO))

    shiny::fluidRow(
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-yellow",
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
          class = "info-box bg-olive",
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
          class = "info-box bg-teal",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "SOURCES / REPOSITORIES"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", unique_sources)
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
  output$oasisbrPreviewTable <- shiny::renderUI({
    df <- oasisbr_data()
    shiny::req(df)

    preview_cols <- intersect(c("AU", "TI", "SO", "PY", "DT", "LA", "UT"), names(df))
    preview_df <- utils::head(df[, preview_cols, drop = FALSE], 5)

    shiny::tags$div(
      style = "overflow-x: auto; font-size: 13px;",
      shiny::renderTable(preview_df, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%")
    )
  })

  # Load Dataset Directly into Biblioshiny Global State
  shiny::observeEvent(input$oasisbrLoadToApp, {
    df <- oasisbr_data()
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

    values$data_source <- "Oasisbr"
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
      "Oasisbr collection loaded into Biblioshiny! Analysis menus are now unlocked.",
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
  output$oasisbrDownloadCSV <- shiny::downloadHandler(
    filename = function() {
      paste0("oasisbr_collection_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      shiny::req(oasisbr_data())
      utils::write.csv(oasisbr_data(), file = file, row.names = FALSE)
    }
  )

  # Export RData
  output$oasisbrDownloadRData <- shiny::downloadHandler(
    filename = function() {
      paste0("oasisbr_collection_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".RData")
    },
    content = function(file) {
      shiny::req(oasisbr_data())
      export_biblioshiny(oasisbr_data(), file = file)
    }
  )
}
