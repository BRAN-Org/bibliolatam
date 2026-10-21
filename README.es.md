# bibliolatam: Adaptadores de Datos Bibliográficos Latinoamericanos para 'bibliometrix'

<p align="left">
  <a href="https://github.com/BRAN-Org/bibliolatam/blob/main/README.md"><img src="https://raw.githubusercontent.com/BRAN-Org/bibliolatam/main/docs/assets/badge-english.svg" alt="English Version" height="28" /></a>
  <a href="https://github.com/BRAN-Org/bibliolatam/blob/main/README.pt-BR.md"><img src="https://raw.githubusercontent.com/BRAN-Org/bibliolatam/main/docs/assets/badge-portugues.svg" alt="Versão em Português" height="28" /></a>
  <a href="https://github.com/BRAN-Org/bibliolatam/blob/main/README.es.md"><img src="https://raw.githubusercontent.com/BRAN-Org/bibliolatam/main/docs/assets/badge-espanol.svg" alt="Versión en Español" height="28" /></a>
</p>

`bibliolatam` es un paquete en R diseñado para conectar la literatura científica de acceso abierto de América Latina, el Caribe y la Península Ibérica tanto a flujos de trabajo autónomos (**Modo Standalone**) como al ecosistema cienciométrico de [`bibliometrix`](https://github.com/massimoaria/bibliometrix) y [`biblioshiny`](https://github.com/massimoaria/bibliometrix).

---

## ¿Por qué existe bibliolatam?

La mayoría de las herramientas bibliométricas tradicionales asumen índices comerciales y propietarios del Norte Global (Web of Science, Scopus). Sin embargo, la producción científica en América Latina, el Caribe y la Península Ibérica se publica predominantemente bajo modelos no comerciales de **Acceso Abierto Diamante** (como SciELO, Redalyc y SPELL) y se preserva en repositorios nacionales de tesis y disertaciones (como BDTD y Oasisbr en Brasil, y la federación LA Referencia en 12 países).

Debido a que el núcleo de `bibliometrix` restringe deliberadamente sus convertidores nativos a las grandes bases internacionales para mantener la sostenibilidad del código (como se documenta en el [issue #689 de bibliometrix](https://github.com/massimoaria/bibliometrix/issues/689)), `bibliolatam` actúa como un puente modular y desacoplado. Permite cosechar, desduplicar, normalizar y exportar estos datos de manera **100% autónoma** o armonizarlos en el contrato canónico S3 `bibliometrixDB` para análisis cienciométricos y modelado de redes avanzadas.

---

## Dos Modos de Operación: Standalone o Integrado

`bibliolatam` fue diseñado para estar completamente desacoplado. Puede utilizarse de dos formas:

### 1. Modo Standalone (Independiente)
* **Sin dependencia de `bibliometrix`**: Funciona únicamente con R base y paquetes ligeros (`shiny`, `jsonlite`, `utils`, `tools`).
* **Aplicación Web Propia (`run_app()`)**: Incluye un panel interactivo completo con **soporte trilingüe en tiempo real** (🇬🇧 Inglés, 🇧🇷 Portugués y 🇪🇸 Español).
* **Cosecha e Ingesta Flexible**: Descarga datos directamente de APIs públicas (SciELO, BDTD, Oasisbr, LA Referencia) o procesa archivos locales (JATS XML, CSV, TSV, RIS, BibTeX).
* **Normalización y Desduplicación Regional**: Normaliza sufijos generacionales brasileños y apellidos compuestos hispanos, y fusiona bases resolviendo duplicados por DOI y similitud de título.
* **Exportación Universal**: Exporta colecciones armonizadas directamente a `.csv` o `.RData` para uso en R, Python, Excel, VOSviewer o Gephi.

### 2. Modo Integrado (con `bibliometrix` & `biblioshiny`)
* **Contrato Canónico S3 `bibliometrixDB`**: Valida y estandariza todas las etiquetas (`TI`, `AU`, `SO`, `PY`, `CR`, `DE`, `DI`, etc.) para compatibilidad inmediata con las rutinas de `bibliometrix`.
* **Análisis Cienciométrico Avanzado**: Ejecución directa de `biblioAnalysis()`, leyes bibliométricas (Bradford, Lotka), mapas temáticos y redes de coautoría.
* **Redes de Co-citación y Acoplamiento**: Habilitado mediante la extracción completa de referencias citadas (`CR`) de artículos SciELO en XML JATS.
* **Extensión Nativa de Biblioshiny**: Inyección en 1 clic en la sesión activa (`values$M`) dentro de `biblioshiny` o importación manual de archivos `.RData`.

---

## Comparativa de Funcionalidades por Modo de Uso

| Característica / Capacidad | Modo Standalone (`bibliolatam`) | Modo Integrado (`bibliolatam` + `bibliometrix`) |
|:---|:---:|:---:|
| **¿Requiere `bibliometrix` instalado?** | ❌ No (Solo R + Shiny/jsonlite) | ✅ Sí (`bibliometrix` >= 4.0.0) |
| **Aplicación Web Interactiva** | ✅ `bibliolatam::run_app()` (Trilingüe EN/PT/ES) | ✅ Interfaz de `biblioshiny` |
| **Búsqueda Federada en Línea (Omnisearch)** | ✅ Sí (SciELO, BDTD, Oasisbr, LA Referencia) | ✅ Sí |
| **Carga de Archivos Locales (XML/CSV/RIS/BibTeX)** | ✅ Sí | ✅ Sí |
| **Extracción de Referencias Citadas (`CR`)** | ✅ Sí (XML JATS SciELO) | ✅ Sí |
| **Normalización de Autores Regionales** | ✅ Sí (`normalize_authors`) | ✅ Sí |
| **Desduplicación y Fusión entre Bases** | ✅ Sí (`merge_bibliolatam`) | ✅ Sí |
| **Exportación Directa a CSV y .RData** | ✅ Sí | ✅ Sí |
| **Análisis Bibliométrico (`biblioAnalysis`, Bradford)** | ❌ Requiere bibliometrix | ✅ Sí |
| **Redes de Co-citación y Acoplamiento (`biblioNetwork`)** | ❌ Requiere bibliometrix | ✅ Sí |
| **Mapas Temáticos y Estructura Conceptual** | ❌ Requiere bibliometrix | ✅ Sí |

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
[ Motor bibliolatam (Independiente) ]
├── Clientes REST y Parsers Locales (Paginación, manejo defensivo de red)
├── Normalizador de Autores (Sufijos de parentesco y apellidos compuestos hispanos)
├── Desduplicación y Fusión entre Bases (DOI canónico + similitud de título fuzzy)
└── Armonizador Canónico (`as_bibliometrix`)
         │
         ├───▶ [ MODO STANDALONE (Sin bibliometrix) ]
         │     ├── App Web Propio: `bibliolatam::run_app()` (Trilingüe: EN, PT, ES)
         │     ├── Exportación Directa: Archivos `.csv` y `.RData`
         │     └── Manipulación: Base R / Tidyverse / Python / VOSviewer / Gephi
         │
         └───▶ [ MODO INTEGRADO (Con bibliometrix) ]
               ├── Análisis Cienciométrico: `biblioAnalysis()`, Bradford, Lotka
               ├── Redes de Conocimiento: Co-citación (CR), Coautoría, Acoplamiento
               └── Interfaz Biblioshiny: Inyección reactiva directa en `values$M`
```

---

## Instalación

Instale la versión estable de desarrollo directamente desde GitHub:

```r
# Usando remotes
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("BRAN-Org/bibliolatam")

# O usando pak
if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak")
pak::pkg_install("BRAN-Org/bibliolatam")
```

### Requisitos y Dependencias

- **Obligatorio para el núcleo**: R (>= 3.6.0), `jsonlite`, `utils`, `tools`.
- **Para la aplicación web interactiva propia (`run_app()`)**: `shiny`.
- **Para análisis cienciométricos y redes (opcional)**: `bibliometrix` (>= 4.0.0).

---

## Fuentes Soportadas y Métodos de Acceso

| Fuente | Ámbito Geográfico | Tipología | Modo de Ingesta | Capacidades Clave |
|:---|:---|:---|:---|:---|
| **SciELO** | América Latina, Caribe, Península Ibérica | Artículos de Revistas | Archivo (`read_scielo`, `read_scielo_jats`) y API (`download_scielo_search`, `download_scielo_jats`) | Referencias citadas (`CR`) extraídas de XML NLM/JATS; búsqueda en línea por DOI vía Crossref (`10.1590`). |
| **BDTD** | Brasil | Tesis y Disertaciones | Archivo (`read_bdtd`) y API REST (`download_bdtd`) | Asesores académicos (`RP`), mapeo de grado (`DT` como THESIS/DISSERTATION), paginación VuFind Solr. |
| **Oasisbr** | Brasil | Artículos, Tesis, Informes | Archivo (`read_oasisbr`) y API REST (`download_oasisbr`) | Portal brasileño de publicaciones en acceso abierto, normalización tipológica. |
| **LA Referencia** | 12 Países (AR, BR, CL, CO, CR, EC, ES, MX, PA, PE, SV, UY) | Redes Nacionales de Repositorios | API REST (`download_lareferencia`) | Consulta federada cosechando de las redes nacionales de repositorios latinoamericanos. |
| **Redalyc / AmeliCA** | Iberoamérica | Revistas Diamante | Archivo (`read_redalyc`) | Formatos BibTeX (`.bib`), RIS (`.ris`) y CSV con normalización de apellidos compuestos. |
| **SPELL (ANPAD)** | Brasil | Administración y Economía | Archivo (`read_spell`) | Exportaciones tabulares, detección automática de delimitadores (`;`, `,`, `\t`) y codificación (Latin-1/UTF-8). |
| **Omnisearch** | Regional (Multi-Base) | Todas las Tipologías | Función R y Panel Shiny | Búsqueda federada simultánea (SciELO, BDTD, Oasisbr, LA Referencia) con filtro temporal en la API y desduplicación. |

---

## Flujos de Trabajo y Ejemplos

### Flujo 1: Aplicación Web Standalone (Trilingüe)

`bibliolatam` incluye su propia aplicación web interactiva en Shiny. No requiere `bibliometrix` para ejecutarse:

```r
library(bibliolatam)

# Inicia la aplicación interactiva en su navegador predeterminado
run_app()

# O configurando el puerto e idioma inicial (en, pt o es)
run_app(port = 7860, default_lang = "es")
```

**Funcionalidades de la App Standalone:**
* **Selector de Idiomas Dinámico**: Alterne entre 🇬🇧 English, 🇧🇷 Português y 🇪🇸 Español directamente en el encabezado sin recargar la página ni perder el estado de las búsquedas.
* **Módulo Omnisearch**: Consulte SciELO, BDTD, Oasisbr y LA Referencia simultáneamente con filtros de año, límites por base y desduplicación automática.
* **Portales Dedicados**: Pestañas específicas para SciELO (búsqueda por DOIs/PIDs o carga de JATS XML), BDTD (filtro de maestría/doctorado), Oasisbr y Redalyc.
* **Fusión de Colecciones**: Interfaz visual para cargar dos colecciones y resolver duplicados mediante coincidencia fuzzy.
* **Descarga Directa**: Exporte conjuntos armonizados a `.csv` o `.RData` con un solo clic.

---

### Flujo 2: Modo Standalone mediante Scripts en R (Sin bibliometrix)

Puede realizar consultas por lotes, descargas y desduplicaciones utilizando únicamente funciones de `bibliolatam`:

```r
library(bibliolatam)

# 1. Búsqueda federada en 4 bases simultáneamente
datos_unificados <- omnisearch_bibliolatam(
  query = "inteligencia artificial salud",
  sources = c("scielo", "bdtd", "oasisbr", "lareferencia"),
  limit_per_source = 50,
  years = c(2020, 2024),
  deduplicate = TRUE,
  progress = TRUE
)

# 2. Resumen de registros por base de datos
table(datos_unificados$DB)

# 3. Exportar directamente a CSV para análisis en Python, Excel o VOSviewer
write.csv(datos_unificados, "investigacion_salud_latam.csv", row.names = FALSE)
```

---

### Flujo 3: Modo Integrado con bibliometrix (Modelado Cienciométrico)

Cuando `bibliometrix` está instalado, cualquier conjunto producido por `bibliolatam` se reconoce nativamente como un objeto `bibliometrixDB`:

```r
library(bibliolatam)
library(bibliometrix)

# Cosechar artículos de SciELO enriquecidos con referencias citadas (CR)
scielo_corpus <- download_scielo_search(
  query = "vacuna dengue",
  limit = 40,
  years = c(2018, 2024),
  enrich_references = TRUE
)

# 1. Análisis bibliométrico global
analisis <- biblioAnalysis(scielo_corpus)
summary(analisis, k = 10)

# 2. Red de co-citación de referencias (basada en extracción de CR de JATS XML)
red_cocitacion <- biblioNetwork(
  scielo_corpus,
  analysis = "co-citation",
  network = "references",
  sep = ";"
)
networkPlot(red_cocitacion, n = 30, type = "fruchterman", size = TRUE)

# 3. Red de colaboración entre autores
red_coautoria <- biblioNetwork(
  scielo_corpus,
  analysis = "collaboration",
  network = "authors",
  sep = ";"
)
networkPlot(red_coautoria, n = 30, type = "sphere", Title = "Coautoría")
```

---

### Flujo 4: Modo Integrado con biblioshiny

Puede vincular `bibliolatam` con la interfaz gráfica de `biblioshiny` de dos maneras:

1. **Exportación de `.RData` para Carga Manual**:
   ```r
   export_biblioshiny(datos_unificados, "mi_coleccion.RData")
   ```
   Abra `biblioshiny::biblioshiny()`, acceda a *Data -> Load bibliometrix RData* y seleccione el archivo generado.

2. **Módulos Nativos de Bibliolatam en Biblioshiny**:
   Al iniciar Biblioshiny en un entorno con `bibliolatam` instalado, sus módulos (`scieloUI`, `bdtdUI`, `omnisearchUI`) están disponibles en el menú lateral para inyectar datos directamente en la sesión activa (`values$M`) sin generar archivos intermedios.

---

## Matriz de Compatibilidad Analítica y Limitaciones Conocidas

Debido a que los repositorios latinoamericanos son gestionados por diferentes entidades públicas con prácticas de indexación heterogéneas, no todos los campos de bases propietarias (WoS/Scopus) están presentes en todas las fuentes abiertas.

A continuación se detalla la matriz de compatibilidad con las rutinas de `bibliometrix`:

| Módulo Analítico | Etiquetas Requeridas | Fuentes Regionales Soportadas | Comportamiento y Estado Práctico |
|:---|:---|:---|:---|
| **Producción Anual y Crecimiento** | `PY`, `SO`, `DT` | **Todas** (SciELO, BDTD, Oasisbr, Redalyc, LA Referencia, SPELL) | **100% Funcional**. Producción anual, ley de Bradford y relevancia de fuentes funcionan nativamente. |
| **Estructura Conceptual y Tópicos** | `TI`, `AB`, `DE`, `ID` | **Todas** | **100% Funcional**. Redes de coocurrencia de palabras clave, mapas temáticos (`thematicMap`) y análisis factorial (MCA) funcionan sin inconvenientes. |
| **Redes de Colaboración (Coautoría)** | `AU`, `C1`, `RP` | **Todas** | **100% Funcional**. Normalizado mediante `normalize_authors()` (maneja sufijos de parentesco y apellidos hispanos). BDTD asigna asesores a `RP`. |
| **Estructura Intelectual (Co-citación y Acoplamiento)** | `CR` (Referencias Citadas) | **SciELO (vía JATS XML)** | **Soportado en SciELO**: `read_scielo_jats()` y `download_scielo_search(enrich_references = TRUE)` reconstruyen `<ref-list>` en `CR`.<br>**No Disponible en BDTD / LA Referencia / Redalyc CSV**: Los repositorios no indexan bibliografías completas en texto plano. |
| **Impacto y Citaciones Recibidas** | `TC` (Times Cited) | N/A (inicializado en `0`) | **Etiqueta Presente, Métrica Limitada**: Las APIs abiertas no ofrecen recuentos comerciales de citas. `TC` se inicializa en `0` para que `bibliometrix` no falle, pero los rankings basados en citas reflejarán la ausencia de este índice. |

---

## Contrato de Metadatos: `bibliometrixDB`

Cada conjunto de datos producido por `bibliolatam` hereda la clase S3 `bibliometrixDB` y normaliza sus campos con las convenciones de Web of Science:

- `TI` (Título), `AU` (Autores: `APELLIDOS INICIALES; ...`), `SO` (Revista / Institución de Posgrado).
- `PY` (Año, numérico), `DE` (Palabras clave de autor), `AB` (Resumen), `C1` (Afiliaciones), `RP` (Asesor/Autor de correspondencia).
- `CR` (Referencias citadas), `TC` (Conteo de citas), `DI` (DOI canónico), `DT` (Tipo de documento), `LA` (Idioma).
- `DB` (Base de origen), `SR` & `SR_FULL` (Identificadores para matrices), `JI` & `J9` (Identificadores de revista).

Las etiquetas no proporcionadas por la fuente se completan con `NA` (o `0` para conteos numéricos) de forma transparente, sin inventar datos.

---

## Principios y Licenciamiento Dual

- **[Principios FAIR](https://www.gofair.foundation/fair-principles)**: Localizabilidad, Accesibilidad, Interoperabilidad y Reutilizabilidad para la ciencia del Sur Global.
- **[BOAI](https://www.budapestopenaccessinitiative.org/)**: Compromiso con la Iniciativa de Acceso Abierto de Budapest y la comunicación científica no comercial.
- **Licenciamiento Dual**:
  - **Código Fuente**: [GNU General Public License v3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl-3.0.html) - Software libre copyleft que garantiza la apertura permanente.
  - **Fixtures de Muestra (`inst/extdata/`)**: [Creative Commons Atribución-NoComercial-CompartirIgual 4.0 (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/) - Exclusivamente para validación académica y pruebas, con cláusula de protección contra minería para IA comercial.
