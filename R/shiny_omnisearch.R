#' Omnisearch UI Component for Biblioshiny
#'
#' Renders the Latin American scientific Omnisearch panel compatible with biblioshiny.
#'
#' @param lang Character. Interface language: "en", "pt", or "es". Default is "en".
#' @return A Shiny tag list (\code{shiny.tag.list}) containing UI elements and controls for the Omnisearch panel.
#' @keywords internal
#' @export
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(omnisearchUI())
#'   server <- function(input, output, session) {
#'     omnisearchServer(input, output, session)
#'   }
#'   shinyApp(ui, server)
#' }
omnisearchUI <- function(lang = "en") {
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::wellPanel(
          id = "omnisearchPanel",
          style = "background-color: #ffffff; border-top: 3px solid #00a65a; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",

          # Header
          shiny::div(
            style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px;",
            shiny::div(
              shiny::tags$h3(
                bl_i18n("omni_title", lang),
                `data-i18n` = "omni_title",
                style = "font-weight: bold; margin: 0; color: #2c3e50; display: inline-block;"
              ),
              shiny::tags$span(
                bl_i18n("omni_badge", lang),
                `data-i18n` = "omni_badge",
                class = "label label-success",
                style = "margin-left: 10px; font-size: 12px; vertical-align: middle; background-color: #00a65a;"
              )
            ),
            shiny::actionButton(
              "omnisearchTogglePanel",
              shiny::icon("chevron-up"),
              class = "btn-sm btn-default",
              style = "padding: 5px 10px;",
              title = bl_i18n("btn_collapse", lang)
            )
          ),

          # Info banner
          shiny::div(
            style = "margin-bottom: 20px; padding: 12px 15px; background-color: #f0f9f4; border-radius: 4px; border-left: 4px solid #00a65a; color: #1e5235;",
            shiny::icon("globe", style = "margin-right: 8px; font-size: 16px;"),
            shiny::tags$span(
              bl_i18n("omni_banner", lang),
              `data-i18n` = "omni_banner"
            )
          ),

          # Content
          shiny::div(
            id = "omnisearchContent",
            shiny::fluidRow(
              shiny::column(
                width = 6,
                shiny::tags$label(
                  bl_i18n("omni_query", lang),
                  `data-i18n` = "omni_query",
                  `for` = "omniQuery",
                  style = "font-weight: 600; color: #34495e; margin-bottom: 5px; display: block;"
                ),
                shiny::tags$input(
                  id = "omniQuery",
                  type = "text",
                  class = "form-control",
                  placeholder = bl_i18n("omni_query_ph", lang),
                  `data-i18n-ph` = "omni_query_ph",
                  style = "width: 100%;"
                )
              ),
              shiny::column(
                width = 2,
                shiny::tags$label(
                  bl_i18n("omni_year_start", lang),
                  `data-i18n` = "omni_year_start",
                  `for` = "omniYearStart",
                  style = "font-weight: 600; color: #34495e; margin-bottom: 5px; display: block;"
                ),
                shiny::numericInput(
                  "omniYearStart",
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
                  `for` = "omniYearEnd",
                  style = "font-weight: 600; color: #34495e; margin-bottom: 5px; display: block;"
                ),
                shiny::numericInput(
                  "omniYearEnd",
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
                  bl_i18n("omni_limit", lang),
                  `data-i18n` = "omni_limit",
                  `for` = "omniLimit",
                  style = "font-weight: 600; color: #34495e; margin-bottom: 5px; display: block;"
                ),
                shiny::numericInput(
                  "omniLimit",
                  label = NULL,
                  value = 50,
                  min = 5,
                  max = 300,
                  step = 10,
                  width = "100%"
                )
              )
            ),
            shiny::fluidRow(
              style = "margin-top: 15px;",
              shiny::column(
                width = 7,
                shiny::tags$label(
                  bl_i18n("omni_sources", lang),
                  `data-i18n` = "omni_sources",
                  style = "font-weight: 600; color: #34495e; margin-bottom: 5px; display: block;"
                ),
                shiny::checkboxGroupInput(
                  "omniSources",
                  label = NULL,
                  choices = c(
                    "SciELO (Journal Articles)" = "scielo",
                    "BDTD (Theses & Dissertations)" = "bdtd",
                    "Oasisbr (Brazilian Repositories)" = "oasisbr",
                    "LA Referencia (12 Latin American Countries)" = "lareferencia"
                  ),
                  selected = c("scielo", "bdtd", "oasisbr", "lareferencia"),
                  inline = TRUE
                )
              ),
              shiny::column(
                width = 5,
                shiny::div(
                  style = "margin-top: 5px;",
                  shiny::checkboxInput(
                    "omniDeduplicate",
                    shiny::tags$span(bl_i18n("omni_dedup", lang), `data-i18n` = "omni_dedup"),
                    value = TRUE
                  ),
                  shiny::checkboxInput(
                    "omniEnrichCR",
                    shiny::tags$span(bl_i18n("omni_enrich_cr", lang), `data-i18n` = "omni_enrich_cr"),
                    value = FALSE
                  )
                )
              )
            ),
            shiny::div(
              style = "margin-top: 15px; margin-bottom: 15px; text-align: right;",
              shiny::actionButton(
                "omniSearchBtn",
                label = shiny::tags$span(bl_i18n("omni_search_btn", lang), `data-i18n` = "omni_search_btn"),
                icon = shiny::icon("search"),
                class = "btn-primary btn-lg",
                style = "background-color: #00a65a; border-color: #008d4c; font-weight: bold;"
              )
            ),

            # Metrics cards
            shiny::uiOutput("omniMetricsCards"),

            # Preview Section
            shiny::div(
              style = "margin-top: 20px;",
              shiny::uiOutput("omniPreviewHeader"),
              shiny::uiOutput("omniPreviewControls"),
              shiny::uiOutput("omniPreviewTable"),
              shiny::uiOutput("omniLoadSection")
            )
          )
        )
      )
    )
  )
}

