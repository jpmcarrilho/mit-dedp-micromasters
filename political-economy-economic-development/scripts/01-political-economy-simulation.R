# Preliminaries
# -------------------------------------------------
rm(list = ls())
options(scipen = 999)
options(max.print = 99999999)

# Question 1.a
# -------------------------------------------------
# Create a sequence from 1 to 100 and calculate its mean
time_seq <- seq(1, 100)
mean(time_seq)

# Question 1.b
# -------------------------------------------------
# Define a constant alpha vector and check its variance
alpha <- rep(3, 100)
var(alpha)

# Question 1.c
# -------------------------------------------------
set.seed(2653894)

# Generate uniform and normal random variables
epsilon <- rnorm(100, mean = 0, sd = 1)
x_var <- runif(100, min = 0, max = 1)
mean(x_var)

# Question 1.d
# -------------------------------------------------
# Compute the empirical variance of the uniform draw
var(x_var)

# Question 1.e
# -------------------------------------------------
# Simulate y_t with a constant slope beta = 2
beta_slope <- 2
y_var <- alpha + beta_slope * x_var + epsilon
mean(y_var)

# Question 1.g
# -------------------------------------------------
# Generate a non-linear variable q_t
v_noise <- rnorm(100, mean = 0, sd = 1)
q_var <- x_var + 2 * x_var^3 + v_noise
mean(q_var)

# Question 1.h
# -------------------------------------------------
# Simulate z_t with a constant slope gamma = 3
gamma_slope <- 3
z_var <- alpha + beta_slope * x_var + gamma_slope * q_var + epsilon
mean(z_var)

# Question 1.i
# -------------------------------------------------
# Calculate the mid-point of the confidence interval
(5.832 + 10.014) / 2

# Question 1.j
# -------------------------------------------------
# Compute the upper bound of the confidence interval
7.8 + 1.96 * 1.04
