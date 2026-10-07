#' Omnisearch UI Component for Biblioshiny
#'
#' Renders the Latin American scientific Omnisearch panel compatible with biblioshiny.
#'
#' @return A Shiny tagList containing UI elements.
#' @keywords internal
#' @export
omnisearchUI <- function() {
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
              shiny::h3(
                "Latin American Omnisearch Engine",
                style = "font-weight: bold; margin: 0; color: #2c3e50; display: inline-block;"
              ),
              shiny::tags$span(
                "Federated Multi-Source Discovery",
                class = "label label-success",
                style = "margin-left: 10px; font-size: 12px; vertical-align: middle; background-color: #00a65a;"
              )
            ),
            shiny::actionButton(
              "omnisearchTogglePanel",
              shiny::icon("chevron-up"),
              class = "btn-sm btn-default",
              style = "padding: 5px 10px;",
              title = "Collapse/Expand"
            )
          ),

          # Info banner
          shiny::div(
            style = "margin-bottom: 20px; padding: 12px 15px; background-color: #f0f9f4; border-radius: 4px; border-left: 4px solid #00a65a; color: #1e5235;",
            shiny::icon("globe", style = "margin-right: 8px; font-size: 16px;"),
            shiny::strong("Unified Latin American Search: "),
            "Query SciELO, BDTD, Oasisbr, and LA Referencia simultaneously in a single operation. The engine queries each official repository, normalizes records into canonical bibliometrix format, and automatically fuses and deduplicates duplicate entries."
          ),

          # Content
          shiny::div(
            id = "omnisearchContent",
            shiny::fluidRow(
              shiny::column(
                width = 8,
                shiny::textInput(
                  "omniQuery",
                  "Search Query / Termos de Busca:",
                  placeholder = "e.g. \"inteligencia artificial\" OR \"saude coletiva\"",
                  width = "100%"
                )
              ),
              shiny::column(
                width = 4,
                shiny::numericInput(
                  "omniLimit",
                  "Max records per database:",
                  value = 50,
                  min = 5,
                  max = 300,
                  step = 10,
                  width = "100%"
                )
              )
            ),
            shiny::fluidRow(
              shiny::column(
                width = 8,
                shiny::checkboxGroupInput(
                  "omniSources",
                  "Target Databases:",
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
                width = 4,
                shiny::div(
                  style = "margin-top: 25px;",
                  shiny::checkboxInput(
                    "omniDeduplicate",
                    "Automated Cross-Database Deduplication & Fusion",
                    value = TRUE
                  )
                )
              )
            ),
            shiny::div(
              style = "margin-top: 15px; margin-bottom: 15px; text-align: right;",
              shiny::actionButton(
                "omniSearchBtn",
                "Buscar e Carregar no Biblioshiny",
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
#' @keywords internal
#' @export
omnisearchServer <- function(input, output, session, values) {
  omni_data <- shiny::reactiveVal(NULL)
  omni_stats <- shiny::reactiveVal(NULL)

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
    q <- trimws(input$omniQuery)
    if (!nzchar(q)) {
      shiny::showNotification("Por favor, digite um termo de busca antes de pesquisar.", type = "warning")
      return()
    }

    srcs <- input$omniSources
    if (length(srcs) == 0L) {
      shiny::showNotification("Selecione ao menos uma base para consulta.", type = "warning")
      return()
    }

    lim <- as.integer(input$omniLimit)
    if (is.na(lim) || lim <= 0L) lim <- 50L
    dedup <- isTRUE(input$omniDeduplicate)

    shiny::withProgress(message = "Omnisearch Latino-Americano", value = 0.1, {
      shiny::incProgress(0.2, detail = "Consultando repositorios selecionados...")

      df_result <- tryCatch(
        {
          omnisearch_bibliolatam(
            query = q,
            sources = srcs,
            limit_per_source = lim,
            deduplicate = dedup,
            progress = FALSE
          )
        },
        error = function(e) {
          shiny::showNotification(sprintf("Erro durante a consulta: %s", e$message), type = "error")
          NULL
        }
      )

      shiny::incProgress(0.5, detail = "Harmonizando metadados...")

      if (is.null(df_result) || nrow(df_result) == 0L) {
        shiny::showNotification("Nenhum registro encontrado para esta consulta nas bases selecionadas.", type = "warning")
        omni_data(NULL)
        omni_stats(NULL)
        return()
      }

      shiny::incProgress(0.2, detail = "Finalizando e integrando com o Biblioshiny...")

      omni_data(df_result)

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

      # Carregar diretamente no Biblioshiny
      values$M <- df_result
      shiny::showNotification(
        sprintf("Sucesso! %d registros unificados carregados na sessao ativa do Biblioshiny.", nrow(df_result)),
        type = "message",
        duration = 5
      )
    })
  })

  # Metrics Cards
  output$omniMetricsCards <- shiny::renderUI({
    st <- omni_stats()
    if (is.null(st)) return(NULL)

    shiny::fluidRow(
      style = "margin-top: 15px; margin-bottom: 15px;",
      shiny::column(
        width = 3,
        shiny::div(
          style = "background-color: #00a65a; color: #ffffff; padding: 15px; border-radius: 4px; text-align: center;",
          shiny::h4("Total Harmonizado", style = "margin: 0; font-weight: bold;"),
          shiny::h2(st$total, style = "margin: 5px 0 0 0; font-weight: bold;")
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          style = "background-color: #3c8dbc; color: #ffffff; padding: 15px; border-radius: 4px; text-align: center;",
          shiny::h4("Autores Unicos", style = "margin: 0; font-weight: bold;"),
          shiny::h2(st$unique_authors, style = "margin: 5px 0 0 0; font-weight: bold;")
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          style = "background-color: #f39c12; color: #ffffff; padding: 15px; border-radius: 4px; text-align: center;",
          shiny::h4("Periodo (Anos)", style = "margin: 0; font-weight: bold;"),
          shiny::h2(st$timespan, style = "margin: 5px 0 0 0; font-weight: bold; font-size: 20px; line-height: 38px;")
        )
      ),
      shiny::column(
        width = 3,
        shiny::div(
          style = "background-color: #605ca8; color: #ffffff; padding: 15px; border-radius: 4px; text-align: center;",
          shiny::h4("Fontes Ativas", style = "margin: 0; font-weight: bold;"),
          shiny::p(st$sources, style = "margin: 5px 0 0 0; font-size: 13px; font-weight: bold;")
        )
      )
    )
  })

  output$omniPreviewHeader <- shiny::renderUI({
    df <- omni_data()
    if (is.null(df) || nrow(df) == 0L) return(NULL)
    shiny::h4("Previa dos Resultados Harmonizados:", style = "font-weight: bold; color: #2c3e50;")
  })

  output$omniPreviewTable <- shiny::renderUI({
    df <- omni_data()
    if (is.null(df) || nrow(df) == 0L) return(NULL)

    disp_cols <- intersect(c("TI", "AU", "SO", "PY", "DB", "DI"), names(df))
    preview_df <- utils::head(df[, disp_cols, drop = FALSE], 5)

    shiny::tags$div(
      style = "overflow-x: auto; font-size: 13px;",
      shiny::renderTable(preview_df, striped = TRUE, hover = TRUE, bordered = TRUE, width = "100%")
    )
  })

  output$omniLoadSection <- shiny::renderUI({
    df <- omni_data()
    if (is.null(df) || nrow(df) == 0L) return(NULL)

    shiny::div(
      style = "margin-top: 15px; text-align: right;",
      shiny::actionButton(
        "omniReloadBiblioshinyBtn",
        "Recarregar no Biblioshiny",
        icon = shiny::icon("sync"),
        class = "btn-default btn-sm"
      )
    )
  })

  shiny::observeEvent(input$omniReloadBiblioshinyBtn, {
    df <- omni_data()
    if (!is.null(df)) {
      values$M <- df
      shiny::showNotification("Dados recarregados com sucesso na sessao do Biblioshiny!", type = "message")
    }
  })
}
