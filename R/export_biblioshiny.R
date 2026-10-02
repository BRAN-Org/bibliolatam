#' Export a converted collection to biblioshiny-compatible RData
#'
#' Saves the bibliometric data frame as an `.RData` file ready to be loaded
#' directly in the `biblioshiny` web interface under 'Data -> Load bibliometrix RData'.
#'
#' @param data An object of class `bibliometrixDB` or a compatible data frame.
#' @param file Path to the output `.RData` file.
#' @return Invisibly returns the normalized path of the saved file.
#' @export
export_biblioshiny <- function(data, file) {
  # valida caminho do arquivo primeiro (fail-fast)
  if (!is.character(file) || length(file) != 1L || !nzchar(trimws(file))) {
    stop("Caminho de arquivo invalido para salvar o .RData.", call. = FALSE)
  }

  if (!is.data.frame(data)) {
    stop("data precisa ser um data.frame/tibble.", call. = FALSE)
  }

  if (nrow(data) == 0L) {
    stop("data esta vazio, nada para exportar.", call. = FALSE)
  }

  if (!inherits(data, "bibliometrixDB")) {
    warning("data nao possui a classe 'bibliometrixDB'. Tentando converter com as_bibliometrix()...", call. = FALSE)
    data <- as_bibliometrix(data)
  }

  # garante extensao .RData se o dev/usuario esqueceu de por
  if (!grepl("\\.rdata$", file, ignore.case = TRUE)) {
    file <- paste0(file, ".RData")
  }

  # biblioshiny espera o objeto com nome 'M' ao dar load()
  M <- data
  save(M, file = file)

  invisible(normalizePath(file, mustWork = FALSE))
}
