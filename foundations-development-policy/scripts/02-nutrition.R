# ==============================================================================
# COURSE: Foundations of Development Policy
# MODULE: Week 2 - Health, Nutrition, and Deworming in Schools
# TOPIC: Miguel & Kremer (2004) RCT, Compliance, and LATE
# ==============================================================================
# Overview:
# This script replicates and analyzes the core statistics of the landmark randomized
# control trial (RCT) by Miguel and Kremer (2004, Econometrica), "Worms: Identifying 
# Impacts on Education and Health in the Presence of Treatment Externalities".
#
# Research Question: Does deworming treatment (pill) improve school attendance?
#
# Identification Strategy: Randomized Control Trial with Non-Compliance
# - Treatment Assignment (Z): 'treat_sch98' (Child's school assigned to deworming treatment in 1998)
# - Actual Treatment (D): 'pill98' (Whether the child actually received the deworming pill in 1998)
# - Outcome (Y): 'totpar98' (Total school attendance/participation rate in 1998)
#
# Key Econometric Concepts:
# 1. Intent-to-Treat (ITT): The causal effect of treatment *assignment* on attendance:
#    ITT = E[Y | Z = 1] - E[Y | Z = 0]. Since Z is randomized, ITT has a clean causal 
#    interpretation.
# 2. Compliance and Non-Compliance: Some pupils in treatment schools did not take 
#    the pill, and some in control schools might have accessed it elsewhere.
# 3. Local Average Treatment Effect (LATE): Estimating the causal effect of *actual 
#    treatment* on the subset of compliers. It is computed via the Wald Estimator:
#    LATE = ITT / (Pr[D = 1 | Z = 1] - Pr[D = 1 | Z = 0])
# ==============================================================================

# Preliminaries
# -------------------------------------------------
rm(list = ls())
library(tidyverse)

# Load data and convert to a modern tibble
# Adjusted path from local Downloads to portfolio-compliant relative path
data <- as_tibble(read.csv("../data/nutrition_csv.csv"))
summary(data)


# Question 1: Data Granularity Check
# -------------------------------------------------
# We evaluate the panel structure by checking the number of observation entries 
# for a single pupil (pupid = 1071714) in our sample.
data %>%
  filter(pupid == 1071714) %>%
  nrow()


# Question 2: Baseline Descriptive Statistics
# -------------------------------------------------
# We calculate percentages representing baseline demographic and treatment distribution.
pct_male <- mean(data$sex == 1, na.rm = TRUE) * 100
pct_pill <- mean(data$pill98 == 1, na.rm = TRUE) * 100
pct_treat_sch <- mean(data$treat_sch98 == 1, na.rm = TRUE) * 100

print(pct_male)
print(pct_pill)
print(pct_treat_sch)


# Question 3: Biased OLS - Actual Pill Take-Up and Attendance
# -------------------------------------------------
# We compare the average attendance rate (totpar98) between children who actually took
# the deworming pill (pill98 == 1) and those who did not (pill98 == 0).
#
# INTERPRETATION WARNING:
# This comparison is highly biased because actual pill take-up (D) is endogenous. 
# Motivated parents, healthier pupils, or those with better family resources are more 
# likely to take the pill. Therefore, the difference reflects selection bias rather 
# than a pure causal treatment effect.
took98 <- data %>%
  filter(pill98 == 1) %>%
  pull(totpar98) %>%
  mean(na.rm = TRUE)

not_took_98 <- data %>%
  filter(pill98 == 0) %>%
  pull(totpar98) %>%
  mean(na.rm = TRUE)

simple_diff <- took98 - not_took_98
print(simple_diff)


# Question 4: Intent-to-Treat (ITT) Effect
# -------------------------------------------------
# We compare the average attendance rate between children whose schools were randomly 
# assigned to treatment (treat_sch98 == 1) and those in control schools (treat_sch98 == 0).
#
# ECONOMIC INTUITION:
# Because treatment *assignment* (Z) is fully randomized, there is no selection bias. 
# This difference is the Intent-to-Treat (ITT) effect, capturing the real-world 
# impact of offering a deworming program on school attendance.
att_treat98 <- data %>%
  filter(treat_sch98 == 1) %>%
  pull(totpar98) %>%
  mean(na.rm = TRUE)

att_not_treat_98 <- data %>%
  filter(treat_sch98 == 0) %>%
  pull(totpar98) %>%
  mean(na.rm = TRUE)

itt_effect <- att_treat98 - att_not_treat_98
print(itt_effect)


# Question 5: Compliance and Selection Mechanics
# -------------------------------------------------
# To compute the Local Average Treatment Effect (LATE), we must first evaluate the 
# compliance rates in our treatment and control schools.

# i. Pr(Took Pill | Assigned to Treatment School)
p_take_given_treatschool <- (data %>% filter(pill98 == 1, treat_sch98 == 1) %>% nrow()) /
  (data %>% filter(treat_sch98 == 1, !is.na(pill98)) %>% nrow())

# ii. Pr(Took Pill | Assigned to Control School)
p_take_given_nottreatschool <- (data %>% filter(pill98 == 1, treat_sch98 == 0) %>% nrow()) /
  (data %>% filter(treat_sch98 == 0, !is.na(pill98)) %>% nrow())

print(p_take_given_treatschool)
print(p_take_given_nottreatschool)


# Question 6: Local Average Treatment Effect (LATE) via Wald Estimator
# -------------------------------------------------
# The Wald Estimator scales the ITT effect by the difference in compliance rates:
# LATE = ITT / (Compliance_T - Compliance_C)
# This provides the true causal effect of actually taking the deworming pill for 
# "compliers" (the children who take the pill because they are assigned to a 
# treatment school, but wouldn't otherwise).
compliance_diff <- p_take_given_treatschool - p_take_given_nottreatschool
late_effect <- itt_effect / compliance_diff
print(late_effect)
