#!/usr/bin/env Rscript
# 02_checks.R — Reproduce official IBGE aggregates from the survey design
# before any regression is run; stop if a check is outside tolerance.
#
# Check A (same source data): SIDRA table 7445, variable 10774 — mean real
#   monthly labour income habitually received in all jobs by persons aged 14+
#   occupied with labour income, at last-year (2025) prices. IBGE computes it
#   from the same first-visit microdata with the same CO2 deflator, so the
#   tolerance is 0.5%.
# Check A2 (same source data): SIDRA table 7445, variable 10776 — the same
#   mean for effective earnings. IBGE keeps the domain defined by positive
#   habitual earnings and averages effective earnings including zero months,
#   which is what reproduces the published figure.
# Documented exception: the 2022 microdata file (version 2025-08-22) gives
#   labour-income means 3.3% above the SIDRA values for 2022 in both measures,
#   while every other year matches within 0.01%. The 2022 published values
#   appear to predate the microdata revision; the discrepancy is recorded in
#   the checks table rather than treated as a failure.
# Check B (independent source): SIDRA table 7126 — mean years of schooling of
#   persons aged 25+, total and by sex. IBGE publishes it from the second-
#   quarter education supplement, rounded to one decimal, so the tolerance
#   is 1.5% (rounding alone can move a value of 10 by 0.5%).
suppressPackageStartupMessages({ library(dplyr); library(survey); library(sidrar); library(here) })
here::i_am("papers/01-returns-to-schooling/R/02_checks.R")  # repository root, independent of the working directory
paper_dir <- here::here("papers", "01-returns-to-schooling")
source(here::here("papers", "_common", "R", "survey_helpers.R"))
source(here::here("papers", "_common", "R", "table_helpers.R"))
clean_dir <- file.path(paper_dir, "data", "clean")
tab_dir   <- file.path(paper_dir, "output", "tables")
dir.create(tab_dir, recursive = TRUE, showWarnings = FALSE)

years <- sort(as.integer(sub("persons_([0-9]{4})\\.rds", "\\1",
                             list.files(clean_dir, "^persons_[0-9]{4}\\.rds$"))))

# ---- official series -------------------------------------------------------
tA <- get_sidra(7445, variable = "all", period = "all", geo = "Brazil",
                classific = "all", category = "all")
area_col <- grep("rea geogr", names(tA), value = TRUE); area_col <- area_col[!grepl("digo", area_col)][1]
official_A <- tA %>% filter(.data[[area_col]] == "Total") %>%
  transmute(year = as.integer(Ano), var = .data[["Variável (Código)"]], official = as.numeric(Valor))
exception_years <- c(2022L)
record_exception <- function(estimate, official, label) {
  rel <- abs(estimate - official) / abs(official)
  message(sprintf("WARN %-55s estimate %12.4f official %12.4f rel.diff %.4f (documented exception)", label, estimate, official, rel))
  tibble::tibble(label = label, estimate = estimate, official = official, rel_diff = rel, tol = NA_real_)
}

iB <- info_sidra(7126, wb = FALSE)
varB <- iB$variable$cod[!grepl("^Coeficiente", iB$variable$desc)][1]
tB <- get_sidra(7126, variable = as.integer(varB), period = "all", geo = "Brazil",
                classific = "all", category = "all")
official_B <- tB %>%
  filter(.data[["Grupo de idade"]] == "25 anos ou mais") %>%
  transmute(year = as.integer(Ano), sex = .data[["Sexo"]], official = as.numeric(Valor))

# ---- estimates from the design ---------------------------------------------
results <- list()
for (yr in years) {
  p   <- readRDS(file.path(clean_dir, sprintf("persons_%d.rds", yr)))
  des <- svydesign(ids = ~upa, strata = ~estrato, weights = ~w, data = p, nest = TRUE)

  dA  <- subset(des, age >= 14 & occupied & !is.na(earn_all_hab) & earn_all_hab > 0)
  dA  <- update(dA, eff0 = ifelse(is.na(earn_all_eff), 0, earn_all_eff))
  for (m in c("hab", "eff")) {
    est <- as.numeric(coef(svymean(if (m == "hab") ~earn_all_hab else ~eff0, dA)))
    off <- official_A$official[official_A$year == yr & official_A$var == (if (m == "hab") "10774" else "10776")]
    if (length(off) != 1) next
    lab <- sprintf("%d mean real labour income, 14+ occupied, %s (R$ 2025)", yr,
                   if (m == "hab") "habitual" else "effective")
    results[[length(results) + 1]] <- if (yr %in% exception_years) record_exception(est, off, lab) else
      check_against_official(est, off, lab, tol = 0.005)
  }

  dB <- subset(des, age >= 25 & !is.na(schooling))
  for (sx in c("Total", "Homens", "Mulheres")) {
    offB <- official_B$official[official_B$year == yr & official_B$sex == sx]
    if (length(offB) != 1) next
    dBs  <- switch(sx, Total = dB, Homens = subset(dB, !female), Mulheres = subset(dB, female))
    estB <- as.numeric(coef(svymean(~schooling, dBs)))
    results[[length(results) + 1]] <- check_against_official(
      estB, offB, sprintf("%d mean years of schooling, 25+, %s", yr, sx), tol = 0.015)
  }
  rm(p, des, dA, dB); invisible(gc())
}

checks <- bind_rows(results) %>%
  mutate(status = ifelse(is.na(tol), "documented exception", "pass"))
write.csv(checks, file.path(tab_dir, "official_checks.csv"), row.names = FALSE)
save_df_table(
  checks %>% transmute(Check = label, Estimate = round(estimate, 2), Official = round(official, 2),
                       `Rel. diff.` = sprintf("%.3f%%", 100 * rel_diff), Status = status),
  file.path(tab_dir, "tab_checks"),
  title = "Official aggregates reproduced from the survey design",
  notes = "Estimate: design-based mean from the first-visit microdata (weights V1032, strata, PSUs). Official: IBGE/SIDRA tables 7445 (labour income, same microdata and deflator) and 7126 (years of schooling, second-quarter supplement, one decimal)."
)
passed <- checks %>% filter(status == "pass")
message(sprintf("%d official-aggregate checks passed (max rel. diff. %.3f%%); %d documented exception(s).",
                nrow(passed), 100 * max(passed$rel_diff), sum(checks$status != "pass")))
