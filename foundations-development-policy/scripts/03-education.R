# ==============================================================================
# COURSE: Foundations of Development Policy
# MODULE: Week 3 - Education, School Construction, and Returns to Schooling
# TOPIC: Difference-in-Differences (DiD) and Instrumental Variables (2SLS)
# ==============================================================================
# Overview:
# This script replicates and analyzes the seminal paper by Esther Duflo (2001, AER),
# "Schooling and Labor Market Consequences of School Construction in Indonesia:
# Evidence from an Unusual Policy Experiment".
#
# Research Question: What are the economic returns to education in a developing country?
#
# Identification Strategy: Difference-in-Differences (DiD) & Instrumental Variables (IV)
# - Policy Intervention: INPRES program (1973-1979), building over 61,000 primary schools.
# - Cohort Exposure (First Difference): Children born in 1968 or later (aged <= 5 in 1974)
#   were young enough to attend newly built schools, while older cohorts were not.
# - Regional Intensity (Second Difference): High-intensity vs. low-intensity school
#   construction districts based on baseline regional school enrollment rates.
#
# Econometric Synthesis:
# 1. 2x2 Difference-in-Differences (DiD): Isolates the causal effect of school construction
#    on both education attainment and modern adult wages.
# 2. Wald Estimator: Computes returns to schooling as the ratio of the Reduced Form (Wages)
#    to the First Stage (Years of Education).
# 3. Two-Stage Least Squares (2SLS): Estimates the returns to education controlling for 
#    district and birth year fixed effects, using school construction intensity as an IV.
# ==============================================================================

# Preliminaries
# -------------------------------------------------
rm(list = ls())
library(tidyverse)
library(AER)

# Load data and convert to a modern tibble
data <- as_tibble(read.csv("../data/inpres_data_corrected.csv"))


# Question 1: Constructing Cohort Exposure Indicator
# -------------------------------------------------
# We create a dummy variable 'young' indicating whether the individual was born
# in 1968 or later (2-digit year >= 68), making them eligible for the newly constructed schools.
data <- data %>%
  mutate(young = if_else(birth_year >= 68, 1, 0))


# Question 2: First-Stage 2x2 DiD Table (Education Attainment)
# -------------------------------------------------
# We compute average years of schooling across age cohorts and program intensity districts.
means_educ <- data %>%
  group_by(young, high_intensity) %>%
  summarise(mean_educ = mean(education, na.rm = TRUE), .groups = "drop")

# Extract individual cell means
A <- means_educ %>% filter(young == 1, high_intensity == 1) %>% pull(mean_educ)
B <- means_educ %>% filter(young == 1, high_intensity == 0) %>% pull(mean_educ)
C <- A - B

D <- means_educ %>% filter(young == 0, high_intensity == 1) %>% pull(mean_educ)
E <- means_educ %>% filter(young == 0, high_intensity == 0) %>% pull(mean_educ)
F_val <- D - E

G <- A - D
H <- B - E
I <- C - F_val  # First Stage DiD estimate for years of education

# Display 3x3 DiD matrix for education
did_table_educ <- tibble(
  Group = c("Young (Born 1968 or later)", "Old (Born before 1968)", "Difference (Young - Old)"),
  `High Intensity (Treatment)` = round(c(A, D, G), 2),
  `Low Intensity (Control)` = round(c(B, E, H), 2),
  `Difference (Treatment - Control)` = round(c(C, F_val, I), 2)
)

print(did_table_educ)


# Question 3: Reduced-Form 2x2 DiD Table (Log Wages)
# -------------------------------------------------
# We evaluate the reduced-form policy impact on adult log earnings ('log_wage').
means_wage <- data %>%
  group_by(young, high_intensity) %>%
  summarise(mean_log_wage = mean(log_wage, na.rm = TRUE), .groups = "drop")

A_2 <- means_wage %>% filter(young == 1, high_intensity == 1) %>% pull(mean_log_wage)
B_2 <- means_wage %>% filter(young == 1, high_intensity == 0) %>% pull(mean_log_wage)
C_2 <- A_2 - B_2

D_2 <- means_wage %>% filter(young == 0, high_intensity == 1) %>% pull(mean_log_wage)
E_2 <- means_wage %>% filter(young == 0, high_intensity == 0) %>% pull(mean_log_wage)
F_2 <- D_2 - E_2

G_2 <- A_2 - D_2
H_2 <- B_2 - E_2
I_2 <- C_2 - F_2  # Reduced Form DiD estimate for log wages

# Display 3x3 DiD matrix for log wages
did_table_earnings <- tibble(
  Group = c("Young (Born 1968 or later)", "Old (Born before 1968)", "Difference (Young - Old)"),
  `High Intensity (Treatment)` = round(c(A_2, D_2, G_2), 3),
  `Low Intensity (Control)` = round(c(B_2, E_2, H_2), 3),
  `Difference (Treatment - Control)` = round(c(C_2, F_2, I_2), 3)
)

print(did_table_earnings)


# Question 4: Indirect Wald Estimator (Economic Returns to Education)
# -------------------------------------------------
# Specification: Returns to Education = Reduced Form DiD / First Stage DiD
first_stage <- lm(education ~ young * high_intensity, data = data)
gamma_FS <- coef(first_stage)["young:high_intensity"]

reduced_form <- lm(log_wage ~ young * high_intensity, data = data)
gamma_RF <- coef(reduced_form)["young:high_intensity"]

wald_estimate <- gamma_RF / gamma_FS

cat(sprintf("First Stage DD Estimate (Education): %.4f\n", gamma_FS))
cat(sprintf("Reduced Form DD Estimate (Log Wage): %.4f\n", gamma_RF))
cat(sprintf("Wald Estimate (Returns to Education): %.3f\n", round(wald_estimate, 3)))


# Question 5: Simple 2SLS IV Regression
# -------------------------------------------------
# Instrumenting education using the interaction term 'young:high_intensity'
iv_model <- ivreg(
  log_wage ~ high_intensity + young + education | 
    high_intensity + young + high_intensity:young, 
  data = data
)

model_summary <- summary(iv_model)
print(model_summary)

coef_delta1 <- coef(model_summary)["education", "Estimate"]
se_delta1   <- coef(model_summary)["education", "Std. Error"]

cat(sprintf("2SLS Returns to Schooling: %.3f (SE: %.3f)\n", round(coef_delta1, 3), round(se_delta1, 3)))


# Question 6: High-Dimensional Continuous IV with District and Cohort Fixed Effects
# -------------------------------------------------
# In her full empirical specification, Duflo controls for:
# - Birth Year Fixed Effects ('birth_year_factor')
# - Birth District Fixed Effects ('birth_region_factor')
# - Baseline Enrollment interaction controls ('young_ch71')
# Using the continuous intensity instrument: num_schools * young
factored_dataset <- data %>%
  mutate(
    birth_year_factor   = factor(birth_year),
    birth_region_factor = factor(birth_region),
    young_ch71          = young * children71,
    inst_schools        = num_schools * young
  )

iv_continuous <- ivreg(
  log_wage ~ education + birth_year_factor + birth_region_factor + young_ch71 |
    inst_schools + birth_year_factor + birth_region_factor + young_ch71,
  data = factored_dataset
)

model_summary_cont <- summary(iv_continuous)

beta_education <- coef(model_summary_cont)["education", "Estimate"]
se_education   <- coef(model_summary_cont)["education", "Std. Error"]

cat(sprintf("\nFull Specification IV Estimate of Returns to Schooling: %.3f (SE: %.3f)\n", 
            round(beta_education, 3), round(se_education, 3)))
