# ==============================================================================
# COURSE: Foundations of Development Policy
# MODULE: Week 8 - Political Economy and Development
# TOPIC: The Persistent Effects of Peru's Mining Mita (Dell 2010)
# ==============================================================================
# Overview:
# This script reproduces the main household-consumption result of Melissa Dell (2010,
# Econometrica), "The Persistent Effects of Peru's Mining Mita". The Mita was a forced
# labor system for silver and mercury mining set up by the Spanish empire in 1573 and
# abolished in 1812. The question is whether districts that were subject to it are poorer today.
#
# Research Question: Does a forced labor institution that ended two hundred years ago
#                    still lower household consumption in the districts it covered?
#
# Identification Strategy: Geographic regression discontinuity design (RDD)
# - Running variable: location, measured by longitude/latitude (x, y) or by distance to
#   Potosi (dpot). The Mita boundary is the cutoff.
# - Treatment: pothuan_mita = 1 for households in districts inside the Mita boundary.
# - Outcome: lhhequiv, the log of equivalent household consumption (2001).
# - Samples: households within 100 km, 75 km and 50 km of the boundary (d_bnd).
#
# Key Econometric Concepts:
# 1. Continuity: households just inside and just outside the boundary would have had
#    similar outcomes without the Mita, so a jump at the boundary is the Mita effect.
# 2. Smooth control for location: a cubic polynomial in x and y (or in dpot) absorbs the
#    smooth effect of location, so only the jump at the boundary remains.
# 3. Clustered standard errors: households in a district share local shocks, so errors are
#    clustered by district.
# ==============================================================================

# Preliminaries
# -------------------------------------------------
rm(list = ls())
library(tidyverse)
library(sandwich)
library(lmtest)

# Load data
# -------------------------------------------------
# CSV in data/mita_data_corrected.csv, copied unchanged from the course download.
mita_data <- read_csv("../data/mita_data_corrected.csv", show_col_types = FALSE)


# Data Check
# -------------------------------------------------
# Dimensions, number of households inside and outside the Mita, and districts in the sample.
cat("Rows:", nrow(mita_data), " Columns:", ncol(mita_data), "\n")
print(table(mita_data$pothuan_mita))
cat("Districts:", n_distinct(mita_data$district), "\n")
cat("Missing values in the variables used:",
    sum(is.na(mita_data[c("lhhequiv", "pothuan_mita", "elv_sh", "slope", "infants", "children",
                          "adults", "bfe4_1", "bfe4_2", "bfe4_3", "x", "y", "dpot", "d_bnd",
                          "district")])), "\n")


# Question 1: Why a Regression Discontinuity Design?
# -------------------------------------------------
# The design exploits the fact that conditions just inside and just outside the Mita border
# would likely have been very similar in the absence of the mining Mita. Any jump in
# outcomes at the border can then be attributed to the Mita.
#
# Question 2: The Running Variable
# -------------------------------------------------
# The running variable is a measure of location, either latitude/longitude or distance to
# the Mita. It is the continuous characteristic at which the policy cutoff applies. Income
# is the outcome, institutional quality is a mechanism, and the Mita dummy is the treatment.


# Spatial Polynomial Terms
# -------------------------------------------------
# Cubic polynomial in longitude and latitude: x, y, x^2, y^2, xy, x^3, y^3, x^2*y and x*y^2.
# Cubic polynomial in distance to Potosi: dpot, dpot^2 and dpot^3.
mita_data <- mita_data %>%
  mutate(
    x_2   = x^2,
    y_2   = y^2,
    x_y   = x * y,
    x_3   = x^3,
    y_3   = y^3,
    x_2_y = x^2 * y,
    y_2_x = y^2 * x,
    dpot_2 = dpot^2,
    dpot_3 = dpot^3
  )


# Clustered Standard Errors (Easy Clustered Standard Errors in R)
# -------------------------------------------------
# get_CL_vcov: cluster-robust variance matrix with the finite-sample correction.
# get_CL_df: degrees of freedom for the t-test, number of clusters minus one.
get_CL_vcov <- function(model, cluster) {
  M <- length(unique(cluster))
  N <- length(cluster)
  K <- model$rank
  dfc <- (M / (M - 1)) * ((N - 1) / (N - K))
  uj <- apply(estfun(model), 2, function(x) tapply(x, cluster, sum))
  vcovCL <- dfc * sandwich(model, meat = crossprod(uj) / N)
  return(vcovCL)
}

get_CL_df <- function(model, cluster) {
  M <- length(unique(cluster))
  df <- M - 1
  return(df)
}

