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

# Question 2.a
# -------------------------------------------------
# Estimate treatment effects on road project missing expenditures (unclustered, robust SEs)
model_expenditures <- lm(lndiffeall4mainancil ~ audit + und + fpm, data = corruption_data)

# Run coeftest with heteroskedasticity-robust standard errors (HC1)
coeftest(model_expenditures, vcov = vcovHC(model_expenditures, type = "HC1"))

# Question 2.b
# -------------------------------------------------
# Estimate treatment effects with standard errors clustered at the subdistrict (kecid) level
coeftest(model_expenditures, cluster.vcov(model_expenditures, corruption_data$kecid))

# Question 2.c
# -------------------------------------------------
# Add audit stratification block fixed effects (auditstratnum) to model 1, with subdistrict clustering
model_expenditures_fe <- lm(
  lndiffeall4mainancil ~ audit + und + fpm + factor(auditstratnum), 
  data = corruption_data
)
coeftest(model_expenditures_fe, cluster.vcov(model_expenditures_fe, corruption_data$kecid))

# Question 2.d
# -------------------------------------------------
# Estimate treatment effects on road project missing materials prices (unclustered, robust SEs)
model_prices <- lm(lndiffpall4 ~ audit + und + fpm, data = corruption_data)

# Run coeftest with heteroskedasticity-robust standard errors (HC1)
coeftest(model_prices, vcov = vcovHC(model_prices, type = "HC1"))

# Question 2.e
# -------------------------------------------------
# Estimate treatment effects on missing materials prices with standard errors clustered by subdistrict (kecid)
coeftest(model_prices, cluster.vcov(model_prices, corruption_data$kecid))

# Question 2.f
# -------------------------------------------------
# Add audit stratification block fixed effects (auditstratnum) to the prices model, with subdistrict clustering
model_prices_fe <- lm(
  lndiffpall4 ~ audit + und + fpm + factor(auditstratnum), 
  data = corruption_data
)
coeftest(model_prices_fe, cluster.vcov(model_prices_fe, corruption_data$kecid))
