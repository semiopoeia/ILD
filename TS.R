#https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/arima.sim


# Set parameters
set.seed(123)
n_simulations <- 100   # Number of Monte Carlo simulations
n_steps <- 200         # Number of time steps
mu <- 0.05             # Drift term (trend)
sigma_0 <- 1           # Initial standard deviation
phi <- 0.98            # Autoregressive component for volatility

# Initialize matrix to store simulations
simulations <- matrix(0, nrow = n_steps, ncol = n_simulations)

# Generate random walks with stochastic volatility
for (i in 1:n_simulations) {
  steps <- numeric(n_steps)
  sigma_t <- sigma_0  # Initialize volatility
  for (t in 2:n_steps) {
    epsilon_t <- rnorm(1, mean = 0, sd = sigma_t)  # Random shock
    sigma_t <- abs(phi * sigma_t + rnorm(1, mean = 0, sd = 0.1))  # Stochastic volatility
    steps[t] <- steps[t-1] + mu + epsilon_t  # Stochastic trend update
  }
  simulations[, i] <- steps  # Store simulation path
}

# Plot the random walks
matplot(simulations, type = "l", lty = 1, col = rainbow(n_simulations), 
        main = "Monte Carlo Simulation with Stochastic Trend",
        xlab = "Time Steps", ylab = "Value")
abline(h = 0, col = "black", lwd = 2)
