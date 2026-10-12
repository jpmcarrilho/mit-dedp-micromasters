# MIT DEDP MicroMasters: Empirical Economics & Causal Inference

A comprehensive repository of empirical econometrics, causal inference methodologies, and development policy evaluations developed across the **MIT Data, Economics, and Development Policy (DEDP) MicroMasters** program. 

This repository documents rigorous R implementations replicating seminal papers in development economics, public policy, and political economy—leveraging randomized controlled trials (RCTs), difference-in-differences (DiD), instrumental variables (2SLS), regression discontinuity designs (RDD), and high-dimensional two-way fixed effects (TWFE).

---

## Courses & Curriculum

### 1. Data Analysis for Social Scientists
Exploratory data analysis, probability theory, causal inference, and regression modeling applied to empirical social science questions.

**Course Modules & Topics:**
- **Module 1**: Introduction to the Course
- **Module 2**: Fundamentals of Probability, Random Variables, Joint Distributions & Collecting Data
  - Script: `02-probability-and-random-variables.R`
- **Module 3**: Describing Data, Joint and Conditional Distributions of Random Variables
  - Script: `03-describing-data-and-distributions.R`
- **Module 4**: Functions and Moments of a Random Variable & Intro to Regressions
- **Module 5**: Special Distributions, the Sample Mean, the Central Limit Theorem
- **Module 6**: Assessing and Deriving Estimators, Confidence Intervals, and Hypothesis Testing
  - Script: `06-estimators-and-hypothesis-testing.R`
- **Module 7**: Causality, Analyzing Randomized Experiments, & Nonparametric Regression
  - Script: `07-causality-and-randomized-experiments.R`
- **Module 8**: Single and Multivariate Linear Models
  - Script: `08-linear-models.R`
- **Module 9**: Practical Issues in Running Regressions and Omitted Variable Bias
  - Script: `09-regressions-and-ovb.R`
- **Module 10**: Endogeneity, Instrumental Variables, Experimental Design, and Data Visualization *(Included in Mod 11 script)*
- **Module 11**: Endogeneity and Instrumental Variables
  - Script: `11-endogeneity-and-instrumental-variables.R`

### 2. Foundations of Development Policy
Microeconomic and macroeconomic considerations of policy interventions, evaluating global health, educational investments, gender inequality, and intrahousehold bargaining.

**Course Weeks & Topics:**
- **Week 1**: Global Development Indicators, Wealth, and Human Welfare
  - Script: `01-development-indicators.R`
- **Week 2**: Health, Nutrition, and Deworming in Schools (Miguel & Kremer 2004)
  - Script: `02-nutrition.R`
- **Week 3**: Education, School Construction, and Returns to Schooling (Duflo 2001)
  - Script: `03-education.R`
- **Week 4**: Gender, Intrahousehold Allocation, and Comparative Advantage (Qian 2008)
  - Script: `04-gender.R`

### 3. Political Economy and Economic Development
Empirical analyses investigating governance, institutions, state capacity, corruption, and the political drivers of economic development.

**Course Weeks & Topics:**
- **Week 1**: Introduction to R & Economic Development Simulation
  - Script: `01-political-economy-simulation.R`
- **Week 2**: Leaders, Assassinations, and Institutional Change (Jones & Olken 2009)
  - Script: `02-assassinations-and-institutions.R`
- **Week 3**: Colonial Origins of Comparative Development (Acemoglu, Johnson & Robinson 2001)
  - Script: `03-colonial-origins-institutions.R`
- **Week 4**: Historical Legacy of the Mita and Regression Discontinuity (Dell 2010)
  - Script: `04-mita-regression-discontinuity.R`
- **Week 7**: Campaign Donations and County-Level Fixed Effects
  - Script: `07-campaign-donations-fixed-effects.R`
- **Week 9**: Corruption, Monitoring, and Audits in Infrastructure Projects (Olken 2007)
  - Script: `09-corruption-monitoring-indonesia.R`

---

## Econometric Toolset & Technologies
- **Language**: R
- **Data Wrangling & Visualization**: `tidyverse` (`dplyr`, `ggplot2`, `readr`, `tibble`, `tidyr`)
- **Panel & Fixed Effects Econometrics**: `lfe` (`felm`)
- **Instrumental Variables & 2SLS**: `AER` (`ivreg`), `sandwich`, `lmtest`
- **Survey Inference** (papers/): `survey`, `srvyr`, `PNADcIBGE`
- **Reporting**: Quarto (papers/)

---

## Brazilian Replication Papers (`papers/`)

Short, reproducible working papers that re-run the course methods on Brazilian public microdata, with design-based inference and a replication package per paper. See [`papers/README.md`](papers/README.md) for the series, [`papers/CHECKLIST.md`](papers/CHECKLIST.md) for the validity standard, and [`papers/PUBLISHING.md`](papers/PUBLISHING.md) for the release path.

- **Paper 01**: Returns to Schooling in Brazil, 2012–2025: Design-Based Mincer Estimates from the PNAD Contínua (`papers/01-returns-to-schooling/`)
