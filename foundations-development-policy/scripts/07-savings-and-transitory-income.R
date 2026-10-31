# ==============================================================================
# COURSE: Foundations of Development Policy
# MODULE: Week 7 - Savings and Transitory Income
# TOPIC: Savings Response to Weather-Driven Transitory Income (Paxson 1992)
# ==============================================================================
# Overview:
# This script replicates the income and savings analysis of Christina Paxson (1992, AER),
# "Using Weather Variability to Estimate the Response of Savings to Transitory Income in
# Thailand". Rainfall deviations serve as a source of transitory income shocks.
#
# Research Question: How much of a transitory income shock is saved, and how much of a
# permanent income change is saved?
#
# Identification Strategy: Two-step permanent-income model
# - Income equation (Table 3, column 1): income on household characteristics, year and
#   region effects, and rainfall deviations, estimated by OLS.
# - Permanent income (incperm): predicted from household characteristics, year and region.
# - Transitory income (inctrans): predicted from year effects and rainfall deviations.
# - Unexplained income (incunexp): residual of the income equation.
# - Savings equation (Table 4, two-step): save2 on the three income components, household
#   counts, rainfall standard deviations, and year effects.
#
# Key Econometric Concepts:
# 1. Permanent-income hypothesis: savings respond differently to permanent and transitory
#    income, so the two propensities to save are estimated separately.
# 2. Weather as an instrument for transitory income: rainfall shocks change income but are
#    unrelated to permanent household characteristics.
# 3. Two-step estimation: the income equation is estimated first, and its predicted
#    components are used as regressors in the savings equation.
# ==============================================================================

# Preliminaries
# -------------------------------------------------
rm(list = ls())
library(tidyverse)
library(haven)

# Load data
# -------------------------------------------------
# Stata file in data/paxson.dta, copied unchanged from the original download.
# Survey years are coded 76, 81 and 86.
paxson_data <- read_dta("../data/paxson.dta")


# Data Check
# -------------------------------------------------
# Dimensions and number of observations per survey year.
cat("Rows:", nrow(paxson_data), " Columns:", ncol(paxson_data), "\n")
print(table(paxson_data$year))


# Household Member Categories (13 age/sex/education categories)
# -------------------------------------------------
# These counts form the household block of Paxson's equation (2). The codebook has no
# sex split for people aged 0-5, so that group is the 13th category.
# The codebook labels the education groups "18-65", but the counts match the 18-64 total
# (p18to64), so the education groups are treated as ages 18-64.
member_categories <- c(
  "p0to5",                           # people aged 0-5 (no sex recorded)
  "m12", "m18", "m65",               # males: 6-11, 12-17, 65+
  "m18elem", "m18sec", "m18pos",     # males 18-64: elementary, secondary, post-secondary
  "f12", "f18", "f65",               # females: 6-11, 12-17, 65+
  "f18elem", "f18sec", "f18pos"      # females 18-64: elementary, secondary, post-secondary
)

# Check: the categories add up to the people counts by age group
age_group_mismatch <- with(paxson_data,
  (m12 + f12 != p6to11) |
  (m18 + f18 != p12to17) |
  (m65 + f65 != p65) |
  (m18elem + m18sec + m18pos + f18elem + f18sec + f18pos != p18to64)
)
cat("Categories defined:", length(member_categories), "\n")
cat("Rows where the categories do not match the age totals:", sum(age_group_mismatch), "\n")


# Fixed Effects from Equation (2): Year (beta_t) and Region (beta_0r)
# -------------------------------------------------
# factor() turns the numeric codes into categories. Regression software then creates
# one 0/1 dummy per level, dropping one base level.
paxson_data <- paxson_data %>%
  mutate(
    year_fe   = factor(year),
    region_fe = factor(region)
  )
cat("Year levels:", nlevels(paxson_data$year_fe), " Region levels:", nlevels(paxson_data$region_fe), "\n")


# Permanent Income from the Printed Table 3 Coefficients (YP_irt)
# -------------------------------------------------
# Uses only the coefficients printed in the table, so the 20 region coefficients (not
# printed) are missing. Rainfall terms are left out, since permanent income depends on
# household characteristics, year and region.
# Land omitted category: owns 40 rai or more.
intercept_income <- 2455.6
coef_year <- c(y81 = 301.68, y86 = -402.26)        # base year: 76
coef_members <- c(
  p0to5 = 37.693,
  m12 = 59.730, f12 = 79.547,
  m18 = 220.57, f18 = 192.98,
  m18elem = 349.38, m18sec = 765.72, m18pos = 1042.9,
  f18elem = 62.306, f18sec = 345.63, f18pos = 676.93,
  m65 = 135.52, f65 = 159.68
)
coef_land <- c(of0 = -1338.8,                       # of0: farm renter
               of1 = -1699.6,                       # of1: owns less than 2 rai
               of2 = -1769.4,                       # of2: owns 2-4 rai
               of3 = -1583.2,                       # of3: owns 5-9 rai
               of4 = -1368.3,                       # of4: owns 10-19 rai
               of5 = -1008.3)                       # of5: owns 20-39 rai

