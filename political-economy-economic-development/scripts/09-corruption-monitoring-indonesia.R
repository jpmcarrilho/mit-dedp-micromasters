# ==============================================================================
# COURSE: Political Economy and Economic Development
# MODULE: Week 9 - Monitoring Corruption in Infrastructure Projects
# TOPIC: Randomized Controlled Trials (RCTs) and Clustered Standard Errors
# ==============================================================================
# Overview:
# This script replicates and analyzes the seminal randomized field experiment
# of Benjamin Olken (2007, JPE), "Monitoring Corruption: Evidence from a 
# Field Experiment in Indonesia".
#
# Research Question: Which is more effective in curbing public corruption (leakage 
#                    in village road construction projects): top-down centralized 
#                    state audits, or bottom-up grassroot community-led participation?
#
# Treatment Specifications:
# 1. 'audit': Centralized audits treatment (increasing audit probability from 4% to 100%).
# 2. 'und': Invitations treatment (bottom-up community involvement - sending invitations 
#    to village meetings to increase grassroot attendance).
# 3. 'fpm': Feedback form treatment (anonymous feedback forms distributed to the community).
#
# Econometric Challenges & Solutions:
# - Stratification: The randomization was stratified across subdistricts ('auditstratnum').
#   To obtain consistent estimators, we must control for these stratification block 
#   fixed effects.
# - Spatial Shock Correlation & Clustered Standard Errors: Since multiple villages
#   lie within the same subdistrict ('kecid'), they share geographic, logistical, and 
#   subdistrict-level political shocks. OLS standard errors will be biased downwards 
#   due to within-cluster correlation. We cluster our standard errors at the 
#   subdistrict ('kecid') level to ensure valid Wald-type tests and avoid false positives.
# ==============================================================================

# Preliminaries
# -------------------------------------------------
rm(list = ls())
library(tidyverse)
library(lmtest)
library(sandwich)
library(multiwayvcov)

# Load data and convert to a modern tibble
load("../data/jperoaddata.rdata")
corruption_data <- as_tibble(jperoaddata)


# Question 2.a: Basic OLS model with Heteroskedasticity-Robust Standard Errors
# -------------------------------------------------
# Outcome: lndiffeall4mainancil (Log of difference between official and actual road expenditures)
# Specification: Corruption_i = alpha + beta_1 * Audit_i + beta_2 * Invitations_i + beta_3 * Feedback_i + epsilon_i
#
# Standard Error Treatment: Heteroskedasticity-Robust (HC1) Standard Errors
# This controls for arbitrary heteroskedasticity but assumes independent observations.
model_expenditures <- lm(lndiffeall4mainancil ~ audit + und + fpm, data = corruption_data)
coeftest(model_expenditures, vcov = vcovHC(model_expenditures, type = "HC1"))


# Question 2.b: Controlling for Spatial Clustering (Subdistrict Level)
# -------------------------------------------------
# We cluster our standard errors at the subdistrict ('kecid') level.
#
# INTUITION:
# Since corruption opportunities and subdistrict engineers are shared across villages
# in the same subdistrict, standard errors increase significantly when clustering, 
# reflecting the reduced effective sample size of our clusters.
coeftest(model_expenditures, cluster.vcov(model_expenditures, corruption_data$kecid))


# Question 2.c: Incorporating Stratification Fixed Effects
# -------------------------------------------------
# Specification: Corruption_ic = alpha + beta * Treatment_ic + theta_s * Stratification_s_ic + epsilon_ic
#
# METHODOLOGY:
# Since randomization was stratified by audit strata ('auditstratnum'), we must include
# stratification fixed effects (dummies) to isolate our treatment effects within 
# each randomization block, while continuing to cluster at the subdistrict level.
model_expenditures_fe <- lm(
  lndiffeall4mainancil ~ audit + und + fpm + factor(auditstratnum), 
  data = corruption_data
)
coeftest(model_expenditures_fe, cluster.vcov(model_expenditures_fe, corruption_data$kecid))


# Question 2.d: Alternative Outcome - Materials Price Inflation
# -------------------------------------------------
# Outcome: lndiffpall4 (Log difference between price paid and market price for materials)
# We test if the treatments successfully curb price inflation in project procurement.
# Standard Error: Heteroskedasticity-Robust (HC1) unclustered.
model_prices <- lm(lndiffpall4 ~ audit + und + fpm, data = corruption_data)
coeftest(model_prices, vcov = vcovHC(model_prices, type = "HC1"))


# Question 2.e: Materials Price Inflation with Subdistrict-Clustered SEs
# -------------------------------------------------
# Clustering standard errors at the subdistrict level to ensure valid inference 
# in the presence of localized procurement shocks.
coeftest(model_prices, cluster.vcov(model_prices, corruption_data$kecid))


# Question 2.f: Materials Price Inflation with Stratification Fixed Effects & Clustered SEs
# -------------------------------------------------
# Controlling for randomization strata dummies while clustering standard errors at 
# the subdistrict level.
model_prices_fe <- lm(
  lndiffpall4 ~ audit + und + fpm + factor(auditstratnum), 
  data = corruption_data
)
coeftest(model_prices_fe, cluster.vcov(model_prices_fe, corruption_data$kecid))
