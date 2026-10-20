# bibliolatam: Adaptadores de Datos Bibliográficos Latinoamericanos para 'bibliometrix'

<p align="left">
  <a href="README.md"><img src="docs/assets/badge-english.svg" alt="English Version" height="28" /></a>
  <a href="README.pt-BR.md"><img src="docs/assets/badge-portugues.svg" alt="Versão em Português" height="28" /></a>
  <a href="README.es.md"><img src="docs/assets/badge-espanol.svg" alt="Versión en Español" height="28" /></a>
</p>

`bibliolatam` es un paquete complementario en R diseñado para conectar la literatura científica de acceso abierto de América Latina y el Caribe con los flujos de análisis bibliométrico y cienciométrico de [`bibliometrix`](https://github.com/massimoaria/bibliometrix).

---

## ¿Por qué existe bibliolatam?

La mayoría de las herramientas bibliométricas tradicionales asumen índices comerciales de acceso cerrado del Norte Global (Web of Science, Scopus). Sin embargo, la producción científica en América Latina, el Caribe y la Península Ibérica se distribuye predominantemente en modelos no comerciales de **Acceso Abierto Diamante** (como SciELO, Redalyc y SPELL) y se preserva en repositorios nacionales de tesis y disertaciones (como BDTD y Oasisbr en Brasil, y la federación LA Referencia en 12 países).

Debido a que el núcleo de `bibliometrix` restringe deliberadamente sus convertidores nativos a las grandes bases internacionales para mantener la sostenibilidad del código (como se documenta en el [issue #689 de bibliometrix](https://github.com/massimoaria/bibliometrix/issues/689)), `bibliolatam` actúa como un adaptador modular externo. Procesa archivos exportados y consulta APIs REST públicas de estas plataformas regionales, armoniza metadatos heterogéneos en el contrato canónico S3 `bibliometrixDB` y proporciona integración directa con `biblioshiny` y una aplicación interactiva propia (`run_app()`).

---

## Instalación

Instale la versión de desarrollo directamente desde GitHub:

```r
# Usando remotes
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("BRAN-Org/bibliolatam")

# O usando pak
if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak")
pak::pkg_install("BRAN-Org/bibliolatam")
```

### Requisitos y Dependencias

- **Obligatorio**: R (>= 3.6.0).
- **Para consultas a APIs REST**: `jsonlite`, `utils`, `tools`.
- **Para análisis bibliométricos avanzados**: `bibliometrix` (>= 4.0.0).
- **Para la interfaz gráfica interactiva**: `shiny`.

---

## Arquitectura y Flujo de Datos

```text
[ Fuentes Latinoamericanas e Ibéricas ]
├── SciELO          (Archivos: CSV, JATS XML | APIs: Crossref works, XMLs NLM)
├── BDTD / Oasisbr  (Archivos: CSV, TSV      | APIs: IBICT VuFind Solr)
├── LA Referencia   (APIs: VuFind REST v1 para 12 redes nacionales)
├── Redalyc         (Archivos: BibTeX, RIS, CSV)
└── SPELL / ANPAD   (Archivos: CSV)
         │
         ▼
[ Motor de bibliolatam ]
├── Parsers Locales y Clientes REST (Manejo defensivo de red y paginación)
├── Normalizador de Autores (Apellidos compuestos hispanos y sufijos generacionales)
├── Deduplicación entre Fuentes (Resolución por DOI exacto y similitud de título)
└── Armonizador Canónico (`as_bibliometrix`)
         │
         ▼
[ Objeto bibliometrixDB ]
├── Scripts R: `biblioAnalysis()`, `biblioNetwork()`, etc.
├── Interfaz Standalone: `bibliolatam::run_app()`
└── Biblioshiny: Inyección reactiva directa o exportación a `.RData`
```

---

## Fuentes Soportadas y Modos de Uso

| Fuente | Alcance Geográfico | Tipología | Modo de Ingestión | Aspectos Técnicos Destacados |
|:---|:---|:---|:---|:---|
| **SciELO** | América Latina, Caribe, España, Portugal | Artículos de Revistas | Archivo (`read_scielo`, `read_scielo_jats`) y API (`download_scielo_search`, `download_scielo_jats`) | Referencias citadas (`CR`) reconstruidas desde XML NLM/JATS; búsqueda online vía Crossref (prefijo `10.1590`). |
| **BDTD** | Brasil | Tesis y Disertaciones | Archivo (`read_bdtd`) y API REST (`download_bdtd`) | Asesores/Directores académicos (`RP`), grados académicos (`DT` como THESIS/DISSERTATION), paginación VuFind Solr. |
| **Oasisbr** | Brasil | Artículos, Tesis, Informes | Archivo (`read_oasisbr`) y API REST (`download_oasisbr`) | Portal brasileño de publicaciones en acceso abierto multidisciplinario. |
| **LA Referencia** | 12 Países (AR, BR, CL, CO, CR, EC, ES, MX, PA, PE, SV, UY) | Redes Nacionales de Repositorios | API REST (`download_lareferencia`) | Consulta federada a cosechadores de redes nacionales de repositorios de América Latina. |
| **Redalyc / AmeliCA** | Iberoamérica | Revistas Diamante | Archivo (`read_redalyc`) | Formatos BibTeX (`.bib`), RIS (`.ris`) y CSV con normalización de apellidos compuestos hispanos. |
| **SPELL (ANPAD)** | Brasil | Administración y Economía | Archivo (`read_spell`) | Exportaciones tabulares, detección automática de delimitador (`;`, `,`, `\t`) y codificación (Latin-1/UTF-8). |
| **Omnisearch** | Regional (Multi-Fuente) | Todas las Tipologías | Función R y Panel Shiny | Búsqueda federada simultánea (SciELO, BDTD, Oasisbr, LA Referencia) con filtro temporal y deduplicación. |

---

## Tutoriales Prácticos y Ejemplos

### 1. Omnisearch Federado (Búsqueda Online Simultánea)

Consulte múltiples repositorios simultáneamente en una sola línea de código, con filtros por año en las APIs y deduplicación automática:

```r
library(bibliolatam)
library(bibliometrix)

# Consulta unificada en SciELO, BDTD, Oasisbr y LA Referencia
resultados <- omnisearch_bibliolatam(
  query = "energia solar",
  sources = c("scielo", "bdtd", "oasisbr", "lareferencia"),
  limit_per_source = 50,
  years = c(2020, 2024),
  deduplicate = TRUE,
  progress = TRUE
)

# Ejecuta análisis de bibliometrix directamente
analisis <- biblioAnalysis(resultados)
summary(analisis)
```

---

### 2. Búsqueda Automatizada vía APIs REST Específicas

Consulte repositorios específicos directamente mediante R sin necesidad de descargar archivos manualmente:

```r
library(bibliolatam)

# 1. Tesis y disertaciones en BDTD
tesis <- download_bdtd(
  query = "inteligencia artificial salud",
  limit = 50,
  years = c(2021, 2024)
)

# 2. Artículos de SciELO enriquecidos con Referencias Citadas (CR) vía JATS XML
articulos <- download_scielo_search(
  query = "vacuna dengue",
  limit = 30,
  years = c(2020, 2024),
  enrich_references = TRUE
)

# 3. Repositorios de 12 países vía LA Referencia
paises_latinos <- download_lareferencia(
  query = "cambio climatico",
  limit = 50,
  years = c(2019, 2024)
)
```

---

### 3. Lectura de Archivos Locales Exportados

Para colecciones extensas descargadas directamente desde los portales web oficiales:

```r
library(bibliolatam)
library(bibliometrix)

# SciELO: CSV exportado o XML NLM/JATS
df_scielo <- read_scielo("scielo_busqueda.csv")
df_jats   <- read_scielo_jats("articulo_scielo.xml")

# BDTD / Oasisbr: Exportaciones en CSV o TSV
df_bdtd <- read_bdtd("tesis_bdtd.csv")

# Redalyc: Archivos BibTeX, RIS o CSV
df_redalyc <- read_redalyc("redalyc_export.bib")

# SPELL: CSV de ANPAD (Administración y Economía)
df_spell <- read_spell("spell_articulos.csv")

# Validación y garantía del contrato bibliometrixDB
M <- as_bibliometrix(df_scielo, dbsource = "scielo")
```

---

### 4. Normalización de Nombres de Autores

`normalize_authors()` estandariza cadenas de nombres individuales o vectores completos, gestionando partículas y apellidos compuestos:

```r
library(bibliolatam)

# Cadena simple con múltiples autores
normalize_authors("Batista Filho, Jose Rodrigues; Perez Gomez, Maria del Carmen")
# Resultado: "BATISTA FILHO JR; PEREZ GOMEZ MC"

# Vector de autores
autores <- c("Gama, Gabriel", "Antonio Carlos Neto", "Maria de la Cruz Hernandez")
normalize_authors(autores)
```

---

### 5. Fusión y Deduplicación entre Fuentes Heterogéneas

Para combinar colecciones de diferentes orígenes eliminando redundancias:

```r
library(bibliolatam)

# Unifica dos colecciones (ej. SciELO + Oasisbr)
# Resuelve duplicados por DOI normalizado y similitud de título (Levenshtein)
corpus_unificado <- merge_bibliolatam(df_scielo, df_bdtd, match_by = c("doi", "title"))
```

---

### 6. Aplicación Web Interactiva (`run_app`)

Para usar la interfaz web interactiva con soporte trilingüe (**Español**, **Português**, **English**):

```r
library(bibliolatam)

# Inicia la aplicación en el navegador predeterminado
run_app()
```

O para exportar directamente a `biblioshiny`:
```r
export_biblioshiny(resultados, "corpus_latino.RData")
# En biblioshiny -> Data -> Load bibliometrix RData -> cargar archivo
```

---

## Matriz de Compatibilidad Analítica

| Módulo Analítico | Campos Requeridos | Fuentes Soportadas | Comportamiento |
|:---|:---|:---|:---|
| **Producción Anual y Dinámica** | `PY`, `SO`, `DT` | **Todas** (SciELO, BDTD, Oasisbr, Redalyc, LA Referencia, SPELL) | **100% Funcional**. Producción anual, Ley de Bradford y relevancia de revistas/instituciones. |
| **Estructura Conceptual y Tópicos** | `TI`, `AB`, `DE`, `ID` | **Todas** | **100% Funcional**. Redes de coocurrencia, mapas temáticos (`thematicMap`) y análisis factorial. |
| **Redes de Colaboración** | `AU`, `C1`, `RP` | **Todas** | **100% Funcional**. Nombres normalizados por `normalize_authors()`. |
| **Estructura Intelectual (Cocitación y Acoplamiento)** | `CR` (Cited References) | **SciELO (vía JATS XML)** | **Soportado en SciELO**: El parser JATS y la opción `enrich_references = TRUE` reconstruyen `<ref-list>` en `CR`.<br>**No disponible en BDTD / LA Referencia / Redalyc CSV**. |
| **Métricas de Impacto Global** | `TC` (Times Cited) | N/A (inicializado en `0`) | **Campo presente, métrica limitada**: APIs abiertas públicas no proporcionan conteos propietarios. Se inicializa en `0` para compatibilidad. |

---

## Principios y Licencia

- **[Principios FAIR](https://www.gofair.foundation/fair-principles)**: Promoviendo Encontrabilidad, Accesibilidad, Interoperabilidad y Reusabilidad para la ciencia del Sur Global.
- **[Declaración BOAI](https://www.budapestopenaccessinitiative.org/)**: Compromiso con infraestructuras de Acceso Abierto Diamante.
- **Licencia Dual**:
  - **Código Fuente**: [GNU General Public License v3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl-3.0.html) - Software libre copyleft.
  - **Datos de Ejemplo (`inst/extdata/`)**: [Creative Commons Atribución-NoComercial-CompartirIgual 4.0 (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/) - Para investigación y pruebas académicas.