# Runs the regression on households within `bandwidth` km of the boundary and clusters
# the standard errors by district. Returns the Mita row of the coefficient table.
run_mita_rdd <- function(formula, bandwidth) {
  sample_data <- mita_data %>% filter(d_bnd < bandwidth)
  fit <- lm(formula, data = sample_data)
  test <- coeftest(fit, vcov = get_CL_vcov(fit, sample_data$district),
                   df = get_CL_df(fit, sample_data$district))
  list(fit = fit, test = test, n = nobs(fit),
       clusters = n_distinct(sample_data$district),
       mita = test["pothuan_mita", ])
}

bandwidths <- c(100, 75, 50)


# Questions 3-8: Main Result, Cubic Polynomial in Longitude and Latitude
# -------------------------------------------------
# Regress the log equivalent household consumption (lhhequiv) on Mita, all polynomial
# terms, elevation, mean slope, household composition (infants, children, adults) and
# boundary segment fixed effects (bfe4_1, bfe4_2, bfe4_3).
xy_formula <- lhhequiv ~ pothuan_mita + x + y + x_2 + y_2 + x_y + x_3 + y_3 + x_2_y + y_2_x +
  elv_sh + slope + infants + children + adults + bfe4_1 + bfe4_2 + bfe4_3

xy_results <- map(bandwidths, ~ run_mita_rdd(xy_formula, .x)) %>% set_names(bandwidths)
for (bw in bandwidths) {
  cat("\n--- Longitude/latitude polynomial, d_bnd <", bw, "km (n =", xy_results[[as.character(bw)]]$n,
      ", clusters =", xy_results[[as.character(bw)]]$clusters, ") ---\n")
  print(xy_results[[as.character(bw)]]$test[c("(Intercept)", "pothuan_mita"), ])
}


# Questions 9-14: Alternative Control, Cubic Polynomial in Distance to Potosi
# -------------------------------------------------
# Same regressions, with a cubic in distance to Potosi (dpot) in place of the longitude
# and latitude polynomial.
dpot_formula <- lhhequiv ~ pothuan_mita + dpot + dpot_2 + dpot_3 +
  elv_sh + slope + infants + children + adults + bfe4_1 + bfe4_2 + bfe4_3

dpot_results <- map(bandwidths, ~ run_mita_rdd(dpot_formula, .x)) %>% set_names(bandwidths)
for (bw in bandwidths) {
  cat("\n--- Distance to Potosi polynomial, d_bnd <", bw, "km (n =", dpot_results[[as.character(bw)]]$n,
      ", clusters =", dpot_results[[as.character(bw)]]$clusters, ") ---\n")
  print(dpot_results[[as.character(bw)]]$test[c("(Intercept)", "pothuan_mita"), ])
}


# Results Table: Mita Coefficient
# -------------------------------------------------
# Estimate, clustered standard error, p-value (t distribution with clusters - 1 degrees of
# freedom) and significance at the 5% level, for each specification and bandwidth.
mita_table <- bind_rows(
  imap_dfr(xy_results, ~ tibble(control = "Longitude/latitude (Q3-Q8)", bandwidth_km = as.numeric(.y),
                                n = .x$n, estimate = .x$mita["Estimate"], se = .x$mita["Std. Error"],
                                p_value = .x$mita["Pr(>|t|)"])),
  imap_dfr(dpot_results, ~ tibble(control = "Distance to Potosi (Q9-Q14)", bandwidth_km = as.numeric(.y),
                                  n = .x$n, estimate = .x$mita["Estimate"], se = .x$mita["Std. Error"],
                                  p_value = .x$mita["Pr(>|t|)"]))
) %>%
  mutate(significant_5pct = ifelse(p_value < 0.05, "Yes", "No"))
print(mita_table, n = Inf)


# Question 15: Why Does Significance Differ Between the Two Sets?
# -------------------------------------------------
# The coefficients are similar, but the longitude/latitude regressions use nine location
# terms and the distance regressions use three. Distance to Potosi is a single measure
# that captures the residual variation in consumption that longitude and latitude only
# approximate, so the distance specification leaves less unexplained variance and gives
# smaller standard errors, and therefore a different significance.


# ==============================================================================
# Summary of Results
# ==============================================================================
cat("==============================================================================\n")
cat("SUMMARY: Effect of the Mita on log equivalent household consumption (lhhequiv)\n")
cat("==============================================================================\n")
for (i in seq_len(nrow(mita_table))) {
  cat(sprintf("%-28s d_bnd < %3d km: %7.3f (SE %.3f), p = %.4f, significant at 5%%: %s\n",
              mita_table$control[i], mita_table$bandwidth_km[i], mita_table$estimate[i],
              mita_table$se[i], mita_table$p_value[i], mita_table$significant_5pct[i]))
}
cat("==============================================================================\n")
