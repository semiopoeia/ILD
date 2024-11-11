library(tidyverse)
library(readxl)
library(hms)

setwd("C:/Users/PWS5/")

mpathdat<-read_excel("mpathMaskFake.xlsx", sheet = "in")
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
SIdat<-read_excel("SIFakeMask.xlsx", sheet = "in")
#set id "initials" to match to mPath
SIdat$initials<-SIdat$Patient_Number

###formatting to match on date and order in ascending order
SIdat1<- SIdat %>%
	mutate(Date=as.Date(Sleep_Conclusion)) %>%
	arrange(initials,Date)

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

