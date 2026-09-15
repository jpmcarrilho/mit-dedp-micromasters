# Preliminaries
# -------------------------------------------------
# Course: Foundations of Development Policy
# Topic: Global Development Indicators, Wealth, and Human Welfare
# -------------------------------------------------
rm(list = ls())
library(tidyverse)

# Load data and convert to a modern tibble
dev_data <- as_tibble(read.csv("../data/wb_dev_ind.csv"))

# Question 1: Summary Statistics
# -------------------------------------------------
# Examining central tendencies and dispersions of macro-level development indicators
summary(dev_data, digits = 5)

mean_gdp <- mean(dev_data$gdp_per_capita, na.rm = TRUE)
sd_gdp   <- sd(dev_data$gdp_per_capita, na.rm = TRUE)

mean_lit <- mean(dev_data$literacy_all, na.rm = TRUE)
sd_lit   <- sd(dev_data$literacy_all, na.rm = TRUE)

# Fixed bug: na.rm parameter value was missing in the original script
sd_infant_mortality <- sd(dev_data$infant_mortality, na.rm = TRUE)

print(mean_gdp)
print(sd_gdp)
print(mean_lit)
print(sd_lit)
print(sd_infant_mortality)


# Question 2: Gender Disparities in Literacy
# -------------------------------------------------
# Analyzing global adult illiteracy rates across genders
illiteracy_male   <- 100 - mean(dev_data$literacy_male, na.rm = TRUE)
illiteracy_female <- 100 - mean(dev_data$literacy_female, na.rm = TRUE)

print(illiteracy_male)
print(illiteracy_female)


# Question 3: Comparative Cohort Analysis (Top 50 vs Bottom 50 countries by GDP)
# -------------------------------------------------
# ECONOMIC INTUITION: Comparing educational outcomes across wealth boundaries. 
# We segment the global sample into extreme cohorts to explore how structural 
# underdevelopment and poverty correlate with national illiteracy.

# Cohort A: Top 50 richest countries by GDP per Capita
df_top50 <- dev_data %>%
  slice_max(order_by = gdp_per_capita, n = 50) %>%
  mutate(illiteracy_rate = 100 - literacy_all)

summary(df_top50)

# Cohort B: Bottom 50 poorest countries by GDP per Capita
df_min50 <- dev_data %>%
  slice_min(order_by = gdp_per_capita, n = 50) %>%
  mutate(illiteracy_rate = 100 - literacy_all)

summary(df_min50)


# Question 4: Econometric Modeling - Welfare and Wealth
# -------------------------------------------------
# MODEL 1: Bivariate relationship between Infant Mortality and Economic Wealth
# Specification: InfantMortality_i = alpha + beta * GDP_per_capita_i + epsilon_i
#
# INTERPRETATION CAVEATS:
# While wealth is a strong predictor of child survival, this bivariate correlation 
# does not establish causality. Confounding variables (e.g., national healthcare 
# infrastructure, institution quality, social safety nets) are omitted, which 
# would likely lead to Omitted Variable Bias (OVB) in our beta coefficient.

# Fixed bug: original script called summary(model) instead of summary(model_1)
model_infant_mortality <- lm(infant_mortality ~ gdp_per_capita, data = dev_data)
summary(model_infant_mortality)

# Visualizing Infant Mortality vs GDP per Capita
p1 <- ggplot(dev_data, aes(x = gdp_per_capita, y = infant_mortality)) +
  geom_point(alpha = 0.6, color = "darkred") +
  geom_smooth(method = "lm", se = FALSE, color = "black", linewidth = 1) +
  labs(
    x = "GDP per Capita (USD)",
    y = "Infant Mortality Rate (per 1,000 live births)",
    title = "Infant Mortality vs. National Income",
    subtitle = "Explore the relationship between wealth and basic health outcomes"
  ) +
  theme_classic()

print(p1)
ggsave("gdp_vs_infant_mortality.png", plot = p1, width = 7, height = 5)


# MODEL 2: Bivariate relationship between Literacy and Economic Wealth
# Specification: LiteracyAll_i = alpha + gamma * GDP_per_capita_i + u_i
model_literacy <- lm(literacy_all ~ gdp_per_capita, data = dev_data)
summary(model_literacy)

# Visualizing Literacy vs GDP per Capita
p2 <- ggplot(dev_data, aes(x = gdp_per_capita, y = literacy_all)) +
  geom_point(alpha = 0.6, color = "darkblue") +
  geom_smooth(method = "lm", se = FALSE, color = "black", linewidth = 1) +
  labs(
    x = "GDP per Capita (USD)",
    y = "Total Literacy Rate (%)",
    title = "National Literacy vs. National Income",
    subtitle = "Wealth as a predictor of educational access"
  ) +
  theme_classic()

print(p2)
ggsave("gdp_vs_literacy.png", plot = p2, width = 7, height = 5)
