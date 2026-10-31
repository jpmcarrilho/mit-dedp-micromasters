#!/usr/bin/env Rscript
# 03_analysis.R — Design-based Mincer estimates for Brazil, 2012-2025 (fitting).
# Reads data/clean/persons_<year>.rds, builds one survey design per year
# (ids = UPA, strata = Estrato, weights = V1032, nest = TRUE), subsets to the
# analysis domain and fits svyglm models. A pooled design stacks all years with
# year fixed effects, clustering on the same UPAs across years. Saves every
# estimate needed downstream to data/clean/results.rds and output/tables/*.csv;
# 04_report.R turns them into tables and figures.
suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(purrr); library(survey); library(here)
  library(ggplot2); library(sandwich); library(lmtest)
})
here::i_am("papers/01-returns-to-schooling/R/03_analysis.R")  # repository root, independent of the working directory
paper_dir <- here::here("papers", "01-returns-to-schooling")
common    <- here::here("papers", "_common", "R")
source(file.path(common, "survey_helpers.R"))
source(file.path(common, "table_helpers.R"))
source(file.path(common, "theme.R"))
source(file.path(paper_dir, "R", "build_functions.R"))
clean_dir <- file.path(paper_dir, "data", "clean")
tab_dir   <- file.path(paper_dir, "output", "tables")
fig_dir   <- file.path(paper_dir, "output", "figures")
dir.create(tab_dir, recursive = TRUE, showWarnings = FALSE)
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
options(survey.lonely.psu = "adjust")
t0 <- Sys.time()

years <- sort(as.integer(sub("persons_([0-9]{4})\\.rds", "\\1",
                             list.files(clean_dir, "^persons_[0-9]{4}\\.rds$"))))
message("Years: ", paste(years, collapse = " "))

SE_NOTE <- paste(
  "Design-based standard errors in parentheses, computed from the PNAD Contínua strata,",
  "primary sampling units and first-visit weights (V1032). Dependent variable: log real hourly",
  "earnings in the main job (habitual monthly earnings at 2025 prices divided by 52/12 times weekly hours).",
  "Sample: occupied persons aged 25-64 with positive earnings and 1-120 weekly hours.",
  "+ p < 0.1, * p < 0.05, ** p < 0.01, *** p < 0.001.")

prep <- function(p) {
  p$age2     <- p$age^2
  p$uf_f     <- factor(p$uf)
  p$year_f   <- factor(p$year)
  p$female_f <- factor(ifelse(p$female, "Women", "Men"), levels = c("Men", "Women"))
  p$black_brown <- p$race == "Black/Brown"
  p$hourly   <- exp(p$log_wage)
  p
}
year_design <- function(yr) {
  p <- prep(readRDS(file.path(clean_dir, sprintf("persons_%d.rds", yr))))
  svydesign(ids = ~upa, strata = ~estrato, weights = ~w, data = p, nest = TRUE)
}

f_lin <- log_wage ~ schooling + age + age2 + female_f + race + urban + uf_f
f_lev <- log_wage ~ edu_level + age + age2 + female_f + race + urban + uf_f
f_het <- log_wage ~ schooling * female_f + schooling * race + age + age2 + urban + uf_f

het_groups <- list(
  "Men, White/Asian"   = "schooling",
  "Women, White/Asian" = c("schooling", "schooling:female_fWomen"),
  "Men, Black/Brown"   = c("schooling", "schooling:raceBlack/Brown"),
  "Women, Black/Brown" = c("schooling", "schooling:female_fWomen", "schooling:raceBlack/Brown")
)
lincom <- function(fit, terms) {
  b <- coef(fit); V <- vcov(fit)
  a <- setNames(rep(0, length(b)), names(b)); a[terms] <- 1
  est <- sum(a * b); se <- sqrt(as.numeric(t(a) %*% V %*% a))
  df <- survey::degf(fit$survey.design); tcrit <- qt(0.975, df)
  tibble(estimate = est, std.error = se, conf.low = est - tcrit * se, conf.high = est + tcrit * se)
}

