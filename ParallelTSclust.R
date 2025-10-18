#install.packages("future.apply")
library(future.apply)
plan(multisession, workers = parallel::detectCores() - 1)

# Define a list of clustering configurations
configs <- list(
  list(k = 2L, type = "partitional", distance = "dtw_lb"),
  list(k = 3L, type = "partitional", distance = "dtw_lb"),
  list(k = 4L, type = "partitional", distance = "dtw_lb"),
  list(k = 5L, type = "partitional", distance = "dtw_lb"),
  list(k = 6L, type = "partitional", distance = "dtw_lb"),
  list(k = 7L, type = "partitional", distance = "dtw_lb"),
  list(k = 8L, type = "partitional", distance = "dtw_lb"),
  list(k = 2L, type = "partitional", distance = "L2"),
  list(k = 3L, type = "partitional", distance = "L2"),
  list(k = 4L, type = "partitional", distance = "L2"),
  list(k = 5L, type = "partitional", distance = "L2"),
  list(k = 6L, type = "partitional", distance = "L2"),
  list(k = 7L, type = "partitional", distance = "L2"),
  list(k = 8L, type = "partitional", distance = "L2"),
  list(k = 2L, type = "partitional", distance = "sbd", centroid = "shape"),
  list(k = 3L, type = "partitional", distance = "sbd", centroid = "shape"),
  list(k = 4L, type = "partitional", distance = "sbd", centroid = "shape"),
  list(k = 5L, type = "partitional", distance = "sbd", centroid = "shape"),
  list(k = 6L, type = "partitional", distance = "sbd", centroid = "shape"),
  list(k = 7L, type = "partitional", distance = "sbd", centroid = "shape"),
  list(k = 8L, type = "partitional", distance = "sbd", centroid = "shape")
)

# Run in parallel
results <- future_lapply(configs, function(cfg) {
  tsclust(
    zscore(TSdatWk),
    type = cfg$type,
    k = cfg$k,
    window.size = 5L,
    distance = cfg$distance,
    centroid = cfg$centroid %||% "pam",  # default to "pam" if not specified
    control = partitional_control(pam.precompute = FALSE),
    seed = 8L
  )
})

results
Rclulist<-c(
results[[8]],results[[9]],results[[10]],results[[11]],results[[12]],results[[13]],results[[14]])

#validation
cvi(results[[15]],type=c("Sil","CH","DBstar"))

#try loop
cvi_list <- lapply(Rclulist, function(model) {
tryCatch({
  cvi_values<-cvi(model, type = c("Sil","CH","DBstar"))
  return(cvi_values)
},error=function(e){  message("Error processing model: ", e$message)
    return(NA)
   })
  })
names(cvi_list)<-paste0("model_",1:length(Rclulist))
print(cvi_list)



#cvi_results_lapply <- lapply(model_list, function(model) {
#  tryCatch({
 #   cvi_values <- cvi(model, type = c("Sil", "DB"))
  #  return(cvi_values)
  #}, error = function(e) {
   # message("Error processing model: ", e$message)
    #return(NA) # Return NA or some other indicator for failed computations
  #})
#})

# Name the results list for easier identification
#names(cvi_results_lapply) <- paste0("model_", 1:length(model_list))
# Print the results
#print("CVI Results (lapply):")
#print(cvi_results_lapply)