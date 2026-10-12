#!/usr/bin/env Rscript
# 04_report.R — Tables (Markdown + LaTeX), figures and headline numbers from
# the estimates saved by 03_analysis.R in data/clean/results.rds.
suppressPackageStartupMessages({ library(dplyr); library(tidyr); library(purrr); library(here); library(ggplot2) })
here::i_am("papers/01-returns-to-schooling/R/04_report.R")  # repository root, independent of the working directory
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
R <- readRDS(file.path(clean_dir, "results.rds"))
years <- R$years; SE_NOTE <- R$se_note
by_year <- R$by_year; lev_year <- R$lev_year; het_year <- R$het_year; desc_year <- R$desc_year
pooled_reg <- R$pooled_reg; pooled_het <- R$pooled_het; rob_tidies <- R$rob_tidies

# Every estimate behind the tables and figures, as CSV (regenerated here so a
# report run restores them even if output/ was emptied).
write.csv(by_year,       file.path(tab_dir, "estimates_by_year.csv"), row.names = FALSE)
write.csv(lev_year,      file.path(tab_dir, "levels_by_year.csv"), row.names = FALSE)
write.csv(het_year,      file.path(tab_dir, "heterogeneity_by_year.csv"), row.names = FALSE)
write.csv(R$reg_year,    file.path(tab_dir, "regions_by_year.csv"), row.names = FALSE)
write.csv(desc_year,     file.path(tab_dir, "descriptives_by_year.csv"), row.names = FALSE)
write.csv(pooled_het,    file.path(tab_dir, "heterogeneity_pooled.csv"), row.names = FALSE)
write.csv(pooled_reg,    file.path(tab_dir, "regions_pooled.csv"), row.names = FALSE)

message("tables")
coef_lin <- c(schooling = "Years of schooling", age = "Age", age2 = "Age squared",
              female_fWomen = "Women", `raceBlack/Brown` = "Black/Brown", raceIndigenous = "Indigenous",
              urbanTRUE = "Urban")
coef_lev <- c(`edu_levelFundamental incomplete` = "Fundamental incomplete",
              `edu_levelFundamental complete` = "Fundamental complete",
              `edu_levelMedio incomplete` = "Médio incomplete",
              `edu_levelMedio complete` = "Médio complete",
              `edu_levelSuperior incomplete` = "Superior incomplete",
              `edu_levelSuperior complete` = "Superior complete")
coef_het <- c(schooling = "Years of schooling", `schooling:female_fWomen` = "Schooling × Women",
              `schooling:raceBlack/Brown` = "Schooling × Black/Brown",
              `schooling:raceIndigenous` = "Schooling × Indigenous",
              female_fWomen = "Women", `raceBlack/Brown` = "Black/Brown", raceIndigenous = "Indigenous")

main_tidies <- list("(1) Linear" = R$tidy_pm_lin, "(2) Levels" = R$tidy_pm_lev,
                    "(3) Interactions" = R$tidy_pm_het)
main_map <- c(coef_lin[1], coef_lev, coef_het[-1], coef_lin[-1]); main_map <- main_map[!duplicated(names(main_map))]
main_tab <- make_coef_table(main_tidies, main_map, digits = 4,
                            extra_rows = data.frame(a = c("State and year fixed effects"), b = "Yes", c = "Yes", d = "Yes"))
save_char_table(main_tab, file.path(tab_dir, "tab_main"),
                title = "Mincer regressions, pooled 2012-2025",
                notes = paste(SE_NOTE, "Education levels are relative to no schooling; interactions are relative to men and to White/Asian workers."))

lev_tidies <- c(R$tidy_lev_keep, list(Pooled = R$tidy_pm_lev))
lev_tab <- make_coef_table(lev_tidies, coef_lev)
save_char_table(lev_tab, file.path(tab_dir, "tab_levels"),
                title = "Earnings premia by completed level of education, relative to no schooling",
                notes = paste(SE_NOTE, "Controls: age, age squared, sex, race, urban, state fixed effects (and year fixed effects in the pooled column)."))

by_year_tab <- by_year %>%
  transmute(Year = as.character(year), Estimate = sprintf("%.4f", estimate), SE = sprintf("(%.4f)", std.error),
            `95% CI` = sprintf("[%.3f, %.3f]", conf.low, conf.high), Observations = format(nobs, big.mark = ","))
save_char_table(by_year_tab, file.path(tab_dir, "tab_by_year"),
                title = "Return to a year of schooling by survey year",
                notes = paste(SE_NOTE, "Coefficient on years of schooling in the linear specification with state fixed effects, one regression per year. No first-visit microdata were released for 2020 and 2021."))

reg_tab <- pooled_reg %>%
  transmute(Region = region, Estimate = sprintf("%.4f", estimate), SE = sprintf("(%.4f)", std.error),
            `95% CI` = sprintf("[%.3f, %.3f]", conf.low, conf.high), Observations = format(nobs, big.mark = ","))
