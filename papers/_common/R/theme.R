# Shared ggplot2 theme and palette for the series. Colours follow a palette
# validated for colour-vision deficiency: categorical hues are used in fixed
# slot order and never cycled (at most three slots when every pair must be
# distinguishable, four with direct labels); one blue for single-series
# figures; text always in ink tokens, never in a series colour.
suppressPackageStartupMessages(library(ggplot2))

pal_series <- c("#2a78d6", "#eb6834", "#1baf7a", "#eda100")
pal_ink    <- c(primary = "#0b0b0b", secondary = "#52514e", muted = "#898781",
                grid = "#e1e0d9", axis = "#c3c2b7", surface = "#fcfcfb")
pal_seq    <- c("#cde2fb", "#9ec5f4", "#6da7ec", "#3987e5", "#256abf", "#184f95", "#0d366b")

theme_series <- function(base_size = 11) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.background    = element_rect(fill = "white", colour = NA),
      panel.grid.minor   = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.major.y = element_line(colour = pal_ink[["grid"]], linewidth = 0.3),
      axis.line.x        = element_line(colour = pal_ink[["axis"]], linewidth = 0.4),
      axis.ticks         = element_blank(),
      axis.text          = element_text(colour = pal_ink[["muted"]]),
      axis.title         = element_text(colour = pal_ink[["secondary"]]),
      plot.title         = element_text(colour = pal_ink[["primary"]], face = "bold"),
      plot.subtitle      = element_text(colour = pal_ink[["secondary"]]),
      plot.caption       = element_text(colour = pal_ink[["muted"]], hjust = 0),
      legend.position    = "bottom",
      legend.title       = element_blank(),
      strip.text         = element_text(colour = pal_ink[["secondary"]], face = "bold", hjust = 0)
    )
}

scale_colour_series <- function(...) ggplot2::scale_colour_manual(values = pal_series, ...)
scale_fill_series   <- function(...) ggplot2::scale_fill_manual(values = pal_series, ...)

#' Save a figure as PDF (for the paper) and PNG (for Markdown/HTML).
save_figure <- function(plot, stem, width = 7, height = 4.2) {
  ggplot2::ggsave(paste0(stem, ".pdf"), plot, width = width, height = height)
  ggplot2::ggsave(paste0(stem, ".png"), plot, width = width, height = height, dpi = 200, bg = "white")
  invisible(stem)
}
