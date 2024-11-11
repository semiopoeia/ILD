#install.packages("MplusAutomation",dep=T)
library(MplusAutomation)
setwd("C:/Users/PWS5/OneDrive - University of Pittsburgh/Desktop/SoN_Proj/Yurun/ModFile")

#loop over Mplus input files in given folder
runModels(
  "C:/Users/PWS5/OneDrive - University of Pittsburgh/Desktop/SoN_Proj/Yurun/ModFile",
  recursive=TRUE,
  logFile="C:/Users/PWS5/OneDrive - University of Pittsburgh/Desktop/SoN_Proj/Yurun/ModFilLog.txt")

ModParams <- readModels(target="genmodel2.out")
#keeps giving error
# Read the file

lines <- readLines("genmodel1.out")
match<-grep("STDYX",lines,value=TRUE)