member_part <- as.vector(as.matrix(paxson_data[names(coef_members)]) %*% coef_members)
land_part <- as.vector(as.matrix(paxson_data[names(coef_land)]) %*% coef_land)

paxson_data <- paxson_data %>%
  mutate(
    YP_irt = intercept_income +
      coef_year["y81"] * (year == 81) + coef_year["y86"] * (year == 86) +
      member_part + land_part
  )
cat("YP_irt summary:\n")
print(summary(paxson_data$YP_irt))


# Income Regression (Table 3, Column 1), Re-estimated
# -------------------------------------------------
# The table does not print the region coefficients, but the regression that produces it
# estimates them. Re-estimating reproduces the printed coefficients (for example,
# intercept 2455.64 and year 81 effect 301.68), so every term is available here.
# Rainfall: dev1-dev4 are rainfall deviations from the mean by season (Jan-Mar, Apr-Jun,
# Jul-Sep, Oct-Dec). dvsq1-dvsq4 are the same deviations squared.
perm_vars <- c("p0to5", "m12", "f12", "m18", "f18", "m18elem", "m18sec", "m18pos",
               "f18elem", "f18sec", "f18pos", "m65", "f65",
               "of0", "of1", "of2", "of3", "of4", "of5")
rain_vars <- c("dev1", "dev2", "dev3", "dev4", "dvsq1", "dvsq2", "dvsq3", "dvsq4")
income_formula <- as.formula(paste("inc ~ year_fe + region_fe +",
                                   paste(c(perm_vars, rain_vars), collapse = " + ")))
reg_sum <- summary(lm(income_formula, data = paxson_data))
coefs <- coef(reg_sum)[, "Estimate"]


# Permanent Income (incperm)
# -------------------------------------------------
# Permanent characteristics times their estimated coefficients, summed (equation 2).
# Year effects, region effects and the household and land terms are included; rainfall
# is excluded, so incperm is the permanent part of income.
perm_matrix <- model.matrix(as.formula(paste("~ year_fe + region_fe +", paste(perm_vars, collapse = " + "))),
                            data = paxson_data)
paxson_data <- paxson_data %>%
  mutate(incperm = as.vector(perm_matrix %*% coefs[colnames(perm_matrix)]))
cat("SD of incperm:", sd(paxson_data$incperm), "\n")


# Transitory Income (inctrans)
# -------------------------------------------------
# Equation (3): year effect (with the intercept) plus the region-specific rainfall terms
# (four seasonal deviations and their squares), each times its coefficient.
trans_matrix <- model.matrix(as.formula(paste("~ year_fe +", paste(rain_vars, collapse = " + "))),
                             data = paxson_data)
paxson_data <- paxson_data %>%
  mutate(inctrans = as.vector(trans_matrix %*% coefs[colnames(trans_matrix)]))
cat("SD of inctrans:", sd(paxson_data$inctrans), "\n")


# Unexplained Income (incunexp)
# -------------------------------------------------
# The part of income not explained by permanent or transitory components.
paxson_data <- paxson_data %>%
  mutate(incunexp = inc - incperm - inctrans)
cat("SD of incunexp:", sd(paxson_data$incunexp), "\n")


# Savings Regression: save2 on Predicted Permanent and Transitory Income
# -------------------------------------------------
# Regressors: inctrans (transitory propensity), incperm (permanent propensity), incunexp
# (income residual), the five people-by-age counts, the four rainfall standard deviations,
# and year effects (the time-varying intercept, Table 4).
# This specification matches Paxson's Table 4 two-step SAVE2 estimates
# (0.8039 transitory, 0.4400 permanent, 0.6925 unexplained).
savings_formula <- save2 ~ inctrans + incperm + incunexp + p0to5 + p6to11 + p12to17 + p18to64 + p65 +
  sd1 + sd2 + sd3 + sd4 + year_fe
savings_fit <- lm(savings_formula, data = paxson_data)
savings_coefs <- coef(summary(savings_fit))
print(round(savings_coefs[c("inctrans", "incperm", "incunexp"), ], 4))
cat("Marginal propensity to save out of transitory income (inctrans):",
    round(savings_coefs["inctrans", "Estimate"], 4), "\n")
cat("Marginal propensity to save out of permanent income (incperm):",
    round(savings_coefs["incperm", "Estimate"], 4), "\n")


# Test: Equal Propensities to Save
# -------------------------------------------------
# Null hypothesis: the propensity to save out of transitory income equals the propensity
# out of permanent income (inctrans = incperm).
if (requireNamespace("car", quietly = TRUE)) {
  print(car::linearHypothesis(savings_fit, "inctrans = incperm"))
}


# ==============================================================================
# Summary of Results
# ==============================================================================
cat("==============================================================================\n")
cat("SUMMARY: Savings Response to Permanent and Transitory Income (save2)\n")
cat("==============================================================================\n")
cat(sprintf("Propensity to save out of transitory income: %.4f\n", savings_coefs["inctrans", "Estimate"]))
cat(sprintf("Propensity to save out of permanent income:  %.4f\n", savings_coefs["incperm", "Estimate"]))
cat("==============================================================================\n")
