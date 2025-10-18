library(dplyr)
library(data.table)
library(readxl)
library(hms)
library(lubridate)

# load data
mpath_raw <- fread("mPath_103124_fixed.csv", stringsAsFactors = F)

# Remove strange `range_computation#3`
mpath_raw_df <- mpath_raw %>%
          select(-`range_computation#3`)

# List of IDs to exclude
exclude <- read.csv("exclude_mPath_11222024.csv", stringsAsFactors = F)

mpath_clean <- mpath_raw_df %>%
          dplyr::filter(questionListName %in% c("Morning Survey", "Afternoon Survey", "Evening Survey")) %>%
          select(connectionId, initials, questionListName, timeStampScheduled, timeStampSent, timeStampStart, timeStampStop, timeZoneOffset,
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
          select(row_id, connectionId, SI_id=initials, questionListName, DateStart, TimeStart, DateStop, TimeStop, ElapseDay, ElapseHr,timeZoneOffset,
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

## To do:
# Define which EMA observations fell in window
# Create Time Zone covariate

