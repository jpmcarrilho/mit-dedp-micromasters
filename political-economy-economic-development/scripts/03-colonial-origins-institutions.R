# ==============================================================================
# COURSE: Political Economy and Economic Development
# MODULE: Week 3 - Colonial Origins of Comparative Development
# TOPIC: Institutions, Geography, and Instrumental Variables Estimation
# ==============================================================================
# Overview:
# This script replicates and analyzes the core econometric results of the seminal 
# paper by Acemoglu, Johnson, and Robinson (2001, AER), "The Colonial Origins of 
# Comparative Development: An Empirical Investigation".
#
# Research Question: Do institutions (specifically property rights protection) 
#                    have a causal effect on modern economic performance (GDP)?
#
# Identification Strategy: Two-Stage Least Squares (2SLS) / Instrumental Variables (IV)
# - Endogenous Regressand (X): avexpr (Protection Against Expropriation)
# - Instrument (Z): logem4 (Log Settler Mortality in the 17th-19th centuries)
# - Outcome (Y): logpgp95 (Log GDP per Capita in 1995)
#
# Econometric Assumptions:
# 1. Relevance Condition (Cov(X, Z) != 0): Settler mortality determined 
#    historical colonization patterns (extractive vs. settlement colonies), which 
#    shaped early institutions, persisting to the modern day (First-Stage).
# 2. Exclusion Restriction (Cov(Z, epsilon) == 0): Historical settler mortality 
#    has no direct impact on modern economic output, other than its indirect legacy 
#    through modern institutional quality.
# ==============================================================================

# Preliminaries
# -------------------------------------------------
rm(list = ls())
library(tidyverse)
library(AER)

# Load data and convert to a modern tibble
load("../data/AJRData.rdata")
ajr_data <- as_tibble(AJRData) %>% 
  filter(baseco == 1)


# Question 1.a: Ordinary Least Squares (OLS) Baseline
# -------------------------------------------------
# Specification: Log_GDP_95_i = alpha + beta * Protection_Expropriation_i + epsilon_i
#
# INTERPRETATION WARNING:
# While OLS shows a strong positive correlation, beta is highly biased due to:
# - Reverse Causality: Richer nations can afford better property rights.
# - Omitted Variable Bias (OVB): Geographic, cultural, or religious factors 
#   correlate both with modern wealth and institutional structures.
model_ols <- lm(logpgp95 ~ avexpr, data = ajr_data)
summary(model_ols)

# Interpreting the OLS coefficient as percentage change:
# Since the dependent variable is log-transformed, a 1-unit increase in Protection
# increases modern national income by approximately (exp(beta) - 1) * 100%.
gdp_effect <- exp(coef(model_ols)["avexpr"]) - 1
print(gdp_effect)


# Question 1.c: Visualizing the Bivariate Association
# -------------------------------------------------
# We plot the classical upward sloping correlation between institutional quality 
# and modern prosperity, representing the biased OLS baseline.
p1 <- ggplot(ajr_data, aes(x = avexpr, y = logpgp95)) +
  geom_point(shape = 1, size = 2.5, color = "black") +
  geom_smooth(method = "lm", se = FALSE, color = "darkblue", linewidth = 1) +
  labs(
    x = "Average Protection Against Expropriation Risk",
    y = "Log GDP per Capita (1995)",
    title = "Institutions and Economic Performance (AJR 2001)"
  ) +
  theme_classic()

print(p1)
ggsave("gdp_institutions.png", plot = p1, width = 7, height = 5)


# Question 2.a & 2.b: The First-Stage Relationship (Instrument Relevance)
# -------------------------------------------------
# Specification: Protection_Expropriation_i = delta_0 + delta_1 * Log_Settler_Mortality_i + u_i
#
# RELEVANCE CRITERION:
# We test if Log Settler Mortality is a strong predictor of property rights protection.
# The coefficient (delta_1) must be highly significant (with an F-statistic > 10) 
# to ensure we do not have a weak instrument problem.
model_first_stage <- lm(avexpr ~ logem4, data = ajr_data)
summary(model_first_stage)

# Visualizing the first-stage (Settler mortality successfully predicts institution types)
p2 <- ggplot(ajr_data, aes(x = logem4, y = avexpr)) +
  geom_point(shape = 1, size = 2.5, color = "black") +
  geom_smooth(method = "lm", se = FALSE, color = "darkred", linewidth = 1) +
  labs(
    x = "Log Settler Mortality",
    y = "Average Protection Against Expropriation",
    title = "First-Stage Relationship: Colonial Origins of Institutions"
  ) +
  theme_classic()

print(p2)
ggsave("first_stage.png", plot = p2, width = 7, height = 5)


# Question 3.a: The Reduced-Form Relationship
# -------------------------------------------------
# Specification: Log_GDP_95_i = gamma_0 + gamma_1 * Log_Settler_Mortality_i + v_i
#
# INTUITION:
# This model explores the direct link between historical settler mortality and modern 
# wealth. It represents the "Intent-to-Treat" (ITT) effect of colonial structural type.
model_reduced_form <- lm(logpgp95 ~ logem4, data = ajr_data)
summary(model_reduced_form)

# Plot reduced-form relationship
p3 <- ggplot(ajr_data, aes(x = logem4, y = logpgp95)) +
  geom_point(shape = 1, size = 2.5, color = "black") +
  geom_smooth(method = "lm", se = FALSE, color = "darkgreen", linewidth = 1) +
  labs(
    x = "Log Settler Mortality",
    y = "Log GDP per Capita (1995)",
    title = "Reduced-Form Relationship: Colonial Origins and Economic Development"
  ) +
  theme_classic()

print(p3)
ggsave("reduced_form.png", plot = p3, width = 7, height = 5)


# Question 3.d: The Indirect Wald Estimator
# -------------------------------------------------
# MATHEMATICAL INTUITION:
# The instrumental variables treatment effect (beta_2SLS) can be derived directly as 
# the ratio of the Reduced Form effect to the First Stage effect:
# beta_2SLS = gamma_1 (Reduced Form) / delta_1 (First Stage)
wald_estimator <- coef(model_reduced_form)["logem4"] / coef(model_first_stage)["logem4"]
print(wald_estimator)


# Question 4: Two-Stage Least Squares (2SLS) IV Model
# -------------------------------------------------
# We run the unified 2SLS model: 
# First Stage: avexpr_hat = delta_0 + delta_1 * logem4 + u
# Second Stage: logpgp95 = alpha + beta_2SLS * avexpr_hat + epsilon
#
# INTERPRETATION:
# The 2SLS coefficient is larger than the baseline OLS. This demonstrates that OLS 
# is biased downwards (perhaps due to measurement error in institutions causing 
# attenuation bias), and confirms that institutional design has a powerful, 
# long-run causal effect on national wealth.
model_iv <- ivreg(logpgp95 ~ avexpr | logem4, data = ajr_data)
summary(model_iv)

# Percentage impact of institutions estimated via 2SLS
iv_effect <- exp(coef(model_iv)["avexpr"]) - 1
print(iv_effect)
