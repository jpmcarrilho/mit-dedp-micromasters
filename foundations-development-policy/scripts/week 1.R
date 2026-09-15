data <- read.csv('../data/wb_dev_ind.csv')
summary(data, digits = 5)
mean(data$gdp_per_capita, na.rm = TRUE)
sd(data$gdp_per_capita, na.rm = TRUE)
mean(data$literacy_all, na.rm = TRUE)
sd(data$literacy_all, na.rm = TRUE)

sd(data$infant_mortality, na.rm)



100 - mean(data$literacy_male, na.rm = TRUE)
100 - mean(data$literacy_female, na.rm = TRUE)


library(dplyr)

# Top 50 highest values
df_top50 <- data %>%
  slice_max(order_by = gdp_per_capita, n = 50) 

df_top50$illiteracy_rate <- 100 - df_top50$literacy_all
summary(df_top50)

df_min50 <- data %>%
  slice_min(order_by = gdp_per_capita, n = 50) 

df_min50$illiteracy_rate <- 100 - df_min50$literacy_all
summary(df_min50)


model_1 <- lm(data$infant_mortality ~ data$gdp_per_capita)
summary(model)

model_2 <- lm(literacy_all ~ gdp_per_capita , data = data)
summary(model_2)
