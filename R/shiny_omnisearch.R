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
              title = bl_i18n("btn_collapse", lang),
              `data-i18n-title` = "btn_collapse"
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

            # Action bar: Advanced Settings toggle (left) + Search button (right)
            shiny::div(
              style = "margin-top: 15px; margin-bottom: 12px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;",
              shiny::tags$button(
                id = "omniToggleAdvanced",
                type = "button",
                class = "btn btn-default",
                style = "font-weight: 600; color: #34495e; border-color: #cbd5e1;",
                shiny::icon("sliders-h"),
                " ",
                shiny::tags$span(bl_i18n("omni_adv_toggle", lang), `data-i18n` = "omni_adv_toggle"),
                " ",
                shiny::tags$i(id = "omniAdvancedChevron", class = "fa fa-chevron-down", style = "margin-left: 4px; font-size: 11px;")
              ),
              shiny::actionButton(
                "omniSearchBtn",
                label = shiny::tags$span(bl_i18n("omni_search_btn", lang), `data-i18n` = "omni_search_btn"),
                icon = shiny::icon("search"),
                class = "btn-primary btn-lg",
                style = "background-color: #00a65a; border-color: #008d4c; font-weight: bold;"
              )
            ),

            # Collapsible Advanced Settings Drawer (hidden by default)
            shiny::div(
              id = "omniAdvancedPanel",
              style = "display: none; margin-bottom: 18px; padding: 16px; background-color: #f8fafc; border: 1px solid #d9e2ec; border-left: 4px solid #3c8dbc; border-radius: 4px;",
              shiny::fluidRow(
                # Block A: Entity Resolution & Deduplication
                shiny::column(
                  width = 4,
                  shiny::tags$h5(
                    shiny::icon("object-group", style = "margin-right: 6px; color: #3c8dbc;"),
                    shiny::tags$span(bl_i18n("omni_adv_sec_merge", lang), `data-i18n` = "omni_adv_sec_merge"),
                    style = "font-weight: bold; color: #2c3e50; margin-top: 0; border-bottom: 1px solid #e2e8f0; padding-bottom: 6px;"
                  ),
                  shiny::tags$label(
                    bl_i18n("omni_adv_match_by", lang),
                    `data-i18n` = "omni_adv_match_by",
                    style = "font-weight: 600; font-size: 12px; color: #34495e; display: block;"
                  ),
                  shiny::checkboxGroupInput(
                    "omniMatchBy",
                    label = NULL,
                    choices = c("Canonical DOI" = "doi", "Fuzzy Title" = "title"),
                    selected = c("doi", "title"),
                    inline = TRUE
                  ),
                  shiny::tags$label(
                    bl_i18n("omni_adv_threshold", lang),
                    `data-i18n` = "omni_adv_threshold",
                    `for` = "omniSimilarityThreshold",
                    style = "font-weight: 600; font-size: 12px; color: #34495e; display: block; margin-top: 6px;"
                  ),
                  shiny::sliderInput(
                    "omniSimilarityThreshold",
                    label = NULL,
                    min = 0.80,
                    max = 1.00,
                    value = 0.90,
                    step = 0.02,
                    width = "100%"
                  ),
                  shiny::checkboxInput(
                    "omniNormalizeAuthors",
                    shiny::tags$span(bl_i18n("omni_adv_norm_au", lang), `data-i18n` = "omni_adv_norm_au"),
                    value = TRUE
                  )
                ),

                # Block B: Corpus Quality Filters
                shiny::column(
                  width = 4,
                  shiny::tags$h5(
                    shiny::icon("filter", style = "margin-right: 6px; color: #3c8dbc;"),
                    shiny::tags$span(bl_i18n("omni_adv_sec_filters", lang), `data-i18n` = "omni_adv_sec_filters"),
                    style = "font-weight: bold; color: #2c3e50; margin-top: 0; border-bottom: 1px solid #e2e8f0; padding-bottom: 6px;"
                  ),
                  shiny::tags$label(
                    bl_i18n("omni_adv_doc_types", lang),
                    `data-i18n` = "omni_adv_doc_types",
                    style = "font-weight: 600; font-size: 12px; color: #34495e; display: block;"
                  ),
                  shiny::checkboxGroupInput(
                    "omniDocTypeFilter",
                    label = NULL,
                    choices = c(
                      "Article" = "ARTICLE",
                      "Thesis" = "THESIS",
                      "Dissertation" = "DISSERTATION",
                      "Book" = "BOOK",
                      "Conference" = "CONFERENCE"
                    ),
                    selected = character(0L),
                    inline = TRUE
                  ),
                  shiny::tags$label(
                    bl_i18n("omni_adv_languages", lang),
                    `data-i18n` = "omni_adv_languages",
                    style = "font-weight: 600; font-size: 12px; color: #34495e; display: block; margin-top: 6px;"
                  ),
                  shiny::checkboxGroupInput(
                    "omniLanguageFilter",
                    label = NULL,
                    choices = c(
                      "Portuguese" = "PORTUGUESE",
                      "Spanish" = "SPANISH",
                      "English" = "ENGLISH"
                    ),
                    selected = character(0L),
                    inline = TRUE
                  ),
                  shiny::div(
                    style = "margin-top: 6px;",
                    shiny::checkboxInput(
                      "omniRequireDoi",
                      shiny::tags$span(bl_i18n("omni_adv_req_doi", lang), `data-i18n` = "omni_adv_req_doi"),
                      value = FALSE
                    ),
                    shiny::checkboxInput(
                      "omniRequireAbstract",
                      shiny::tags$span(bl_i18n("omni_adv_req_ab", lang), `data-i18n` = "omni_adv_req_ab"),
                      value = FALSE
                    )
                  )
                ),

                # Block C: SciELO Collections, Network & Export
                shiny::column(
                  width = 4,
                  shiny::tags$h5(
                    shiny::icon("globe-americas", style = "margin-right: 6px; color: #3c8dbc;"),
                    shiny::tags$span(bl_i18n("omni_adv_sec_network", lang), `data-i18n` = "omni_adv_sec_network"),
                    style = "font-weight: bold; color: #2c3e50; margin-top: 0; border-bottom: 1px solid #e2e8f0; padding-bottom: 6px;"
                  ),
                  shiny::tags$label(
                    bl_i18n("omni_adv_scielo_col", lang),
                    `data-i18n` = "omni_adv_scielo_col",
                    style = "font-weight: 600; font-size: 12px; color: #34495e; display: block;"
                  ),
                  shiny::checkboxGroupInput(
                    "omniScieloCollections",
                    label = NULL,
                    choices = c(
                      "BR (10.1590)" = "br",
                      "CL (10.4067)" = "cl",
                      "ES (10.4321)" = "es",
                      "CR (10.15517)" = "cr",
                      "PE (10.17843)" = "pe",
                      "UY (10.26461)" = "uy"
                    ),
                    selected = c("br", "cl", "es", "cr", "pe", "uy"),
                    inline = TRUE
                  ),
                  shiny::tags$label(
                    bl_i18n("omni_adv_timeout", lang),
                    `data-i18n` = "omni_adv_timeout",
                    `for` = "omniTimeout",
                    style = "font-weight: 600; font-size: 12px; color: #34495e; display: block; margin-top: 6px;"
                  ),
                  shiny::numericInput(
                    "omniTimeout",
                    label = NULL,
                    value = 30,
                    min = 10,
                    max = 120,
                    step = 5,
                    width = "100%"
                  ),
                  shiny::tags$label(
                    bl_i18n("omni_adv_csv_sep", lang),
                    `data-i18n` = "omni_adv_csv_sep",
                    style = "font-weight: 600; font-size: 12px; color: #34495e; display: block; margin-top: 4px;"
                  ),
                  shiny::radioButtons(
                    "omniCsvSep",
                    label = NULL,
                    choices = c("Comma (,)" = ",", "Semicolon (;)" = ";"),
                    selected = ",",
                    inline = TRUE
                  ),
                  shiny::checkboxInput(
                    "omniCsvBom",
                    shiny::tags$span(bl_i18n("omni_adv_csv_bom", lang), `data-i18n` = "omni_adv_csv_bom"),
                    value = FALSE
                  )
                )
              ),
              shiny::div(
                style = "margin-top: 8px; padding-top: 8px; border-top: 1px solid #e2e8f0; text-align: right;",
                shiny::actionButton(
                  "omniResetAdvancedBtn",
                  label = shiny::tags$span(bl_i18n("omni_adv_reset", lang), `data-i18n` = "omni_adv_reset"),
                  icon = shiny::icon("undo"),
                  class = "btn-default btn-xs"
                )
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
    ),

    # JavaScript for reversible panel collapse and Advanced Settings drawer toggle
    shiny::tags$script(shiny::HTML(
      "$(document).ready(function() {
         var omniCollapsed = false;
         $(document).off('click.omnisearchToggle', '#omnisearchTogglePanel').on('click.omnisearchToggle', '#omnisearchTogglePanel', function() {
           omniCollapsed = !omniCollapsed;
           $('#omnisearchContent').slideToggle(300);
           if (omniCollapsed) {
             $(this).html('<i class=\"fa fa-chevron-down\"></i>');
           } else {
             $(this).html('<i class=\"fa fa-chevron-up\"></i>');
           }
         });

         var advOpen = false;
         $(document).off('click.omniAdvToggle', '#omniToggleAdvanced').on('click.omniAdvToggle', '#omniToggleAdvanced', function() {
           advOpen = !advOpen;
           $('#omniAdvancedPanel').slideToggle(250);
           var chev = $('#omniAdvancedChevron');
           if (advOpen) {
             chev.removeClass('fa-chevron-down').addClass('fa-chevron-up');
           } else {
             chev.removeClass('fa-chevron-up').addClass('fa-chevron-down');
           }
         });
       });"
    ))
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

  # Reset Advanced Settings to defaults
  shiny::observeEvent(input$omniResetAdvancedBtn, {
    lang <- get_lang()
    shiny::updateCheckboxGroupInput(session, "omniMatchBy", selected = c("doi", "title"))
    shiny::updateSliderInput(session, "omniSimilarityThreshold", value = 0.90)
    shiny::updateCheckboxInput(session, "omniNormalizeAuthors", value = TRUE)
    shiny::updateCheckboxGroupInput(session, "omniDocTypeFilter", selected = character(0L))
    shiny::updateCheckboxGroupInput(session, "omniLanguageFilter", selected = character(0L))
    shiny::updateCheckboxInput(session, "omniRequireDoi", value = FALSE)
    shiny::updateCheckboxInput(session, "omniRequireAbstract", value = FALSE)
    shiny::updateCheckboxGroupInput(
      session,
      "omniScieloCollections",
      selected = c("br", "cl", "es", "cr", "pe", "uy")
    )
    shiny::updateNumericInput(session, "omniTimeout", value = 30)
    shiny::updateRadioButtons(session, "omniCsvSep", selected = ",")
    shiny::updateCheckboxInput(session, "omniCsvBom", value = FALSE)
    shiny::showNotification(bl_i18n("omni_adv_reset_ok", lang), type = "message", duration = 3)
  })

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

    # Advanced settings with safe defaults
    match_by_arg <- input$omniMatchBy
    if (is.null(match_by_arg) || length(match_by_arg) == 0L) {
      match_by_arg <- c("doi", "title")
    }

    sim_thresh_arg <- suppressWarnings(as.numeric(input$omniSimilarityThreshold))
    if (length(sim_thresh_arg) != 1L || is.na(sim_thresh_arg) || sim_thresh_arg <= 0 || sim_thresh_arg > 1) {
      sim_thresh_arg <- 0.90
    }

    norm_au_arg <- if (is.null(input$omniNormalizeAuthors)) TRUE else isTRUE(input$omniNormalizeAuthors)

    scielo_col_arg <- input$omniScieloCollections
    if (is.null(scielo_col_arg) || length(scielo_col_arg) == 0L) {
      scielo_col_arg <- c("br", "cl", "es", "cr", "pe", "uy")
    }

    timeout_arg <- suppressWarnings(as.numeric(input$omniTimeout))
    if (length(timeout_arg) != 1L || is.na(timeout_arg) || timeout_arg < 10) {
      timeout_arg <- 30
    }

    doc_types_arg <- input$omniDocTypeFilter
    if (length(doc_types_arg) == 0L) doc_types_arg <- NULL

    langs_arg <- input$omniLanguageFilter
    if (length(langs_arg) == 0L) langs_arg <- NULL

    req_doi_arg <- isTRUE(input$omniRequireDoi)
    req_ab_arg <- isTRUE(input$omniRequireAbstract)

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
            progress = FALSE,
            timeout = timeout_arg,
            match_by = match_by_arg,
            similarity_threshold = sim_thresh_arg,
            normalize_authors = norm_au_arg,
            scielo_collections = scielo_col_arg,
            doc_types = doc_types_arg,
            languages = langs_arg,
            require_doi = req_doi_arg,
            require_abstract = req_ab_arg
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
    raw_df <- omni_data()
    if (is.null(raw_df) || nrow(raw_df) == 0L) return(NULL)

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
        csv_sep <- if (!is.null(input$omniCsvSep) && identical(input$omniCsvSep, ";")) ";" else ","
        use_bom <- isTRUE(input$omniCsvBom)
        if (use_bom) {
          tmp_csv <- tempfile(fileext = ".csv")
          on.exit(unlink(tmp_csv), add = TRUE)
          utils::write.table(
            df,
            file = tmp_csv,
            sep = csv_sep,
            row.names = FALSE,
            col.names = TRUE,
            qmethod = "double",
            na = ""
          )
          raw_csv <- readBin(tmp_csv, what = "raw", n = file.info(tmp_csv)$size)
          bom_bytes <- as.raw(c(0xef, 0xbb, 0xbf))
          con <- file(file, open = "wb")
          on.exit(close(con), add = TRUE)
          writeBin(c(bom_bytes, raw_csv), con)
        } else {
          utils::write.table(
            df,
            file = file,
            sep = csv_sep,
            row.names = FALSE,
            col.names = TRUE,
            qmethod = "double",
            na = ""
          )
        }
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