save_char_table(reg_tab, file.path(tab_dir, "tab_regions"),
                title = "Return to a year of schooling by macro-region, pooled 2012-2025",
                notes = paste(SE_NOTE, "Linear specification with state and year fixed effects, estimated separately by region."))

rob_rows <- map_dfr(rob_tidies, ~ filter(.x, term == "schooling"), .id = "variant") %>%
  transmute(Variant = variant, `Years of schooling` = sprintf("%.4f", estimate), SE = sprintf("(%.4f)", std.error),
            `95% CI` = sprintf("[%.4f, %.4f]", estimate - 1.96 * std.error, estimate + 1.96 * std.error),
            Observations = format(nobs, big.mark = ","))
save_char_table(as.data.frame(rob_rows), file.path(tab_dir, "tab_robustness"),
                title = "Robustness of the pooled linear estimate",
                notes = paste("Coefficient on years of schooling in the linear specification with state and year fixed effects, pooled 2012-2025.",
                              "Rows (1)-(6) use design-based inference (PNAD Contínua strata, PSUs and first-visit weights); (7) ignores weights and design and uses HC1 standard errors;",
                              "(8) uses the weights with standard errors clustered by UPA but ignores strata. (2) uses effective instead of habitual earnings; (3) keeps signed-card or statutory employees and contributing self-employed;",
                              "(4) keeps wage employees; (5) widens the age range; (6) drops the 0.5% tails of log earnings."))
write.csv(map_dfr(rob_tidies, ~ filter(.x, term == "schooling"), .id = "variant"),
          file.path(tab_dir, "robustness_schooling.csv"), row.names = FALSE)
write.csv(bind_rows(linear = R$tidy_pm_lin, levels = R$tidy_pm_lev, interactions = R$tidy_pm_het, .id = "model") %>%
            filter(!grepl("^uf_f|^year_f", term)),
          file.path(tab_dir, "pooled_coefficients.csv"), row.names = FALSE)

desc_tab <- desc_year %>%
  transmute(Year = as.character(year), Observations = format(n, big.mark = ","),
            Schooling = sprintf("%.2f", schooling), `Hourly earnings` = sprintf("%.2f", hourly),
            Age = sprintf("%.1f", age), Women = sprintf("%.3f", female), `Black or Brown` = sprintf("%.3f", black_brown),
            Formal = sprintf("%.3f", formal))
save_char_table(as.data.frame(desc_tab), file.path(tab_dir, "tab_descriptives"),
                title = "Analysis sample by year: design-based means",
                notes = "Occupied persons aged 25-64 with positive habitual earnings and 1-120 weekly hours in the main job. Means use the first-visit weights. Schooling in years; hourly earnings in the main job at 2025 prices (R$); women, Black or Brown and formal are shares. Formal: signed-card or statutory employees, or self-employed and employers contributing to social security. Weighted sample sizes range from 68.5 million (2012) to 83.7 million (2025) person-years.")

counts <- read.csv(file.path(clean_dir, "build_counts.csv"))
step_short <- c("All persons" = "All persons", "Aged 25-64" = "Aged 25-64", "Occupied" = "Occupied",
                "Positive habitual earnings, main job" = "Positive earnings",
                "Hours 1-120 per week, main job" = "Hours 1-120",
                "Schooling and race reported (analysis sample)" = "Analysis sample")
counts_tab <- counts %>% mutate(step = step_short[step], n = format(n, big.mark = ",")) %>%
  select(year, step, n) %>% pivot_wider(names_from = step, values_from = n) %>%
  mutate(year = as.character(year)) %>% rename(Year = year)
save_char_table(as.data.frame(counts_tab), file.path(tab_dir, "tab_build_counts"),
                title = "Sample construction: unweighted counts at each filter step",
                notes = "First-visit annual microdata, PNAD Contínua. Each column applies one more filter to the column to its left: aged 25-64; occupied in the reference week; positive habitual earnings in the main job; 1-120 weekly hours in the main job; schooling and race reported.")

labels <- c(tab_main = "tbl-main", tab_levels = "tbl-levels", tab_by_year = "tbl-byyear",
            tab_regions = "tbl-regions", tab_robustness = "tbl-robust", tab_descriptives = "tbl-desc",
            tab_build_counts = "tbl-counts", tab_checks = "tbl-checks")
for (nm in names(labels)) {
  f <- file.path(tab_dir, paste0(nm, ".md"))
  if (file.exists(f)) label_md_table(f, labels[[nm]])
}

