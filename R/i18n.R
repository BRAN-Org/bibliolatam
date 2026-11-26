#' Internationalization (i18n) Dictionary and Helpers for bibliolatam
#'
#' Provides trilingual support (English, Portuguese, Spanish) across all
#' UI components, notifications, metrics, and exports.
#'
#' @name i18n
#' @keywords internal
NULL

#' bibliolatam Trilingual Dictionary
#'
#' @format A named list of translation terms with nested sublists containing strings for 'en', 'pt', and 'es'.
#' @keywords internal
BL_I18N_DICT <- list(
  # Navbar & Navigation
  tab_omnisearch = list(en = "Omnisearch", pt = "Omnisearch", es = "Omnisearch"),
  tab_scielo = list(en = "SciELO", pt = "SciELO", es = "SciELO"),
  tab_bdtd = list(en = "BDTD", pt = "BDTD", es = "BDTD"),
  tab_oasisbr = list(en = "Oasisbr", pt = "Oasisbr", es = "Oasisbr"),
  tab_redalyc = list(en = "Redalyc", pt = "Redalyc", es = "Redalyc"),
  tab_spell = list(en = "SPELL", pt = "SPELL", es = "SPELL"),
  tab_merge = list(en = "Merge & Deduplicate", pt = "Unificar e Deduplicar", es = "Unificar y Deduplicar"),
  tab_about = list(en = "About", pt = "Sobre", es = "Acerca de"),
  lang_label = list(en = "Language:", pt = "Idioma:", es = "Idioma:"),

  # Omnisearch
  omni_title = list(en = "Omnisearch Engine", pt = "Mecanismo Omnisearch", es = "Motor Omnisearch"),
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
  preview_filter_all_sources = list(en = "All Sources", pt = "Todas as Fontes", es = "Todas las Fuentes"),
  preview_page_size = list(en = "Show:", pt = "Exibir:", es = "Mostrar:"),
  preview_search_ph = list(en = "Filter preview (title, author, DOI)...", pt = "Filtrar previa (titulo, autor, DOI)...", es = "Filtrar vista previa (titulo, autor, DOI)..."),
  preview_page_label = list(en = "Page %d of %d (%d items)", pt = "Pagina %d de %d (%d itens)", es = "Pagina %d de %d (%d elementos)"),
  preview_btn_prev = list(en = "Previous", pt = "Anterior", es = "Anterior"),
  preview_btn_next = list(en = "Next", pt = "Proxima", es = "Siguiente"),
  preview_no_match = list(en = "No records match the current preview filter.", pt = "Nenhum registro corresponde ao filtro de previa atual.", es = "Ningun registro coincide con el filtro de vista previa actual."),
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
  omni_adv_toggle = list(en = "Advanced Settings", pt = "Configuracoes Avancadas", es = "Configuracion Avanzada"),
  omni_adv_sec_filters = list(en = "Corpus Quality & Author Normalization", pt = "Qualidade do Corpus e Normalizacao de Autores", es = "Calidad del Corpus y Normalizacion de Autores"),
  omni_adv_doc_types = list(en = "Document Types (DT):", pt = "Tipos de Documento (DT):", es = "Tipos de Documento (DT):"),
  omni_adv_languages = list(en = "Languages (LA):", pt = "Idiomas (LA):", es = "Idiomas (LA):"),
  omni_adv_req_doi = list(en = "Only records with DOI", pt = "Apenas registros com DOI", es = "Solo registros con DOI"),
  omni_adv_req_ab = list(en = "Only records with Abstract", pt = "Apenas registros com Resumo", es = "Solo registros con Resumen"),
  omni_adv_norm_au = list(en = "Normalize Luso-Hispanic author names", pt = "Normalizar nomes de autores luso-hispanicos", es = "Normalizar nombres de autores luso-hispanos"),
  omni_adv_sec_network = list(en = "SciELO Collections, Network & Export", pt = "Colecoes SciELO, Rede e Exportacao", es = "Colecciones SciELO, Red y Exportacion"),
  omni_adv_scielo_col = list(en = "SciELO Collections (DOI Prefixes):", pt = "Colecoes SciELO (Prefixos DOI):", es = "Colecciones SciELO (Prefijos DOI):"),
  omni_adv_timeout = list(en = "API Timeout (seconds):", pt = "Timeout da API (segundos):", es = "Timeout de la API (segundos):"),
  omni_adv_csv_sep = list(en = "CSV Export Separator:", pt = "Separador de Exportacao CSV:", es = "Separador de Exportacion CSV:"),
  omni_adv_csv_bom = list(en = "UTF-8 BOM (Excel compatibility)", pt = "UTF-8 BOM (compatibilidade Excel)", es = "UTF-8 BOM (compatibilidad Excel)"),
  omni_adv_reset = list(en = "Reset Defaults", pt = "Restaurar Padroes", es = "Restaurar Valores"),
  omni_adv_reset_ok = list(en = "Advanced settings restored to defaults.", pt = "Configuracoes avancadas restauradas para os padroes.", es = "Configuracion avanzada restaurada a los valores predeterminados."),
  omni_help_dedup = list(
    en = "Automatically merges duplicate works across databases using validated canonical DOI and 90% fuzzy title matching with anti-false-positive guardrails (series and author checks), preserving cited references (CR).",
    pt = "Funde automaticamente trabalhos duplicados entre bases usando DOI canonico e similaridade de titulo validada em 90% com guardrails anti-falso positivo (series e autores), preservando referencias citadas (CR).",
    es = "Fusiona automaticamente trabajos duplicados entre bases usando DOI canonico y similitud de titulo validada al 90% con guardrails anti-falso positivo (series y autores), preservando referencias citadas (CR)."
  ),
  omni_help_enrich_cr = list(
    en = "Downloads full-text NLM/JATS XML for SciELO articles to reconstruct the Cited References (CR) field required for co-citation and bibliographic coupling networks. Increases retrieval time.",
    pt = "Baixa o XML NLM/JATS completo dos artigos do SciELO para reconstruir o campo Referencias Citadas (CR), necessario para redes de co-citacao e acoplamento bibliografico. Aumenta o tempo de coleta.",
    es = "Descarga el XML NLM/JATS completo de los articulos de SciELO para reconstruir el campo Referencias Citadas (CR), necesario para redes de co-citacion y acoplamiento bibliografico. Aumenta el tiempo de consulta."
  ),
  omni_help_doc_types = list(
    en = "Filter results to specific document types (e.g., Articles, Theses, Dissertations). Leave all unchecked to keep every document type returned by the repositories.",
    pt = "Filtra os resultados para tipos documentais especificos (ex.: Artigos, Teses, Dissertacoes). Deixe tudo desmarcado para manter todos os tipos retornados pelos repositorios.",
    es = "Filtra los resultados por tipos documentales especificos (ej.: Articulos, Tesis, Disertaciones). Deje todo desmarcado para conservar todos los tipos devueltos por los repositorios."
  ),
  omni_help_languages = list(
    en = "Restrict results to specific publication languages (Portuguese, Spanish, English). Leave all unchecked to retain works in all languages.",
    pt = "Restringe os resultados a idiomas especificos de publicacao (Portugues, Espanhol, Ingles). Deixe tudo desmarcado para manter obras em todos os idiomas.",
    es = "Restringe los resultados a idiomas especificos de publicacion (Portugues, Espanol, Ingles). Deje todo desmarcado para conservar obras en todos los idiomas."
  ),
  omni_help_req_doi = list(
    en = "Keep only bibliographic records that have a valid Digital Object Identifier (DOI). Useful for citation linking, though some theses in BDTD/Oasisbr lack DOIs.",
    pt = "Mantem apenas registros bibliograficos que possuem um DOI valido. Util para vinculacao de citacoes, embora muitas teses da BDTD/Oasisbr nao possuam DOI.",
    es = "Mantiene solo registros bibliograficos que poseen un DOI valido. Util para vinculacion de citas, aunque muchas tesis en BDTD/Oasisbr no tienen DOI."
  ),
  omni_help_req_ab = list(
    en = "Keep only records containing a non-empty abstract (AB). Recommended for text mining, topic modeling, and thematic map analyses.",
    pt = "Mantem apenas registros que possuem resumo (AB) preenchido. Recomendado para mineracao de texto, modelagem de topicos e mapas tematicos.",
    es = "Mantiene solo registros que poseen resumen (AB). Recomendado para mineria de texto, modelado de topicos y mapas tematicos."
  ),
  omni_help_norm_au = list(
    en = "Standardizes author names into canonical WoS format (SURNAME INITIALS) while preserving Brazilian/Hispanic generational suffixes (Filho, Neto, Junior, Sobrinho) and handling particles (da, de, del).",
    pt = "Padroniza nomes de autores no formato canonico WoS (SOBRENOME INICIAIS), preservando sufixos geracionais brasileiros/hispanicos (Filho, Neto, Junior, Sobrinho) e tratando particulas (da, de, del).",
    es = "Estandariza nombres de autores en formato canonico WoS (APELLIDO INICIALES), preservando sufijos generacionales brasilenos/hispanos (Filho, Neto, Junior, Sobrinho) y tratando particulas (da, de, del)."
  ),
  omni_help_scielo_col = list(
    en = "Select which SciELO national collections (Crossref DOI prefixes) to include when querying SciELO: Brazil (10.1590), Chile (10.4067), Spain (10.4321), Costa Rica (10.15517), Peru (10.17843), and Uruguay (10.26461).",
    pt = "Selecione quais colecoes nacionais do SciELO (prefixos DOI no Crossref) consultar: Brasil (10.1590), Chile (10.4067), Espanha (10.4321), Costa Rica (10.15517), Peru (10.17843) e Uruguai (10.26461).",
    es = "Seleccione que colecciones nacionales de SciELO (prefijos DOI en Crossref) consultar: Brasil (10.1590), Chile (10.4067), Espana (10.4321), Costa Rica (10.15517), Peru (10.17843) y Uruguay (10.26461)."
  ),
  omni_help_timeout = list(
    en = "Maximum time in seconds to wait for each repository API response. Increase to 60-120s if public portals such as IBICT (BDTD/Oasisbr) are responding slowly.",
    pt = "Tempo maximo em segundos para aguardar resposta de cada API. Aumente para 60-120s caso portais publicos como o IBICT (BDTD/Oasisbr) estejam lentos.",
    es = "Tiempo maximo en segundos para esperar respuesta de cada API. Aumente a 60-120s si portales publicos como IBICT (BDTD/Oasisbr) responden lentamente."
  ),
  omni_help_csv_sep = list(
    en = "Choose the column delimiter for exported CSV files: Comma (,) for R/Python/international tools, or Semicolon (;) to open directly in columns in Portuguese/Spanish Microsoft Excel.",
    pt = "Escolha o delimitador de colunas do arquivo CSV exportado: Virgula (,) para R/Python/padrao internacional, ou Ponto e virgula (;) para abrir direto em colunas no Microsoft Excel em Portugues/Espanhol.",
    es = "Elija el delimitador de columnas del archivo CSV exportado: Coma (,) para R/Python/estandar internacional, o Punto y coma (;) para abrir directo en columnas en Microsoft Excel en Espanol/Portugues."
  ),
  omni_help_csv_bom = list(
    en = "Prepends a UTF-8 Byte Order Mark (BOM) to exported CSV files so accented Portuguese and Spanish characters display properly when opened directly in Microsoft Excel on Windows.",
    pt = "Adiciona a marca UTF-8 BOM no inicio do CSV exportado para que acentos em portugues e espanhol aparecam corretamente ao abrir o arquivo direto no Microsoft Excel no Windows.",
    es = "Anade la marca UTF-8 BOM al inicio del CSV exportado para que los acentos en espanol y portugues se muestren correctamente al abrir el archivo directo en Microsoft Excel en Windows."
  ),

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
  scielo_tab_search = list(en = "Online Search (Keywords)", pt = "Busca Online (Palavras-chave)", es = "Busqueda en Linea (Palabras clave)"),
  scielo_query_label = list(en = "Search Query (Keywords, Title, Author, or Topic):", pt = "Termos de Busca (Palavras-chave, Titulo, Autor ou Tema):", es = "Terminos de Busqueda (Palabras clave, Titulo, Autor o Tema):"),
  scielo_query_ph = list(en = "e.g. dengue vaccine, public health, open science", pt = "ex: vacina dengue, saude coletiva, ciencia aberta", es = "ej: vacuna dengue, salud publica, ciencia abierta"),
  scielo_collections_label = list(en = "SciELO National Collections (Crossref DOI Prefixes):", pt = "Colecoes Nacionais SciELO (Prefixos DOI Crossref):", es = "Colecciones Nacionales SciELO (Prefijos DOI Crossref):"),
  scielo_col_br = list(en = "Brazil (10.1590)", pt = "Brasil (10.1590)", es = "Brasil (10.1590)"),
  scielo_col_cl = list(en = "Chile (10.4067)", pt = "Chile (10.4067)", es = "Chile (10.4067)"),
  scielo_col_es = list(en = "Spain (10.4321)", pt = "Espanha (10.4321)", es = "Espana (10.4321)"),
  scielo_col_cr = list(en = "Costa Rica (10.15517)", pt = "Costa Rica (10.15517)", es = "Costa Rica (10.15517)"),
  scielo_col_pe = list(en = "Peru (10.17843)", pt = "Peru (10.17843)", es = "Peru (10.17843)"),
  scielo_col_uy = list(en = "Uruguay (10.26461)", pt = "Uruguai (10.26461)", es = "Uruguay (10.26461)"),
  scielo_search_btn = list(en = "Search SciELO Articles", pt = "Buscar Artigos no SciELO", es = "Buscar Articulos en SciELO"),
  scielo_norm_au_label = list(en = "Normalize Brazilian & Hispanic author names (generational suffixes & particles)", pt = "Normalizar nomes de autores brasileiros e hispanicos (sufixos e particulas)", es = "Normalizar nombres de autores brasilenos e hispanos (sufijos y particulas)"),
  scielo_clear_btn = list(en = "Clear", pt = "Limpar", es = "Limpiar"),
  scielo_upload_format_label = list(en = "Select file format:", pt = "Selecione o formato do arquivo:", es = "Seleccione el formato del archivo:"),
  scielo_fmt_jats = list(en = "Full-text JATS XML package (.zip or .xml)", pt = "Pacote XML NLM/JATS completo (.zip ou .xml)", es = "Paquete XML NLM/JATS completo (.zip o .xml)"),
  scielo_fmt_csv = list(en = "Tabular metadata export (.csv)", pt = "Exportacao tabular de metadados (.csv)", es = "Exportacion tabular de metadatos (.csv)"),
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
  oasisbr_limit_label = list(en = "Max Records to Retrieve:", pt = "Limite Maximo de Registros:", es = "Limite Maximo de Registros:"),
  oasisbr_filter_label = list(en = "Filter Document Type (DT):", pt = "Filtrar Tipo de Documento (DT):", es = "Filtrar Tipo de Documento (DT):"),
  oasisbr_choice_all = list(en = "All Document Types", pt = "Todos os Tipos de Documento", es = "Todos los Tipos de Documento"),
  oasisbr_choice_articles = list(en = "Journal Articles Only", pt = "Apenas Artigos de Periodicos", es = "Solo Articulos de Revistas"),
  oasisbr_choice_theses = list(en = "Theses & Dissertations", pt = "Teses e Dissertacoes", es = "Tesis y Disertaciones"),
  oasisbr_choice_thesis_only = list(en = "Only Theses (Doutorado)", pt = "Apenas Teses (Doutorado)", es = "Solo Tesis (Doctorado)"),
  oasisbr_choice_diss_only = list(en = "Only Dissertations (Mestrado)", pt = "Apenas Dissertacoes (Mestrado)", es = "Solo Disertaciones (Maestria)"),
  oasisbr_choice_books = list(en = "Books & Book Chapters", pt = "Livros e Capitulos de Livros", es = "Libros y Capitulos de Libros"),
  oasisbr_choice_conf = list(en = "Conference Proceedings", pt = "Anais de Eventos", es = "Memorias de Congresos"),
  oasisbr_upload_label = list(en = "Select Oasisbr Export File (CSV or TSV):", pt = "Selecione Arquivo de Exportacao Oasisbr (CSV ou TSV):", es = "Seleccione Archivo de Exportacion Oasisbr (CSV o TSV):"),
  oasisbr_norm_label = list(en = "Normalize Brazilian author names (generational suffixes & particles)", pt = "Normalizar nomes de autores brasileiros (sufixos e particulas)", es = "Normalizar nombres de autores brasilenos (sufijos y particulas)"),
  oasisbr_fetch_btn = list(en = "Search & Retrieve from Oasisbr", pt = "Buscar e Recuperar do Oasisbr", es = "Buscar y Recuperar de Oasisbr"),
  oasisbr_process_btn = list(en = "Process Oasisbr File", pt = "Processar Arquivo Oasisbr", es = "Procesar Archivo Oasisbr"),

  # Redalyc
  redalyc_title = list(en = "Redalyc & AmeliCA Collection", pt = "Coleta Redalyc e AmeliCA", es = "Recoleccion Redalyc y AmeliCA"),
  redalyc_badge = list(en = "Non-commercial Diamond OA Network", pt = "Rede de Acesso Aberto Diamante Nao-Comercial", es = "Red de Acceso Abierto Diamante No Comercial"),
  redalyc_banner = list(
    en = "Ibero-American Diamond Open Access Journals: Upload bibliographic export files from Redalyc or AmeliCA in BibTeX (.bib), RIS (.ris), or CSV format. Standardizes Hispanic compound author surnames, journal sources, and keywords.",
    pt = "Periodicos Ibero-Americanos de Acesso Aberto Diamante: Envie arquivos exportados da Redalyc ou AmeliCA em formato BibTeX (.bib), RIS (.ris) ou CSV. Padroniza sobrenomes compostos hispanicos, periodicos e palavras-chave.",
    es = "Revistas Iberoamericanas de Acceso Abierto Diamante: Cargue archivos exportados de Redalyc o AmeliCA en formato BibTeX (.bib), RIS (.ris) o CSV. Estandariza apellidos compuestos hispanos, revistas y palabras clave."
  ),
  redalyc_tab_upload = list(en = "Upload Redalyc Export File", pt = "Upload de Arquivo Redalyc", es = "Carga de Archivo Redalyc"),
  redalyc_upload_label = list(en = "Select Redalyc Export File (CSV, TSV, RIS, or BibTeX):", pt = "Selecione Arquivo Redalyc (CSV, TSV, RIS ou BibTeX):", es = "Seleccione Archivo Redalyc (CSV, TSV, RIS o BibTeX):"),
  redalyc_norm_label = list(en = "Normalize Hispanic compound surnames", pt = "Normalizar sobrenomes compostos hispanicos", es = "Normalizar apellidos compuestos hispanos"),
  redalyc_process_btn = list(en = "Process Redalyc File", pt = "Processar Arquivo Redalyc", es = "Procesar Archivo Redalyc"),

  # SPELL
  spell_title = list(en = "SPELL / ANPAD Collection", pt = "Coleta SPELL / ANPAD", es = "Recoleccion SPELL / ANPAD"),
  spell_badge = list(en = "Administration, Accounting & Economics", pt = "Administracao, Contabilidade e Economia", es = "Administracion, Contabilidad y Economia"),
  spell_banner = list(
    en = "Scientific Periodicals Electronic Library (SPELL / ANPAD): Upload CSV or TSV metadata exports from SPELL. Automatically detects column delimiters and encodings (UTF-8 / Latin-1), standardizes Brazilian author names, and converts articles to bibliometrixDB format.",
    pt = "Scientific Periodicals Electronic Library (SPELL / ANPAD): Envie exportacoes CSV ou TSV de metadados do SPELL. Detecta automaticamente delimitadores e codificacoes (UTF-8 / Latin-1), padroniza autores brasileiros e converte artigos para o formato bibliometrixDB.",
    es = "Scientific Periodicals Electronic Library (SPELL / ANPAD): Cargue exportaciones CSV o TSV de metadatos de SPELL. Detecta automaticamente delimitadores y codificaciones (UTF-8 / Latin-1), estandariza autores brasilenos y convierte articulos al formato bibliometrixDB."
  ),
  spell_upload_label = list(en = "Select SPELL Export File (CSV or TSV):", pt = "Selecione Arquivo de Exportacao SPELL (CSV ou TSV):", es = "Seleccione Archivo de Exportacion SPELL (CSV o TSV):"),
  spell_process_btn = list(en = "Process SPELL File", pt = "Processar Arquivo SPELL", es = "Procesar Archivo SPELL"),
  spell_preview_title = list(en = "SPELL Collection Preview & Metrics", pt = "Previa da Coleta SPELL e Metricas", es = "Vista Previa de la Coleccion SPELL y Metricas"),

  # Merge
  merge_title = list(en = "Cross-Database Merge & Deduplication", pt = "Unificacao e Deduplicacao Entre Bases", es = "Fusion y Deduplicacion Entre Bases"),
  merge_badge = list(en = "Regional & Global Data Harmonizer", pt = "Harmonizador Regional e Global de Dados", es = "Armonizador Regional y Global de Datos"),
  merge_banner = list(
    en = "Harmonize & Fuse Latin American Collections: Merge two datasets (e.g. SciELO + Oasisbr or SciELO + SPELL), automatically resolve duplicate records using canonical DOI cleaning and fuzzy title matching, and enrich complementary fields (Cited References, Abstracts, Keywords).",
    pt = "Harmonize e Funda Colecoes Latino-Americanas: Unifique duas bases (ex.: SciELO + Oasisbr ou SciELO + SPELL), resolva duplicatas automaticamente via limpeza canonica de DOI e casamento aproximado de titulo, e enriqueca campos complementares (Referencias Citadas, Resumos, Palavras-chave).",
    es = "Armonice y Fusione Colecciones Latinoamericanas: Unifique dos bases (ej.: SciELO + Oasisbr o SciELO + SPELL), resuelva duplicados automaticamente mediante limpieza canonica de DOI y similitud de titulo, y enriquezca campos complementarios (Referencias Citadas, Resumenes, Palabras clave)."
  ),
  merge_source1_label = list(en = "Choose Source for Dataset 1:", pt = "Escolha a Fonte do Conjunto 1:", es = "Elija la Fuente del Conjunto 1:"),
  merge_s1_active = list(en = "Currently Loaded Collection in App", pt = "Colecao Atualmente Carregada no App", es = "Coleccion Actualmente Cargada en la App"),
  merge_s1_file = list(en = "Upload New File (.csv, .RData, .tsv, .bib, .ris)", pt = "Enviar Novo Arquivo (.csv, .RData, .tsv, .bib, .ris)", es = "Cargar Nuevo Archivo (.csv, .RData, .tsv, .bib, .ris)"),
  merge_file1_label = list(en = "Select Dataset 1 File:", pt = "Selecione o Arquivo do Conjunto 1:", es = "Seleccione el Archivo del Conjunto 1:"),
  merge_source2_label = list(en = "Select Dataset 2 File (.csv, .RData, .tsv, .bib, .ris):", pt = "Selecione o Arquivo do Conjunto 2 (.csv, .RData, .tsv, .bib, .ris):", es = "Seleccione el Archivo del Conjunto 2 (.csv, .RData, .tsv, .bib, .ris):"),
  merge_criteria_label = list(en = "Matching & Deduplication Criteria:", pt = "Criterios de Casamento e Deduplicacao:", es = "Criterios de Emparejamiento y Deduplicacion:"),
  merge_crit_doi = list(en = "Canonical Clean DOI", pt = "DOI Canonico Higienizado", es = "DOI Canonico Limpio"),
  merge_crit_title = list(en = "Fuzzy Title Matching", pt = "Similaridade Aproximada de Titulo", es = "Similitud Aproximada de Titulo"),
  merge_thresh_label = list(en = "Title Similarity Threshold:", pt = "Limiar de Similaridade de Titulo:", es = "Umbral de Similitud de Titulo:"),
  merge_btn = list(en = "Merge & Deduplicate Collections", pt = "Unificar e Deduplicar Colecoes", es = "Fusionar y Deduplicar Colecciones"),

  # Shared KPI Boxes & Export Actions
  export_csv_btn = list(en = "Export CSV", pt = "Exportar CSV", es = "Exportar CSV"),
  export_excel_btn = list(en = "Export CSV", pt = "Exportar CSV", es = "Exportar CSV"),
  export_rdata_btn = list(en = "Export .RData", pt = "Exportar .RData", es = "Exportar .RData"),
  load_biblioshiny_btn = list(en = "Load into Biblioshiny", pt = "Carregar no Biblioshiny", es = "Cargar en Biblioshiny"),
  kpi_total_works = list(en = "TOTAL WORKS", pt = "TOTAL DE OBRAS", es = "TOTAL DE OBRAS"),
  kpi_total_articles = list(en = "TOTAL ARTICLES", pt = "TOTAL DE ARTIGOS", es = "TOTAL DE ARTICULOS"),
  kpi_theses_diss = list(en = "THESES / DISSERTATIONS", pt = "TESES / DISSERTACOES", es = "TESIS / DISERTACIONES"),
  kpi_institutions = list(en = "INSTITUTIONS", pt = "INSTITUICOES", es = "INSTITUCIONES"),
  kpi_authors = list(en = "AUTHORS", pt = "AUTORES", es = "AUTORES"),
  kpi_sources_repos = list(en = "SOURCES / REPOSITORIES", pt = "FONTES / REPOSITORIOS", es = "FUENTES / REPOSITORIOS"),
  kpi_journals = list(en = "JOURNALS", pt = "PERIODICOS", es = "REVISTAS"),
  kpi_timespan = list(en = "TIMESPAN", pt = "PERIODO", es = "PERIODO"),
  kpi_initial_combined = list(en = "INITIAL COMBINED", pt = "TOTAL INICIAL COMBINADO", es = "TOTAL INICIAL COMBINADO"),
  kpi_dups_resolved = list(en = "DUPLICATES RESOLVED", pt = "DUPLICATAS RESOLVIDAS", es = "DUPLICADOS RESUELTOS"),
  kpi_final_unique = list(en = "FINAL UNIQUE WORKS", pt = "OBRAS UNICAS FINAIS", es = "OBRAS UNICAS FINALES"),
  kpi_sources_fused = list(en = "SOURCES FUSED", pt = "FONTES FUNDIDAS", es = "FUENTES FUSIONADAS"),

  # Previews & Diagnostics
  scielo_preview_title = list(en = "Dataset Preview & Quality Summary", pt = "Previa do Conjunto de Dados e Resumo de Qualidade", es = "Vista Previa del Conjunto de Datos y Resumen de Calidad"),
  bdtd_preview_title = list(en = "BDTD Collection Preview & Metrics", pt = "Previa da Coleta BDTD e Metricas", es = "Vista Previa de la Coleccion BDTD y Metricas"),
  oasisbr_preview_title = list(en = "Oasisbr Collection Preview & Metrics", pt = "Previa da Coleta Oasisbr e Metricas", es = "Vista Previa de la Coleccion Oasisbr y Metricas"),
  redalyc_preview_title = list(en = "Redalyc Collection Preview & Metrics", pt = "Previa da Coleta Redalyc e Metricas", es = "Vista Previa de la Coleccion Redalyc y Metricas"),
  merge_d1_title = list(en = "Dataset 1 (Primary / Base)", pt = "Conjunto de Dados 1 (Primario / Base)", es = "Conjunto de Datos 1 (Primario / Base)"),
  merge_d2_title = list(en = "Dataset 2 (To Merge & Fuse)", pt = "Conjunto de Dados 2 (Para Unificar e Fundir)", es = "Conjunto de Datos 2 (Para Fusionar y Unificar)"),
  merge_metrics_title = list(en = "Merged Collection Metrics & Diagnostics", pt = "Metricas e Diagnosticos da Coleta Unificada", es = "Metricas y Diagnosticos de la Coleccion Fusionada"),

  # About
  info_title = list(en = "bibliolatam", pt = "bibliolatam", es = "bibliolatam"),
  info_tagline = list(
    en = "Latin American & Iberian Bibliographic Data Adapter for 'bibliometrix' and 'biblioshiny'.",
    pt = "Adaptador de Dados Bibliograficos Latino-Americanos e Ibericos para 'bibliometrix' e 'biblioshiny'.",
    es = "Adaptador de Datos Bibliograficos Latinoamericanos e Ibericos para 'bibliometrix' y 'biblioshiny'."
  ),
  info_why = list(en = "Why bibliolatam?", pt = "Por que o bibliolatam?", es = "Por que bibliolatam?"),
  info_why_p1 = list(
    en = "Mainstream bibliometric pipelines primarily support commercial North American and European indexes (Scopus, Web of Science, Dimensions, PubMed). In Latin America, Spain, and Portugal, a vast portion of high-impact research is published under <strong>Diamond Open Access</strong> repositories (SciELO, Redalyc) or preserved in national graduate thesis libraries (BDTD/Oasisbr, LA Referencia).",
    pt = "Os principais fluxos de trabalho bibliometricos atendem primordialmente a indices comerciais norte-americanos e europeus (Scopus, Web of Science, Dimensions, PubMed). Na America Latina, Espanha e Portugal, uma parcela substancial da pesquisa de alto impacto e publicada em repositorios de <strong>Acesso Aberto Diamante</strong> (SciELO, Redalyc) ou preservada em bibliotecas nacionais de teses e dissertacoes (BDTD/Oasisbr, LA Referencia).",
    es = "Los principales flujos de trabajo bibliometricos atienden primordialmente a indices comerciales norteamericanos y europeos (Scopus, Web of Science, Dimensions, PubMed). En America Latina, Espana y Portugal, una parte sustancial de la investigacion de alto impacto se publica en repositorios de <strong>Acceso Abierto Diamante</strong> (SciELO, Redalyc) o se preserva en bibliotecas nacionales de tesis y disertaciones (BDTD/Oasisbr, LA Referencia)."
  ),
  info_why_p2 = list(
    en = "Because <code>bibliometrix</code> limits its built-in parsers to global multidisciplinary databases to keep maintenance sustainable (Issue #689), <strong>bibliolatam</strong> acts as an official bridge. It parses raw XML, CSV, and OAI-PMH records from Latin American platforms, normalizes regional author naming patterns (Brazilian generational suffixes and Hispanic compound surnames), and injects standardized <code>bibliometrixDB</code> data frames directly into the analysis engine.",
    pt = "Como o <code>bibliometrix</code> restringe seus parsers nativos a bases globais multidisciplinares para manter sua sustentabilidade (Issue #689), o <strong>bibliolatam</strong> atua como uma ponte oficial. Ele processa registros brutos em XML, CSV e OAI-PMH de plataformas latino-americanas, normaliza padroes regionais de nomes de autores (aglutinacoes geracionais brasileiras e sobrenomes compostos hispanicos) e injeta data frames padronizados do <code>bibliometrixDB</code> diretamente no motor de analise.",
    es = "Dado que <code>bibliometrix</code> restringe sus analizadores nativos a bases globales multidisciplinares para mantener la sostenibilidad (Issue #689), <strong>bibliolatam</strong> actua como un puente oficial. Procesa registros brutos en XML, CSV y OAI-PMH de plataformas latinoamericanas, normaliza patrones regionales de nombres de autores (sufijos generacionales brasilenos y apellidos compuestos hispanos) e inyecta data frames estandarizados de <code>bibliometrixDB</code> directamente en el motor de analisis."
  ),
  info_repos_title = list(
    en = "Supported & Planned Regional Repositories",
    pt = "Repositorios Regionais Suportados e Planejados",
    es = "Repositorios Regionales Soportados y Planificados"
  ),
  info_badge_active = list(en = "ACTIVE", pt = "ATIVO", es = "ACTIVO"),
  info_scielo_desc = list(
    en = "Scientific Electronic Library Online. Multidisciplinary diamond OA network across 16 countries. Full NLM/JATS XML parsing with cited references (CR) extraction and direct DOI/PID download engine.",
    pt = "Scientific Electronic Library Online. Rede multidisciplinar de acesso aberto diamante presente em 16 paises. Processamento completo de XML NLM/JATS com extracao de referencias citadas (CR) e mecanismo de download direto por DOI/PID.",
    es = "Scientific Electronic Library Online. Red multidisciplinar de acceso abierto diamante en 16 paises. Procesamiento completo de XML NLM/JATS con extraccion de referencias citadas (CR) y motor de descarga directa por DOI/PID."
  ),
  info_bdtd_desc = list(
    en = "Brazilian Digital Library of Theses and Dissertations (IBICT). Online API search and tabular parsing for theses (Doutorado) and dissertations (Mestrado), graduate programs, and advisor mapping.",
    pt = "Biblioteca Digital Brasileira de Teses e Dissertacoes (IBICT). Busca online via API e analise tabular de teses (Doutorado) e dissertacoes (Mestrado), programas de pos-graduacao e mapeamento de orientadores.",
    es = "Biblioteca Digital Brasilena de Tesis y Disertaciones (IBICT). Busqueda en linea por API y analisis tabular de tesis (Doctorado) y disertaciones (Maestria), programas de posgrado y mapeo de asesores."
  ),
  info_oasisbr_desc = list(
    en = "Brazilian Open Access Portal (IBICT). Online search and tabular parsing for multidisciplinary production: articles, theses, books, and conference proceedings across institutional repositories.",
    pt = "Portal Brasileiro de Publicacoes Cientificas em Acesso Aberto (IBICT). Busca online e analise tabular de producao multidisciplinar: artigos, teses, livros e anais em repositorios institucionais.",
    es = "Portal Brasileno de Publicaciones Cientificas en Acceso Abierto (IBICT). Busqueda en linea y analisis tabular de produccion multidisciplinaria: articulos, tesis, libros y memorias en repositorios institucionales."
  ),
  info_spell_desc = list(
    en = "Scientific Periodicals Electronic Library. Specialized index by ANPAD for Business Administration, Accounting, Economics, and Public Management.",
    pt = "Scientific Periodicals Electronic Library. Indice especializado da ANPAD para Administracao, Contabilidade, Economia e Gestao Publica.",
    es = "Scientific Periodicals Electronic Library. Indice especializado de ANPAD para Administracion, Contabilidad, Economia y Gestion Publica."
  ),
  info_redalyc_desc = list(
    en = "Network of Scientific Journals from Latin America and the Caribbean, Spain and Portugal (UAEMex). Parses BibTeX, RIS, and CSV formats with Hispanic compound author name resolution.",
    pt = "Rede de Periodicos Cientificos da America Latina e Caribe, Espanha e Portugal (UAEMex). Analise de formatos BibTeX, RIS e CSV com resolucao de sobrenomes compostos hispanicos.",
    es = "Red de Revistas Cientificas de America Latina y el Caribe, Espana y Portugal (UAEMex). Analisis de formatos BibTeX, RIS y CSV con resolucion de apellidos compuestos hispanos."
  ),
  info_lareferencia_desc = list(
    en = "Federated Network of Institutional Repositories of Scientific Publications. Continental aggregator connecting university research outputs from 12 Latin American nations with live VuFind API integration.",
    pt = "Rede Federada de Repositorios Institucionais de Publicacoes Cientificas. Agregador continental integrando a producao cientifica universitaria de 12 paises latino-americanos via API VuFind.",
    es = "Red Federada de Repositorios Institucionales de Publicaciones Cientificas. Agregador continental que integra la produccion cientifica universitaria de 12 paises latinoamericanos mediante API VuFind."
  ),
  info_omnisearch_box_title = list(
    en = "Omnisearch Engine (SciELO + BDTD + Oasisbr + LA Referencia)",
    pt = "Mecanismo Omnisearch (SciELO + BDTD + Oasisbr + LA Referencia)",
    es = "Motor Omnisearch (SciELO + BDTD + Oasisbr + LA Referencia)"
  ),
  info_omnisearch_desc = list(
    en = "Unified 1-click discovery engine across peer-reviewed journals, national graduate thesis archives, and open access repositories across Latin America with automated DOI and fuzzy title deduplication.",
    pt = "Mecanismo unificado de busca em 1 clique abrangendo periodicos revisados por pares, bancos nacionais de teses e repositorios de acesso aberto na America Latina, com deduplicacao automatica por DOI e titulo aproximado.",
    es = "Motor unificado de busqueda en 1 clic que abarca revistas revisadas por pares, repositorios nacionales de tesis y archivos de acceso abierto en America Latina, con deduplicacion automatica por DOI y titulo aproximado."
  ),
  info_gov_title = list(
    en = "Principles & Governance",
    pt = "Principios e Governanca",
    es = "Principios y Gobernanza"
  ),
  info_gov_fair_title = list(
    en = "FAIR Principles: ",
    pt = "Principios FAIR: ",
    es = "Principios FAIR: "
  ),
  info_gov_fair_desc = list(
    en = "Findable, Accessible, Interoperable, and Reusable data standards for regional science.",
    pt = "Padroes de dados Localizaveis, Acessiveis, Interoperaveis e Reutilizaveis para a ciencia regional.",
    es = "Estandares de datos Localizables, Accesibles, Interoperables y Reutilizables para la ciencia regional."
  ),
  info_gov_boai_title = list(
    en = "BOAI Adherence: ",
    pt = "Adesao a BOAI: ",
    es = "Adhesion a BOAI: "
  ),
  info_gov_boai_desc = list(
    en = "Committed to the Budapest Open Access Initiative and non-commercial scientific communication.",
    pt = "Compromisso com a Iniciativa de Acesso Aberto de Budapeste e comunicacao cientifica nao-comercial.",
    es = "Compromiso con la Iniciativa de Acceso Abierto de Budapest y la comunicacion cientifica no comercial."
  ),
  info_gov_license_title = list(
    en = "Dual Licensing: ",
    pt = "Licenciamento Duplo: ",
    es = "Licenciamiento Doble: "
  ),
  info_gov_license_desc = list(
    en = "Source code licensed under GNU GPL-3.0. Metadata fixtures protected under CC BY-NC-SA 4.0 with Anti-AI commercial ingestion restrictions.",
    pt = "Codigo-fonte sob licenca GNU GPL-3.0. Amostras de metadados sob licenca CC BY-NC-SA 4.0 com restricoes contra ingestao comercial por IA.",
    es = "Codigo fuente bajo licencia GNU GPL-3.0. Muestras de metadatos bajo licencia CC BY-NC-SA 4.0 con restricciones contra ingestion comercial por IA."
  ),
  info_gov_dev_title = list(
    en = "Open Development: ",
    pt = "Desenvolvimento Aberto: ",
    es = "Desarrollo Abierto: "
  ),
  info_gov_dev_repo = list(
    en = "GitHub Repository (BRAN-Org/bibliolatam)",
    pt = "Repositorio no GitHub (BRAN-Org/bibliolatam)",
    es = "Repositorio en GitHub (BRAN-Org/bibliolatam)"
  ),
  info_gov_conventions_title = list(
    en = "Methodological Transparency: ",
    pt = "Transparencia Metodologica: ",
    es = "Transparencia Metodologica: "
  ),
  info_gov_conventions_desc = list(
    en = "Times Cited (TC = 0) reflects unindexed citation counts in regional aggregators rather than confirmed zero citations. Keywords Plus (ID <- DE) mirrors Author Keywords when absent for bibliometrix downstream compatibility.",
    pt = "Citacoes (TC = 0) reflete ausencia de indexacao de citacoes no agregador regional e nao zero citacoes reais. Keywords Plus (ID <- DE) espelha palavras-chave do autor quando ausente para compatibilidade com bibliometrix.",
    es = "Citas (TC = 0) refleja falta de indexacion de citas en el agregador regional y no cero citas reales. Keywords Plus (ID <- DE) refleja palabras clave del autor cuando ausente para compatibilidad con bibliometrix."
  ),
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
  if (is.null(key) || !is.character(key) || length(key) == 0L || !nzchar(key[1])) {
    return(key)
  }

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

    // Translate DOM elements with data-i18n-html
    document.querySelectorAll("[data-i18n-html]").forEach(function(el) {
      var k = el.getAttribute("data-i18n-html");
      if (dict[k] && dict[k][lang]) {
        el.innerHTML = dict[k][lang];
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
      "SPELL": "tab_spell",
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
