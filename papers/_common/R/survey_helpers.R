# Shared helpers for design-based analysis of IBGE household surveys.
# Every estimate goes through the `survey` package so that sampling weights,
# strata and primary sampling units enter point estimates and standard errors.

suppressPackageStartupMessages({
  library(survey)
  library(dplyr)
  library(tibble)
})

# IBGE designs can contain strata with a single PSU after subsetting; centre
# such strata at the grand mean instead of dropping them (Lumley 2010, ch. 3).
options(survey.lonely.psu = "adjust")

#' Tidy a svyglm fit into a tibble with design-based SEs and 95% CIs.
#' Degrees of freedom follow survey::degf (PSUs minus strata), which is the
#' correct reference distribution for design-based inference.
tidy_svyglm <- function(fit, level = 0.95) {
  s  <- summary(fit)$coefficients
  df <- survey::degf(fit$survey.design)
  tcrit <- stats::qt(1 - (1 - level) / 2, df)
  tibble::tibble(
    term      = rownames(s),
    estimate  = s[, "Estimate"],
    std.error = s[, "Std. Error"],
    statistic = s[, "t value"],
    p.value   = s[, "Pr(>|t|)"],
    conf.low  = s[, "Estimate"] - tcrit * s[, "Std. Error"],
    conf.high = s[, "Estimate"] + tcrit * s[, "Std. Error"],
    df        = df,
    nobs      = stats::nobs(fit)
  )
}

#' Pull one coefficient (and its CI) from a svyglm fit.
svy_coef <- function(fit, term, level = 0.95) {
  out <- tidy_svyglm(fit, level)
  out[out$term == term, ]
}

#' Design-based mean of `formula` on `design`, returned as a one-row tibble.
svy_mean_tbl <- function(design, formula, label = NULL) {
  m  <- survey::svymean(formula, design, na.rm = TRUE)
  tibble::tibble(
    label    = if (is.null(label)) deparse(formula[[2]]) else label,
    estimate = as.numeric(coef(m))[1],
    se       = as.numeric(survey::SE(m))[1]
  )
}

#' Hand-computed weighted mean, used in tests to confirm that svymean and the
#' weights agree.
wtd_mean_manual <- function(x, w) {
  ok <- !is.na(x) & !is.na(w)
  sum(x[ok] * w[ok]) / sum(w[ok])
}

#' Compare an estimate with an official published figure and stop if the
#' relative difference exceeds `tol`. Returns the comparison invisibly.
check_against_official <- function(estimate, official, label, tol = 0.01) {
  rel <- abs(estimate - official) / abs(official)
  msg <- sprintf("%-55s estimate %12.4f official %12.4f rel.diff %.4f",
                 label, estimate, official, rel)
  if (!is.finite(rel) || rel > tol) {
    stop("Official-aggregate check FAILED: ", msg, call. = FALSE)
  }
  message("OK   ", msg)
  invisible(tibble::tibble(label = label, estimate = estimate,
                           official = official, rel_diff = rel, tol = tol))
}

#' Tidy an lm fit with a supplied covariance matrix (e.g. sandwich::vcovHC or
#' vcovCL), in the same shape as tidy_svyglm so tables can mix both.
tidy_lm_vcov <- function(fit, V) {
  ct <- lmtest::coeftest(fit, vcov. = V)
  tibble::tibble(
    term      = rownames(ct),
    estimate  = ct[, 1],
    std.error = ct[, 2],
    statistic = ct[, 3],
    p.value   = ct[, 4],
    nobs      = stats::nobs(fit)
  )
}
