install.packages("dtwclust",dep=T)
library(dtwclust)
library(tidyverse)

#brining in the BLSA data
rawBLSA<-read_csv("BLSA_ACR_1440_20210109(in).csv",
			col_types = cols(date = col_date(format = "%m/%d/%Y")))

#create a day indicator variable for each subject
#and extract of day of the week variable for dates
sortBLSA <- rawBLSA |>
  group_by(id) |>
  arrange(id, date) |>
  mutate(day = row_number())|>
  mutate(weekday=weekdays(date))
table(sortBLSA$day)
table(sortBLSA$weekday)

#dropping invalid cases
validBLSA<-sortBLSA|>
	filter(valid==1)
table(validBLSA$valid)

#selecting a day to cluster data from
#cross-tab to find most prevalent day, weekday combo
max(table(validBLSA$day,validBLSA$weekday))
table(validBLSA$day,validBLSA$weekday)
#4th day as sunday is most common (n=246)
subBLSA<- validBLSA |>
		filter(day==4 & weekday=="Sunday")


#time series data format
TSdat<-as.matrix(subBLSA[,7:1446],ncol=1440,nrow=length(subBLSA$id))


##standard DTW with PAM
clu2<- 
tsclust(TSdat, type = "partitional", k = 2L, window.size=5L, distance = "dtw", centroid="pam")
clu2
plot(clu2,type="sc")
plot(clu2,type="centroid")

centroids <- clu2@centroids
df_list <- lapply(seq_along(centroids), function(i) {
  data.frame(Time = 1:length(centroids[[i]]),
             Value = centroids[[i]],
             Cluster = paste0("Cluster ", i))
})
df <- do.call(rbind, df_list)
ggplot(df, aes(x = Time, y = Value, color = Cluster)) +
  geom_line(linewidth = 1) +
  labs(title = "General Trajectory per Cluster") +
  theme_minimal()

clu3<- 
tsclust(TSdat, type = "partitional", k = 3L, window.size=5L, distance = "dtw", centroid="pam")
clu4<- 
tsclust(TSdat, type = "partitional", k = 4L, window.size=5L, distance = "dtw", centroid="pam")
clu5<- 
tsclust(TSdat, type = "partitional", k = 5L, window.size=5L, distance = "dtw", centroid="pam")
clu6<- 
tsclust(TSdat, type = "partitional", k = 6L, window.size=5L, distance = "dtw", centroid="pam")
clu7<- 
tsclust(TSdat, type = "partitional", k = 7L, window.size=5L, distance = "dtw", centroid="pam")
clu8<- 
tsclust(TSdat, type = "partitional", k = 8L, window.size=5L, distance = "dtw", centroid="pam")
clu9<- 
tsclust(TSdat, type = "partitional", k = 9L, window.size=5L, distance = "dtw", centroid="pam")

#10 clusters
clu10<- 
tsclust(TSdat, type = "partitional", k = 10L, window.size=5L, distance = "dtw", centroid="pam")
clu10
plot(clu10,type="sc")
plot(clu10,type="centroid")
library(ggplot2)
centroids <- clu10@centroids
df_list <- lapply(seq_along(centroids), function(i) {
  data.frame(Time = 1:length(centroids[[i]]),
             Value = centroids[[i]],
             Cluster = paste0("Cluster ", i))
})
df <- do.call(rbind, df_list)
ggplot(df, aes(x = Time, y = Value, color = Cluster)) +
  geom_line(linewidth = 1) +
  labs(title = "General Trajectory per Cluster") +
  theme_minimal()

#######L2
#simpler partitioning around medoid (PAM) with Euclidean distance
edc2<- 
tsclust(TSdat, type = "partitional", k = 2L, window.size=5L, distance = "L2", centroid="pam")

plot(edc2,type="sc")
plot(edc2,type="centroid")

centroids <- edc2@centroids
df_list <- lapply(seq_along(centroids), function(i) {
  data.frame(Time = 1:length(centroids[[i]]),
             Value = centroids[[i]],
             Cluster = paste0("Cluster ", i))
})
df <- do.call(rbind, df_list)
ggplot(df, aes(x = Time, y = Value, color = Cluster)) +
  geom_line(linewidth = 1) +
  labs(title = "General Trajectory per Cluster") +
  theme_minimal()

edc3<- 
tsclust(TSdat, type = "partitional", k = 3L, window.size=5L, distance = "L2", centroid="pam")
edc4<- 
tsclust(TSdat, type = "partitional", k = 4L, window.size=5L, distance = "L2", centroid="pam")
edc5<- 
tsclust(TSdat, type = "partitional", k = 5L, window.size=5L, distance = "L2", centroid="pam")
edc6<- 
tsclust(TSdat, type = "partitional", k = 6L, window.size=5L, distance = "L2", centroid="pam")
edc7<- 
tsclust(TSdat, type = "partitional", k = 7L, window.size=5L, distance = "L2", centroid="pam")
edc8<- 
tsclust(TSdat, type = "partitional", k = 8L, window.size=5L, distance = "L2", centroid="pam")
edc9<- 
tsclust(TSdat, type = "partitional", k = 9L, window.size=5L, distance = "L2", centroid="pam")
edc10<- 
tsclust(TSdat, type = "partitional", k = 10L, window.size=5L, distance = "L2", centroid="pam")

