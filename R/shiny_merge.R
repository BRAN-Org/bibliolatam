#' Bibliolatam Merge UI Component for Biblioshiny
#'
#' Renders the Cross-Database Deduplication & Merge panel compatible with biblioshiny.
#'
#' @return A Shiny tagList containing UI elements.
#' @keywords internal
#' @export
bibliolatamMergeUI <- function() {
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::wellPanel(
          id = "bibliolatamMergePanel",
          style = "background-color: #ffffff; border-top: 3px solid #605ca8; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",

          # Header
          shiny::div(
            style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;",
            shiny::div(
              shiny::h3(
                "Cross-Database Merge & Deduplication",
                style = "font-weight: bold; margin: 0; color: #2c3e50; display: inline-block;"
              ),
              shiny::tags$span(
                "Bibliolatam Engine",
                class = "label label-primary",
                style = "margin-left: 10px; font-size: 12px; vertical-align: middle; background-color: #605ca8;"
              )
            ),
            shiny::actionButton(
              "bibliolatamMergeTogglePanel",
              shiny::icon("chevron-up"),
              class = "btn-sm btn-default",
              style = "padding: 5px 10px;",
              title = "Collapse/Expand"
            )
          ),

          # Info banner
          shiny::div(
            style = "margin-bottom: 20px; padding: 12px 15px; background-color: #f4f0fa; border-radius: 4px; border-left: 4px solid #605ca8; color: #3d246c;",
            shiny::icon("object-group", style = "margin-right: 8px; font-size: 16px;"),
            shiny::strong("Harmonize & Fuse Latin American Collections: "),
            "Merge two datasets (e.g. SciELO + Oasisbr or SciELO + SPELL), automatically resolve duplicate records using canonical DOI cleaning and fuzzy title matching, and enrich complementary fields (Cited References, Abstracts, Keywords)."
          ),

          # Content
          shiny::div(
            id = "bibliolatamMergeContent",
            shiny::div(
              style = "padding: 15px; background-color: #fafbfc; border: 1px solid #e1e4e8; border-radius: 4px;",
              shiny::fluidRow(
                shiny::column(
                  width = 6,
                  shiny::h4("Dataset 1 (Primary / Base)", style = "font-weight: bold; color: #2c3e50; margin-top: 0;"),
                  shiny::radioButtons(
                    "mergeSource1",
                    "Choose Source for Dataset 1:",
                    choices = c(
                      "Currently Loaded Collection in App" = "active",
                      "Upload New File (.csv, .RData, .tsv, .bib, .ris)" = "file"
                    ),
                    selected = "active"
                  ),
                  shiny::conditionalPanel(
                    condition = "input.mergeSource1 == 'file'",
                    shiny::fileInput("mergeFile1", "Select Dataset 1 File:", width = "100%")
                  )
                ),
                shiny::column(
                  width = 6,
                  shiny::h4("Dataset 2 (To Merge & Fuse)", style = "font-weight: bold; color: #2c3e50; margin-top: 0;"),
                  shiny::fileInput(
                    "mergeFile2",
                    "Select Dataset 2 File (.csv, .RData, .tsv, .bib, .ris):",
                    width = "100%"
                  )
                )
              ),
              shiny::hr(style = "margin: 15px 0; border-top: 1px solid #eee;"),
              shiny::fluidRow(
                shiny::column(
                  width = 6,
                  shiny::checkboxGroupInput(
                    "mergeMatchCriteria",
                    "Matching & Deduplication Criteria:",
                    choices = c("Canonical Clean DOI" = "doi", "Fuzzy Title Matching" = "title"),
                    selected = c("doi", "title"),
                    inline = TRUE
                  )
                ),
                shiny::column(
                  width = 6,
                  shiny::sliderInput(
                    "mergeSimilarityThreshold",
                    "Title Similarity Threshold:",
                    min = 0.80,
                    max = 1.00,
                    value = 0.90,
                    step = 0.02,
                    width = "100%"
                  )
                )
              ),
              shiny::div(
                style = "margin-top: 10px; display: flex; justify-content: flex-end;",
                shiny::actionButton(
                  "mergeRunAction",
                  "Merge & Deduplicate Collections",
                  icon = shiny::icon("random"),
                  class = "btn-primary",
                  style = "font-weight: bold; background-color: #605ca8; border-color: #4b4691;"
                )
              )
            )
          )
        )
      )
    ),

    # Results & Preview Section
    shiny::conditionalPanel(
      condition = "output.bibliolatamMergeDataAvailable",
      shiny::fluidRow(
        shiny::column(
          width = 12,
          shiny::wellPanel(
            style = "background-color: #ffffff; border-top: 3px solid #00a65a; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",
            shiny::div(
              style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;",
              shiny::h4("Merged Collection Metrics & Diagnostics", style = "font-weight: bold; margin: 0; color: #2c3e50;"),
              shiny::div(
                shiny::downloadButton("mergeDownloadCSV", "Export CSV", class = "btn-sm btn-default"),
                shiny::downloadButton("mergeDownloadRData", "Export .RData", class = "btn-sm btn-info", style = "margin-left: 5px;"),
                shiny::actionButton("mergeLoadToApp", "Load into Biblioshiny", icon = shiny::icon("play"), class = "btn-sm btn-success", style = "margin-left: 10px; font-weight: bold;")
              )
            ),
            shiny::uiOutput("bibliolatamMergeSummaryBoxes"),
            shiny::div(
              style = "margin-top: 15px;",
              shiny::uiOutput("bibliolatamMergePreviewTable")
            )
          )
        )
      )
    ),

    # JavaScript toggle
    shiny::tags$script(shiny::HTML(
      "$(document).ready(function() {
         var mergeCollapsed = false;
         $('#bibliolatamMergeTogglePanel').on('click', function() {
           mergeCollapsed = !mergeCollapsed;
           $('#bibliolatamMergeContent').slideToggle(300);
           if (mergeCollapsed) {
             $(this).html('<i class=\"fa fa-chevron-down\"></i>');
           } else {
             $(this).html('<i class=\"fa fa-chevron-up\"></i>');
           }
         });
       });"
    ))
  )
}

