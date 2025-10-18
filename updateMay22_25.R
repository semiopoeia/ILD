setwd("<<<path>>>")
####append and merge for updated data May 22nd#####
si1<-read_excel("Sleep Image 3.1.24 to 10.31.24.xlsx")
si2<-read_excel("SIeep Image 11.1.24 to 5.1.25.xlsx")
sexid<-read_excel("sex and ID.xlsx")
sexid$Patient_Number<-sexid$`Redcap ID`
combined_si <- rbind(si1, si2[,-c(2,3)])
SI_Sex <- merge(combined_si, sexid, by = "Patient_Number")

#create variable based on average sAHI
#classifying Non(<5),Mild(5<=ahi<15),Moderate(15<=ahi<30),Severe(>=30)
cuts<-c(0,5,15,30,Inf)
cats<-c("NoOSA","Mild","Moderate","Severe")
SIahi<-SI_Sex%>%
	group_by(Patient_Number)%>%
	mutate(AHI4ave=mean(`sAHI_4%`,na.rm=TRUE))%>%
	mutate(AHI3ave=mean(`sAHI_3%`,na.rm=TRUE))%>%
	mutate(validn=n())%>%
	filter(validn>=13)%>%
	mutate(AHI4cat=cut(AHI4ave,breaks=cuts,labels=cats,ordered_result=T))%>%
	mutate(AHI3cat=cut(AHI3ave,breaks=cuts,labels=cats,ordered_result=T))%>%
	mutate(StudyDays=row_number())%>%
	arrange(Patient_Number,StudyDays)%>%
	dplyr::select(Patient_Number, `Birth Sex`,validn,StudyDays,Start_Date,Timezone,`sAHI_3%`,`sAHI_4%`,AHI4ave,AHI4cat,AHI3ave,AHI3cat)%>%
	pivot_wider(
	id_cols=c(Patient_Number,AHI3ave,AHI3cat,AHI4ave,AHI4cat,validn,`Birth Sex`),
	names_from=StudyDays,
	values_from=c(`sAHI_3%`,`sAHI_4%`))%>%
	mutate(n3ave3=mean(c(`sAHI_3%_1`,`sAHI_3%_2`,`sAHI_3%_3`),na.rm=T))%>%
	mutate(n7ave3=mean(c(
	`sAHI_3%_1`,`sAHI_3%_2`,`sAHI_3%_3`,`sAHI_3%_4`,`sAHI_3%_5`,`sAHI_3%_6`,`sAHI_3%_7`)
	,na.rm=T))%>%
	mutate(n12ave3=mean(c(
	`sAHI_3%_1`,`sAHI_3%_2`,`sAHI_3%_3`,`sAHI_3%_4`,`sAHI_3%_5`,`sAHI_3%_6`,`sAHI_3%_7`,
	`sAHI_3%_8`,`sAHI_3%_9`,`sAHI_3%_10`,`sAHI_3%_11`,`sAHI_3%_12`)
	,na.rm=T))%>%
	mutate(n3ave4=mean(c(`sAHI_4%_1`,`sAHI_4%_2`,`sAHI_4%_3`),na.rm=T))%>%
	mutate(n7ave4=mean(c(
	`sAHI_4%_1`,`sAHI_4%_2`,`sAHI_4%_3`,`sAHI_4%_4`,`sAHI_4%_5`,`sAHI_4%_6`,`sAHI_4%_7`)
	,na.rm=T))%>%
	mutate(n12ave4=mean(c(
	`sAHI_4%_1`,`sAHI_4%_2`,`sAHI_4%_3`,`sAHI_4%_4`,`sAHI_4%_5`,`sAHI_4%_6`,`sAHI_4%_7`,
	`sAHI_4%_8`,`sAHI_4%_9`,`sAHI_4%_10`,`sAHI_4%_11`,`sAHI_4%_12`)
	,na.rm=T))%>%
	mutate(n1_cat3=cut(`sAHI_3%_1`,breaks=cuts,labels=cats,ordered_result=T))%>%
	mutate(n1_cat4=cut(`sAHI_4%_1`,breaks=cuts,labels=cats,ordered_result=T))%>%
	mutate(n3ave_cat3=cut(n3ave3,breaks=cuts,labels=cats,ordered_result=T))%>%
	mutate(n3ave_cat4=cut(n3ave4,breaks=cuts,labels=cats,ordered_result=T))%>%
	mutate(n7ave_cat3=cut(n7ave3,breaks=cuts,labels=cats,ordered_result=T))%>%
	mutate(n7ave_cat4=cut(n7ave4,breaks=cuts,labels=cats,ordered_result=T))%>%
	mutate(n12ave_cat3=cut(n12ave3,breaks=cuts,labels=cats,ordered_result=T))%>%
	mutate(n12ave_cat4=cut(n12ave4,breaks=cuts,labels=cats,ordered_result=T))%>%
      filter(AHI4cat!="NoOSA")

SIahiM<-filter(SIahi,`Birth Sex`=="Male")

critdiag<-c(SIahiM$n1_cat3,SIahiM$n1_cat4,SIahiM$n3ave_cat3,SIahiM$n3ave_cat4,
		SIahiM$n7ave_cat3,SIahiM$n7ave_cat4,SIahiM$n12ave_cat3,SIahiM$n12ave_cat4)

critdiag_vars <- c("n1_cat3", "n1_cat4", "n3ave_cat3", "n3ave_cat4",
                   "n7ave_cat3", "n7ave_cat4", "n12ave_cat3", "n12ave_cat4")
odd_indices <- seq_along(critdiag_vars)[seq_along(critdiag_vars) %% 2 == 1]
even_indices <- seq_along(critdiag_vars)[seq_along(critdiag_vars) %% 2 == 0]

critdiag_vars3 <- critdiag_vars[odd_indices]
critdiag_vars4 <- critdiag_vars[even_indices]
	
cross_tabs <- list()

for (var in critdiag_vars3) {
  temp_df <- data.frame(
    critdiag = SIahiM[[var]],
    AHI3cat = SIahiM$AHI3cat,
    source = var  # to keep track of which variable this came from
  )
  
  # Create the cross-tab
  tab <- table(temp_df$critdiag, temp_df$AHI3cat)
  
  # Convert to data frame and add a column for the variable name
  tab_df <- as.data.frame.matrix(tab)
  tab_df$critdiag_level <- rownames(tab_df)
  tab_df$source <- var
  
  # Store in the list
  cross_tabs[[var]] <- tab_df
}
final_table3 <- do.call(rbind, cross_tabs)

cross_tabs <- list()

for (var in critdiag_vars4) {
  temp_df <- data.frame(
    critdiag = SIahiM[[var]],
    AHI4cat = SIahiM$AHI4cat,
    source = var  # to keep track of which variable this came from
  )
  
  # Create the cross-tab
  tab <- table(temp_df$critdiag, temp_df$AHI4cat)
  
  # Convert to data frame and add a column for the variable name
  tab_df <- as.data.frame.matrix(tab)
  tab_df$critdiag_level <- rownames(tab_df)
  tab_df$source <- var
  
  # Store in the list
  cross_tabs[[var]] <- tab_df
}
final_table4 <- do.call(rbind, cross_tabs)

final_table<-rbind(final_table3,final_table4)

write.table(final_table,"MaleTableMay22_25.csv",sep=",",row.names=F)
