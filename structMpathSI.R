library(tidyverse)
library(readxl)
library(hms)

setwd("<<<path>>>")

mpathdat<-read_excel("mpath91024.xlsx", sheet = "in")
View(mpathdat)

mpathdat <- mpathdat[order(mpathdat$connectionId, mpathdat$timeStampSent), ]

###operating directly on integer values for time stamp####
#mpath <- mpathdat %>%
#  group_by(connectionId) %>%
#  arrange(connectionId, timeStampSent) %>%  
#  mutate(ElapseSec = (timeStampSent-first(timeStampSent))+60) %>%
#  mutate(ElapseDay=ceiling(ElapseSec/86400)) %>%
#  group_by(connectionId,ElapseDay) %>%
#  arrange(connectionId,ElapseDay) %>%
#  mutate(ElapseHR=round(((timeStampSent- first(timeStampSent))/3600),digits=0)) %>%
#  mutate(TimeSentUTC=as_datetime(timeStampSent)) 	
#View(mpath)

###operating on UTC formatted time stamp elapsing time from interaction start####
#mpath2 <- mpathdat %>%
#  mutate(TimeSentUTC=as_datetime(timeStampSent)) %>% 		
#  group_by(connectionId) %>%
#  arrange(connectionId, TimeSentUTC) %>%  
#  mutate(ElapseDay = ceiling(difftime(TimeSentUTC+60,first(TimeSentUTC),units="days"))) %>%
#  group_by(connectionId,ElapseDay) %>%
#  arrange(connectionId,ElapseDay) %>%
#  mutate(ElapseHr=round(difftime(TimeSentUTC,first(TimeSentUTC),units="hours"),digits=2))
#View(mpath2)

###formatting into a Date and Time component###
mpath3 <- mpathdat %>%
  mutate(TimeSentUTC=as_datetime(timeStampSent)) %>%
  mutate(Date=as.Date(TimeSentUTC)) %>%
  mutate (Time=hms::as_hms(TimeSentUTC)) %>% 		
  group_by(connectionId) %>%
  arrange(connectionId, Date) %>%  
  mutate(ElapseDay = difftime(Date,first(Date),units="days")+1)%>%
  group_by(connectionId,Date) %>%
  arrange(connectionId,Date) %>%
  mutate(ElapseHr=round(difftime(Time,first(Time),units="hours"),digits=2))
View(mpath3)

write.table(mpath3,file="mPath3.csv",sep=",",col.names=TRUE,row.names=FALSE)


######bringing in SI data########
#SIdat<-read_excel("SI.xlsx", sheet = "in")
#set id "initials" to match to mPath
#SIdat$initials<-SIdat$Patient_Number

###formatting to match on date and order in ascending order
SIdat1<- SIdat %>%
	mutate(Date=as.Date(Sleep_Conclusion)) %>%
	arrange(SI_id,Date)

#compare side to side
View(SIdat1)
View(mpath3)

##create a matching ID
SIdatM<-
SIdat1 %>%
mutate(matchID=paste(initials,Date,sep="_"))

mpathM<-
mpath3 %>%
mutate(matchID=paste(initials,Date,sep="_"))

View(SIdatM)
View(mpathM)

##full join, sort time ascending
SI_mPath_fulljoin<-
	merge(SIdatM,mpathM,by="matchID",all=TRUE) %>%
	arrange(matchID,Time)
View(SI_mPath_fulljoin)
write.table(SI_mPath_fulljoin,file="fulljoinSImPath.csv",sep=",",col.names=TRUE, row.names=FALSE)

##inner join, sort time ascending
SI_mPath_innerjoin<-
	merge(SIdatM,mpathM,by="matchID") %>%
	arrange(matchID,Time)
View(SI_mPath_innerjoin)
write.table(SI_mPath_innerjoin,file="innerjoinSImPath.csv",sep=",",col.names=TRUE, row.names=FALSE)

####append and merge for updated data May 22nd#####
si1<-read_excel("Sleep Image 3.1.24 to 10.31.24.xlsx")
si2<-read_excel("SIeep Image 11.1.24 to 5.1.25.xlsx")
sexid<-read_excel("sex and ID.xlsx")
sexid$Patient_Number<-sexid$`Redcap ID`
combined_si <- rbind(si1, si2[,-c(2,3)])
SI_Sex <- merge(combined_si, sexid, by = "Patient_Number")