# ---- 1. year-by-year models -------------------------------------------------
by_year <- list(); lev_year <- list(); het_year <- list(); reg_year <- list()
desc_year <- list(); tidy_lev_keep <- list()
for (yr in years) {
  message(sprintf("year %d  (%s)", yr, format(Sys.time(), "%H:%M:%S")))
  des <- year_design(yr)
  d   <- subset(des, in_sample)

  m_lin <- svyglm(f_lin, design = d)
  m_lev <- svyglm(f_lev, design = d)
  m_het <- svyglm(f_het, design = d)

  by_year[[as.character(yr)]] <- svy_coef(m_lin, "schooling") %>% mutate(year = yr, .before = 1)
  tl <- tidy_svyglm(m_lev) %>% mutate(year = yr, .before = 1)
  lev_year[[as.character(yr)]] <- filter(tl, grepl("^edu_level", term))
  if (yr %in% c(min(years), 2019L, max(years))) tidy_lev_keep[[as.character(yr)]] <- tidy_svyglm(m_lev)
  het_year[[as.character(yr)]] <- map_dfr(names(het_groups), function(g)
    lincom(m_het, het_groups[[g]]) %>% mutate(year = yr, group = g, .before = 1))

  for (r in REGION_LEVELS) {
    dr <- update(subset(d, region == r), uf_f = droplevels(uf_f))
    reg_year[[paste(yr, r)]] <- svy_coef(svyglm(f_lin, design = dr), "schooling") %>%
      mutate(year = yr, region = r, .before = 1)
  }

  mn <- svymean(~schooling + log_wage + hourly + age + female + black_brown + formal + wage_employee + urban, d)
  desc_year[[as.character(yr)]] <- tibble(
    year = yr, n = nrow(d$variables), n_weighted = sum(weights(d)),
    schooling = coef(mn)[["schooling"]], log_wage = coef(mn)[["log_wage"]],
    hourly = coef(mn)[["hourly"]], age = coef(mn)[["age"]],
    female = coef(mn)[["femaleTRUE"]], black_brown = coef(mn)[["black_brownTRUE"]],
    formal = coef(mn)[["formalTRUE"]], wage_employee = coef(mn)[["wage_employeeTRUE"]],
    urban = coef(mn)[["urbanTRUE"]])
  rm(des, d, m_lin, m_lev, m_het, dr); invisible(gc())
}
by_year  <- bind_rows(by_year);  lev_year <- bind_rows(lev_year)
het_year <- bind_rows(het_year); reg_year <- bind_rows(reg_year); desc_year <- bind_rows(desc_year)
write.csv(by_year,  file.path(tab_dir, "estimates_by_year.csv"), row.names = FALSE)
write.csv(lev_year, file.path(tab_dir, "levels_by_year.csv"), row.names = FALSE)
write.csv(het_year, file.path(tab_dir, "heterogeneity_by_year.csv"), row.names = FALSE)
write.csv(reg_year, file.path(tab_dir, "regions_by_year.csv"), row.names = FALSE)
write.csv(desc_year, file.path(tab_dir, "descriptives_by_year.csv"), row.names = FALSE)

# ---- 2. pooled design (all years, year fixed effects) ------------------------
message(sprintf("pooled design  (%s)", format(Sys.time(), "%H:%M:%S")))
keep <- c("year", "upa", "estrato", "w", "has_wage", "in_sample", "in_sample_young",
          "log_wage", "log_wage_eff", "schooling", "edu_level", "age", "female", "race",
          "urban", "uf", "region", "formal", "wage_employee")