sbd2<- 
tsclust(zscore(TSdat),seed=8L, type = "partitional", k = 2L, distance = "sbd", centroid="shape",
window.size = 5L)

plot(sbd7,type="sc")
plot(sbd7,type="centroid")

centroids <- sbd2@centroids
df_list <- lapply(seq_along(centroids), function(i) {
  data.frame(Time = 1:length(centroids[[i]]),
             Value = centroids[[i]],
             Cluster = paste0("Cluster ", i))
})
df <- do.call(rbind, df_list)
ggplot(df, aes(x = Time, y = Value, color = Cluster)) +
  geom_line(linewidth = 1) +
  labs(title = "General Trajectory per Cluster") +
  theme_minimal()

#get cluster assignments
cluster_assignments <- sbd2@cluster
#data frame with subject IDs and their clusters
cluster_df2 <- data.frame(ID = subBLSA$id, Cluster = cluster_assignments)
write.table(cluster_df2,"sbd2clusters.csv",row.names=F, col.names=T,sep=",")

sbd3<- 
tsclust(zscore(TSdat),seed=8L, type = "partitional", k = 3L, distance = "sbd", centroid="shape",
window.size = 5L)

centroids <- sbd3@centroids
df_list <- lapply(seq_along(centroids), function(i) {
  data.frame(Time = 1:length(centroids[[i]]),
             Value = centroids[[i]],
             Cluster = paste0("Cluster ", i))
})
df <- do.call(rbind, df_list)
ggplot(df, aes(x = Time, y = Value, color = Cluster)) +
  geom_line(linewidth = 1) +
  labs(title = "General Trajectory per Cluster") +
  theme_minimal()

#get cluster assignments
cluster_assignments <- sbd3@cluster
#data frame with subject IDs and their clusters
cluster_df3 <- data.frame(ID = subBLSA$id, Visit=subBLSA$visit, Cluster = cluster_assignments)
write.table(cluster_df3,"sbd3clusters.csv",row.names=F, col.names=T,sep=",")


sbd4<- 
tsclust(zscore(TSdat),seed=8L, type = "partitional", k = 4L, distance = "sbd", centroid="shape",
window.size = 5L)
sbd5<- 
tsclust(zscore(TSdat),seed=8L, type = "partitional", k = 5L, distance = "sbd", centroid="shape",
window.size = 5L)
sbd6<- 
tsclust(zscore(TSdat),seed=8L, type = "partitional", k = 6L, distance = "sbd", centroid="shape",
window.size = 5L)
sbd7<- 
tsclust(zscore(TSdat),seed=8L, type = "partitional", k = 7L, distance = "sbd", centroid="shape",
window.size = 5L)
sbd8<- 
tsclust(zscore(TSdat),seed=8L, type = "partitional", k = 8L, distance = "sbd", centroid="shape",
window.size = 5L)
sbd9<- 
tsclust(zscore(TSdat),seed=8L, type = "partitional", k = 9L, distance = "sbd", centroid="shape",
window.size = 5L)
sbd10<- 
tsclust(zscore(TSdat),seed=8L, type = "partitional", k = 10L, distance = "sbd", centroid="shape",
window.size = 5L)

#take first visit
library(dplyr)
visit1BLSA <- validBLSA |>
	arrange(id,visit) |>
	group_by(id) |>
	filter(visit==first(visit)) |>
	ungroup() |>
	filter(!weekday %in% c("Saturday","Sunday")) #drop weekends

#average for minute per subject across weekdays
aggWkDayBLSA <- visit1BLSA |>
	group_by(id) |>
	summarise(across(starts_with("min"),mean,na.rm=TRUE))


TSdatWk<-as.matrix(aggWkDayBLSA[,2:1441],ncol=1440,nrow=length(aggWkDayBLSA$id))

library(proxy)
#library(doParallel)
#registerDoParallel(cores = parallel::detectCores() - 1)

##lower bound approximate DTW with PAM

lbkdist<- 
proxy::dist(zscore(TSdatWk),method="lbk",window.size=5L)

