library(dtwclust)
library(zoo)       # for moving average
library(ggplot2)
library(reshape2)  # for data reshaping

centroids <- results[[2]]@centroids

# Smooth centroids using moving average
smoothed_centroids <- lapply(centroids, function(x) rollmean(x, k = 120, fill = NA))

# Convert to data frame for ggplot
df <- do.call(cbind, smoothed_centroids)
df <- data.frame(Time = 1:nrow(df), df)
df_melt <- melt(df, id.vars = "Time", variable.name = "Cluster", value.name = "Value")

# Plot
ggplot(df_melt, aes(x = Time, y = Value, color = Cluster)) +
  geom_line(size = 1) +
  labs(title = "Smoothed Time Series Cluster Centroids",
       x = "Time", y = "Value") +
  theme_minimal()


#get cluster assignments
cluster_assignments <- clu2@cluster
#data frame with subject IDs and their clusters
cluster_df3 <- data.frame(ID = subBLSA$id, Cluster = cluster_assignments)
write.table(cluster_df3,"DTW2clustersSun.csv",row.names=F, col.names=T,sep=",")

