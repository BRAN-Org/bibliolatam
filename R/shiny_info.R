#' Bibliolatam Info UI Component for Biblioshiny
#'
#' Renders the information and documentation tab for Bibliolatam inside biblioshiny.
#'
#' @return A Shiny tagList containing the UI elements.
#' @keywords internal
#' @export
bibliolatamInfoUI <- function() {
  shiny::tagList(
    shiny::fluidRow(
      shiny::column(
        width = 12,
        shiny::wellPanel(
          style = "background-color: #ffffff; border-top: 3px solid #3c8dbc; border-radius: 4px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); padding: 25px;",

          # Title Header
          shiny::div(
            style = "margin-bottom: 20px; border-bottom: 1px solid #eee; padding-bottom: 15px;",
            shiny::h2(
              "bibliolatam",
              style = "font-weight: bold; color: #2c3e50; margin: 0 0 8px 0; display: inline-block;"
            ),
            shiny::tags$span(
              "v0.1.0",
              class = "label label-primary",
              style = "margin-left: 10px; font-size: 14px; vertical-align: middle;"
            ),
            shiny::tags$span(
              "BRAN Org",
              class = "label label-success",
              style = "margin-left: 5px; font-size: 14px; vertical-align: middle;"
            ),
            shiny::p(
              "Latin American & Iberian Bibliographic Data Adapter for 'bibliometrix' and 'biblioshiny'.",
              style = "font-size: 15px; color: #7f8c8d; margin-top: 5px;"
            )
          ),

          # Motivation & Mission Box
          shiny::div(
            style = "margin-bottom: 25px; padding: 15px 20px; background-color: #f8f9fa; border-left: 4px solid #3c8dbc; border-radius: 4px;",
            shiny::h4("Why bibliolatam?", style = "font-weight: bold; color: #2c3e50; margin-top: 0;"),
            shiny::p(
              "Mainstream bibliometric pipelines primarily support commercial North American and European indexes (Scopus, Web of Science, Dimensions, PubMed). ",
              "In Latin America, Spain, and Portugal, a vast portion of high-impact research is published under ",
              shiny::strong("Diamond Open Access"),
              " repositories (SciELO, Redalyc) or preserved in national graduate thesis libraries (BDTD/Oasisbr, LA Referencia)."
            ),
            shiny::p(
              "Because ", shiny::code("bibliometrix"), " limits its built-in parsers to global multidisciplinary databases to keep maintenance sustainable (Issue #689), ",
              shiny::strong("bibliolatam"), " acts as an official bridge. It parses raw XML, CSV, and OAI-PMH records from Latin American platforms, ",
              "normalizes regional author naming patterns (Brazilian generational suffixes and Hispanic compound surnames), ",
              "and injects standardized ", shiny::code("bibliometrixDB"), " data frames directly into the analysis engine."
            )
          ),

          # Database Coverage Grid
          shiny::h4("Supported & Planned Regional Repositories", style = "font-weight: bold; color: #2c3e50; margin-bottom: 15px;"),
          shiny::fluidRow(
            # SciELO
            shiny::column(
              width = 4,
              shiny::div(
                style = "border: 1px solid #e1e4e8; border-radius: 6px; padding: 15px; background: #fff; min-height: 200px; margin-bottom: 15px;",
                shiny::div(
                  shiny::span(class = "label label-success", "ACTIVE"),
                  shiny::h4("SciELO", style = "font-weight: bold; margin-top: 8px; color: #16a085;"),
                  shiny::p(
                    "Scientific Electronic Library Online. Multidisciplinary diamond OA network across 16 countries. ",
                    "Full NLM/JATS XML parsing with cited references (CR) extraction and direct DOI/PID download engine."
                  )
                )
              )
            ),
            # BDTD
            shiny::column(
              width = 4,
              shiny::div(
                style = "border: 1px solid #e1e4e8; border-radius: 6px; padding: 15px; background: #fff; min-height: 200px; margin-bottom: 15px;",
                shiny::div(
                  shiny::span(class = "label label-success", "ACTIVE"),
                  shiny::h4("BDTD", style = "font-weight: bold; margin-top: 8px; color: #2980b9;"),
                  shiny::p(
                    "Brazilian Digital Library of Theses and Dissertations (IBICT). ",
                    "Online API search and tabular parsing for theses (Doutorado) and dissertations (Mestrado), graduate programs, and advisor mapping."
                  )
                )
              )
            ),
            # Oasisbr
            shiny::column(
              width = 4,
              shiny::div(
                style = "border: 1px solid #e1e4e8; border-radius: 6px; padding: 15px; background: #fff; min-height: 200px; margin-bottom: 15px;",
                shiny::div(
                  shiny::span(class = "label label-success", "ACTIVE"),
                  shiny::h4("Oasisbr", style = "font-weight: bold; margin-top: 8px; color: #e67e22;"),
                  shiny::p(
                    "Brazilian Open Access Portal (IBICT). ",
                    "Online search and tabular parsing for multidisciplinary production: articles, theses, books, and conference proceedings across institutional repositories."
                  )
                )
              )
            )
          ),

          shiny::fluidRow(
            # SPELL / ANPAD
            shiny::column(
              width = 4,
              shiny::div(
                style = "border: 1px solid #e1e4e8; border-radius: 6px; padding: 15px; background: #fff; min-height: 180px; margin-bottom: 15px;",
                shiny::div(
                  shiny::span(class = "label label-success", "ACTIVE"),
                  shiny::h4("SPELL / ANPAD", style = "font-weight: bold; margin-top: 8px; color: #8e44ad;"),
                  shiny::p(
                    "Scientific Periodicals Electronic Library. Specialized index by ANPAD for Business Administration, Accounting, Economics, and Public Management."
                  )
                )
              )
            )
          ),

          shiny::fluidRow(
            # Redalyc
            shiny::column(
              width = 6,
              shiny::div(
                style = "border: 1px solid #e1e4e8; border-radius: 6px; padding: 15px; background: #fff; min-height: 160px; margin-bottom: 15px;",
                shiny::div(
                  shiny::span(class = "label label-success", "ACTIVE"),
                  shiny::h4("Redalyc / AmeliCA", style = "font-weight: bold; margin-top: 8px; color: #d35400;"),
                  shiny::p(
                    "Network of Scientific Journals from Latin America and the Caribbean, Spain and Portugal (UAEMex). Parses BibTeX, RIS, and CSV formats with Hispanic compound author name resolution."
                  )
                )
              )
            ),
            # LA Referencia
            shiny::column(
              width = 6,
              shiny::div(
                style = "border: 1px solid #e1e4e8; border-radius: 6px; padding: 15px; background: #fff; min-height: 160px; margin-bottom: 15px;",
                shiny::div(
                  shiny::span(class = "label label-info", "NEXT PHASE"),
                  shiny::h4("LA Referencia", style = "font-weight: bold; margin-top: 8px; color: #c0392b;"),
                  shiny::p(
                    "Federated Network of Institutional Repositories of Scientific Publications. Continental aggregator connecting university research outputs from 12 Latin American nations."
                  )
                )
              )
            )
          ),

          # Scientific Principles & Governance
          shiny::div(
            style = "margin-top: 15px; padding-top: 15px; border-top: 1px solid #eee;",
            shiny::h4("Principles & Governance", style = "font-weight: bold; color: #2c3e50; margin-bottom: 10px;"),
            shiny::tags$ul(
              style = "color: #555; line-height: 1.8;",
              shiny::tags$li(shiny::strong("FAIR Principles: "), "Findable, Accessible, Interoperable, and Reusable data standards for regional science."),
              shiny::tags$li(shiny::strong("BOAI Adherence: "), "Committed to the Budapest Open Access Initiative and non-commercial scientific communication."),
              shiny::tags$li(shiny::strong("Dual Licensing: "), "Source code licensed under GNU GPL-3.0. Metadata fixtures protected under CC BY-NC-SA 4.0 with Anti-AI commercial ingestion restrictions."),
              shiny::tags$li(shiny::strong("Open Development: "), shiny::tags$a(href = "https://github.com/BRAN-Org/bibliolatam", target = "_blank", "GitHub Repository (BRAN-Org/bibliolatam)"))
            )
          )
        )
      )
    )
  )
}
