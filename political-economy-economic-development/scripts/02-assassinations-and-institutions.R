# ==============================================================================
# COURSE: Political Economy and Economic Development
# MODULE: Week 2 - Leaders, Assassinations, and Institutional Transitions
# TOPIC: Causal Inference and Natural Experiments in History
# ==============================================================================
# Overview:
# This script replicates and explores the empirical framework of Jones and Olken
# (2009), "Hit or Miss? The Effect of Assassinations on Institutions and War".
#
# Identification Strategy: Natural Experiment (Localized RCT)
# - Treatment Group: Successful leader assassinations.
# - Control Group: Failed leader assassination attempts.
#
# Intuition:
# While assassination attempts are highly endogenous (they occur in countries with
# existing political instability, civil unrest, or economic decline), whether the
# bullet actually "hits" or "misses" (conditional on an attempt being made) behaves
# like a localized random trial. By restricting our sample strictly to "serious" 
# attempts, we can isolate the true causal effect of individual leaders on national 
# institutional change (measured by the Polity IV index).
# ==============================================================================

# Preliminaries
# -------------------------------------------------
rm(list = ls())
library(tidyverse)

# Load data and convert to a modern tibble
load("../data/AssassinationsData.rdata")
assassinations <- as_tibble(AssassinationsData)


# Question 2.a: Descriptive Cohort Analysis
# -------------------------------------------------
# Analyzing institutional environments (Polity IV score) across different historical cohorts.
# The variable 'npolity2dummy' is a dummy indicator for democratic regimes (Polity score > 0).
# The variable 'absnpolity2dummy11' captures absolute changes in the polity index.

# i. Democratic prevalence in the global sample in year 1900
summary_1900 <- assassinations %>% filter(year == 1900) %>% pull(npolity2dummy) %>% summary()

# ii. Democratic prevalence in the global sample in year 2000 (reflecting the third wave of democracy)
summary_2000 <- assassinations %>% filter(year == 2000) %>% pull(npolity2dummy) %>% summary()

# iii. Absolute polity score shifts following World War II (1945)
summary_1945 <- assassinations %>% filter(year == 1945) %>% pull(absnpolity2dummy11) %>% summary()

# iv. Absolute polity score shifts during the height of the Cold War (1980)
summary_1980 <- assassinations %>% filter(year == 1980) %>% pull(absnpolity2dummy11) %>% summary()

print(summary_1900)
print(summary_2000)
print(summary_1945)
print(summary_1980)


# Question 2.b: The Natural Experiment - Simple Bivariate OLS
# -------------------------------------------------
# We restrict our sample to serious attempts ('seriousattempt == 1') to satisfy
# the conditional independence assumption. 
# Specification: Delta_Polity_i = alpha + beta * Success_i + epsilon_i
#
# Under the "Hit or Miss" assumption, E[epsilon_i | Success_i, Attempt_i = 1] = 0.
# Therefore, beta captures the causal impact of leader transition on institutional change.
serious_attempts <- assassinations %>% filter(seriousattempt == 1)

model_simple <- lm(absnpolity2dummy11 ~ success, data = serious_attempts)
summary(model_simple)


# Question 2.d: Statistical Significance & Confidence Bounds
# -------------------------------------------------
# Computing the 95% confidence interval for our treatment effect (beta).
# If the interval does not cross zero, we reject the null hypothesis of no leader effect.
confint(model_simple, "success", level = 0.95)


# Question 2.e: Model Robustness and Regression Summary
# -------------------------------------------------
# Full review of residuals, standard errors, and R-squared. 
# Note that while beta is highly significant (confirming that individual leaders 
# do play a causal role in shaping history), the R-squared is quite low. This indicates
# that institutional change is highly complex, and most of its variance is driven 
# by factors other than leader transitions.
summary(model_simple)


# Question 3: Controlling for Weapon Fixed Effects
# -------------------------------------------------
# REVIEW OF POTENTIAL BIASES:
# Although conditional on an attempt, success is largely random, different weapon 
# types (e.g., handguns vs. explosive devices) have different baseline lethality rates
# and might be selected in different political contexts. To control for this potential 
# confound, we introduce weapon-type fixed effects (dummies 'weapondum2' through 'weapondum6').
#
# Specification: Delta_Polity_i = alpha + beta * Success_i + theta_w * Weapon_w_i + epsilon_i
model_fe <- lm(
  absnpolity2dummy11 ~ success + weapondum2 + weapondum3 + weapondum4 + weapondum5 + weapondum6, 
  data = serious_attempts
)
summary(model_fe)


# Question 3.c: Causal Treatment Effect under Fixed Effects Control
# -------------------------------------------------
# Computing the 95% confidence interval for beta after parsing out weapon-specific lethality.
# If beta remains statistically significant, our causal interpretation is highly robust.
confint(model_fe, "success", level = 0.95)
