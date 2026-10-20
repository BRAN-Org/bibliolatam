#' Bibliolatam Info UI Component for Biblioshiny
#'
#' Renders the information and documentation tab for Bibliolatam inside biblioshiny.
#'
#' @param lang Character. Interface language: "en", "pt", or "es". Default is "en".
#' @return A Shiny tagList containing the UI elements.
#' @keywords internal
#' @export
#' @examples
#' if (interactive()) {
#'   library(shiny)
#'   ui <- fluidPage(bibliolatamInfoUI())
#'   server <- function(input, output, session) {}
#'   shinyApp(ui, server)
#' }
bibliolatamInfoUI <- function(lang = "en") {
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
              "v1.0.0",
              class = "label label-primary",
              style = "margin-left: 10px; font-size: 14px; vertical-align: middle;"
            ),
            shiny::tags$span(
              "BRAN Org",
              class = "label label-success",
              style = "margin-left: 5px; font-size: 14px; vertical-align: middle;"
            ),
            shiny::tags$p(
              bl_i18n("info_tagline", lang),
              `data-i18n` = "info_tagline",
              style = "font-size: 15px; color: #7f8c8d; margin-top: 5px;"
            )
          ),

          # Motivation & Mission Box
          shiny::div(
            style = "margin-bottom: 25px; padding: 15px 20px; background-color: #f8f9fa; border-left: 4px solid #3c8dbc; border-radius: 4px;",
            shiny::tags$h4(
              bl_i18n("info_why", lang),
              `data-i18n` = "info_why",
              style = "font-weight: bold; color: #2c3e50; margin-top: 0;"
            ),
            shiny::tags$p(
              shiny::HTML(bl_i18n("info_why_p1", lang)),
              `data-i18n-html` = "info_why_p1"
            ),
            shiny::tags$p(
              shiny::HTML(bl_i18n("info_why_p2", lang)),
              `data-i18n-html` = "info_why_p2"
            )
          ),

          # Database Coverage Grid
          shiny::h4(
            bl_i18n("info_repos_title", lang),
            `data-i18n` = "info_repos_title",
            style = "font-weight: bold; color: #2c3e50; margin-bottom: 15px;"
          ),
          shiny::fluidRow(
            # SciELO
            shiny::column(
              width = 4,
              shiny::div(
                style = "border: 1px solid #e1e4e8; border-radius: 6px; padding: 15px; background: #fff; min-height: 200px; margin-bottom: 15px;",
                shiny::div(
                  shiny::span(class = "label label-success", bl_i18n("info_badge_active", lang), `data-i18n` = "info_badge_active"),
                  shiny::h4("SciELO", style = "font-weight: bold; margin-top: 8px; color: #16a085;"),
                  shiny::p(
                    bl_i18n("info_scielo_desc", lang),
                    `data-i18n` = "info_scielo_desc"
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
                  shiny::span(class = "label label-success", bl_i18n("info_badge_active", lang), `data-i18n` = "info_badge_active"),
                  shiny::h4("BDTD", style = "font-weight: bold; margin-top: 8px; color: #2980b9;"),
                  shiny::p(
                    bl_i18n("info_bdtd_desc", lang),
                    `data-i18n` = "info_bdtd_desc"
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
                  shiny::span(class = "label label-success", bl_i18n("info_badge_active", lang), `data-i18n` = "info_badge_active"),
                  shiny::h4("Oasisbr", style = "font-weight: bold; margin-top: 8px; color: #e67e22;"),
                  shiny::p(
                    bl_i18n("info_oasisbr_desc", lang),
                    `data-i18n` = "info_oasisbr_desc"
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
                  shiny::span(class = "label label-success", bl_i18n("info_badge_active", lang), `data-i18n` = "info_badge_active"),
                  shiny::h4("SPELL / ANPAD", style = "font-weight: bold; margin-top: 8px; color: #8e44ad;"),
                  shiny::p(
                    bl_i18n("info_spell_desc", lang),
                    `data-i18n` = "info_spell_desc"
                  )
                )
              )
            ),
            # Redalyc
            shiny::column(
              width = 4,
              shiny::div(
                style = "border: 1px solid #e1e4e8; border-radius: 6px; padding: 15px; background: #fff; min-height: 180px; margin-bottom: 15px;",
                shiny::div(
                  shiny::span(class = "label label-success", bl_i18n("info_badge_active", lang), `data-i18n` = "info_badge_active"),
                  shiny::h4("Redalyc / AmeliCA", style = "font-weight: bold; margin-top: 8px; color: #d35400;"),
                  shiny::p(
                    bl_i18n("info_redalyc_desc", lang),
                    `data-i18n` = "info_redalyc_desc"
                  )
                )
              )
            ),
            # LA Referencia
            shiny::column(
              width = 4,
              shiny::div(
                style = "border: 1px solid #e1e4e8; border-radius: 6px; padding: 15px; background: #fff; min-height: 180px; margin-bottom: 15px;",
                shiny::div(
                  shiny::span(class = "label label-success", bl_i18n("info_badge_active", lang), `data-i18n` = "info_badge_active"),
                  shiny::h4("LA Referencia", style = "font-weight: bold; margin-top: 8px; color: #c0392b;"),
                  shiny::p(
                    bl_i18n("info_lareferencia_desc", lang),
                    `data-i18n` = "info_lareferencia_desc"
                  )
                )
              )
            )
          ),

          shiny::fluidRow(
            # Omnisearch Engine
            shiny::column(
              width = 12,
              shiny::div(
                style = "border: 1px solid #b7eb8f; border-radius: 6px; padding: 15px; background: #f6ffed; margin-bottom: 15px;",
                shiny::div(
                  shiny::span(class = "label label-success", bl_i18n("info_badge_active", lang), `data-i18n` = "info_badge_active"),
                  shiny::h4(bl_i18n("info_omnisearch_box_title", lang), `data-i18n` = "info_omnisearch_box_title", style = "font-weight: bold; margin-top: 8px; color: #389e0d;"),
                  shiny::p(
                    bl_i18n("info_omnisearch_desc", lang),
                    `data-i18n` = "info_omnisearch_desc"
                  )
                )
              )
            )
          ),

          # Scientific Principles & Governance
          shiny::div(
            style = "margin-top: 15px; padding-top: 15px; border-top: 1px solid #eee;",
            shiny::h4(
              bl_i18n("info_gov_title", lang),
              `data-i18n` = "info_gov_title",
              style = "font-weight: bold; color: #2c3e50; margin-bottom: 10px;"
            ),
            shiny::tags$ul(
              style = "color: #555; line-height: 1.8;",
              shiny::tags$li(
                shiny::strong(bl_i18n("info_gov_fair_title", lang), `data-i18n` = "info_gov_fair_title"),
                shiny::span(bl_i18n("info_gov_fair_desc", lang), `data-i18n` = "info_gov_fair_desc")
              ),
              shiny::tags$li(
                shiny::strong(bl_i18n("info_gov_boai_title", lang), `data-i18n` = "info_gov_boai_title"),
                shiny::span(bl_i18n("info_gov_boai_desc", lang), `data-i18n` = "info_gov_boai_desc")
              ),
              shiny::tags$li(
                shiny::strong(bl_i18n("info_gov_license_title", lang), `data-i18n` = "info_gov_license_title"),
                shiny::span(bl_i18n("info_gov_license_desc", lang), `data-i18n` = "info_gov_license_desc")
              ),
              shiny::tags$li(
                shiny::strong(bl_i18n("info_gov_dev_title", lang), `data-i18n` = "info_gov_dev_title"),
                shiny::tags$a(
                  href = "https://github.com/BRAN-Org/bibliolatam",
                  target = "_blank",
                  bl_i18n("info_gov_dev_repo", lang),
                  `data-i18n` = "info_gov_dev_repo"
                )
              )
            )
          )
        )
      )
    )
  )
}
