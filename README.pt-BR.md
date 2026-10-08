# bibliolatam: Adaptadores de Dados Bibliográficos Latino-Americanos para o 'bibliometrix'

<p align="left">
  <a href="README.md"><img src="docs/assets/badge-english.svg" alt="English Version" height="28" /></a>
  <a href="README.pt-BR.md"><img src="docs/assets/badge-portugues.svg" alt="Versão em Português" height="28" /></a>
</p>

`bibliolatam` é um pacote complementar em R projetado para conectar a literatura científica de acesso aberto da América Latina aos fluxos de análise bibliométrica e cienciométrica do [`bibliometrix`](https://github.com/massimoaria/bibliometrix).

---

## Por que o bibliolatam existe?

A maioria dos fluxos bibliométricos tradicionais foi construída assumindo bases de dados comerciais e proprietárias do Norte Global (Web of Science, Scopus). Contudo, a produção científica na América Latina e Caribe é historicamente distribuída em modelos não-comerciais de **Acesso Aberto Diamante** (como SciELO, Redalyc e SPELL) e preservada em repositórios nacionais de teses e dissertações (como BDTD e Oasisbr no Brasil, e a federação LA Referencia em 12 países).

Como o núcleo do `bibliometrix` deliberadamente restringe seus conversores nativos às grandes bases internacionais para manter a manutenção sustentável (conforme documentado na [issue #689 do bibliometrix](https://github.com/massimoaria/bibliometrix/issues/689)), o `bibliolatam` atua como um adaptador externo modular. Ele analisa arquivos exportados e consulta APIs REST públicas dessas plataformas, harmoniza os metadados heterogêneos no formato canônico da classe S3 `bibliometrixDB` e oferece integração reativa direta com o `biblioshiny`.

---

## Instalação

Você pode instalar a versão estável diretamente do repositório no GitHub:

```r
# Utilizando o pacote remotes
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("BRAN-Org/bibliolatam")

# Ou utilizando o pak
if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak")
pak::pkg_install("BRAN-Org/bibliolatam")
```

### Requisitos e Dependências

- **Obrigatório**: R (>= 3.6.0).
- **Para execução de análises**: `bibliometrix` (>= 4.0.0).
- **Para consultas a APIs REST e interface web**: `jsonlite`, `shiny`.

---

## Arquitetura e Fluxo dos Dados

```text
[ Fontes Latino-Americanas ]
├── SciELO          (Arquivos: CSV, JATS XML | APIs: Crossref works, XMLs NLM)
├── BDTD / Oasisbr  (Arquivos: CSV, TSV      | APIs: IBICT VuFind Solr)
├── LA Referencia   (APIs: VuFind REST v1 cobrindo 12 redes nacionais)
├── Redalyc         (Arquivos: BibTeX, RIS, CSV)
└── SPELL / ANPAD   (Arquivos: CSV)
         │
         ▼
[ Motor do bibliolatam ]
├── Parsers Locais e Clientes REST (Tratamento defensivo de rede e paginação)
├── Normalizador de Autores (Sufixos geracionais: Filho/Neto e nomes hispânicos)
├── Deduplicação entre Bases (Resolução por DOI exato e título fuzzy)
└── Harmonizador Canônico (`as_bibliometrix`)
         │
         ▼
[ Objeto bibliometrixDB ]
├── Scripts R: `biblioAnalysis()`, `biblioNetwork()`, etc.
└── Interface Gráfica: Injeção direta no `biblioshiny` ou exportação para `.RData`
```

---

## Fontes Suportadas e Modos de Uso

| Fonte | Escopo Geográfico | Tipologia | Modo de Ingestão | Destaques Técnicos |
|:---|:---|:---|:---|:---|
| **SciELO** | América Latina, Caribe, Península Ibérica | Artigos de Periódicos | Arquivo (`read_scielo`, `read_scielo_jats`) e API (`download_scielo_search`, `download_scielo_jats`) | Referências citadas (`CR`) extraídas do XML NLM/JATS; busca online por DOI via Crossref (prefixo `10.1590`). |
| **BDTD** | Brasil | Teses e Dissertações | Arquivo (`read_bdtd`) e API REST (`download_bdtd`) | Nomes de orientadores acadêmicos (`RP`), graus acadêmicos (`DT` como THESIS/DISSERTATION), paginação VuFind Solr do IBICT. |
| **Oasisbr** | Brasil | Artigos, Teses, Relatórios | Arquivo (`read_oasisbr`) e API REST (`download_oasisbr`) | Portal brasileiro de publicações em acesso aberto, mapeamento de tipologias. |
| **LA Referencia** | 12 Países (AR, BR, CL, CO, CR, EC, ES, MX, PA, PE, SV, UY) | Redes Nacionais de Repositórios | API REST (`download_lareferencia`) | Consulta federada colhendo das redes nacionais de repositórios latino-americanos. |
| **Redalyc / AmeliCA** | Ibero-América | Periódicos Diamante | Arquivo (`read_redalyc`) | Formatos BibTeX (`.bib`), RIS (`.ris`) e CSV com normalização de sobrenomes compostos. |
| **SPELL (ANPAD)** | Brasil | Administração e Economia | Arquivo (`read_spell`) | Exportações tabulares, detecção automática de delimitador (`;`, `,`, `\t`) e codificação (Latin-1/UTF-8). |
| **Omnisearch** | Regional (Multi-Base) | Todas as Tipologias | Função R e Painel Shiny | Busca federada simultânea (SciELO, BDTD, Oasisbr, LA Referencia) com filtro temporal na API e deduplicação. |

---

## Tutoriais Práticos e Exemplos

### 1. Omnisearch Federado (Busca Online Simultânea)

Consulte múltiplas bases simultaneamente em uma única linha de código, com filtro de anos direto nas APIs e deduplicação automática:

```r
library(bibliolatam)
library(bibliometrix)

# Consulta unificada em SciELO, BDTD, Oasisbr e LA Referencia
resultados <- omnisearch_bibliolatam(
  query = "energia solar",
  sources = c("scielo", "bdtd", "oasisbr", "lareferencia"),
  limit_per_source = 50,
  years = c(2020, 2024),
  deduplicate = TRUE,
  progress = TRUE
)

# Executa as análises do bibliometrix diretamente
analise <- biblioAnalysis(resultados)
summary(analise)
```

### 2. Busca Automatizada via APIs REST Específicas

Consulte repositórios específicos diretamente via R, sem necessidade de baixar arquivos pelo navegador:

```r
library(bibliolatam)

# 1. Teses e dissertações brasileiras na BDTD
teses <- download_bdtd(
  query = "inteligencia artificial saude",
  limit = 50,
  years = c(2021, 2024)
)

# 2. Artigos do SciELO enriquecidos com Referências Citadas (CR) via JATS XML
artigos <- download_scielo_search(
  query = "vacina dengue",
  limit = 30,
  years = c(2020, 2024),
  enrich_references = TRUE
)

# 3. Repositórios de 12 países via LA Referencia
paises_latinos <- download_lareferencia(
  query = "mudancas climaticas",
  limit = 50,
  years = c(2019, 2024)
)
```

### 3. Leitura de Arquivos Exportados dos Portais

Para coletas amplas realizadas diretamente na interface web dos portais oficiais:

```r
library(bibliolatam)
library(bibliometrix)

# SciELO: CSV exportado ou XML NLM/JATS
df_scielo <- read_scielo("scielo_busca.csv")
df_jats   <- read_scielo_jats("artigo_scielo.xml")

# BDTD / Oasisbr: Exportações em CSV ou TSV
df_bdtd <- read_bdtd("teses_bdtd.csv")

# Redalyc: Arquivos BibTeX, RIS ou CSV
df_redalyc <- read_redalyc("redalyc_export.bib")

# SPELL: CSV da ANPAD (Administração/Economia)
df_spell <- read_spell("spell_artigos.csv")

# Validação e garantia do contrato bibliometrixDB
M <- as_bibliometrix(df_scielo, dbsource = "scielo")
```

### 4. Fusão e Deduplicação entre Bases Heterogêneas

Para unir conjuntos de dados de origens diferentes eliminando redundâncias:

```r
library(bibliolatam)

# Unifica duas coleções (ex.: SciELO + Oasisbr)
# Resolve duplicatas por DOI normalizado e similaridade de título (Levenshtein)
corpus_unificado <- merge_bibliolatam(df_scielo, df_bdtd, match_by = c("doi", "title"))
```

### 5. Interface Gráfica no Biblioshiny

1. **Exportação Direta para .RData**:
   ```r
   export_biblioshiny(resultados, "corpus_latino.RData")
   ```
   Abra o `biblioshiny::biblioshiny()` -> menu *Data -> Load bibliometrix RData* -> carregue o arquivo gerado.

2. **Módulos Integrados do Bibliolatam**:
   Ao executar o Biblioshiny com o `bibliolatam` instalado, utilize o menu lateral **Bibliolatam**:
   - **Omnisearch**: Pesquisa federada, filtros temporais, cartões métricos, download de CSV/.RData e injeção em 1 clique na sessão ativa (`values$M`).
   - **Portais Específicos**: SciELO, BDTD, Oasisbr, Redalyc e Mesclagem de Coleções.

---

## Matriz de Compatibilidade Analítica e Limitações Conhecidas

Como os repositórios latino-americanos são mantidos por diferentes entidades públicas com práticas de indexação distintas, nem todos os campos encontrados em bases fechadas (WoS/Scopus) estão disponíveis em todas as fontes abertas.

Veja a matriz de compatibilidade com as rotinas do `bibliometrix`:

| Módulo Analítico | Campos Necessários | Fontes Regionais Suportadas | Comportamento Prático |
|:---|:---|:---|:---|
| **Produção Anual e Dinâmica** | `PY`, `SO`, `DT` | **Todas** (SciELO, BDTD, Oasisbr, Redalyc, LA Referencia, SPELL) | **100% Funcional**. Produção científica anual, Lei de Bradford e relevância de periódicos/instituições operam nativamente. |
| **Estrutura Conceitual e Tópicos** | `TI`, `AB`, `DE`, `ID` | **Todas** | **100% Funcional**. Redes de coocorrência de termos, mapas temáticos (`thematicMap`) e análise fatorial (MCA) funcionam perfeitamente. |
| **Redes Sociais e Colaboração** | `AU`, `C1`, `RP` | **Todas** | **100% Funcional**. Nomes normalizados por `normalize_authors()`. A BDTD mapeia orientadores acadêmicos em `RP`. |
| **Estrutura Intelectual (Cocitação e Acoplamento)** | `CR` (Cited References) | **SciELO (via JATS XML)** | **Suportado no SciELO**: O parser JATS e o enriquecimento (`enrich_references = TRUE`) reconstroem o `<ref-list>` em `CR`.<br>**Não Disponível em BDTD / LA Referencia / Redalyc CSV**: Essas plataformas não extraem bibliografias de dentro dos PDFs em suas APIs. |
| **Métricas de Impacto e Citações Globais** | `TC` (Times Cited) | N/A (inicializado como `0`) | **Campo Presente, Métrica Limitada**: APIs abertas públicas não fornecem índices de citação proprietários. `TC` é preenchido com `0` para que o `bibliometrix` não quebre, mas rankings por citação refletirão dados não indexados comercialmente. |

---

## Contrato de Dados: `bibliometrixDB`

Todo data frame gerado pelo `bibliolatam` possui a classe S3 `bibliometrixDB` e obedece às tags padrão do Web of Science:

- `TI` (Título), `AU` (Autores: `SOBRENOME INICIAIS; ...`), `SO` (Periódico ou Instituição da Tese).
- `PY` (Ano de publicação, numérico), `DE` (Palavras-chave do autor), `AB` (Resumo), `C1` (Afiliações), `RP` (Orientador/Reprint).
- `CR` (Referências Citadas), `TC` (Contagem de citações), `DI` (DOI limpo), `DT` (Tipo de documento), `LA` (Idioma).
- `DB` (Base de dados de origem), `SR` e `SR_FULL` (Referências padrão para rotinas de matrizes), `JI` e `J9` (Abreviações de periódico).

Campos não presentes na fonte original são preenchidos com `NA` (ou `0` para citações), preservando a integridade dos dados sem invenção de registros.

---

## Princípios e Licença

- **[Princípios FAIR](https://www.gofair.foundation/fair-principles)**: Promovendo Encontrabilidade, Acessibilidade, Interoperabilidade e Reusabilidade para a ciência do Sul Global.
- **[Declaração BOAI](https://www.budapestopenaccessinitiative.org/)**: Compromisso estrito com infraestruturas de Acesso Aberto Diamante.
- **Licença Dupla**:
  - **Código-Fonte**: [GNU General Public License v3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl-3.0.html) - Garantia de software livre com copyleft.
  - **Dados de Exemplo (`inst/extdata/`)**: [Creative Commons Atribuição-NãoComercial-CompartilhaIgual 4.0 (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/) - Para pesquisa e validação acadêmica.
