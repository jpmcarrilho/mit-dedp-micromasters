# build_functions.R — pure functions used by 01_build.R and unit-tested in
# tests/testthat/test-build.R. No file input or output here.

suppressPackageStartupMessages(library(dplyr))

# Raw columns that every cached year must contain (PNADcIBGE, labels = FALSE).
EXPECTED_VARS <- c(
  "Ano", "Trimestre", "UF", "UPA", "Estrato", "V1031", "V1032", "posest", "V1030",
  "V1022", "V1023", "V2007", "V2009", "V2010", "VD3004", "VD3005",
  "VD4001", "VD4002", "VD4009", "VD4012", "VD4016", "VD4017", "VD4019", "VD4020",
  "V4039", "VD4031", "CO1", "CO1e", "CO2", "CO2e"
)

# Weeks per month used to turn weekly hours into monthly hours.
HOURS_PER_MONTH <- 52 / 12

REGION_LEVELS <- c("Norte", "Nordeste", "Sudeste", "Sul", "Centro-Oeste")
RACE_LEVELS   <- c("White/Asian", "Black/Brown", "Indigenous")
EDU_LEVELS    <- c("No schooling", "Fundamental incomplete", "Fundamental complete",
                   "Medio incomplete", "Medio complete", "Superior incomplete",
                   "Superior complete")

#' Macro-region from the two-digit state code (first digit is the region).
uf_region <- function(uf) {
  first <- as.integer(substr(as.character(uf), 1, 1))
  factor(REGION_LEVELS[first], levels = REGION_LEVELS)
}

#' Hourly wage from monthly earnings and weekly hours.
hourly_wage <- function(monthly, weekly_hours) {
  monthly / (weekly_hours * HOURS_PER_MONTH)
}

#' Type and label the raw columns of one PNADcIBGE year (all persons).
#' Earnings are converted to the deflator's reference-year prices with the
#' reference-year deflators: CO2 for habitual and CO2e for effective earnings.
recode_persons <- function(x) {
  missing <- setdiff(EXPECTED_VARS, names(x))
  if (length(missing)) stop("Missing raw variables: ", paste(missing, collapse = ", "))
  x %>%
    transmute(
      year       = as.integer(Ano),
      quarter    = as.integer(Trimestre),
      uf         = as.integer(UF),
      region     = uf_region(UF),
      upa        = as.character(UPA),
      estrato    = as.character(Estrato),
      w_prior    = as.numeric(V1031),
      w          = as.numeric(V1032),
      posest     = as.character(posest),
      posest_pop = as.numeric(V1030),
      urban      = V1022 == "1",
      area       = factor(V1023, levels = c("1", "2", "3", "4"),
                          labels = c("Capital", "Metro region", "RIDE", "Other")),
      female     = V2007 == "2",
      age        = as.integer(V2009),
      race       = factor(case_when(V2010 %in% c("1", "3") ~ RACE_LEVELS[1],
                                    V2010 %in% c("2", "4") ~ RACE_LEVELS[2],
                                    V2010 == "5"           ~ RACE_LEVELS[3],
                                    TRUE                   ~ NA_character_),
                          levels = RACE_LEVELS),
      edu_level  = factor(VD3004, levels = as.character(1:7), labels = EDU_LEVELS),
      schooling  = as.integer(VD3005),
      in_lf      = !is.na(VD4001) & VD4001 == "1",
      occupied   = !is.na(VD4002) & VD4002 == "1",
      position   = as.character(VD4009),
      wage_employee = !is.na(VD4009) & VD4009 %in% c("01", "02", "03", "04", "05", "06", "07"),
      # formal: signed-card or statutory employees, or self-employed/employers
      # who contribute to social security (CNPJ status is not in the extract)
      formal     = (!is.na(VD4009) & VD4009 %in% c("01", "03", "05", "07")) |
                   (!is.na(VD4009) & VD4009 %in% c("08", "09") & !is.na(VD4012) & VD4012 == "1"),
      earn_main_hab = as.numeric(VD4016) * as.numeric(CO2),
      earn_main_eff = as.numeric(VD4017) * as.numeric(CO2e),
      earn_all_hab  = as.numeric(VD4019) * as.numeric(CO2),
      earn_all_eff  = as.numeric(VD4020) * as.numeric(CO2e),
      hours_main = as.numeric(V4039),
      hours_all  = as.numeric(VD4031),
      defl_hab   = as.numeric(CO2),
      defl_eff   = as.numeric(CO2e)
    )
}

#' Flag the analysis sample on a recoded person table and return the
#' sequential filter counts. `has_wage` marks every occupied person with
#' positive habitual earnings, 1-120 weekly hours in the main job and reported
#' schooling and race; the main sample restricts it to ages `age_min`-`age_max`
#' and `in_sample_young` to ages 18-`age_max` (robustness).
flag_sample <- function(p, age_min = 25L, age_max = 64L) {
  valid <- p$occupied & !is.na(p$earn_main_hab) & p$earn_main_hab > 0 &
    !is.na(p$hours_main) & p$hours_main >= 1 & p$hours_main <= 120 &
    !is.na(p$schooling) & !is.na(p$race)
  p$has_wage        <- valid
  p$in_sample       <- valid & p$age >= age_min & p$age <= age_max
  p$in_sample_young <- valid & p$age >= 18L & p$age <= age_max
  p$log_wage     <- ifelse(valid, log(hourly_wage(p$earn_main_hab, p$hours_main)), NA_real_)
  p$log_wage_eff <- ifelse(valid & !is.na(p$earn_main_eff) & p$earn_main_eff > 0,
                           log(hourly_wage(p$earn_main_eff, p$hours_main)), NA_real_)
  p$exper <- pmax(p$age - p$schooling - 6L, 0L)
  step1 <- p$age >= age_min & p$age <= age_max
  step2 <- step1 & p$occupied
  step3 <- step2 & !is.na(p$earn_main_hab) & p$earn_main_hab > 0
  step4 <- step3 & !is.na(p$hours_main) & p$hours_main >= 1 & p$hours_main <= 120
  step5 <- step4 & !is.na(p$schooling) & !is.na(p$race)
  stopifnot(identical(step5, p$in_sample))
  counts <- tibble::tibble(
    step = c("All persons", sprintf("Aged %d-%d", age_min, age_max), "Occupied",
             "Positive habitual earnings, main job", "Hours 1-120 per week, main job",
             "Schooling and race reported (analysis sample)"),
    n = c(nrow(p), sum(step1), sum(step2), sum(step3), sum(step4), sum(step5)),
    n_weighted = c(sum(p$w), sum(p$w[step1]), sum(p$w[step2]), sum(p$w[step3]),
                   sum(p$w[step4]), sum(p$w[step5]))
  )
  list(persons = p, counts = counts)
}
