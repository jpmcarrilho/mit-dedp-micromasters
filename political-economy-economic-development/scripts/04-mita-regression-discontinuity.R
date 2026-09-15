# Preliminaries
# -------------------------------------------------
rm(list = ls())
library(tidyverse)
library(multiwayvcov)
library(lmtest)

# Load data and convert to a modern tibble
load("../data/mitaData.rdata")
mita_raw <- as_tibble(mitaData)

# Question 2.a
# -------------------------------------------------
# Construct coordinate polynomial features using tidyverse mutate
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

# Calculate means of polynomial terms
mean_x2   <- mean(mita_data$x_2)
mean_y3   <- mean(mita_data$y_3)
mean_y2_x <- mean(mita_data$y_2_x)

print(mean_x2)
print(mean_y3)
print(mean_y2_x)

# Question 2.b
# -------------------------------------------------
# Define regression formula with polynomial controls
base_formula <- as.formula(
  "lhhequiv ~ pothuan_mita + elv_sh + slope + infants + children + adults + 
   bfe4_1 + bfe4_2 + bfe4_3 + x + y + x_2 + y_2 + x_y + x_3 + y_3 + x_2_y + y_2_x"
)

# Subset data by distance boundaries (100, 75, 50 km)
mita_100 <- mita_data %>% filter(d_bnd < 100)
mita_75  <- mita_data %>% filter(d_bnd < 75)
mita_50  <- mita_data %>% filter(d_bnd < 50)

# Estimate cluster-robust models for each distance bandwidth
# Bandwidth 100 km
fit_100 <- lm(base_formula, data = mita_100)
vcov_100 <- cluster.vcov(fit_100, mita_100$district)
coeftest(fit_100, vcov_100)

# Bandwidth 75 km
fit_75 <- lm(base_formula, data = mita_75)
vcov_75 <- cluster.vcov(fit_75, mita_75$district)
coeftest(fit_75, vcov_75)

# Bandwidth 50 km
fit_50 <- lm(base_formula, data = mita_50)
vcov_50 <- cluster.vcov(fit_50, mita_50$district)
coeftest(fit_50, vcov_50)

# Question 2.c
# -------------------------------------------------
# Add distance-to-potable-water polynomials
mita_dpot <- mita_data %>%
  mutate(
    dpot_2 = dpot * dpot,
    dpot_3 = dpot * dpot * dpot
  )

dpot_formula <- as.formula(
  "lhhequiv ~ pothuan_mita + elv_sh + slope + infants + children + adults + 
   bfe4_1 + bfe4_2 + bfe4_3 + dpot + dpot_2 + dpot_3"
)

# Subset dpot data by distance boundaries
dpot_100 <- mita_dpot %>% filter(d_bnd < 100)
dpot_75  <- mita_dpot %>% filter(d_bnd < 75)
dpot_50  <- mita_dpot %>% filter(d_bnd < 50)

# Estimate models with dpot polynomial controls and district-level clustering
# Bandwidth 100 km
fit_dpot100 <- lm(dpot_formula, data = dpot_100)
vcov_dpot100 <- cluster.vcov(fit_dpot100, dpot_100$district)
coeftest(fit_dpot100, vcov_dpot100)

# Bandwidth 75 km
fit_dpot75 <- lm(dpot_formula, data = dpot_75)
vcov_dpot75 <- cluster.vcov(fit_dpot75, dpot_75$district)
coeftest(fit_dpot75, vcov_dpot75)

# Bandwidth 50 km
fit_dpot50 <- lm(dpot_formula, data = dpot_50)
vcov_dpot50 <- cluster.vcov(fit_dpot50, dpot_50$district)
coeftest(fit_dpot50, vcov_dpot50)