dtw2w<-
tsclust(zscore(TSdatWk),type = "partitional",k = 2L, window.size=5L, distance = "dtw_lb",centroid = "pam",
control=partitional_control(pam.precompute=FALSE))
dtw3w<- 
tsclust(zscore(TSdatWk), type = "tadpole", k = 3L, window.size=5L, distance = "dtw", centroid="pam",
control=partitional_control(pam.precompute=FALSE))
dtw4w<- 
tsclust(zscore(TSdatWk), type = "tadpole", k = 4L, window.size=5L, distance = "dtw",centroid="pam",
control=partitional_control(pam.precompute=FALSE))
dtw5w<- 
tsclust(zscore(TSdatWk), type = "tadpole", k = 5L, window.size=5L, distance = "dtw",centroid="pam",
control=partitional_control(pam.precompute=FALSE))
dtw6w<- 
tsclust(zscore(TSdatWk), type = "tadpole", k = 6L, window.size=5L, distance = "dtw",centroid="pam",
control=partitional_control(pam.precompute=FALSE))
dtw7w<- 
tsclust(zscore(TSdatWk), type = "tadpole", k = 7L, window.size=5L, distance = "dtw",centroid="pam",
control=partitional_control(pam.precompute=FALSE))
dtw8w<- 
tsclust(zscore(TSdatWk), type = "tadpole", k = 8L, window.size=5L, distance = "dtw", centroid="pam",
control=partitional_control(pam.precompute=FALSE))

#euclidean distances
edc2w<- 
tsclust(zscore(TSdatWk), type = "partitional", k = 2L, window.size=20L, distance = "L2", centroid="pam")
edc3w<- 
tsclust(zscore(TSdatWk), type = "partitional", k = 3L, window.size=15L, distance = "L2", centroid="pam")
edc4w<- 
tsclust(zscore(TSdatWk), type = "partitional", k = 4L, window.size=5L, distance = "L2", centroid="pam")
edc5w<- 
tsclust(zscore(TSdatWk), type = "partitional", k = 5L, window.size=5L, distance = "L2", centroid="pam")
edc6w<- 
tsclust(zscore(TSdatWk), type = "partitional", k = 6L, window.size=5L, distance = "L2", centroid="pam")
edc7w<- 
tsclust(zscore(TSdatWk), type = "partitional", k = 7L, window.size=5L, distance = "L2", centroid="pam")
edc8w<- 
tsclust(zscore(TSdatWk), type = "partitional", k = 8L, window.size=5L, distance = "L2", centroid="pam")



#plan(multisession, workers = 2)
#shape based clustering
sbd2w<- 
tsclust(zscore(TSdatWk),seed=8L, type = "partitional", k = 2L, distance = "sbd", centroid="shape",
window.size = 5L)
sbd3w<- 
tsclust(zscore(TSdatWk),seed=8L, type = "partitional", k = 3L, distance = "sbd", centroid="shape",
window.size = 5L)
sbd4w<- 
tsclust(zscore(TSdatWk),seed=8L, type = "partitional", k = 4L, distance = "sbd", centroid="shape",
window.size = 5L)
sbd5w<- 
tsclust(zscore(TSdatWk),seed=8L, type = "partitional", k = 5L, distance = "sbd", centroid="shape",
window.size = 5L)
sbd6w<- 
tsclust(zscore(TSdatWk),seed=8L, type = "partitional", k = 6L, distance = "sbd", centroid="shape",
window.size = 5L)
sbd7w<- 
tsclust(zscore(TSdatWk),seed=8L, type = "partitional", k = 7L, distance = "sbd", centroid="shape",
window.size = 5L)
sbd8w<- 
tsclust(zscore(TSdatWk),seed=8L, type = "partitional", k = 8L, distance = "sbd", centroid="shape",
window.size = 5L)

###########################EVALUATION#############################
#####RESULTS##########
clulist<-c(
dtw2w,dtw3w,dtw4w,dtw5w,dtw6,dtw7w,dtw8w,
edc2w,edc3w,edc4w,edc5w,edc6w,edc7w,edc8w,
sbd2w,sbd3w,sbd4w,sbd5w,sbd6w,sbd7w,sbd8w)
lapply(clulist,cvi)

#####CVI##############
cvi(sbd7w,type=c("Sil","CH","DBstar"))
###############PLOTTING COMMANDS########################
plot(dtw2w,type="sc")
plot(edc2w,type="centroid")

centroids <- edc3w@centroids
df_list <- lapply(seq_along(centroids), function(i) {
  data.frame(Time = 1:length(centroids[[i]]),
             Value = centroids[[i]],
             Cluster = paste0("Cluster ", i))
})
df <- do.call(rbind, df_list)
ggplot(df, aes(x = Time, y = Value, color = Cluster)) +
  geom_line(linewidth = 1) +
  labs(title = "General Trajectory per Cluster") +
  theme_minimal()

############EXTRACT CLUSTERING ASSIGNMENTS############
#get cluster assignments
cluster_assignments <- sbd6w@cluster
#data frame with subject IDs and their clusters
cluster_df3 <- data.frame(ID = aggWkDayBLSA$id, Cluster = cluster_assignments)
write.table(cluster_df3,"sbd6clusters.csv",row.names=F, col.names=T,sep=",")




results<-load("TSclusterPP.Rdata")