#' Omnisearch Server Logic for Biblioshiny
#'
#' Handles the reactive flow of the Omnisearch engine panel, running multi-source
#' queries, updating metrics, previewing harmonized datasets, and pushing results into `values$M`.
#'
#' @param input Shiny input object.
#' @param output Shiny output object.
#' @param session Shiny session object.
#' @param values Biblioshiny reactive values container.
#' @return No return value, called for side effects (handles reactive queries across multiple Latin American repositories, updates summary metrics, and manages dataset exports).
#' @keywords internal
#' @export
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(omnisearchUI())
#'   server <- function(input, output, session) {
#'     omnisearchServer(input, output, session)
#'   }
#'   shinyApp(ui, server)
#' }
omnisearchServer <- function(input, output, session, values = NULL) {
  omni_data <- shiny::reactiveVal(NULL)
  omni_stats <- shiny::reactiveVal(NULL)
  omni_preview_page <- shiny::reactiveVal(1L)
  omni_preview_source_filter <- shiny::reactiveVal("all")
  omni_preview_page_size <- shiny::reactiveVal(10L)
  omni_preview_search <- shiny::reactiveVal("")

  get_lang <- function() {
    if (!is.null(input$current_lang) && nzchar(input$current_lang)) {
      tolower(input$current_lang)
    } else {
      "en"
    }
  }

  # Toggle panel
  shiny::observeEvent(input$omnisearchTogglePanel, {
    shiny::updateActionButton(
      session,
      "omnisearchTogglePanel",
      icon = if (input$omnisearchTogglePanel %% 2 == 1) shiny::icon("chevron-down") else shiny::icon("chevron-up")
    )
    shiny::removeUI(selector = "#omnisearchContent", immediate = TRUE)
  }, ignoreInit = TRUE)

  # Search execution
  shiny::observeEvent(input$omniSearchBtn, {
    lang <- get_lang()
    q <- trimws(input$omniQuery)
    if (!nzchar(q)) {
      shiny::showNotification(bl_i18n("omni_warn_empty_query", lang), type = "warning")
      return()
    }

    srcs <- input$omniSources
    if (length(srcs) == 0L) {
      shiny::showNotification(bl_i18n("omni_err_select_base", lang), type = "warning")
      return()
    }

    lim <- as.integer(input$omniLimit)
    if (is.na(lim) || lim <= 0L) lim <- 50L
    dedup <- isTRUE(input$omniDeduplicate)
    enrich_cr <- isTRUE(input$omniEnrichCR)

    y_start <- input$omniYearStart
    y_end <- input$omniYearEnd
    years_arg <- NULL
    if (!is.na(y_start) || !is.na(y_end)) {
      ys <- if (!is.na(y_start)) as.integer(y_start) else 1900L
      ye <- if (!is.na(y_end)) as.integer(y_end) else as.integer(format(Sys.Date(), "%Y"))
      years_arg <- c(ys, ye)
    }

    shiny::withProgress(message = bl_i18n("omni_prog_title", lang), value = 0.1, {
      shiny::incProgress(0.2, detail = bl_i18n("omni_prog_querying", lang))

      df_result <- tryCatch(
        {
          omnisearch_bibliolatam(
            query = q,
            sources = srcs,
            limit_per_source = lim,
            years = years_arg,
            enrich_references = enrich_cr,
            deduplicate = dedup,
            progress = FALSE
          )
        },
        error = function(e) {
          shiny::showNotification(sprintf(bl_i18n("omni_err_during_query", lang), e$message), type = "error")
          NULL
        }
      )

      shiny::incProgress(0.5, detail = bl_i18n("omni_prog_harmonizing", lang))

      if (is.null(df_result) || nrow(df_result) == 0L) {
        shiny::showNotification(bl_i18n("omni_warn_no_results", lang), type = "warning")
        omni_data(NULL)
        omni_stats(NULL)
        return()
      }

      shiny::incProgress(0.2, detail = bl_i18n("omni_prog_finalizing", lang))

      omni_data(df_result)
      omni_preview_page(1L)
      omni_preview_source_filter("all")
      omni_preview_search("")

      # Calcular estatisticas
      src_tab <- if ("DB" %in% names(df_result)) table(df_result$DB) else table("ALL" = nrow(df_result))
      src_str <- paste(names(src_tab), as.integer(src_tab), sep = ": ", collapse = " | ")

      stat_obj <- list(
        total = nrow(df_result),
        sources = src_str,
        timespan = if ("PY" %in% names(df_result) && any(!is.na(df_result$PY))) {
          paste0(min(df_result$PY, na.rm = TRUE), " - ", max(df_result$PY, na.rm = TRUE))
        } else {
          "N/A"
        },
        unique_authors = if ("AU" %in% names(df_result)) {
          length(unique(unlist(strsplit(paste(df_result$AU[!is.na(df_result$AU)], collapse = "; "), "; "))))
        } else {
          0
        }
      )
      omni_stats(stat_obj)

      # Inserir no Biblioshiny se aplicavel
      if (!is.null(values)) {
        values$M <- df_result
      }
      shiny::showNotification(
        sprintf(bl_i18n("omni_success_loaded", lang), nrow(df_result)),
        type = "message",
        duration = 5
      )
    })
  })

  # Metrics Cards
  output$omniMetricsCards <- shiny::renderUI({
    st <- omni_stats()
    if (is.null(st)) return(NULL)
    lang <- get_lang()

    shiny::fluidRow(
      style = "margin-top: 15px; margin-bottom: 15px;",
      shiny::column(
        width = 3,
        shiny::div(
          style = "background-color: #00a65a; color: #ffffff; padding: 15px; border-radius: 4px; text-align: center;",
          shiny::h4(bl_i18n("omni_stat_total", lang), style = "margin: 0; font-weight: bold;", `data-i18n` = "omni_stat_total"),
          shiny::h2(st$total, style = "margin: 5px 0 0 0; font-weight: bold;")
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          style = "background-color: #3c8dbc; color: #ffffff; padding: 15px; border-radius: 4px; text-align: center;",
          shiny::h4(bl_i18n("omni_stat_authors", lang), style = "margin: 0; font-weight: bold;", `data-i18n` = "omni_stat_authors"),
          shiny::h2(st$unique_authors, style = "margin: 5px 0 0 0; font-weight: bold;")
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          style = "background-color: #f39c12; color: #ffffff; padding: 15px; border-radius: 4px; text-align: center;",
          shiny::h4(bl_i18n("omni_stat_timespan", lang), style = "margin: 0; font-weight: bold;", `data-i18n` = "omni_stat_timespan"),
          shiny::h2(st$timespan, style = "margin: 5px 0 0 0; font-weight: bold; font-size: 20px; line-height: 38px;")
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          style = "background-color: #605ca8; color: #ffffff; padding: 15px; border-radius: 4px; text-align: center;",
          shiny::h4(bl_i18n("omni_stat_sources", lang), style = "margin: 0; font-weight: bold;", `data-i18n` = "omni_stat_sources"),
          shiny::p(st$sources, style = "margin: 5px 0 0 0; font-size: 13px; font-weight: bold;")
        )
      )
    )
  })

  # Preview Pagination & Filtering Observers
  shiny::observeEvent(input$omniPreviewSourceFilter, {
    if (!is.null(input$omniPreviewSourceFilter)) {
      omni_preview_source_filter(input$omniPreviewSourceFilter)
      omni_preview_page(1L)
    }
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$omniPreviewSearchInput, {
    val <- input$omniPreviewSearchInput
    omni_preview_search(if (is.null(val)) "" else trimws(val))
    omni_preview_page(1L)
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$omniPreviewPageSizeSelect, {
    val <- as.integer(input$omniPreviewPageSizeSelect)
    if (!is.na(val) && val > 0L) {
      omni_preview_page_size(val)
      omni_preview_page(1L)
    }
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$omniPreviewPrevBtn, {
    curr <- omni_preview_page()
    if (curr > 1L) {
      omni_preview_page(curr - 1L)
    }
  })

  shiny::observeEvent(input$omniPreviewNextBtn, {
    df_sub <- preview_filtered_data()
    total_items <- if (is.null(df_sub)) 0L else nrow(df_sub)
    page_size <- omni_preview_page_size()
    total_pages <- max(1L, ceiling(total_items / page_size))
    curr <- omni_preview_page()
    if (curr < total_pages) {
      omni_preview_page(curr + 1L)
    }
  })

  preview_filtered_data <- shiny::reactive({
    df <- omni_data()
    if (is.null(df) || nrow(df) == 0L) return(NULL)

    src_filter <- omni_preview_source_filter()
    if (!is.null(src_filter) && nzchar(src_filter) && src_filter != "all" && "DB" %in% names(df)) {
      df <- df[!is.na(df$DB) & tolower(df$DB) == tolower(src_filter), , drop = FALSE]
    }

    search_term <- omni_preview_search()
    if (!is.null(search_term) && nzchar(search_term)) {
      cols_to_search <- intersect(c("TI", "AU", "SO", "DI"), names(df))
      if (length(cols_to_search) > 0L && nrow(df) > 0L) {
        combined_text <- apply(df[, cols_to_search, drop = FALSE], 1, function(r) {
          paste(r[!is.na(r)], collapse = " ")
        })
        match_idx <- grepl(search_term, combined_text, ignore.case = TRUE)
        df <- df[match_idx, , drop = FALSE]
      }
    }

    df
  })

  output$omniPreviewHeader <- shiny::renderUI({
    df <- omni_data()
    if (is.null(df) || nrow(df) == 0L) return(NULL)
    lang <- get_lang()
    shiny::tags$h4(
      bl_i18n("omni_preview_title", lang),
      `data-i18n` = "omni_preview_title",
      style = "font-weight: bold; color: #2c3e50; margin-bottom: 12px;"
    )
  })

  output$omniPreviewControls <- shiny::renderUI({
    df <- omni_data()
    if (is.null(df) || nrow(df) == 0L) return(NULL)
    lang <- get_lang()

    src_choices <- c("all")
    names(src_choices) <- paste0(bl_i18n("preview_filter_all_sources", lang), " (", nrow(df), ")")

    if ("DB" %in% names(df)) {
      db_tab <- table(df$DB)
      for (s in sort(names(db_tab))) {
        src_choices[[paste0(toupper(s), " (", as.integer(db_tab[[s]]), ")")]] <- s
      }
    }

    shiny::div(
      style = "margin-bottom: 12px; padding: 10px 14px; background-color: #f9f9f9; border: 1px solid #e1e1e1; border-radius: 4px; display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 10px;",
      shiny::div(
        style = "display: flex; align-items: center; gap: 8px; flex-wrap: wrap;",
        shiny::tags$span(shiny::icon("filter"), style = "color: #555;"),
        shiny::selectInput(
          "omniPreviewSourceFilter",
          label = NULL,
          choices = src_choices,
          selected = omni_preview_source_filter(),
          width = "190px"
        ),
        shiny::tags$input(
          id = "omniPreviewSearchInput",
          type = "text",
          class = "form-control input-sm",
          placeholder = bl_i18n("preview_search_ph", lang),
          value = omni_preview_search(),
          onkeyup = "Shiny.setInputValue('omniPreviewSearchInput', this.value);",
          style = "width: 240px; height: 30px;"
        )
      ),
      shiny::div(
        style = "display: flex; align-items: center; gap: 8px;",
        shiny::tags$span(bl_i18n("preview_page_size", lang), style = "font-size: 12px; color: #555; font-weight: 600;"),
        shiny::selectInput(
          "omniPreviewPageSizeSelect",
          label = NULL,
          choices = c("5" = 5, "10" = 10, "20" = 20, "50" = 50),
          selected = omni_preview_page_size(),
          width = "75px"
        ),
        shiny::actionButton(
          "omniPreviewPrevBtn",
          label = NULL,
          icon = shiny::icon("chevron-left"),
          class = "btn-sm btn-default",
          style = "padding: 4px 8px;",
          title = bl_i18n("preview_btn_prev", lang)
        ),
        shiny::uiOutput("omniPreviewPageInfoText", inline = TRUE),
        shiny::actionButton(
          "omniPreviewNextBtn",
          label = NULL,
          icon = shiny::icon("chevron-right"),
          class = "btn-sm btn-default",
          style = "padding: 4px 8px;",
          title = bl_i18n("preview_btn_next", lang)
        )
      )
    )
  })

  output$omniPreviewPageInfoText <- shiny::renderUI({
    df_sub <- preview_filtered_data()
    total_items <- if (is.null(df_sub)) 0L else nrow(df_sub)
    page_size <- omni_preview_page_size()
    total_pages <- max(1L, ceiling(total_items / page_size))
    curr_page <- min(omni_preview_page(), total_pages)
    lang <- get_lang()

    shiny::tags$span(
      sprintf(bl_i18n("preview_page_label", lang), curr_page, total_pages, total_items),
      style = "font-size: 12px; font-weight: 600; color: #333; margin: 0 4px;"
    )
  })

  output$omniPreviewTable <- shiny::renderUI({
    df_sub <- preview_filtered_data()
    if (is.null(df_sub) || nrow(df_sub) == 0L) {
      lang <- get_lang()
      return(
        shiny::div(
          style = "padding: 20px; text-align: center; color: #777; background: #fafafa; border: 1px dashed #ddd; border-radius: 4px;",
          shiny::icon("info-circle", style = "margin-right: 6px;"),
          bl_i18n("preview_no_match", lang)
        )
      )
    }

    disp_cols <- intersect(c("TI", "AU", "SO", "PY", "DB", "DI"), names(df_sub))
    page_size <- omni_preview_page_size()
    total_items <- nrow(df_sub)
    total_pages <- max(1L, ceiling(total_items / page_size))
    curr_page <- min(omni_preview_page(), total_pages)

    start_idx <- (curr_page - 1L) * page_size + 1L
    end_idx <- min(curr_page * page_size, total_items)

    slice_df <- df_sub[start_idx:end_idx, disp_cols, drop = FALSE]

    shiny::tags$div(
      style = "overflow-x: auto; font-size: 13px;",
      shiny::renderTable(slice_df, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%")
    )
  })

  output$omniLoadSection <- shiny::renderUI({
    df <- omni_data()
    if (is.null(df) || nrow(df) == 0L) return(NULL)
    lang <- get_lang()

    shiny::div(
      style = "margin-top: 15px; display: flex; justify-content: flex-end; gap: 10px;",
      shiny::downloadButton(
        "omniDownloadCSV",
        label = shiny::tags$span(bl_i18n("download_csv", lang), `data-i18n` = "download_csv"),
        class = "btn-info btn-sm"
      ),
      shiny::downloadButton(
        "omniDownloadRData",
        label = shiny::tags$span(bl_i18n("export_rdata", lang), `data-i18n` = "export_rdata"),
        class = "btn-success btn-sm"
      ),
      shiny::actionButton(
        "omniReloadBiblioshinyBtn",
        label = shiny::tags$span(bl_i18n("reload_biblioshiny", lang), `data-i18n` = "reload_biblioshiny"),
        icon = shiny::icon("sync"),
        class = "btn-default btn-sm"
      )
    )
  })

  output$omniDownloadCSV <- shiny::downloadHandler(
    filename = function() {
      paste0("omnisearch_results_", format(Sys.Date(), "%Y%m%d"), ".csv")
    },
    content = function(file) {
      df <- omni_data()
      if (!is.null(df)) {
        utils::write.csv(df, file, row.names = FALSE, na = "")
      }
    }
  )

  output$omniDownloadRData <- shiny::downloadHandler(
    filename = function() {
      paste0("omnisearch_results_", format(Sys.Date(), "%Y%m%d"), ".RData")
    },
    content = function(file) {
      M <- omni_data()
      if (!is.null(M)) {
        save(M, file = file)
      }
    }
  )

  # Push to Biblioshiny manually
  shiny::observeEvent(input$omniReloadBiblioshinyBtn, {
    df <- omni_data()
    lang <- get_lang()
    if (!is.null(df) && nrow(df) > 0L) {
      if (!is.null(values)) {
        values$M <- df
      }
      shiny::showNotification(
        sprintf(bl_i18n("omni_success_loaded", lang), nrow(df)),
        type = "message"
      )
    }
  })
}
