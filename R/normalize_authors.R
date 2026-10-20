#' Normalize author names into standard bibliometric format
#'
#' Converts diverse author string formats (e.g. 'Sobrenome, Nome', 'Nome Sobrenome',
#' with generational suffixes like Junior, Filho, Neto) into the canonical
#' WoS/bibliometrix format: `SOBRENOME INICIAIS; ...`. Supports both scalar strings
#' and character vectors.
#'
#' @param au_str Character vector or scalar string containing one or multiple author names
#'   separated by semicolons.
#' @return A normalized character vector of the same length as `au_str`, with `NA_character_`
#'   for empty or missing entries.
#' @export
#' @examples
#' # Single string with multiple authors
#' normalize_authors("Batista Filho, Jose Rodrigues; Perez Gomez, Maria del Carmen")
#'
#' # Vector of author strings
#' normalize_authors(c("Silva, Joao", "Santos Junior, Mario", "Maria da Silva"))
normalize_authors <- function(au_str) {
  if (is.null(au_str) || length(au_str) == 0L) {
    return(character(0L))
  }
  if (length(au_str) > 1L) {
    return(vapply(au_str, normalize_single_author, character(1L), USE.NAMES = FALSE))
  }
  normalize_single_author(au_str)
}

normalize_single_author <- function(au_str) {
  if (is.na(au_str) || !nzchar(trimws(au_str))) {
    return(NA_character_)
  }

  raw_authors <- unlist(strsplit(au_str, ";", fixed = TRUE))
  norm_authors <- character(0L)

  # particulas que nao viram iniciais em padrao cienciometrico
  particulas <- c("da", "de", "do", "das", "dos", "del", "della", "la", "las", "los", "van", "von", "der", "e", "y")
  # sufixos geracionais brasileiros e hispanicos
  sufixos <- c("junior", "jr", "filho", "neto", "sobrinho", "segundo", "terceiro")

  for (a in raw_authors) {
    a <- trimws(a)
    if (!nzchar(a)) next

    if (grepl(",", a, fixed = TRUE)) {
      # formato: 'Sobrenome, Nome Meio' ou 'Sobrenome, Nome Meio Filho'
      parts <- unlist(strsplit(a, ",", fixed = TRUE))
      sobrenome <- toupper(trimws(parts[1]))
      restante <- if (length(parts) > 1) trimws(parts[2]) else ""
      prenomes <- unlist(strsplit(restante, "\\s+"))
      prenomes <- prenomes[nzchar(prenomes)]

      # se o ultimo token dos prenomes for sufixo (ex: 'Batista, Jose Rodrigues Filho')
      if (length(prenomes) > 1 && tolower(prenomes[length(prenomes)]) %in% sufixos) {
        sobrenome <- paste(sobrenome, toupper(prenomes[length(prenomes)]))
        prenomes <- prenomes[-length(prenomes)]
      }

      # extrai iniciais ignorando particulas (ex: 'da', 'de')
      iniciais_tokens <- prenomes[!tolower(prenomes) %in% particulas]
      iniciais <- paste0(substr(iniciais_tokens, 1, 1), collapse = "")

      norm_a <- if (nzchar(iniciais)) paste(sobrenome, toupper(iniciais)) else sobrenome
    } else {
      # formato: 'Nome Meio Sobrenome'
      tokens <- unlist(strsplit(a, "\\s+"))
      tokens <- tokens[nzchar(tokens)]

      if (length(tokens) == 1) {
        norm_a <- toupper(tokens)
      } else {
        last_tok <- tolower(tokens[length(tokens)])
        # trata sufixo geracional (ex: Silva Junior)
        if (last_tok %in% sufixos && length(tokens) >= 3) {
          sobrenome <- toupper(paste(tokens[length(tokens) - 1], tokens[length(tokens)]))
          prenomes <- tokens[1:(length(tokens) - 2)]
        } else {
          sobrenome <- toupper(tokens[length(tokens)])
          prenomes <- tokens[-length(tokens)]
        }

        iniciais_tokens <- prenomes[!tolower(prenomes) %in% particulas]
        iniciais <- paste0(substr(iniciais_tokens, 1, 1), collapse = "")

        norm_a <- if (nzchar(iniciais)) paste(sobrenome, toupper(iniciais)) else sobrenome
      }
    }
    norm_authors <- c(norm_authors, norm_a)
  }

  if (length(norm_authors) == 0L) {
    return(NA_character_)
  }

  paste(norm_authors, collapse = "; ")
}
