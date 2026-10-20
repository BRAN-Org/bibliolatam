#' Internationalization (i18n) Dictionary and Helpers for bibliolatam
#'
#' Provides trilingual support (English, Portuguese, Spanish) across all
#' UI components, notifications, metrics, and exports.
#'
#' @keywords internal
NULL

#' bibliolatam Trilingual Dictionary
#' @keywords internal
BL_I18N_DICT <- list(
  # Navbar & Navigation
  tab_omnisearch = list(en = "Omnisearch", pt = "Omnisearch", es = "Omnisearch"),
  tab_scielo = list(en = "SciELO", pt = "SciELO", es = "SciELO"),
  tab_bdtd = list(en = "BDTD", pt = "BDTD", es = "BDTD"),
  tab_oasisbr = list(en = "Oasisbr", pt = "Oasisbr", es = "Oasisbr"),
  tab_redalyc = list(en = "Redalyc", pt = "Redalyc", es = "Redalyc"),
  tab_merge = list(en = "Merge & Deduplicate", pt = "Unificar e Deduplicar", es = "Unificar y Deduplicar"),
  tab_about = list(en = "About", pt = "Sobre", es = "Acerca de"),
  lang_label = list(en = "Language:", pt = "Idioma:", es = "Idioma:"),

  # Omnisearch
  omni_title = list(en = "Latin American Omnisearch Engine", pt = "Mecanismo Omnisearch Latino-Americano", es = "Motor Omnisearch Latinoamericano"),
  omni_badge = list(en = "Federated Multi-Source Discovery", pt = "Descoberta Federada Multifonte", es = "Descubrimiento Federado Multifuente"),
  omni_banner = list(
    en = "Unified Latin American Search: Query SciELO, BDTD, Oasisbr, and LA Referencia simultaneously in a single operation. The engine queries each official repository, normalizes records into canonical bibliometrix format, and automatically fuses and deduplicates duplicate entries.",
    pt = "Busca Unificada Latino-Americana: Consulte SciELO, BDTD, Oasisbr e LA Referencia simultaneamente em uma unica operacao. O mecanismo consulta cada repositorio oficial, normaliza os registros para o formato canonico do bibliometrix e funde e deduplica automaticamente entradas duplicadas.",
    es = "Busqueda Unificada Latinoamericana: Consulte SciELO, BDTD, Oasisbr y LA Referencia simultaneamente en una sola operacion. El motor consulta cada repositorio oficial, normaliza los registros al formato canonico de bibliometrix y fusiona y deduplica automaticamente entradas duplicadas."
  ),
  omni_query = list(en = "Search Query:", pt = "Termos de Busca:", es = "Terminos de Busqueda:"),
  omni_query_ph = list(en = "e.g. \"artificial intelligence\" OR \"public health\"", pt = "ex: \"inteligencia artificial\" OU \"saude coletiva\"", es = "ej: \"inteligencia artificial\" O \"salud publica\""),
  omni_year_start = list(en = "Start Year:", pt = "Ano Inicial:", es = "Ano Inicial:"),
  omni_year_end = list(en = "End Year:", pt = "Ano Final:", es = "Ano Final:"),
  omni_limit = list(en = "Limit per database:", pt = "Limite por base:", es = "Limite por base:"),
  omni_sources = list(en = "Target Databases:", pt = "Bases de Dados Alvo:", es = "Bases de Datos Objetivo:"),
  omni_src_scielo = list(en = "SciELO (Journal Articles)", pt = "SciELO (Artigos de Periodicos)", es = "SciELO (Articulos de Revistas)"),
  omni_src_bdtd = list(en = "BDTD (Theses & Dissertations)", pt = "BDTD (Teses e Dissertacoes)", es = "BDTD (Tesis y Disertaciones)"),
  omni_src_oasisbr = list(en = "Oasisbr (Brazilian Repositories)", pt = "Oasisbr (Repositorios Brasileiros)", es = "Oasisbr (Repositorios Brasileros)"),
  omni_src_lareferencia = list(en = "LA Referencia (12 Latin American Countries)", pt = "LA Referencia (12 Paises Latino-Americanos)", es = "LA Referencia (12 Paises Latinoamericanos)"),
  omni_dedup = list(en = "Automated Cross-Database Deduplication & Fusion", pt = "Deduplicacao e Fusao Automatica Entre Bases", es = "Deduplicacion y Fusion Automatica Entre Bases"),
  omni_enrich_cr = list(en = "Enrich SciELO with Cited References (JATS XML)", pt = "Enriquecer SciELO com Referencias Citadas (JATS XML)", es = "Enriquecer SciELO con Referencias Citadas (JATS XML)"),
  omni_search_btn = list(en = "Search and Load into Biblioshiny", pt = "Buscar e Carregar no Biblioshiny", es = "Buscar y Cargar en Biblioshiny"),
  omni_stat_total = list(en = "Harmonized Total", pt = "Total Harmonizado", es = "Total Armonizado"),
  omni_stat_authors = list(en = "Unique Authors", pt = "Autores Unicos", es = "Autores Unicos"),
  omni_stat_timespan = list(en = "Timespan (Years)", pt = "Periodo (Anos)", es = "Periodo (Anos)"),
  omni_stat_sources = list(en = "Active Sources", pt = "Fontes Ativas", es = "Fuentes Activas"),
  omni_preview_title = list(en = "Harmonized Results Preview:", pt = "Previa dos Resultados Harmonizados:", es = "Vista Previa de Resultados Armonizados:"),
  download_csv = list(en = "Download CSV", pt = "Baixar CSV", es = "Descargar CSV"),
  export_rdata = list(en = "Export .RData", pt = "Exportar .RData", es = "Exportar .RData"),
  reload_biblioshiny = list(en = "Reload in Biblioshiny", pt = "Recarregar no Biblioshiny", es = "Recargar en Biblioshiny"),
  omni_err_select_base = list(en = "Please select at least one database for query.", pt = "Selecione ao menos uma base para consulta.", es = "Seleccione al menos una base de datos para la consulta."),
  omni_warn_empty_query = list(en = "Please enter a search query before submitting.", pt = "Por favor, digite um termo de busca antes de pesquisar.", es = "Por favor, introduzca un termino de busqueda antes de buscar."),
  omni_warn_no_results = list(en = "No records found for this query in the selected repositories.", pt = "Nenhum registro encontrado para esta consulta nas bases selecionadas.", es = "No se encontraron registros para esta consulta en los repositorios seleccionados."),
  omni_prog_title = list(en = "Latin American Omnisearch", pt = "Omnisearch Latino-Americano", es = "Omnisearch Latinoamericano"),
  omni_prog_querying = list(en = "Querying selected repositories...", pt = "Consultando repositorios selecionados...", es = "Consultando repositorios seleccionados..."),
  omni_prog_harmonizing = list(en = "Harmonizing metadata and resolving authors...", pt = "Harmonizando metadados e resolvendo autores...", es = "Armonizando metadatos y resolviendo autores..."),
  omni_prog_finalizing = list(en = "Finalizing and integrating with Biblioshiny...", pt = "Finalizando e integrando com o Biblioshiny...", es = "Finalizando e integrando com o Biblioshiny..."),
  omni_err_during_query = list(en = "Error during query: %s", pt = "Erro durante a consulta: %s", es = "Error durante la consulta: %s"),
  omni_success_loaded = list(en = "Success! %d harmonized records loaded into active session.", pt = "Sucesso! %d registros harmonizados carregados na sessao ativa.", es = "Exito! %d registros armonizados cargados en la sesion activa."),

  # SciELO
  scielo_title = list(en = "SciELO Data Collection", pt = "Coleta de Dados SciELO", es = "Recoleccion de Datos SciELO"),
  scielo_badge = list(en = "Diamond Open Access (Latin America & Caribbean)", pt = "Acesso Aberto Diamante (America Latina e Caribe)", es = "Acceso Abierto Diamante (America Latina y el Caribe)"),
  scielo_banner = list(
    en = "Full JATS XML & Cited References (CR): Retrieve or upload full-text NLM/JATS XML articles from SciELO. Reconstructs cited references for bibliographic coupling and co-citation networks.",
    pt = "JATS XML Completo e Referencias Citadas (CR): Recupere ou envie artigos NLM/JATS XML completos do SciELO. Reconstroi referencias citadas para acoplamento bibliografico e redes de co-citacao.",
    es = "JATS XML Completo y Referencias Citadas (CR): Recupere o cargue articulos NLM/JATS XML completos de SciELO. Reconstruye referencias citadas para acoplamiento bibliografico y redes de co-citacion."
  ),
  scielo_tab_download = list(en = "Online Retrieval (DOIs / PIDs)", pt = "Recuperacao Online (DOIs / PIDs)", es = "Recuperacion en Linea (DOIs / PIDs)"),
  scielo_tab_upload = list(en = "Local File Upload (XML / ZIP)", pt = "Upload de Arquivo Local (XML / ZIP)", es = "Carga de Archivo Local (XML / ZIP)"),
  scielo_tab_search = list(en = "Online Search & Retrieval", pt = "Busca e Recuperacao Online", es = "Busqueda y Recuperacion en Linea"),
  scielo_input_label = list(en = "SciELO DOIs, PIDs or URLs (one per line or comma-separated):", pt = "DOIs, PIDs ou URLs da SciELO (um por linha ou separados por virgula):", es = "DOIs, PIDs o URLs de SciELO (uno por linea o separados por coma):"),
  scielo_fetch_btn = list(en = "Fetch & Process Articles", pt = "Buscar e Processar Artigos", es = "Obtener y Procesar Articulos"),
  scielo_upload_label = list(en = "Select SciELO XML, ZIP, or Tabular file:", pt = "Selecione arquivo SciELO XML, ZIP ou Tabular:", es = "Seleccione archivo SciELO XML, ZIP o Tabular:"),
  scielo_process_btn = list(en = "Process SciELO File", pt = "Processar Arquivo SciELO", es = "Procesar Archivo SciELO"),
  scielo_load_app_btn = list(en = "Load Data into Biblioshiny Engine", pt = "Carregar Dados no Mecanismo Biblioshiny", es = "Cargar Datos en el Motor Biblioshiny"),
  scielo_box_docs = list(en = "DOCUMENTS", pt = "DOCUMENTOS", es = "DOCUMENTOS"),
  scielo_box_timespan = list(en = "TIMESPAN", pt = "PERIODO", es = "PERIODO"),
  scielo_box_cr = list(en = "CITED REFS (CR)", pt = "REFS. CITADAS (CR)", es = "REFS. CITADAS (CR)"),
  scielo_box_langs = list(en = "LANGUAGES", pt = "IDIOMAS", es = "IDIOMAS"),

  # BDTD
  bdtd_title = list(en = "BDTD Collection", pt = "Coleta BDTD", es = "Recoleccion BDTD"),
  bdtd_badge = list(en = "IBICT (Theses & Dissertations)", pt = "IBICT (Teses e Dissertacoes)", es = "IBICT (Tesis y Disertaciones)"),
  bdtd_banner = list(
    en = "Brazilian Digital Library of Theses and Dissertations (BDTD): Search online via the official IBICT VuFind API or upload tabular export files (CSV, TSV). Maps graduate programs and universities to Source (SO), advisors to Corresponding Author (RP), and classifies degrees into Theses and Dissertations.",
    pt = "Biblioteca Digital Brasileira de Teses e Dissertacoes (BDTD): Pesquise online via API oficial IBICT VuFind ou envie arquivos tabulares exportados (CSV, TSV). Mapeia programas de pos-graduacao e universidades em Source (SO), orientadores em Corresponding Author (RP), e classifica graus em Teses e Dissertacoes.",
    es = "Biblioteca Digital Brasilena de Tesis y Disertaciones (BDTD): Busque en linea a traves de la API oficial IBICT VuFind o cargue archivos tabulares exportados (CSV, TSV). Mapea programas de posgrado y universidades en Source (SO), asesores en Corresponding Author (RP), y clasifica grados en Tesis y Disertaciones."
  ),
  bdtd_tab_online = list(en = "Online Search & Retrieval", pt = "Busca e Recuperacao Online", es = "Busqueda y Recuperacion en Linea"),
  bdtd_tab_upload = list(en = "Local File Upload", pt = "Upload de Arquivo Local", es = "Carga de Archivo Local"),
  bdtd_query_label = list(en = "Search Query (Keywords, Title, Author, or Subject):", pt = "Termos de Busca (Palavras-chave, Titulo, Autor ou Assunto):", es = "Terminos de Busqueda (Palabras clave, Titulo, Autor o Asunto):"),
  bdtd_query_ph = list(en = "e.g. artificial intelligence, sustainability, public education", pt = "ex: inteligencia artificial, sustentabilidade, educacao publica", es = "ej: inteligencia artificial, sostenibilidad, educacion publica"),
  bdtd_limit_label = list(en = "Max Records to Retrieve:", pt = "Limite Maximo de Registros:", es = "Limite Maximo de Registros:"),
  bdtd_filter_label = list(en = "Filter Degree / Document Type:", pt = "Filtrar Grau / Tipo de Documento:", es = "Filtrar Grado / Tipo de Documento:"),
  bdtd_choice_all = list(en = "All (Theses & Dissertations)", pt = "Todos (Teses e Dissertacoes)", es = "Todos (Tesis y Disertaciones)"),
  bdtd_choice_thesis = list(en = "Only Theses (Doutorado)", pt = "Apenas Teses (Doutorado)", es = "Solo Tesis (Doctorado)"),
  bdtd_choice_diss = list(en = "Only Dissertations (Mestrado)", pt = "Apenas Dissertacoes (Mestrado)", es = "Solo Disertaciones (Maestria)"),
  bdtd_normalize_label = list(en = "Normalize Brazilian author and advisor names", pt = "Normalizar nomes de autores e orientadores brasileiros", es = "Normalizar nombres de autores y asesores brasilenos"),
  bdtd_fetch_btn = list(en = "Search & Retrieve from BDTD", pt = "Buscar e Recuperar da BDTD", es = "Buscar y Recuperar de BDTD"),
  bdtd_upload_label = list(en = "Select BDTD Export File (CSV or TSV):", pt = "Selecione Arquivo de Exportacao BDTD (CSV ou TSV):", es = "Seleccione Archivo de Exportacion BDTD (CSV o TSV):"),
  bdtd_process_btn = list(en = "Process BDTD File", pt = "Processar Arquivo BDTD", es = "Procesar Archivo BDTD"),

  # Oasisbr
  oasisbr_title = list(en = "Oasisbr Collection", pt = "Coleta Oasisbr", es = "Recoleccion Oasisbr"),
  oasisbr_badge = list(en = "IBICT Institutional Repositories & Diamond OA", pt = "Repositorios Institucionais IBICT e OA Diamante", es = "Repositorios Institucionales IBICT y OA Diamante"),
  oasisbr_banner = list(
    en = "Search online via the official Oasisbr VuFind API or upload tabular export files (CSV, TSV). Aggregates multidisciplinary production across Brazilian institutional repositories, including articles, theses, dissertations, books, and conference proceedings.",
    pt = "Pesquise online via API oficial Oasisbr VuFind ou envie arquivos tabulares exportados (CSV, TSV). Agrega producao multidisciplinar em repositorios institucionais brasileiros, incluindo artigos, teses, dissertacoes, livros e anais.",
    es = "Busque en linea a traves de la API oficial Oasisbr VuFind o cargue archivos tabulares exportados (CSV, TSV). Agrega produccion multidisciplinaria en repositorios institucionales brasilenos, incluyendo articulos, tesis, disertaciones, libros y memorias."
  ),
  oasisbr_tab_online = list(en = "Online Search & Retrieval", pt = "Busca e Recuperacao Online", es = "Busqueda y Recuperacion en Linea"),
  oasisbr_tab_upload = list(en = "Local File Upload", pt = "Upload de Arquivo Local", es = "Carga de Archivo Local"),
  oasisbr_query_label = list(en = "Search Query (Keywords, Title, Author, or Institution):", pt = "Termos de Busca (Palavras-chave, Titulo, Autor ou Instituicao):", es = "Terminos de Busqueda (Palabras clave, Titulo, Autor o Institucion):"),
  oasisbr_filter_label = list(en = "Filter Document Type:", pt = "Filtrar Tipo de Documento:", es = "Filtrar Tipo de Documento:"),
  oasisbr_choice_all = list(en = "All Document Types", pt = "Todos os Tipos de Documento", es = "Todos los Tipos de Documento"),
  oasisbr_choice_articles = list(en = "Journal Articles Only", pt = "Apenas Artigos de Periodicos", es = "Solo Articulos de Revistas"),
  oasisbr_choice_theses = list(en = "Theses & Dissertations", pt = "Teses e Dissertacoes", es = "Tesis y Disertaciones"),
  oasisbr_choice_books = list(en = "Books & Book Chapters", pt = "Livros e Capitulos de Livros", es = "Libros y Capitulos de Libros"),
  oasisbr_fetch_btn = list(en = "Search & Retrieve from Oasisbr", pt = "Buscar e Recuperar do Oasisbr", es = "Buscar y Recuperar de Oasisbr"),
  oasisbr_process_btn = list(en = "Process Oasisbr File", pt = "Processar Arquivo Oasisbr", es = "Procesar Archivo Oasisbr"),

  # Redalyc
  redalyc_title = list(en = "Redalyc & AmeliCA Collection", pt = "Coleta Redalyc e AmeliCA", es = "Recoleccion Redalyc y AmeliCA"),
  redalyc_badge = list(en = "Non-commercial Diamond OA Network", pt = "Rede de Acesso Aberto Diamante Nao-Comercial", es = "Red de Acceso Abierto Diamante No Comercial"),
  redalyc_tab_upload = list(en = "Upload Redalyc Export File", pt = "Upload de Arquivo Redalyc", es = "Carga de Archivo Redalyc"),
  redalyc_upload_label = list(en = "Select Redalyc Export File (CSV, TSV, RIS, or BibTeX):", pt = "Selecione Arquivo Redalyc (CSV, TSV, RIS ou BibTeX):", es = "Seleccione Archivo Redalyc (CSV, TSV, RIS o BibTeX):"),
  redalyc_process_btn = list(en = "Process Redalyc File", pt = "Processar Arquivo Redalyc", es = "Procesar Archivo Redalyc"),

  # Merge
  merge_title = list(en = "Cross-Database Merge & Deduplication", pt = "Unificacao e Deduplicacao Entre Bases", es = "Fusion y Deduplicacion Entre Bases"),
  merge_badge = list(en = "Regional & Global Data Harmonizer", pt = "Harmonizador Regional e Global de Dados", es = "Armonizador Regional y Global de Datos"),
  merge_source1_label = list(en = "Primary Dataset (Base 1):", pt = "Base Primaria (Base 1):", es = "Base Primaria (Base 1):"),
  merge_source2_label = list(en = "Secondary Dataset (Base 2):", pt = "Base Secundaria (Base 2):", es = "Base Secundaria (Base 2):"),
  merge_btn = list(en = "Merge and Deduplicate Datasets", pt = "Unificar e Deduplicar Bases", es = "Fusionar y Deduplicar Bases"),

  # About
  info_title = list(en = "bibliolatam", pt = "bibliolatam", es = "bibliolatam"),
  info_tagline = list(
    en = "Latin American & Iberian Bibliographic Data Adapter for 'bibliometrix' and 'biblioshiny'.",
    pt = "Adaptador de Dados Bibliograficos Latino-Americanos e Ibericos para 'bibliometrix' e 'biblioshiny'.",
    es = "Adaptador de Datos Bibliograficos Latinoamericanos e Ibericos para 'bibliometrix' y 'biblioshiny'."
  ),
  info_why = list(en = "Why bibliolatam?", pt = "Por que o bibliolatam?", es = "Por que bibliolatam?"),
  info_fair = list(en = "FAIR Principles & Regional Sovereignty", pt = "Principios FAIR e Soberania Regional", es = "Principios FAIR y Soberania Regional"),

  # Common
  btn_collapse = list(en = "Collapse/Expand", pt = "Recolher/Expandir", es = "Colapsar/Expandir")
)

