
df<-read.csv("M1016_Worksheet.07.02.csv")

#extract date from StartTime
df$Date <- as.Date(df$End.Date.and.Time, format = "%m/%d/%Y %H:%M")

#identify rows where Sleep...type starts with "Pre-night"
df$starts_pre_night <- grepl("^Pre-night", df$Sleep...type, ignore.case = TRUE)

#identify rows where Sleep...type starts with "Post-night"
df$starts_post_night <- grepl("^Post-night", df$Sleep...type, ignore.case = TRUE)

#set flag column
df$Flag <- 0

#track whether previous rows were "Pre-night" or "Post-night"
seen_pre_or_post <- FALSE
flagged_dates <- c()

for (i in seq_len(nrow(df))) {
  current_date <- df$Date[i]
  
  if (i == 1) {
    # First row should never be flagged
    seen_pre_or_post <- df$starts_pre_night[i] || df$starts_post_night[i]
    next
  }
  
  if (df$starts_pre_night[i]) {
    if (!seen_pre_or_post && !(current_date %in% flagged_dates)) {
      #flag all rows on this date that start with "Pre-night"
      rows_today <- which(df$Date == current_date & df$starts_pre_night)
      df$Flag[rows_today] <- 1
      flagged_dates <- c(flagged_dates, current_date)
    }
    seen_pre_or_post <- TRUE
  } else if (df$starts_post_night[i]) {
    seen_pre_or_post <- TRUE
  } else {
    seen_pre_or_post <- FALSE
  }

}
