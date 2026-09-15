# Preliminaries
# -------------------------------------------------
rm(list = ls())
library(tidyverse)

# Load data and convert to a modern tibble
load("../data/AssassinationsData.rdata")
assassinations <- as_tibble(AssassinationsData)

# Question 2.a
# -------------------------------------------------
# Summary statistics for NPOLITY2 in specific years
summary_1900 <- assassinations %>% filter(year == 1900) %>% pull(npolity2dummy) %>% summary()
summary_2000 <- assassinations %>% filter(year == 2000) %>% pull(npolity2dummy) %>% summary()
summary_1945 <- assassinations %>% filter(year == 1945) %>% pull(absnpolity2dummy11) %>% summary()
summary_1980 <- assassinations %>% filter(year == 1980) %>% pull(absnpolity2dummy11) %>% summary()

print(summary_1900)
print(summary_2000)
print(summary_1945)
print(summary_1980)

# Question 2.b
# -------------------------------------------------
# Restrict sample to serious assassination attempts
serious_attempts <- assassinations %>% filter(seriousattempt == 1)

# OLS model of change in polity on successful assassination
model_simple <- lm(absnpolity2dummy11 ~ success, data = serious_attempts)
summary(model_simple)

# Question 2.d
# -------------------------------------------------
# 95% Confidence interval for the success coefficient
confint(model_simple, "success", level = 0.95)

# Question 2.e
# -------------------------------------------------
summary(model_simple)

# Question 3
# -------------------------------------------------
# OLS model with weapon fixed effects
model_fe <- lm(
  absnpolity2dummy11 ~ success + weapondum2 + weapondum3 + weapondum4 + weapondum5 + weapondum6, 
  data = serious_attempts
)
summary(model_fe)

# Question 3.c
# -------------------------------------------------
# 95% Confidence interval for the success coefficient with weapon controls
confint(model_fe, "success", level = 0.95)
