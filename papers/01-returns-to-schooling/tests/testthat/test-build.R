# Unit tests for build_functions.R on a synthetic fixture shaped like the raw
# PNADcIBGE extract (character codes, numeric earnings, deflators).
suppressPackageStartupMessages({ library(testthat); library(survey) })

here::i_am("papers/01-returns-to-schooling/tests/testthat/test-build.R")  # repository root, independent of the working directory
paper_dir <- here::here("papers", "01-returns-to-schooling")
source(file.path(paper_dir, "R", "build_functions.R"))
source(here::here("papers", "_common", "R", "survey_helpers.R"))

make_fixture <- function(n = 200, seed = 1) {
  set.seed(seed)
  tibble::tibble(
    Ano = "2023", Trimestre = as.character(sample(1:4, n, TRUE)),
    UF = sprintf("%02d", sample(c(11, 23, 35, 41, 53), n, TRUE)),
    UPA = as.character(sample(1:20, n, TRUE)), Estrato = as.character(sample(1:5, n, TRUE)),
    V1031 = runif(n, 100, 300), V1032 = runif(n, 100, 400),
    posest = as.character(sample(1:3, n, TRUE)), V1030 = 1e5,
    V1022 = as.character(sample(1:2, n, TRUE)), V1023 = as.character(sample(1:4, n, TRUE)),
    V2007 = as.character(sample(1:2, n, TRUE)), V2009 = sample(10:80, n, TRUE),
    V2010 = as.character(sample(c(1, 2, 3, 4, 5, 9), n, TRUE, prob = c(.4, .1, .01, .4, .02, .07))),
    VD3004 = as.character(sample(1:7, n, TRUE)), VD3005 = sprintf("%02d", sample(0:16, n, TRUE)),
    VD4001 = as.character(sample(1:2, n, TRUE)), VD4002 = as.character(sample(c(1, 2, NA), n, TRUE)),
    VD4009 = sample(c(sprintf("%02d", 1:10), NA), n, TRUE), VD4012 = as.character(sample(c(1, 2, NA), n, TRUE)),
    VD4016 = sample(c(NA, 0, 500, 1300, 2600, 10000), n, TRUE), VD4017 = sample(c(NA, 500, 1300, 2600), n, TRUE),
    VD4019 = sample(c(NA, 500, 1300, 2600), n, TRUE), VD4020 = sample(c(NA, 500, 1300, 2600), n, TRUE),
    V4039 = sample(c(NA, 0, 20, 40, 44, 60, 130), n, TRUE), VD4031 = sample(c(NA, 20, 40), n, TRUE),
    CO1 = 1, CO1e = 1, CO2 = 1.094, CO2e = 1.097
  )
}

test_that("hourly wage divides monthly earnings by monthly hours", {
  expect_equal(hourly_wage(2600, 40), 2600 / (40 * 52 / 12))
  expect_equal(hourly_wage(2600, 40), 15, tolerance = 1e-6)
})

test_that("recode_persons types, labels and deflates as specified", {
  p <- recode_persons(make_fixture())
  expect_equal(nrow(p), 200)
  expect_type(p$schooling, "integer")
  expect_true(all(p$schooling[!is.na(p$schooling)] %in% 0:16))
  expect_equal(levels(p$region), REGION_LEVELS)
  expect_equal(as.character(p$region[p$uf == 23][1]), "Nordeste")
  expect_equal(as.character(p$region[p$uf == 35][1]), "Sudeste")
  expect_true(all(is.na(p$race[make_fixture()$V2010 == "9"])))
  expect_equal(p$female, make_fixture()$V2007 == "2")
  expect_equal(p$earn_main_hab, make_fixture()$VD4016 * 1.094)
  expect_equal(p$earn_main_eff, make_fixture()$VD4017 * 1.097)
  expect_false(any(p$occupied[is.na(make_fixture()$VD4002)]))
})

test_that("recode_persons stops when a raw variable is missing", {
  x <- make_fixture(); x$VD4016 <- NULL
  expect_error(recode_persons(x), "Missing raw variables: VD4016")
})

test_that("flag_sample applies the filters and reports monotone counts", {
  b <- flag_sample(recode_persons(make_fixture()))
  p <- b$persons; s <- p[p$in_sample, ]
  expect_true(all(s$age >= 25 & s$age <= 64))
  expect_true(all(s$occupied))
  expect_true(all(s$earn_main_hab > 0))
  expect_true(all(s$hours_main >= 1 & s$hours_main <= 120))
  expect_false(any(is.na(s$schooling)) || any(is.na(s$race)))
  expect_false(any(is.na(s$log_wage)))
  expect_true(all(is.na(p$log_wage[!p$has_wage])))
  expect_true(all(p$in_sample_young[p$in_sample]))
  expect_true(all(p$age[p$in_sample_young] >= 18))
  expect_true(all(diff(b$counts$n) <= 0))
  expect_true(all(diff(b$counts$n_weighted) <= 0))
  expect_equal(b$counts$n[1], 200)
  expect_equal(b$counts$n[6], sum(p$in_sample))
  expect_true(all(s$w > 0) && !any(is.na(s$w)))
  expect_equal(s$log_wage, log(s$earn_main_hab / (s$hours_main * 52 / 12)))
})

test_that("svymean on the design equals the hand-computed weighted mean", {
  p <- flag_sample(recode_persons(make_fixture()))$persons
  des <- svydesign(ids = ~upa, strata = ~estrato, weights = ~w, data = p, nest = TRUE)
  d25 <- subset(des, in_sample)
  expect_equal(as.numeric(coef(svymean(~schooling, d25))),
               wtd_mean_manual(p$schooling[p$in_sample], p$w[p$in_sample]), tolerance = 1e-10)
  expect_equal(as.numeric(coef(svymean(~log_wage, d25))),
               wtd_mean_manual(p$log_wage[p$in_sample], p$w[p$in_sample]), tolerance = 1e-10)
})
