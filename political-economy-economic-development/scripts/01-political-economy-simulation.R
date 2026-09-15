# ==============================================================================
# COURSE: Political Economy and Economic Development
# MODULE: Week 1 - Probability and Estimator Simulations
# TOPIC: Mathematical Foundations and Monte Carlo Simulations
# ==============================================================================
# Overview:
# This script simulates the asymptotic properties of estimators, explores linear
# combinations of independent random variables, and models noise propagation
# in bivariate regression systems. It demonstrates how empirical estimators
# converge to their analytical parameters under various specifications.
# ==============================================================================

# Preliminaries
# -------------------------------------------------
rm(list = ls())
options(scipen = 999)
options(max.print = 99999999)


# Question 1.a: Linear Sequences and Expected Values
# -------------------------------------------------
# We define a deterministic sequence and calculate its sample mean.
# Analytical expected value for sequence 1 to N is: E[t] = (N + 1) / 2 = 50.5.
time_seq <- seq(1, 100)
mean(time_seq)


# Question 1.b: Properties of Constants
# -------------------------------------------------
# Let alpha be a deterministic constant vector (alpha_t = c).
# By definition, the variance of a constant is zero: Var(c) = 0.
alpha <- rep(3, 100)
var(alpha)


# Question 1.c: Joint Probability & Uniform-Normal Generation
# -------------------------------------------------
# Set seed for reproducible simulation draws
set.seed(2653894)

# We draw epsilon from a standard normal distribution: epsilon ~ N(0, 1)
# We draw x from a uniform continuous distribution: x ~ U(0, 1)
epsilon <- rnorm(100, mean = 0, sd = 1)
x_var <- runif(100, min = 0, max = 1)

# Expected value of a continuous uniform distribution U(a, b) is:
# E[x] = (a + b) / 2 = (0 + 1) / 2 = 0.5. Our sample mean converges asymptotically.
mean(x_var)


# Question 1.d: Analytical Variance of a Uniform Distribution
# -------------------------------------------------
# Analytical variance of a uniform continuous distribution U(a, b) is:
# Var(x) = (b - a)^2 / 12 = (1 - 0)^2 / 12 = 1/12 ≈ 0.0833.
# The sample variance converges to this theoretical expectation as N -> infinity.
var(x_var)


# Question 1.e: Bivariate Data Generation Process (DGP)
# -------------------------------------------------
# We simulate a classical linear DGP: y_t = alpha_t + beta * x_t + epsilon_t
# By linearity of expectation, since alpha_t = 3, beta = 2, and E[epsilon_t] = 0:
# E[y_t] = E[alpha_t] + beta * E[x_t] + E[epsilon_t] = 3 + 2 * (0.5) + 0 = 4.0.
beta_slope <- 2
y_var <- alpha + beta_slope * x_var + epsilon
mean(y_var)


# Question 1.g: Non-Linear Data Generating Process
# -------------------------------------------------
# We simulate q_t as a non-linear cubic function of x_var with additive normal noise:
# q_t = x_t + 2 * x_t^3 + v_t, where v_t ~ N(0, 1)
v_noise <- rnorm(100, mean = 0, sd = 1)
q_var <- x_var + 2 * x_var^3 + v_noise
mean(q_var)


# Question 1.h: Multivariate Super-System and Structural Noise
# -------------------------------------------------
# We construct a system z_t where the non-linear variable q_var is an additive regressor:
# z_t = alpha_t + beta * x_t + gamma * q_t + epsilon_t
# Here, E[z_t] = 3 + 2 * (0.5) + 3 * E[q_t] + 0.
gamma_slope <- 3
z_var <- alpha + beta_slope * x_var + gamma_slope * q_var + epsilon
mean(z_var)


# Question 1.i: Interpreting OLS Confidence Intervals
# -------------------------------------------------
# The point estimate of a symmetric confidence interval lies at its exact midpoint.
# Midpoint = (Lower Bound + Upper Bound) / 2.
(5.832 + 10.014) / 2


# Question 1.j: Calculating Confidence Upper Bounds
# -------------------------------------------------
# For a standard 95% Wald-type confidence interval, the upper bound is computed as:
# Upper Bound = Point Estimate + z_critical * Standard Error
# Under normality, the 95% critical value (two-tailed) is approximately 1.96.
7.8 + 1.96 * 1.04
