# Load data
rm(list = ls())
library(car)

nlsw88 <- read.csv('../data/nlsw88.csv')

# covariance
cov_yx <- cov(nlsw88$lwage, nlsw88$yrs_school)  
var_x <- var(nlsw88$yrs_school) 
hatbeta1_0 <- cov_yx / var_x
print(hatbeta1_0)

# simple linear regression
single <- lm(lwage ~ yrs_school, data = nlsw88)
summary(single) # show results
coefficients(single) # model coefficients

ci <- confint(single, level = 0.9) 
print(ci)

resid <- residuals(single) # residuals
sum(resid)

# dummy variables
meanother <- mean(nlsw88$lwage[nlsw88$black == 0])
meanblack <- mean(nlsw88$lwage[nlsw88$black == 1])

print(meanother)
print(meanblack - meanother)

dummymodel <- lm(lwage ~ black, data = nlsw88)
summary(dummymodel)

# multivariable regression
multi <- lm(lwage ~ yrs_school + ttl_exp, data = nlsw88)
summary(multi) # show results
anova_unrest <- anova(multi)

# Restricted model
nlsw88$newvar <- nlsw88$yrs_school + 2 * nlsw88$ttl_exp
restricted <- lm(lwage ~ newvar, data = nlsw88)
summary(restricted) # show results
anova_rest <- anova(restricted)

# Test
numerator <- (anova_rest$`Sum Sq`[2] - anova_unrest$`Sum Sq`[3]) / 1
denominator <- anova_unrest$`Sum Sq`[3] / anova_unrest$Df[3]
statistic_test <- numerator / denominator

print(statistic_test)

pvalue <- df(statistic_test, 1, anova_unrest$Df[3])
print(pvalue)

matrixR <- c(0, -2, 1)
linearHypothesis(multi, matrixR)