stack <- map_dfr(years, function(yr) readRDS(file.path(clean_dir, sprintf("persons_%d.rds", yr)))[, keep])
stack <- prep(stack)
des_all <- svydesign(ids = ~upa, strata = ~estrato, weights = ~w, data = stack, nest = TRUE)
rm(stack); invisible(gc())
dp <- subset(des_all, in_sample)
q  <- quantile(dp$variables$log_wage, c(0.005, 0.995))

f_lin_y <- update(f_lin, . ~ . + year_f)
f_lev_y <- update(f_lev, . ~ . + year_f)
f_het_y <- update(f_het, . ~ . + year_f)

message("  pooled main models")
pm_lin <- svyglm(f_lin_y, design = dp)
pm_lev <- svyglm(f_lev_y, design = dp)
pm_het <- svyglm(f_het_y, design = dp)
pooled_het <- map_dfr(names(het_groups), function(g)
  lincom(pm_het, het_groups[[g]]) %>% mutate(group = g, .before = 1))
write.csv(pooled_het, file.path(tab_dir, "heterogeneity_pooled.csv"), row.names = FALSE)

message("  pooled by region")
pooled_reg <- map_dfr(REGION_LEVELS, function(r) {
  dr <- update(subset(dp, region == r), uf_f = droplevels(uf_f))
  svy_coef(svyglm(f_lin_y, design = dr), "schooling") %>% mutate(region = r, .before = 1)
})
write.csv(pooled_reg, file.path(tab_dir, "regions_pooled.csv"), row.names = FALSE)

message("  robustness variants")
rb_eff    <- svyglm(update(f_lin_y, log_wage_eff ~ .), design = subset(dp, !is.na(log_wage_eff)))
rb_formal <- svyglm(f_lin_y, design = subset(dp, formal))
rb_wage   <- svyglm(f_lin_y, design = subset(dp, wage_employee))
rb_young  <- svyglm(f_lin_y, design = subset(des_all, in_sample_young))
rb_trim   <- svyglm(f_lin_y, design = subset(dp, log_wage > q[1] & log_wage < q[2]))
samp <- dp$variables
ols_unw   <- lm(f_lin_y, data = samp)
ols_wls   <- lm(f_lin_y, data = samp, weights = w)
tidy_unw  <- tidy_lm_vcov(ols_unw, sandwich::vcovHC(ols_unw, type = "HC1"))
tidy_wls  <- tidy_lm_vcov(ols_wls, sandwich::vcovCL(ols_wls, cluster = samp$upa, type = "HC1"))
rm(ols_unw, ols_wls, samp); invisible(gc())

# ---- 3. save everything the report needs -------------------------------------
results <- list(
  years = years, by_year = by_year, lev_year = lev_year, het_year = het_year,
  reg_year = reg_year, desc_year = desc_year, tidy_lev_keep = tidy_lev_keep,
  tidy_pm_lin = tidy_svyglm(pm_lin), tidy_pm_lev = tidy_svyglm(pm_lev), tidy_pm_het = tidy_svyglm(pm_het),
  pooled_het = pooled_het, pooled_reg = pooled_reg,
  rob_tidies = list("(1) Baseline" = tidy_svyglm(pm_lin), "(2) Effective earnings" = tidy_svyglm(rb_eff),
                    "(3) Formal only" = tidy_svyglm(rb_formal), "(4) Wage employees" = tidy_svyglm(rb_wage),
                    "(5) Ages 18-64" = tidy_svyglm(rb_young), "(6) Trimmed 0.5/99.5" = tidy_svyglm(rb_trim),
                    "(7) Unweighted OLS, HC1" = tidy_unw, "(8) Weighted OLS, cluster UPA" = tidy_wls),
  degf_pooled = survey::degf(dp), trim_quantiles = q,
  n_pooled = nrow(dp$variables), se_note = SE_NOTE
)
saveRDS(results, file.path(clean_dir, "results.rds"))
message(sprintf("03_analysis.R finished in %.1f minutes", as.numeric(difftime(Sys.time(), t0, units = "mins"))))
