# bibliolatam: Adaptadores de Dados Bibliográficos Latino-Americanos para o 'bibliometrix'

<p align="left">
  <a href="https://github.com/BRAN-Org/bibliolatam/blob/main/README.md"><img src="https://raw.githubusercontent.com/BRAN-Org/bibliolatam/main/docs/assets/badge-english.svg" alt="English Version" height="28" /></a>
  <a href="https://github.com/BRAN-Org/bibliolatam/blob/main/README.pt-BR.md"><img src="https://raw.githubusercontent.com/BRAN-Org/bibliolatam/main/docs/assets/badge-portugues.svg" alt="Versão em Português" height="28" /></a>
  <a href="https://github.com/BRAN-Org/bibliolatam/blob/main/README.es.md"><img src="https://raw.githubusercontent.com/BRAN-Org/bibliolatam/main/docs/assets/badge-espanol.svg" alt="Versión en Español" height="28" /></a>
</p>

`bibliolatam` é um pacote em R projetado para conectar a literatura científica de acesso aberto da América Latina, Caribe e Península Ibérica tanto a fluxos de análise independentes (**Modo Standalone**) quanto ao ecossistema cienciométrico do [`bibliometrix`](https://github.com/massimoaria/bibliometrix) e [`biblioshiny`](https://github.com/massimoaria/bibliometrix).

---

## Por que o bibliolatam existe?

A maioria dos fluxos bibliométricos tradicionais foi construída assumindo bases de dados comerciais e proprietárias do Norte Global (Web of Science, Scopus). Contudo, a produção científica na América Latina e Caribe é historicamente distribuída em modelos não-comerciais de **Acesso Aberto Diamante** (como SciELO, Redalyc e SPELL) e preservada em repositórios nacionais de teses e dissertações (como BDTD e Oasisbr no Brasil, e a federação LA Referencia em 12 países).

Como o núcleo do `bibliometrix` deliberadamente restringe seus conversores nativos às grandes bases internacionais para manter a manutenção sustentável (conforme documentado na [issue #689 do bibliometrix](https://github.com/massimoaria/bibliometrix/issues/689)), o `bibliolatam` atua como uma ponte modular e flexível. Ele permite coletar, desduplicar, normalizar e exportar esses dados de maneira **100% autônoma** ou convertê-los no formato canônico da classe S3 `bibliometrixDB` para análises avançadas de redes e cienciometria.

---

## Dois Modos de Operação: Standalone ou Integrado

O `bibliolatam` foi desenhado para ser totalmente desacoplado. Você pode utilizá-lo de duas formas:

### 1. Modo Standalone (Independente)
* **Sem dependência do `bibliometrix`**: Funciona apenas com o R base e pacotes leves (`shiny`, `jsonlite`, `utils`, `tools`).
* **Aplicação Web Própria (`run_app()`)**: Inclui uma interface gráfica interativa completa com **suporte trilíngue em tempo real** (🇬🇧 Inglês, 🇧🇷 Português e 🇪🇸 Espanhol).
* **Coleta e Ingestão Flexível**: Baixa dados diretamente de APIs públicas (SciELO, BDTD, Oasisbr, LA Referencia) ou processa arquivos locais (JATS XML, CSV, TSV, RIS, BibTeX).
* **Normalização e Desduplicação**: Normaliza autores brasileiros e hispânicos e funde bases com resolução de duplicatas por DOI e título fuzzy.
* **Exportação Universal**: Exporta datasets harmonizados diretamente para `.csv` ou `.RData` para uso no R, Python, Excel, VOSviewer ou Gephi.

### 2. Modo Integrado (com `bibliometrix` & `biblioshiny`)
* **Contrato Canônico S3 `bibliometrixDB`**: Converte e valida todos os campos (`TI`, `AU`, `SO`, `PY`, `CR`, `DE`, `DI`, etc.) para conformidade imediata com as rotinas do `bibliometrix`.
* **Análises Cientométricas Avançadas**: Execução de `biblioAnalysis()`, leis bibliométricas (Bradford, Lotka), mapeamento temático e redes de coautoria.
* **Redes de Co-citação e Acoplamento**: Ativado pela extração completa de referências citadas (`CR`) de artigos SciELO em JATS XML.
* **Extensão Nativa do Biblioshiny**: Injeção em 1 clique na sessão ativa (`values$M`) dentro do `biblioshiny` ou importação de arquivos `.RData`.

---

## Comparativo de Recursos por Modo de Uso

| Capacidade / Recurso | Modo Standalone (`bibliolatam`) | Modo Integrado (`bibliolatam` + `bibliometrix`) |
|:---|:---:|:---:|
| **Requer `bibliometrix` instalado?** | ❌ Não (Apenas R + Shiny/jsonlite) | ✅ Sim (`bibliometrix` >= 4.0.0) |
| **Aplicação Web Interativa** | ✅ `bibliolatam::run_app()` (Trilíngue EN/PT/ES) | ✅ Interface do `biblioshiny` |
| **Busca Federada Online (Omnisearch)** | ✅ Sim (SciELO, BDTD, Oasisbr, LA Referencia) | ✅ Sim |
| **Ingestão de Arquivos Locais (XML/CSV/RIS/BibTeX)** | ✅ Sim | ✅ Sim |
| **Extração de Referências Citadas (`CR`)** | ✅ Sim (XML JATS SciELO) | ✅ Sim |
| **Normalização de Autores Regionais** | ✅ Sim (`normalize_authors`) | ✅ Sim |
| **Desduplicação e Fusão entre Bases** | ✅ Sim (`merge_bibliolatam`) | ✅ Sim |
| **Exportação Direta para CSV e .RData** | ✅ Sim | ✅ Sim |
| **Análise Bibliométrica (`biblioAnalysis`, Bradford)** | ❌ Requer bibliometrix | ✅ Sim |
| **Redes de Co-citação e Acoplamento (`biblioNetwork`)** | ❌ Requer bibliometrix | ✅ Sim |
| **Mapas Temáticos e Estrutura Conceitual** | ❌ Requer bibliometrix | ✅ Sim |

---

## Arquitetura e Fluxo dos Dados

```text
[ Fontes Latino-Americanas e Ibéricas ]
├── SciELO          (Arquivos: CSV, JATS XML | APIs: Crossref works, XMLs NLM)
├── BDTD / Oasisbr  (Arquivos: CSV, TSV      | APIs: IBICT VuFind Solr)
├── LA Referencia   (APIs: VuFind REST v1 cobrindo 12 redes nacionais)
├── Redalyc         (Arquivos: BibTeX, RIS, CSV)
└── SPELL / ANPAD   (Arquivos: CSV)
         │
         ▼
[ Motor bibliolatam (Independente) ]
├── Clientes REST & Parsers Locais (Paginação, tratamento defensivo de rede)
├── Normalizador de Autores (Sufixos brasileiros e sobrenomes compostos hispânicos)
├── Desduplicação & Fusão entre Bases (DOI canônico + similaridade de título fuzzy)
└── Harmonizador Canônico (`as_bibliometrix`)
         │
         ├───▶ [ MODO STANDALONE (Sem bibliometrix) ]
         │     ├── App Web Próprio: `bibliolatam::run_app()` (Trilíngue: EN, PT, ES)
         │     ├── Exportação Direta: Arquivos `.csv` e `.RData`
         │     └── Manipulação em R Base / Tidyverse / Python / VOSviewer / Gephi
         │
         └───▶ [ MODO INTEGRADO (Com bibliometrix) ]
               ├── Análise Cientométrica R: `biblioAnalysis()`, Bradford, Lotka
               ├── Redes de Conhecimento: Co-citação (CR), Coautoria, Acoplamento
               └── Interface Biblioshiny: Injeção reativa direta em `values$M`
```

---

## Instalação

Instale a versão estável de desenvolvimento diretamente do GitHub:

```r
# Utilizando o pacote remotes
if (!requireNamespace("remotes", quietly = TRUE)) install.packages("remotes")
remotes::install_github("BRAN-Org/bibliolatam")

# Ou utilizando o pak
if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak")
pak::pkg_install("BRAN-Org/bibliolatam")
```

### Requisitos e Dependências

- **Obrigatório para o núcleo**: R (>= 3.6.0), `jsonlite`, `utils`, `tools`.
- **Para a aplicação web interativa própria (`run_app()`)**: `shiny`.
- **Para análises cientométricas e redes (opcional)**: `bibliometrix` (>= 4.0.0).

---

## Fontes Suportadas e Métodos de Acesso

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

### Fluxo 1: Aplicação Web Standalone (Trilíngue)

O `bibliolatam` inclui sua própria aplicação web interativa em Shiny. Não requer `bibliometrix` para ser executada:

```r
library(bibliolatam)

# Inicia o aplicativo interativo no seu navegador padrão
run_app()

# Ou configurando porta e idioma inicial (en, pt ou es)
run_app(port = 7860, default_lang = "pt")
```

**Recursos do Aplicativo Standalone:**
* **Seletor de Idiomas em Tempo Real**: Alterne entre 🇬🇧 English, 🇧🇷 Português e 🇪🇸 Español diretamente no cabeçalho sem perder o estado dos formulários ou termos digitados.
* **Módulo Omnisearch**: Consulte SciELO, BDTD, Oasisbr e LA Referencia simultaneamente com filtros de ano, limites e desduplicação automática.
* **Portais Específicos**: Abas dedicadas para SciELO (busca por DOIs/PIDs ou upload JATS XML), BDTD (filtro de mestrado/doutorado), Oasisbr e Redalyc.
* **Unificação e Fusão**: Interface visual para carregar duas bases e aplicar desduplicação por similaridade.
* **Exportação Direta**: Baixe datasets harmonizados em `.csv` ou `.RData` com um clique.

---

### Fluxo 2: Modo Standalone via Scripts R (Sem bibliometrix)

Você pode realizar buscas, extrações e desduplicações em lote usando apenas funções do `bibliolatam`:

```r
library(bibliolatam)

# 1. Busca federada em 4 bases simultaneamente
dados_unificados <- omnisearch_bibliolatam(
  query = "inteligencia artificial saude",
  sources = c("scielo", "bdtd", "oasisbr", "lareferencia"),
  limit_per_source = 50,
  years = c(2020, 2024),
  deduplicate = TRUE,
  progress = TRUE
)

# 2. Verificar resumo dos dados coletados
table(dados_unificados$DB)

# 3. Exportar diretamente para CSV para análise em qualquer ferramenta
write.csv(dados_unificados, "pesquisa_saude_latam.csv", row.names = FALSE)
```

---

### Fluxo 3: Modo Integrado com bibliometrix (Análises Cientométricas)

Quando o pacote `bibliometrix` está instalado, todo dataset gerado pelo `bibliolatam` é reconhecido nativamente como um objeto `bibliometrixDB`:

```r
library(bibliolatam)
library(bibliometrix)

# Coletar artigos do SciELO enriquecidos com referências citadas (CR)
scielo_corpus <- download_scielo_search(
  query = "vacina dengue",
  limit = 40,
  years = c(2018, 2024),
  enrich_references = TRUE
)

# 1. Análise bibliométrica global
analise <- biblioAnalysis(scielo_corpus)
summary(analise, k = 10)

# 2. Rede de co-citação de referências (requer CR, presente no SciELO JATS XML)
rede_cocitacao <- biblioNetwork(
  scielo_corpus,
  analysis = "co-citation",
  network = "references",
  sep = ";"
)
networkPlot(rede_cocitacao, n = 30, type = "fruchterman", size = TRUE)

# 3. Rede de colaboração entre autores
rede_coautoria <- biblioNetwork(
  scielo_corpus,
  analysis = "collaboration",
  network = "authors",
  sep = ";"
)
networkPlot(rede_coautoria, n = 30, type = "sphere", Title = "Coautoria")
```

---

### Fluxo 4: Modo Integrado com biblioshiny

Você pode usar o `bibliolatam` dentro da interface gráfica oficial do `biblioshiny` de duas formas:

1. **Exportação de `.RData` para Carga Manual**:
   ```r
   export_biblioshiny(dados_unificados, "meu_corpus.RData")
   ```
   Abra `biblioshiny::biblioshiny()`, acesse o menu *Data -> Load bibliometrix RData* e selecione o arquivo gerado.

2. **Uso dos Módulos Bibliolatam no Biblioshiny**:
   Ao iniciar o Biblioshiny em um ambiente onde o `bibliolatam` está instalado, os módulos regionais (`scieloUI`, `bdtdUI`, `omnisearchUI`) ficam acessíveis para carregar dados diretamente na sessão ativa (`values$M`) sem necessidade de salvar arquivos intermediários.

---

## Matriz de Compatibilidade Analítica e Limitações Conhecidas

Como os repositórios latino-americanos são mantidos por diferentes entidades públicas com práticas de indexação distintas, nem todos os campos encontrados em bases fechadas (WoS/Scopus) estão disponíveis em todas as fontes abertas.

Veja a matriz de compatibilidade com as rotinas do `bibliometrix`:

| Módulo Analítico | Campos Necessários | Fontes Regionais Suportadas | Comportamento Prático |
|:---|:---|:---|:---|
| **Produção Anual e Crescimento** | `PY`, `SO`, `DT` | **Todas** (SciELO, BDTD, Oasisbr, Redalyc, LA Referencia, SPELL) | **100% Funcional**. Produção científica anual, lei de Bradford e relevância de periódicos funcionam nativamente. |
| **Estrutura Conceitual e Tópicos** | `TI`, `AB`, `DE`, `ID` | **Todas** | **100% Funcional**. Redes de coocorrência de palavras-chave, mapas temáticos (`thematicMap`) e análise fatorial (MCA) funcionam perfeitamente. |
| **Redes de Colaboração (Coautoria)** | `AU`, `C1`, `RP` | **Todas** | **100% Funcional**. Normalizado por `normalize_authors()` (trata sufixos de parentesco e sobrenomes hispânicos). BDTD mapeia orientadores acadêmicos em `RP`. |
| **Estrutura Intelectual (Co-citação e Acoplamento)** | `CR` (Referências Citadas) | **SciELO (via JATS XML)** | **Suportado no SciELO**: `read_scielo_jats()` e `download_scielo_search(enrich_references = TRUE)` reconstroem o `<ref-list>` no campo `CR`.<br>**Não Disponível em BDTD / LA Referencia / Redalyc CSV**: Repositórios não indexam bibliografias completas em formato estruturado. |
| **Impacto e Citações Recebidas** | `TC` (Times Cited) | N/A (inicializado como `0`) | **Campo Presente, Métrica Limitada**: APIs públicas não fornecem contadores globais de citação proprietários. `TC` é inicializado como `0` para que as rotinas do `bibliometrix` não quebrem, mas ranqueamentos por citação refletirão a ausência desse índice. |

---

## Contrato de Metadados: `bibliometrixDB`

Todo data frame gerado pelo `bibliolatam` herda a classe S3 `bibliometrixDB` e padroniza as colunas nas convenções da Web of Science:

- `TI` (Título), `AU` (Autores: `SOBRENOME INICIAIS; ...`), `SO` (Periódico / Instituição de Pós-Graduação).
- `PY` (Ano, numérico), `DE` (Palavras-chave de autor), `AB` (Resumo), `C1` (Afiliações), `RP` (Orientador/Autor correspondente).
- `CR` (Referências citadas), `TC` (Contagem de citações), `DI` (DOI canônico), `DT` (Tipo de documento), `LA` (Idioma).
- `DB` (Base de origem), `SR` & `SR_FULL` (Identificadores para matrizes), `JI` & `J9` (Identificadores de periódico).

Campos não suportados pela fonte são preenchidos como `NA` (ou `0` para citações) de forma transparente, sem fabricação de dados.

---

## Princípios e Licenciamento Duplo

- **[Princípios FAIR](https://www.gofair.foundation/fair-principles)**: Localizabilidade, Acessibilidade, Interoperabilidade e Reusabilidade para a ciência do Sul Global.
- **[BOAI](https://www.budapestopenaccessinitiative.org/)**: Alinhamento estrito à Iniciativa de Acesso Aberto de Budapeste e à comunicação científica não-comercial.
- **Licenciamento Duplo**:
  - **Código-Fonte**: [GNU General Public License v3.0 (GPL-3.0)](https://www.gnu.org/licenses/gpl-3.0.html) - Software livre copyleft garantindo abertura contínua.
  - **Fixtures de Amostra (`inst/extdata/`)**: [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/) - Uso exclusivo para validação acadêmica e testes, com cláusula de proteção contra raspagem para IA comercial.
