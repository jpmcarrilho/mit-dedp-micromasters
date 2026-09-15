# ==============================================================================
# COURSE: Political Economy and Economic Development
# MODULE: Week 7 - Campaign Donations and Fixed Effects
# TOPIC: Panel Data Econometrics and Unobserved Heterogeneity
# ==============================================================================
# Overview:
# This script explores panel data econometrics and compares Pooled Ordinary Least 
# Squares (OLS) with Fixed Effects (FE) models.
#
# Research Question: Do campaign donations (X) affect election vote shares (Y)?
#
# Econometric Challenge: Omitted Variable Bias (OVB)
# Counties differ significantly in their unobserved, time-invariant characteristics
# (e.g., local political ideology, voter engagement, historical partisan leanings,
# or demographic density). If these unobserved factors correlate BOTH with the volume
# of campaign donations raised and the voting outcomes, a simple pooled OLS model 
# will produce a biased and inconsistent estimate of our treatment effect (beta).
#
# Solutions:
# 1. Least Squares Dummy Variable (LSDV) Model: Introducing explicit dummy variables
#    for each county (factor(county)) to parse out county-level fixed effects.
# 2. Within-Demeaning Estimator: Natively demeaning both the independent and 
#    dependent variables within each county grouping before running OLS. This
#    natively sweeps out time-invariant unobservables, delivering identical estimates
#    to LSDV without the degrees-of-freedom bloat of thousands of dummy variables.
# ==============================================================================

# Preliminaries
# -------------------------------------------------
rm(list = ls())
library(tidyverse)

# Load data and convert to a modern tibble
load("../data/votingData.rdata")
voting_data <- as_tibble(votingData)


# Question 1.a: The Pooled OLS Model (Biased Baseline)
# -------------------------------------------------
# Specification: votePercent_i = alpha + beta_pooled * campaignDonation_i + epsilon_i
#
# INTERPRETATION WARNING:
# Here, we treat all observations as independent, ignoring county boundaries. 
# If unobserved pro-democracy or high-turnout counties are also more lucrative for 
# fundraising, beta_pooled absorbs this covariance, leading to severe OVB.
model_pooled <- lm(votePercent ~ campaignDonation, data = voting_data)
summary(model_pooled)


# Question 1.b: Sample Dispersion
# -------------------------------------------------
# We calculate the standard deviation of our treatment variable (campaign donations)
# to evaluate its empirical variance across the global sample.
sd_campaign <- sd(voting_data$campaignDonation)
print(sd_campaign)


# Question 1.c: Economic Impact Evaluation (Pooled Baseline)
# -------------------------------------------------
# We compute the expected shift in voting outcomes associated with a 1 standard 
# deviation increase in campaign donations, under the biased pooled model.
# Effect = beta_pooled * SD(Donations)
donation_coefficient <- coef(model_pooled)["campaignDonation"]
standard_deviation_effect <- sd_campaign * donation_coefficient
percentage_point_effect <- 100 * standard_deviation_effect

print(standard_deviation_effect)
print(percentage_point_effect)


# Question 2: Bivariate Visual Representation
# -------------------------------------------------
# Plotting the raw relationship between campaign donations and vote share.
# This visualization captures the uncorrected, pooled correlation.
p1 <- ggplot(voting_data, aes(x = campaignDonation, y = votePercent)) +
  geom_point(alpha = 0.5, color = "darkblue") +
  labs(
    x = "Campaign Donations",
    y = "Vote Share (%)",
    title = "Relationship Between Donations and Vote Percent"
  ) +
  theme_minimal()

print(p1)
ggsave("donations_vote_share.png", plot = p1, width = 7, height = 5)


# Question 3.a: Least Squares Dummy Variable (LSDV) Model
# -------------------------------------------------
# Specification: votePercent_ic = alpha + beta_FE * campaignDonation_ic + theta_c * factor(county)_c + epsilon_ic
#
# INTUITION:
# By adding dummy variables for each county, we allow each county to have its own 
# baseline intercept (theta_c). This effectively controls for all unobserved, 
# time-invariant county characteristics, isolating the within-county variation of 
# donations on vote share.
model_lsdv <- lm(votePercent ~ campaignDonation + factor(county), data = voting_data)
summary(model_lsdv)


# Question 3.b: Within-County Economic Impact
# -------------------------------------------------
# We re-evaluate the impact of a 1 standard deviation increase in campaign donations 
# on vote share using our corrected within-county coefficient (beta_FE).
# Notice how the effect size changes once we parse out county-level confounding!
lsdv_coefficient <- coef(model_lsdv)["campaignDonation"]
within_sd_effect <- sd_campaign * lsdv_coefficient
within_pct_effect <- 100 * within_sd_effect

print(within_sd_effect)
print(within_pct_effect)


# Question 3.c: The Within-Demeaning Estimator
# -------------------------------------------------
# MATHEMATICAL EQUIVALENCE:
# We manually verify the Within-estimator. We demean both the independent (X) and 
# dependent (Y) variables within each county:
# Y_tilde_ic = Y_ic - Mean(Y_c)
# X_tilde_ic = X_ic - Mean(X_c)
#
# Running a simple OLS on these demeaned variables:
# Y_tilde_ic = beta_FE * X_tilde_ic + epsilon_ic
# This sweeps out the fixed effects intercept terms entirely, yielding the exact
# same beta_FE coefficient as the LSDV model.
voting_demeaned <- voting_data %>%
  group_by(county) %>%
  mutate(
    demeaned_vote = votePercent - mean(votePercent),
    demeaned_donation = campaignDonation - mean(campaignDonation)
  ) %>%
  ungroup()

model_within <- lm(demeaned_vote ~ demeaned_donation, data = voting_demeaned)
summary(model_within)


# Question 4: Multi-Group Fixed Effects Visualization
# -------------------------------------------------
# Visualizing the relationship colored by county groupings. This clearly shows
# how the pooled slope can differ from the within-county slopes, demonstrating 
# the intuitive mechanics of Simpson's Paradox and Fixed Effects correction.
p2 <- ggplot(voting_data, aes(x = campaignDonation, y = votePercent, color = factor(county))) +
  geom_point(alpha = 0.6) +
  labs(
    x = "Campaign Donations",
    y = "Vote Share (%)",
    title = "Vote Share and Campaign Donations by County"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

print(p2)
ggsave("donations_by_county.png", plot = p2, width = 7, height = 5)
