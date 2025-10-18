#Parameter settings
#Sample Size
n <- 1000
#Time Points
time <- 10  
#Stochastic trend 
#Drift  
mu <- 0             
#initial SD
sigma_0 <- 1
#autoregressive path weight (AR(1))           
phi <- .98

#Deterministic trend
#Linear (positive)
b1p <- 0.2
#Linear (negative)
b1n<- -0.2 
#Quadratic (negative)
b2n <- -0.05 
#Quadratic (positive)
b2p <- 0.05     

#set cuts for grouping
c1<-250
c2<-500
c3<-750


##program producing time series##
# Initialize matrices to store results
stochastic_simulations <- matrix(0, nrow = time, ncol = n)
deterministic_simulations <- matrix(0, nrow = time, ncol = n)
combined_simulations <- matrix(0, nrow = time, ncol = n)

# Generate stochastic trends (random walks with stochastic volatility)
for (i in 1:n) {
  steps <- numeric(time)
  sigma_t <- sigma_0  # Initialize volatility
  
  for (t in 2:time) {
    epsilon_t <- rnorm(1, mean = 0, sd = sigma_t)  # Random shock
    sigma_t <- abs(phi * sigma_t + rnorm(1, mean = 0, sd = 0.1))  # Stochastic volatility
    steps[t] <- steps[t-1] + mu + epsilon_t  # Stochastic trend update
  }
  
  stochastic_simulations[, i] <- steps  # Store stochastic paths
}

# Generate deterministic trends (Linear, Quadratic, Exponential)
for (i in 1:n) {
  steps <- numeric(time)
  
  for (t in 2:time) {
    if (i <= c1) {  # Group 1: Linear positve trend
      steps[t] <- b1p*t
    } else if (i <= c2) {  # Group 2: Linear negative trend
      steps[t] <-b1n*t
    } else if (i <= c3) {  # Group 3: Negative quad trend
      steps[t] <-b2n*t^2
    } else {  # Group 4: Postive quad trend
      steps[t] <- b2p*t^2
    }
  }
  deterministic_simulations[, i] <- steps  # Store deterministic paths
}

# Combine Stochastic and Deterministic Trends
combined_simulations <- stochastic_simulations + deterministic_simulations

# Plot Stochastic Trends
matplot(stochastic_simulations, type = "l", lty = 1, col = rainbow(n), 
        main = "Monte Carlo Simulation: Stochastic Trends",
        xlab = "Time Steps", ylab = "Value")
abline(h = 0, col = "black", lwd = 2)

# Plot Deterministic Trends
matplot(deterministic_simulations, type = "l", lty = 1, col = rainbow(n), 
        main = "Monte Carlo Simulation: Deterministic Trends",
        xlab = "Time Steps", ylab = "Value")
abline(h = 0, col = "black", lwd = 2)

# Plot Combined Trends
matplot(combined_simulations, type = "l", lty = 1, col = rainbow(n), 
        main = "Monte Carlo Simulation: Combined Stochastic & Deterministic Trends",
        xlab = "Time Steps", ylab = "Value")
abline(h = 0, col = "black", lwd = 2)


par(mfrow=c(2,2))
n <- 1440  # number of time points
time<-seq(0, 24, length.out = n)# Time over 24 hours
mesor <- 10 # Midline Estimating Statistic Of Rhythm (baseline)
amplitude <- 3 # Amplitude of the rhythm
acrophase <- pi / 3 # Phase shift (in radians)
# Simulate cosinor model
cosinor <- mesor + amplitude * cos(2 * pi * time / 24 - acrophase)
# Plot the result
plot(time, cosinor, type = "l", col = "blue", lwd = 2,main = "Simulated Cosinor Model",xlab = "Time (hours)", ylab = "Value")

#linear trend
linear<-.5*time
plot(time, linear, type = "l", col = "blue", lwd = 2,main = "Simulated Linear Model",xlab = "Time (hours)", ylab = "Value")

# Parameters
drift <- 0.1        # Drift term
noise <- rnorm(n)    # White noise

# Generate random walk with drift
random_walk_drift <- cumsum(drift + noise)
# Plot the time series
ts.plot(random_walk_drift, main = "Random Walk with Drift", ylab = "Value", xlab = "Time")


# Simulate white noise
white_noise <- rnorm(n, mean = 0, sd = 1)

# Plot the white noise
ts.plot(white_noise, main = "White Noise", ylab = "Value", xlab = "Time")