#' Helper to load arbitrary supported file into data frame
#' @noRd
load_any_latam_file <- function(file_path) {
  ext <- tolower(tools::file_ext(file_path))
  if (ext %in% c("rdata", "rda")) {
    env <- new.env()
    load(file_path, envir = env)
    objs <- ls(env)
    for (o in objs) {
      if (is.data.frame(env[[o]])) return(env[[o]])
    }
    stop("Nenhum data.frame encontrado no arquivo .RData.", call. = FALSE)
  } else if (ext %in% c("bib", "ris")) {
    return(read_redalyc(file_path, convert = TRUE))
  } else {
    # Tenta read_scielo primeiro, senao read_bdtd
    res <- tryCatch(
      read_scielo(file_path, convert = TRUE),
      error = function(e1) {
        tryCatch(
          read_bdtd(file_path, convert = TRUE),
          error = function(e2) {
            read_spell(file_path, convert = TRUE)
          }
        )
      }
    )
    return(res)
  }
}

#' Bibliolatam Merge Server Logic for Biblioshiny
#'
#' @param input Shiny input.
#' @param output Shiny output.
#' @param session Shiny session.
#' @param values ReactiveValues global state.
#' @keywords internal
#' @export
bibliolatamMergeServer <- function(input, output, session, values) {
  merged_dataset <- shiny::reactiveVal(NULL)

  output$bibliolatamMergeDataAvailable <- shiny::reactive({
    !is.null(merged_dataset()) && nrow(merged_dataset()) > 0
  })
  shiny::outputOptions(output, "bibliolatamMergeDataAvailable", suspendWhenHidden = FALSE)

  shiny::observeEvent(input$mergeRunAction, {
    # 1. Obter df1
    df1 <- NULL
    if (identical(input$mergeSource1, "active")) {
      if (is.null(values$M) || !is.data.frame(values$M) || nrow(values$M) == 0) {
        shiny::showModal(shiny::modalDialog(
          title = "No Active Collection",
          "There is no active collection loaded into the app. Please load a collection first or select 'Upload New File'.",
          easyClose = TRUE,
          footer = shiny::modalButton("OK")
        ))
        return()
      }
      df1 <- values$M
    } else {
      file1 <- input$mergeFile1
      if (is.null(file1)) {
        shiny::showModal(shiny::modalDialog(
          title = "File Missing",
          "Please choose a file for Dataset 1.",
          easyClose = TRUE,
          footer = shiny::modalButton("OK")
        ))
        return()
      }
      tryCatch({
        df1 <- load_any_latam_file(file1$datapath)
      }, error = function(e) {
        shiny::showModal(shiny::modalDialog(title = "Error Loading Dataset 1", e$message, easyClose = TRUE))
        return()
      })
    }

    # 2. Obter df2
    file2 <- input$mergeFile2
    if (is.null(file2)) {
      shiny::showModal(shiny::modalDialog(
        title = "Dataset 2 Missing",
        "Please select a file to merge as Dataset 2.",
        easyClose = TRUE,
        footer = shiny::modalButton("OK")
      ))
      return()
    }
    df2 <- NULL
    tryCatch({
      df2 <- load_any_latam_file(file2$datapath)
    }, error = function(e) {
      shiny::showModal(shiny::modalDialog(title = "Error Loading Dataset 2", e$message, easyClose = TRUE))
      return()
    })

    if (is.null(df1) || is.null(df2)) return()

    match_by <- input$mergeMatchCriteria
    if (length(match_by) == 0) match_by <- c("doi", "title")
    threshold <- input$mergeSimilarityThreshold

    shiny::withProgress(message = "Merging and deduplicating collections...", value = 0.5, {
      tryCatch({
        merged <- merge_bibliolatam(
          df1 = df1,
          df2 = df2,
          match_by = match_by,
          similarity_threshold = threshold,
          verbose = FALSE
        )

        merged_dataset(merged)

        stats <- attr(merged, "merge_stats")
        shiny::showNotification(
          sprintf("Merge complete: %d records in Dataset 1 + %d in Dataset 2 -> %d unique merged records (%d duplicates resolved).",
                  stats$n1, stats$n2, stats$final_count, stats$total_duplicates),
          type = "message",
          duration = 6
        )
      }, error = function(e) {
        shiny::showModal(shiny::modalDialog(
          title = "Merge Error",
          paste("Failed to merge collections:", e$message),
          easyClose = TRUE,
          footer = shiny::modalButton("OK")
        ))
      })
    })
  })

  # Render Summary Boxes
  output$bibliolatamMergeSummaryBoxes <- shiny::renderUI({
    df <- merged_dataset()
    shiny::req(df)
    stats <- attr(df, "merge_stats")
    if (is.null(stats)) stats <- list(n1 = nrow(df), n2 = 0, doi_duplicates = 0, title_duplicates = 0, total_duplicates = 0, final_count = nrow(df))

    shiny::fluidRow(
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-purple",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "INITIAL COMBINED"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", stats$n1 + stats$n2)
          )
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-yellow",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "DUPLICATES RESOLVED"),
            shiny::span(class = "info-box-number", style = "font-size: 16px; font-weight: bold;",
                        sprintf("Total: %d (DOI: %d | Title: %d)", stats$total_duplicates, stats$doi_duplicates, stats$title_duplicates))
          )
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-green",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "FINAL UNIQUE WORKS"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", stats$final_count)
          )
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          class = "info-box bg-teal",
          style = "border-radius: 4px; padding: 10px;",
          shiny::div(class = "info-box-content",
            shiny::span(class = "info-box-text", "SOURCES FUSED"),
            shiny::span(class = "info-box-number", style = "font-size: 24px; font-weight: bold;", length(unique(df$DB)))
          )
        )
      )
    )
  })

  # Render Table Preview
  output$bibliolatamMergePreviewTable <- shiny::renderUI({
    df <- merged_dataset()
    shiny::req(df)

    preview_cols <- intersect(c("AU", "TI", "SO", "PY", "DI", "DB"), names(df))
    preview_df <- utils::head(df[, preview_cols, drop = FALSE], 6)

    shiny::tags$div(
      style = "overflow-x: auto; font-size: 13px;",
      shiny::renderTable(preview_df, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%")
    )
  })

  # Load Merged Collection into App
  shiny::observeEvent(input$mergeLoadToApp, {
    df <- merged_dataset()
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

    values$data_source <- "Bibliolatam_Merged"
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
      "Merged collection loaded into Biblioshiny! Analysis menus are now unlocked.",
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
  output$mergeDownloadCSV <- shiny::downloadHandler(
    filename = function() {
      paste0("merged_latam_collection_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".csv")
    },
    content = function(file) {
      shiny::req(merged_dataset())
      utils::write.csv(merged_dataset(), file = file, row.names = FALSE)
    }
  )

  # Export RData
  output$mergeDownloadRData <- shiny::downloadHandler(
    filename = function() {
      paste0("merged_latam_collection_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".RData")
    },
    content = function(file) {
      shiny::req(merged_dataset())
      export_biblioshiny(merged_dataset(), file = file)
    }
  )
}
