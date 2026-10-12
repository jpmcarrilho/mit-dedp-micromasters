#!/usr/bin/env Rscript
# run_all.R — single entry point: download (cached years are skipped), build,
# unit tests, official-aggregate checks, analysis, and the Quarto render.
# Usage from the repository root or from papers/:  Rscript R/run_all.R
suppressPackageStartupMessages(library(here))
here::i_am("papers/01-returns-to-schooling/R/run_all.R")  # repository root, independent of the working directory
paper_dir <- here::here("papers", "01-returns-to-schooling")
t_start <- Sys.time()

run_script <- function(name) {
  message("\n### ", name, "  (", format(Sys.time(), "%H:%M:%S"), ")")
  status <- system2("Rscript", shQuote(file.path(paper_dir, "R", name)))
  if (!identical(status, 0L)) stop(name, " failed with status ", status, call. = FALSE)
}

run_script("00_download.R")
run_script("01_build.R")

message("\n### unit tests")
testthat::test_dir(file.path(paper_dir, "tests", "testthat"), reporter = "summary",
                   stop_on_failure = TRUE)

run_script("02_checks.R")
run_script("03_analysis.R")
run_script("04_report.R")

message("\n### quarto render")
quarto_bin <- Sys.which("quarto")
if (quarto_bin == "") quarto_bin <- path.expand("~/.local/bin/quarto")
if (!file.exists(quarto_bin)) stop("Quarto CLI not found; install it or set PATH", call. = FALSE)
# Render next to the source (never with --output-dir output: Quarto would
# clean that folder, which also holds the tables and figures), then move the PDF.
status <- system2(quarto_bin, c("render", shQuote(file.path(paper_dir, "paper.qmd")), "--to", "pdf"))
if (!identical(status, 0L)) stop("quarto render failed", call. = FALSE)
file.rename(file.path(paper_dir, "paper.pdf"), file.path(paper_dir, "output", "paper.pdf"))

message(sprintf("\nrun_all.R finished in %.1f minutes; PDF at %s",
                as.numeric(difftime(Sys.time(), t_start, units = "mins")),
                file.path(paper_dir, "output", "paper.pdf")))
