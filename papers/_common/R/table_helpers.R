# Table export shared across papers. Tables are written as Markdown (included
# in paper.qmd with the {{< include >}} shortcode, which renders in PDF and
# HTML alike) and as LaTeX for direct use elsewhere.

suppressPackageStartupMessages({
  library(modelsummary)
})

# Report design-based SEs as stored in the svyglm object; never let
# modelsummary recompute them with a different vcov.
options(modelsummary_factory_default = "tinytable")

#' Write a regression table to <stem>.md and <stem>.tex.
#' `models` is a named list of fits; `notes` must state the SE type and sample.
save_model_table <- function(models, stem, title = NULL, notes = NULL,
                             coef_map = NULL, gof_map = NULL, stars = TRUE, ...) {
  if (is.null(gof_map)) {
    gof_map <- data.frame(raw = "nobs", clean = "Observations", fmt = 0)
  }
  for (ext in c(".md", ".tex")) {
    modelsummary::modelsummary(
      models, output = paste0(stem, ext), title = title, notes = notes,
      coef_map = coef_map, gof_map = gof_map, stars = stars,
      escape = FALSE, ...
    )
  }
  invisible(stem)
}

#' Write a plain data frame as a Markdown table (for descriptive tables).
save_df_table <- function(df, stem, title = NULL, notes = NULL, digits = 3) {
  for (ext in c(".md", ".tex")) {
    modelsummary::datasummary_df(df, output = paste0(stem, ext), title = title,
                                 notes = notes, fmt = digits)
  }
  invisible(stem)
}

#' Build a coefficient table (estimate with stars over SE) from tidy tibbles.
#' `tidies` is a named list of tibbles with term, estimate, std.error, p.value,
#' nobs; `coef_map` maps term -> label and fixes the row order; `extra_rows`
#' is an optional data frame of extra bottom rows (first column = label).
make_coef_table <- function(tidies, coef_map, extra_rows = NULL, digits = 3) {
  stars <- function(p) ifelse(p < 0.001, "***", ifelse(p < 0.01, "**", ifelse(p < 0.05, "*", ifelse(p < 0.1, "+", ""))))
  fmt <- function(x) formatC(x, digits = digits, format = "f")
  rows <- list()
  for (term in names(coef_map)) {
    est_row <- c(coef_map[[term]]); se_row <- c("")
    for (nm in names(tidies)) {
      td <- tidies[[nm]]; r <- td[td$term == term, ]
      if (nrow(r) == 1) {
        est_row <- c(est_row, paste0(fmt(r$estimate), stars(r$p.value)))
        se_row  <- c(se_row, paste0("(", fmt(r$std.error), ")"))
      } else { est_row <- c(est_row, ""); se_row <- c(se_row, "") }
    }
    rows[[length(rows) + 1]] <- est_row; rows[[length(rows) + 1]] <- se_row
  }
  nobs_row <- c("Observations", vapply(tidies, function(td) format(td$nobs[1], big.mark = ","), ""))
  out <- as.data.frame(do.call(rbind, c(rows, list(nobs_row))), stringsAsFactors = FALSE)
  names(out) <- c(" ", names(tidies))
  if (!is.null(extra_rows)) { names(extra_rows) <- names(out); out <- rbind(out, extra_rows) }
  rownames(out) <- NULL
  out
}

#' Write a character data frame as a Markdown and a LaTeX table.
save_char_table <- function(df, stem, title = NULL, notes = NULL) {
  for (ext in c(".md", ".tex")) {
    modelsummary::datasummary_df(df, output = paste0(stem, ext), title = title, notes = notes)
  }
  invisible(stem)
}

#' Append a Quarto cross-reference label to the caption line of a Markdown
#' grid table written by the functions above ("Table: ..." -> "Table: ... {#tbl-id}").
label_md_table <- function(file, id) {
  x <- readLines(file)
  i <- grep("^Table: ", x)
  if (length(i) == 1 && !grepl("\\{#tbl-", x[i])) x[i] <- paste0(x[i], " {#", id, "}")
  writeLines(x, file)
  invisible(file)
}
