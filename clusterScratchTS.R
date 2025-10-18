#mclust
model<-Mclust...
post_prob<-as.data.frame(FIT$z)
post_prob$id<-1:nrow(post_prob)
param_results$id<-1:nrow(param_results)
mergeObs<-param_results%>%
		left_join(post_prob,by="id")


#####
#PAM with multi-arm bandit (computationally quicker but requires python installation)
install.packages("reticulate")
reticulate::py_install("banditpam")
library(reticulate)
# Import the banditpam package
banditpam <- import("banditpam")
# Convert the data to a Python-compatible format
data_py <- r_to_py(data)
# Initialize and fit the BanditPAM model
k <- 3  # Number of clusters
model <- banditpam$KMedoids(n_medoids = k)
model$fit(data_py)
# Get the cluster assignments
clusters <- model$labels_
# Convert the cluster assignments back to R
clusters_r <- py_to_r(clusters)
# Print the cluster assignments
print(clusters_r)


###
#standard PAM (partioning around medoids)
install.packages("cluster")
library(cluster)
k <- 4  # Number of clusters
pam_result <- pam(pc_scores, k)
# Cluster assignments
clusters <- pam_result$clustering
# Medoids
medoids <- pam_result$medoids
# Print the results
View(clusters)
print(medoids)
clusplot(pam_result, main = "PAM Clustering")

table(SARIMAcomps)
###
#dynamic time warping on time series data
install.packages("dtwclust")
library(dtwclust)


# Perform clustering using DTW
k <- 4  # Number of clusters
#complete time series
clusterDTW <- tsclust(t(combined_simulationsF), type = "partitional", k = k, distance = "dtw")
# Print the clustering results
print(clusterDTW)
# Plot the clustering results
plot(clusterDTW)
clusterDTW@cluster
cvi(clusterDTW)

#Expereienced sampled time series
clusterDTW_ESM <- tsclust(t(combined_simulationsT), type = "partitional", k = k, distance = "dtw")
# Print the clustering results
print(clusterDTW_ESM)
# Plot the clustering results
plot(clusterDTW_ESM)
clusterDTW_ESM@cluster
cvi(clusterDTW_ESM)

