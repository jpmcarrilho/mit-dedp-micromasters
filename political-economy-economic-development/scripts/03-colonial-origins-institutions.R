# Preliminaries
# -------------------------------------------------
rm(list = ls())
library(tidyverse)
library(AER)

# Load data and convert to a modern tibble
load("../data/AJRData.rdata")
ajr_data <- as_tibble(AJRData) %>% 
  filter(baseco == 1)

# Question 1.a
# -------------------------------------------------
# OLS Regression of log GDP per capita on protection against expropriation risk
model_ols <- lm(logpgp95 ~ avexpr, data = ajr_data)
summary(model_ols)

# Interpreting the protection expropriation risk coefficient as percentage change
gdp_effect <- exp(coef(model_ols)["avexpr"]) - 1
print(gdp_effect)

# Question 1.c
# -------------------------------------------------
# Plot institutions and economic performance
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

# Question 2.a & 2.b
# -------------------------------------------------
# First stage: Regressing protection against expropriation on log settler mortality
model_first_stage <- lm(avexpr ~ logem4, data = ajr_data)
summary(model_first_stage)

# Plot first-stage relationship
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

# Question 3.a
# -------------------------------------------------
# Reduced form: Regressing log GDP per capita on log settler mortality
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

# Question 3.d
# -------------------------------------------------
# Indirect Wald estimator (Ratio of reduced form to first stage)
wald_estimator <- coef(model_reduced_form)["logem4"] / coef(model_first_stage)["logem4"]
print(wald_estimator)

# Question 4
# -------------------------------------------------
# Two-Stage Least Squares (2SLS) Instrumental Variables estimation
model_iv <- ivreg(logpgp95 ~ avexpr | logem4, data = ajr_data)
summary(model_iv)

# Percentage impact from 2SLS coefficient
iv_effect <- exp(coef(model_iv)["avexpr"]) - 1
print(iv_effect)