#' Translate a Key to the Selected Language
#'
#' @param key Character. Translation key.
#' @param lang Character. Language code ("en", "pt", or "es"). Default is "en".
#' @return Translated character string.
#' @keywords internal
bl_i18n <- function(key, lang = "en") {
  if (is.null(lang) || !nzchar(lang)) {
    lang <- "en"
  }
  lang <- tolower(trimws(lang))
  if (!lang %in% c("en", "pt", "es")) {
    lang <- "en"
  }

  entry <- BL_I18N_DICT[[key]]
  if (is.null(entry)) {
    return(key)
  }

  val <- entry[[lang]]
  if (is.null(val) || !nzchar(val)) {
    val <- entry[["en"]]
  }
  if (is.null(val)) {
    val <- key
  }
  val
}

#' Generate Client-Side JavaScript for Trilingual Dynamic Switching
#'
#' @return A Shiny HTML tag with the embedded JavaScript logic.
#' @keywords internal
bl_i18n_script <- function() {
  # Build JSON translation dictionary
  dict_json <- jsonlite::toJSON(BL_I18N_DICT, auto_unbox = TRUE)

  js_code <- sprintf('
  window.bibliolatam_dict = %s;

  function setBibliolatamLang(lang) {
    if (!["en", "pt", "es"].includes(lang)) lang = "en";
    try {
      localStorage.setItem("bibliolatam_lang", lang);
    } catch(e) {}

    // Update active button state
    ["en", "pt", "es"].forEach(function(l) {
      var btn = document.getElementById("btn_lang_" + l);
      if (btn) {
        if (l === lang) {
          btn.classList.add("active");
          btn.style.backgroundColor = "#3c8dbc";
          btn.style.color = "#ffffff";
          btn.style.fontWeight = "bold";
        } else {
          btn.classList.remove("active");
          btn.style.backgroundColor = "#ffffff";
          btn.style.color = "#333333";
          btn.style.fontWeight = "normal";
        }
      }
    });

    // Notify Shiny server
    if (window.Shiny && typeof Shiny.setInputValue === "function") {
      Shiny.setInputValue("current_lang", lang);
    }

    // Translate DOM elements with data-i18n
    var dict = window.bibliolatam_dict;
    document.querySelectorAll("[data-i18n]").forEach(function(el) {
      var k = el.getAttribute("data-i18n");
      if (dict[k] && dict[k][lang]) {
        el.textContent = dict[k][lang];
      }
    });

    // Translate placeholders
    document.querySelectorAll("[data-i18n-ph]").forEach(function(el) {
      var k = el.getAttribute("data-i18n-ph");
      if (dict[k] && dict[k][lang]) {
        el.placeholder = dict[k][lang];
      }
    });

    // Translate titles / tooltips
    document.querySelectorAll("[data-i18n-title]").forEach(function(el) {
      var k = el.getAttribute("data-i18n-title");
      if (dict[k] && dict[k][lang]) {
        el.title = dict[k][lang];
      }
    });

    // Translate Navbar Tabs dynamically
    var tabMap = {
      "Omnisearch": "tab_omnisearch",
      "SciELO": "tab_scielo",
      "BDTD": "tab_bdtd",
      "Oasisbr": "tab_oasisbr",
      "Redalyc": "tab_redalyc",
      "Merge & Deduplicate": "tab_merge",
      "Unificar e Deduplicar": "tab_merge",
      "Unificar y Deduplicar": "tab_merge",
      "About": "tab_about",
      "Sobre": "tab_about",
      "Acerca de": "tab_about"
    };

    document.querySelectorAll(".navbar-nav > li > a").forEach(function(tabLink) {
      var txt = tabLink.innerText.trim();
      for (var original in tabMap) {
        if (txt === original || (dict[tabMap[original]] && Object.values(dict[tabMap[original]]).includes(txt))) {
          var key = tabMap[original];
          if (dict[key] && dict[key][lang]) {
            tabLink.innerText = dict[key][lang];
          }
          break;
        }
      }
    });
  }

  // Auto initialize on DOM ready and after Shiny flushes
  document.addEventListener("DOMContentLoaded", function() {
    var saved = "en";
    try {
      saved = localStorage.getItem("bibliolatam_lang") || "en";
    } catch(e) {}
    setBibliolatamLang(saved);
  });

  if (window.jQuery) {
    $(document).on("shiny:connected", function() {
      var saved = "en";
      try {
        saved = localStorage.getItem("bibliolatam_lang") || "en";
      } catch(e) {}
      setBibliolatamLang(saved);
    });
  }
  ', dict_json)

  shiny::tags$script(shiny::HTML(js_code))
}
