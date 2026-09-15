# Preliminaries
# -------------------------------------------------
rm(list = ls())
library(tidyverse)

# Load data and convert to a modern tibble
load("../data/votingData.rdata")
voting_data <- as_tibble(votingData)

# Question 1.a
# -------------------------------------------------
# Pooled OLS model of vote percent on campaign donations
model_pooled <- lm(votePercent ~ campaignDonation, data = voting_data)
summary(model_pooled)

# Question 1.b
# -------------------------------------------------
# Calculate the standard deviation of campaign donations
sd_campaign <- sd(voting_data$campaignDonation)
print(sd_campaign)

# Question 1.c
# -------------------------------------------------
# Calculate effect of a 1 standard deviation increase on vote percent
donation_coefficient <- coef(model_pooled)["campaignDonation"]
standard_deviation_effect <- sd_campaign * donation_coefficient
percentage_point_effect <- 100 * standard_deviation_effect

print(standard_deviation_effect)
print(percentage_point_effect)

# Question 2
# -------------------------------------------------
# Visualizing relationship between donations and vote percent
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

# Question 3.a
# -------------------------------------------------
# Least Squares Dummy Variable (LSDV) model with county fixed effects
model_lsdv <- lm(votePercent ~ campaignDonation + factor(county), data = voting_data)
summary(model_lsdv)

# Question 3.b
# -------------------------------------------------
# Calculate within-county standard deviation effect
lsdv_coefficient <- coef(model_lsdv)["campaignDonation"]
within_sd_effect <- sd_campaign * lsdv_coefficient
within_pct_effect <- 100 * within_sd_effect

print(within_sd_effect)
print(within_pct_effect)

# Question 3.c
# -------------------------------------------------
# Demean variables manually within each county to estimate Within-estimator
voting_demeaned <- voting_data %>%
  group_by(county) %>%
  mutate(
    demeaned_vote = votePercent - mean(votePercent),
    demeaned_donation = campaignDonation - mean(campaignDonation)
  ) %>%
  ungroup()

model_within <- lm(demeaned_vote ~ demeaned_donation, data = voting_demeaned)
summary(model_within)

# Question 4
# -------------------------------------------------
# Visualizing the relationship with county-level groupings (fixed effects intuition)
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
