setwd("C:/Users/PWS5/OneDrive - University of Pittsburgh/Desktop/SoN_Proj/Yurun/ModFile/")

dat<-read.table("specfactorscores_graphlast.dat",header=F)
dat2<-read.table("genfactorscores_graphlast.dat",header=F)

##########################Note: following code will not format as numeric when * is used to demark missing value
#install.packages("readr")
#install.packages("dplyr")
library(readr)
library(dplyr)

# Define the format codes, column widths, and varnames for each column
format_codes <-c((rep(F10.3,29)),I5)
wz<-c(rep(10,29),5)

# Read the Fortran data table with format codes
data <- read.fwf(
"specfactorscores_graphlast.dat", 
widths = wz, 
col.names = labs, 
colClasses = format_codes)
######################################################################################

write.csv(dat, file = "specFactorScores.csv")
write.csv(dat2, file = "genFactorScores.csv")
