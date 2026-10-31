#!/usr/bin/env Rscript
# 01_build.R — Recode every cached year, flag the analysis sample and write:
#   data/clean/persons_<year>.rds  all persons of the year (needed to build the
#                                  survey design before subsetting to a domain)
#   data/clean/sample.rds          analysis rows of all years (descriptives, tests)
#   data/clean/build_counts.csv    sequential filter counts per year
suppressPackageStartupMessages({ library(dplyr); library(here) })
here::i_am("papers/01-returns-to-schooling/R/01_build.R")  # repository root, independent of the working directory
paper_dir <- here::here("papers", "01-returns-to-schooling")
raw_dir   <- file.path(paper_dir, "data", "raw")
clean_dir <- file.path(paper_dir, "data", "clean")
dir.create(clean_dir, recursive = TRUE, showWarnings = FALSE)
source(file.path(paper_dir, "R", "build_functions.R"))

files <- sort(list.files(raw_dir, pattern = "^pnadc_[0-9]{4}_visita1\\.rds$", full.names = TRUE))
if (!length(files)) stop("No cached years in ", raw_dir, "; run R/00_download.R first")

counts <- list(); samples <- list()
for (f in files) {
  raw <- readRDS(f)
  yr  <- as.integer(unique(raw$Ano))
  stopifnot(length(yr) == 1)
  b <- flag_sample(recode_persons(raw))
  saveRDS(b$persons, file.path(clean_dir, sprintf("persons_%d.rds", yr)))
  counts[[as.character(yr)]]  <- mutate(b$counts, year = yr, .before = 1)
  samples[[as.character(yr)]] <- filter(b$persons, in_sample)
  message(sprintf("%d: %s persons, %s in sample (%.1f%% of 25-64 occupied)", yr,
                  format(nrow(b$persons), big.mark = ","), format(sum(b$persons$in_sample), big.mark = ","),
                  100 * sum(b$persons$in_sample) / b$counts$n[3]))
  rm(raw, b); invisible(gc())
}
sample <- bind_rows(samples)
saveRDS(sample, file.path(clean_dir, "sample.rds"))
counts <- bind_rows(counts)
write.csv(counts, file.path(clean_dir, "build_counts.csv"), row.names = FALSE)
message("Analysis sample: ", format(nrow(sample), big.mark = ","), " person-years over ",
        length(files), " years; written to ", clean_dir)
