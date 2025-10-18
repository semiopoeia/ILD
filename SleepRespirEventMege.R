setwd("C:/Users/PWS5/OneDrive - University of Pittsburgh/Desktop/SleepHUB/JonnaMorris")

#set up and sort sleep events data
SleepEvent<-read.csv("SleepEvents.csv",header=T)%>%
arrange(StartDate)%>%
rename(SlpEvenType=Type)%>%
rename(SlpEventDur=Duration)
View(SleepEvent)

#set up and sort respiratory events data
RespEvent<-read.csv("RespiratoryEvents.csv",header=T)%>%
arrange(StartDate)%>%
rename(RspEvenType=Type)%>%
rename(RspEventDur=Duration)
View(RespEvent)

#full join together
SlpRspEvent<-full_join(SleepEvent,RespEvent,by="StartDate")%>%
arrange(StartDate)
View(SlpRspEvent)
SlpRspEventFill<-
SlpRspEvent%>%
arrange(StartDate)%>%
fill(SlpEvenType,.direction="down")%>%
fill(SlpEventDur,.direction="down")%>%
fill(RspEvenType,.direction="down")%>%
fill(RspEventDur,.direction="down")%>%
fill(Attribute1,.direction="down")%>%
fill(Attribute2,.direction="down")%>%
mutate(UnitElapsOverall=StartDate-first(StartDate))%>%
mutate(SI_id=1)
View(SlpRspEventFill)

