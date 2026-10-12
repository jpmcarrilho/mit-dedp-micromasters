#!/usr/bin/env Rscript
# 00_download.R — Download PNAD Contínua annual first-visit microdata with
# PNADcIBGE, keep the analysis variables plus the survey-design variables, and
# cache one .rds per year in data/raw/ (git-ignored).
#
# Resumable: a year whose .rds already exists is skipped unless FORCE=1.
# Usage:  Rscript R/00_download.R            # all years (2023 first, then 2012-2025)
#         Rscript R/00_download.R 2019 2020  # selected years
suppressPackageStartupMessages({
  library(PNADcIBGE)
  library(dplyr)
  library(here)
})

here::i_am("papers/01-returns-to-schooling/R/00_download.R")  # repository root, independent of the working directory
paper_dir <- here::here("papers", "01-returns-to-schooling")
raw_dir   <- file.path(paper_dir, "data", "raw")
dir.create(raw_dir, recursive = TRUE, showWarnings = FALSE)

args  <- commandArgs(trailingOnly = TRUE)
years <- if (length(args)) as.integer(args) else c(2023L, 2012:2022, 2024L, 2025L)
force <- identical(Sys.getenv("FORCE"), "1")

# Analysis variables (annual first-visit dictionary). PNADcIBGE always keeps
# the design variables (UPA, Estrato, V1032, posest, posest_sxi, V1029, V1033).
vars <- c(
  "V1022",  # urban / rural
  "V1023",  # type of area (capital, metro region, other)
  "V2007",  # sex
  "V2009",  # age in years
  "V2010",  # race / colour
  "V3001",  # literate
  "VD3004", # highest education level completed
  "VD3005", # years of schooling (0-16)
  "VD3006", # schooling groups
  "VD4001", # labour-force status
  "VD4002", # occupied / unemployed
  "VD4009", # position in occupation (formal / informal / self-employed ...)
  "VD4010", # sector of activity
  "VD4012", # contributes to social security
  "VD4016", # habitual monthly earnings, main job (nominal)
  "VD4017", # effective monthly earnings, main job (nominal)
  "VD4019", # habitual monthly earnings, all jobs (nominal)
  "VD4020", # effective monthly earnings, all jobs (nominal)
  "VD4031", # hours habitually worked per week, all jobs
  "VD4035", # hours effectively worked per week, all jobs
  "V4039",  # hours habitually worked per week, main job
  "V4040"   # time in the main job (categories)
)

for (yr in years) {
  out <- file.path(raw_dir, sprintf("pnadc_%d_visita1.rds", yr))
  if (file.exists(out) && !force) { message("skip ", yr, " (cached)"); next }
  message(sprintf("==> %d  start %s", yr, format(Sys.time(), "%H:%M:%S")))
  t0 <- Sys.time()
  res <- tryCatch(
    PNADcIBGE::get_pnadc(year = yr, interview = 1, vars = vars, labels = FALSE,
                         deflator = TRUE, defyear = as.integer(Sys.getenv("DEFYEAR", "2025")), design = FALSE,
                         savedir = raw_dir, reload = FALSE),
    error = function(e) { message("FAILED ", yr, ": ", conditionMessage(e)); NULL }
  )
  if (is.null(res)) next
  res$source_year <- yr
  # The 200 bootstrap replicate weights (V1032001-V1032200) are not used by
  # pnadc_design(), which post-stratifies the UPA/Estrato/V1031 design; drop
  # them to keep each year under ~60 MB on disk.
  res <- res[, !grepl("^V1032[0-9]{3}$", names(res))]
  saveRDS(res, out)
  # the extracted fixed-width text files are large; the zip is kept for reuse
  unlink(list.files(raw_dir, pattern = "\\.txt$", full.names = TRUE))
  message(sprintf("    %s rows x %d cols; columns: %s", format(nrow(res), big.mark = ","),
                  ncol(res), paste(names(res), collapse = " ")))
  message(sprintf("    done in %.1f min", as.numeric(difftime(Sys.time(), t0, units = "mins"))))
}
message("00_download.R finished ", format(Sys.time()))