# ---- 4. figures --------------------------------------------------------------
message("figures")
src_caption <- "Source: PNAD Contínua first-visit microdata (IBGE). Bands: design-based 95% CIs."
by_year <- by_year %>% mutate(block = ifelse(year <= 2019, "a", "b"))
fig1 <- ggplot(by_year, aes(year, estimate)) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high, group = block), fill = pal_series[1], alpha = 0.15) +
  geom_line(aes(group = block), colour = pal_series[1], linewidth = 0.8) +
  geom_point(colour = pal_series[1], size = 2.2) +
  scale_x_continuous(breaks = years) +
  scale_y_continuous(labels = function(x) sprintf("%.1f%%", 100 * x)) +
  labs(x = NULL, y = "Return to a year of schooling",
       title = "The return to a year of schooling stayed close to 10 percent",
       subtitle = "Coefficient on years of schooling, log real hourly earnings, ages 25-64, by year",
       caption = paste(src_caption, "No files for 2020-21.")) +
  theme_series()
save_figure(fig1, file.path(fig_dir, "fig_returns_by_year"))

lev_plot <- lev_year %>%
  filter(term %in% c("edu_levelFundamental complete", "edu_levelMedio complete", "edu_levelSuperior complete")) %>%
  mutate(level = factor(sub("edu_level", "", term), levels = c("Superior complete", "Medio complete", "Fundamental complete"),
                        labels = c("Superior complete", "Médio complete", "Fundamental complete")),
         block = ifelse(year <= 2019, "a", "b"))
fig2 <- ggplot(lev_plot, aes(year, estimate, colour = level)) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill = level, group = interaction(level, block)), alpha = 0.12, colour = NA) +
  geom_line(aes(group = interaction(level, block)), linewidth = 0.8) +
  geom_point(size = 2) +
  scale_colour_series() + scale_fill_series() +
  scale_x_continuous(breaks = years) +
  scale_y_continuous(labels = function(x) sprintf("%.0f%%", 100 * x)) +
  labs(x = NULL, y = "Log-point premium vs no schooling",
       title = "Premia by completed level fell, most of all for a degree",
       subtitle = "Premia by completed level, relative to no schooling, with controls, by year",
       caption = src_caption) +
  theme_series()
save_figure(fig2, file.path(fig_dir, "fig_levels_by_year"))

het_plot <- het_year %>%
  separate(group, into = c("sex", "race"), sep = ", ", remove = FALSE) %>%
  mutate(block = ifelse(year <= 2019, "a", "b"))
fig3 <- ggplot(het_plot, aes(year, estimate, colour = race)) +
  geom_ribbon(aes(ymin = conf.low, ymax = conf.high, fill = race, group = interaction(race, block)), alpha = 0.12, colour = NA) +
  geom_line(aes(group = interaction(race, block)), linewidth = 0.8) +
  geom_point(size = 1.8) +
  facet_wrap(~sex) +
  scale_colour_series() + scale_fill_series() +
  scale_x_continuous(breaks = seq(2012, 2025, 4)) +
  scale_y_continuous(labels = function(x) sprintf("%.1f%%", 100 * x)) +
  labs(x = NULL, y = "Return to a year of schooling",
       title = "Returns by sex and race",
       subtitle = "Schooling coefficient from the interaction model, by year",
       caption = src_caption) +
  theme_series()
save_figure(fig3, file.path(fig_dir, "fig_heterogeneity"), height = 4.6)

fig4 <- ggplot(pooled_reg, aes(estimate, factor(region, levels = rev(REGION_LEVELS)))) +
  geom_errorbar(aes(xmin = conf.low, xmax = conf.high), width = 0, colour = pal_series[1], linewidth = 0.8) +
  geom_point(colour = pal_series[1], size = 2.6) +
  scale_x_continuous(labels = function(x) sprintf("%.1f%%", 100 * x)) +
  labs(x = "Return to a year of schooling, pooled 2012-2025", y = NULL,
       title = "Returns are highest in the Nordeste",
       subtitle = "Linear specification with state and year fixed effects, by macro-region",
       caption = src_caption) +
  theme_series() + theme(panel.grid.major.y = element_blank(), panel.grid.major.x = element_line(colour = pal_ink[["grid"]], linewidth = 0.3))
save_figure(fig4, file.path(fig_dir, "fig_regions"), height = 3.4)

# ---- 5. headline numbers for the text ---------------------------------------
headline <- list(
  years = years, n_total = sum(desc_year$n),
  pooled_linear = filter(R$tidy_pm_lin, term == "schooling"),
  first_year = by_year[by_year$year == min(years), ], last_year = by_year[by_year$year == max(years), ],
  max_year = by_year[which.max(by_year$estimate), ], min_year = by_year[which.min(by_year$estimate), ],
  pooled_het = pooled_het, pooled_reg = pooled_reg,
  pooled_levels = filter(R$tidy_pm_lev, grepl("^edu_level", term)),
  robustness = map_dfr(rob_tidies, ~ filter(.x, term == "schooling"), .id = "variant"),
  degf_pooled = R$degf_pooled, trim_quantiles = R$trim_quantiles
)
saveRDS(headline, file.path(tab_dir, "headline.rds"))
message("04_report.R finished: tables in ", tab_dir, ", figures in ", fig_dir)
