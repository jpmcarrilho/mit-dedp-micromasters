# ==============================================================================
# COURSE: Political Economy and Economic Development
# MODULE: Week 4 - Historical Legacy of the Mining Mita
# TOPIC: Spatial Regression Discontinuity Design (RDD) and Coordinate Polynomials
# ==============================================================================
# Overview:
# This script replicates and analyzes the geographic Regression Discontinuity 
# Design (RDD) developed by Melissa Dell (2010, Econometrica), "The Persistent 
# Effects of Peru's Mining Mita".
#
# Research Question: Does a historical, extractive forced labor system (the mining 
#                    Mita, established in 1573) have a persistent causal effect 
#                    on modern household consumption?
#
# Identification Strategy: Spatial Regression Discontinuity (RDD)
# - Running Variable: Geodesic distance to the Mita boundary.
# - Cutoff: The boundary itself (dist = 0). Inside boundary = Treated (Mita).
#
# Econometric Challenges & Solutions:
# 1. Geographic Confounding: Altitude, terrain slope, and local climates vary 
#    across the Andes and correlate both with Mita placement and modern prosperity.
# 2. Solution: We restrict our sample to narrow geographic bands (100km, 75km, 50km)
#    from the boundary and control for multi-dimensional coordinate polynomials
#    (latitude, longitude, and elevation) to isolate the boundary cutoff effect 
#    from general geographic trends.
# 3. Standard Error Clustering: Since local shocks are highly spatially correlated, 
#    standard errors must be clustered at the district level ('district') to prevent 
#    inflated t-statistics.
# ==============================================================================

# Preliminaries
# -------------------------------------------------
rm(list = ls())
library(tidyverse)
library(multiwayvcov)
library(lmtest)

# Load data and convert to a modern tibble
load("../data/mitaData.rdata")
mita_raw <- as_tibble(mitaData)


# Question 2.a: Generating Spatial Polynomial Control Functions
# -------------------------------------------------
# To capture smooth, non-linear geographic trends, we construct high-dimensional
# polynomial terms of the coordinate system (longitude 'x' and latitude 'y').
# Specifically, we generate second and third-degree interaction terms:
# x^2, y^2, xy, x^3, y^3, x^2y, y^2x
mita_data <- mita_raw %>%
  mutate(
    x_2   = x * x,
    y_2   = y * y,
    x_y   = x * y,
    x_3   = x * x * x,
    y_3   = y * y * y,
    x_2_y = x * x * y,
    y_2_x = y * y * x
  )

# Calculate sample means of the newly constructed spatial polynomials
mean_x2   <- mean(mita_data$x_2)
mean_y3   <- mean(mita_data$y_3)
mean_y2_x <- mean(mita_data$y_2_x)

print(mean_x2)
print(mean_y3)
print(mean_y2_x)


# Question 2.b: Estimating Spatial RDD with Boundary Geographic Polynomials
# -------------------------------------------------
# We estimate the effect of Mita presence ('pothuan_mita') on log household 
# equivalent consumption ('lhhequiv').
#
# Controls:
# - Geography: elevation ('elv_sh'), slope ('slope'), coordinates ('x', 'y') 
#   and their interactions up to cubic terms.
# - Demographics: household demographic composition dummies ('infants', 'children', 'adults').
# - Boundary Segment Fixed Effects: dummies ('bfe4_1', 'bfe4_2', 'bfe4_3') to compare 
#   households strictly along the same local boundary segments.
#
# We run this RDD specification across three shrinking geographic bandwidths:
# 100km, 75km, and 50km from the boundary.
base_formula <- as.formula(
  "lhhequiv ~ pothuan_mita + elv_sh + slope + infants + children + adults + 
   bfe4_1 + bfe4_2 + bfe4_3 + x + y + x_2 + y_2 + x_y + x_3 + y_3 + x_2_y + y_2_x"
)

mita_100 <- mita_data %>% filter(d_bnd < 100)
mita_75  <- mita_data %>% filter(d_bnd < 75)
mita_50  <- mita_data %>% filter(d_bnd < 50)

# Specification A: Bandwidth 100 km
fit_100 <- lm(base_formula, data = mita_100)
vcov_100 <- cluster.vcov(fit_100, mita_100$district)
coeftest(fit_100, vcov_100)

# Specification B: Bandwidth 75 km
fit_75 <- lm(base_formula, data = mita_75)
vcov_75 <- cluster.vcov(fit_75, mita_75$district)
coeftest(fit_75, vcov_75)

# Specification C: Bandwidth 50 km (most conservative and localized boundary comparison)
fit_50 <- lm(base_formula, data = mita_50)
vcov_50 <- cluster.vcov(fit_50, mita_50$district)
coeftest(fit_50, vcov_50)


# Question 2.c: Alternative Specification - Distance to Market Control Function
# -------------------------------------------------
# ECONOMIC VALIDATION:
# Instead of modeling geographic trends with coordinate polynomials, we can model
# them using polynomials of distance-to-market ('dpot', 'dpot_2', 'dpot_3'). This
# controls directly for the unobserved cost of integration into modern markets, which 
# is a key driver of modern consumption.
mita_dpot <- mita_data %>%
  mutate(
    dpot_2 = dpot * dpot,
    dpot_3 = dpot * dpot * dpot
  )

dpot_formula <- as.formula(
  "lhhequiv ~ pothuan_mita + elv_sh + slope + infants + children + adults + 
   bfe4_1 + bfe4_2 + bfe4_3 + dpot + dpot_2 + dpot_3"
)

dpot_100 <- mita_dpot %>% filter(d_bnd < 100)
dpot_75  <- mita_dpot %>% filter(d_bnd < 75)
dpot_50  <- mita_dpot %>% filter(d_bnd < 50)

# Specification D: Bandwidth 100 km with Market Distance Polynomials
fit_dpot100 <- lm(dpot_formula, data = dpot_100)
vcov_dpot100 <- cluster.vcov(fit_dpot100, dpot_100$district)
coeftest(fit_dpot100, vcov_dpot100)

# Specification E: Bandwidth 75 km with Market Distance Polynomials
fit_dpot75 <- lm(dpot_formula, data = dpot_75)
vcov_dpot75 <- cluster.vcov(fit_dpot75, dpot_75$district)
coeftest(fit_dpot75, vcov_dpot75)

# Specification F: Bandwidth 50 km with Market Distance Polynomials
fit_dpot50 <- lm(dpot_formula, data = dpot_50)
vcov_dpot50 <- cluster.vcov(fit_dpot50, dpot_50$district)
coeftest(fit_dpot50, vcov_dpot50)
