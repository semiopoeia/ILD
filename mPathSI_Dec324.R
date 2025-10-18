library(dplyr)
library(data.table)
library(readxl)
library(hms)
library(lubridate)

# load data
mpath_raw <- fread("mPath103124_fixed.csv", stringsAsFactors = F)

# Remove strange `range_computation#3`
mpath_raw_df <- mpath_raw %>%
          dplyr::select(-`range_computation#3`)

# List of IDs to exclude
exclude <- read.csv("exclude_mPath_11222024.csv", stringsAsFactors = F)

mpath_clean <- mpath_raw_df %>%
          dplyr::filter(questionListName %in% c("Morning Survey", "Afternoon Survey", "Evening Survey")) %>%
          dplyr::select(connectionId, initials, questionListName, timeStampScheduled, timeStampSent, timeStampStart, timeStampStop, timeZoneOffset,
                 # Scales and nap
                 Mood_smiley, Stress_smiley, Sleepiness_sliderNegPos, Fatigue_sliderNegPos, Nap_yesno, `Nap Length_open`,
                 # Caffeine
                 Caffeine_multipleChoice_string, `Tea Cups_open`, `Tea Time_time`, `Soda Glasses_open`, `Soda Time_time`, `Coffee Cups_open`, `Coffee Time_time`,
                 # Support questions
                 `Today Caregiving_multipleChoice_string`, `Today Work_multipleChoice_string`, `Today Emotional_multipleChoice_string`,
                 `Today Social_multipleChoice_string`, `Today Discriminated_multipleChoice_string`,
                 # Sleep
                 `Sleep Quality_sliderNegPos`, `Sleeping Pills_yesno`, `Sleeping Pills Taken_open`) %>%
          # Scheduled Times
          mutate(TimeScheduledUTC=as_datetime(timeStampScheduled)) %>%
          mutate(DateScheduled=as.Date(TimeScheduledUTC)) %>%
          mutate (TimeScheduled=hms::as_hms(TimeScheduledUTC)) %>%
          # Sent Times
          mutate(TimeSentUTC=as_datetime(timeStampSent)) %>%
          mutate(DateSent=as.Date(TimeSentUTC)) %>%
          mutate (TimeSent=hms::as_hms(TimeSentUTC)) %>%
          # Start Times
          mutate(TimeStartUTC=as_datetime(timeStampStart)) %>%
          mutate(DateStart=as.Date(TimeStartUTC)) %>%
          mutate (TimeStart=hms::as_hms(TimeStartUTC)) %>%
          # Stop Times
          mutate(TimeStopUTC=as_datetime(timeStampStop)) %>%
          mutate(DateStop=as.Date(TimeStopUTC)) %>%
          mutate (TimeStop=hms::as_hms(TimeStopUTC)) %>%
          group_by(connectionId) %>%
          arrange(connectionId, DateStop) %>%  
          mutate(ElapseDay = difftime(DateStop,first(DateStop),units="days")+1)%>%
          group_by(connectionId,DateStop) %>%
          arrange(connectionId,DateStop) %>%
          mutate(ElapseHr=round(difftime(TimeStop,first(TimeStop),units="hours"),digits=2)) %>%
          ungroup() %>%
          mutate(row_id=row_number()) %>%
          dplyr::select(row_id, connectionId, SI_id=initials, questionListName, DateStart, TimeStart, DateStop, TimeStop, ElapseDay, ElapseHr,timeZoneOffset,
                 # Scales and nap
                 Mood_smiley, Stress_smiley, Sleepiness_sliderNegPos, Fatigue_sliderNegPos, Nap_yesno, `Nap Length_open`,
                 # Caffeine
                 Caffeine_multipleChoice_string, `Tea Cups_open`, `Tea Time_time`, `Soda Glasses_open`, `Soda Time_time`, `Coffee Cups_open`, `Coffee Time_time`,
                 # Support questions
                 `Today Caregiving_multipleChoice_string`, `Today Work_multipleChoice_string`, `Today Emotional_multipleChoice_string`,
                 `Today Social_multipleChoice_string`, `Today Discriminated_multipleChoice_string`,
                 # Sleep
                 `Sleep Quality_sliderNegPos`, `Sleeping Pills_yesno`, `Sleeping Pills Taken_open`) %>%
          filter(!(row_id %in% exclude$exclude)) 

write.csv(mpath_clean, "mpath_cleaner_11272024.csv", row.names = F)

mpath_set<-mpath_clean %>%
#set ema time window
mutate(EMAtimeWindow=difftime(TimeStop,TimeStart,units="hours"))%>%
#time zone covariate
group_by(SI_id)%>%
mutate(TZcovHR=(timeZoneOffset-first(timeZoneOffset))/3600)%>%
filter(EMAtimeWindow>0 & EMAtimeWindow<=2)

#start merging to sleep image data
######bringing in SI data########
SIdat<-read_excel("Sleep Image_103124.xlsx", sheet = "Sleep Image_103124")
#set id "initials" to match to mPath
SIdat$SI_id<-SIdat$Patient_Number

demogSI<-read_excel("N2Ndemog.xlsx",sheet="N2NVariabilitySleepI_DATA_2024-")
demogSI$SI_id<-demogSI$record_id

#making unique date and matching for 1:m merge
SIdat0<- SIdat %>%
	mutate(Date=as.Date(Sleep_Conclusion)) %>%
	arrange(SI_id,Date)
SIdat1<-
merge(SIdat0,demogSI,by="SI_id",all=TRUE)

SIdatM<-
SIdat1 %>%
mutate(matchID=paste(SI_id,Date,sep="_"))


mpathM<-
mpath_set %>%
mutate(matchID=paste(SI_id,DateStart,sep="_"))
#check to conform
View(mpathM)
View(SIdatM)

#create data sets for analysis
##full join, sort time ascending
SI_mPath_fulljoin<-
	merge(SIdatM,mpathM,by="matchID",all=TRUE) %>%
	arrange(SI_id.y,DateStart,TimeStart)
View(SI_mPath_fulljoin)
write.table(SI_mPath_fulljoin,file="fulljoinSImPath.csv",sep=",",col.names=TRUE, row.names=FALSE)

##inner join, sort time ascending
SI_mPath_innerjoin<-
	merge(SIdatM,mpathM,by="matchID") %>%
	arrange(SI_id.y,DateStart,TimeStart)
View(SI_mPath_innerjoin)
write.table(SI_mPath_innerjoin,file="innerjoinSImPath.csv",sep=",",col.names=TRUE, row.names=FALSE)


####here SI is merged with Demog gives n=43, while n=44 without the merging###
