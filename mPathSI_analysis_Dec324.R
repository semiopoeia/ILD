#plays off mPathSI_Dec324 script
##Aim 1: diagnostic accuracy single vs. mulitple nights##
#create variable based on average sAHI
#classifying Non(<5),Mild(5<=ahi<15),Moderate(15<=ahi<30),Severe(>=30)
cuts<-c(0,5,15,30,Inf)
cats<-c("NoOSA","Mild","Moderate","Severe")
SIahi<-SIdat1%>%
	group_by(SI_id)%>%
	mutate(AHI4ave=mean(`sAHI_4%`,na.rm=TRUE))%>%
	mutate(AHI3ave=mean(`sAHI_3%`,na.rm=TRUE))%>%
	mutate(validn=n())%>%
	filter(validn>=13)%>%
	mutate(AHI4cat=cut(AHI4ave,breaks=cuts,labels=cats,ordered_result=T))%>%
	mutate(AHI3cat=cut(AHI3ave,breaks=cuts,labels=cats,ordered_result=T))%>%
	mutate(StudyDays=row_number())%>%
	arrange(SI_id,StudyDays)%>%
	dplyr::select(SI_id, birthsex,validn,StudyDays,Date,Timezone,`sAHI_3%`,`sAHI_4%`,AHI4ave,AHI4cat,AHI3ave,AHI3cat)%>%
	pivot_wider(
	id_cols=c(SI_id,AHI3ave,AHI3cat,AHI4ave,AHI4cat,validn,birthsex),
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
	mutate(n12ave_cat4=cut(n12ave4,breaks=cuts,labels=cats,ordered_result=T))



t<-table(SIahi$n12ave_cat4,SIahi$AHI4cat,SIahi$birthsex)
round(prop.table(t[,,2],margin=2),digits=3)
sum(diag(t[,,2]))/sum(t[,,2])
t[,,2]
	
write.table(SIahi,"SIahi.csv",sep=",",row.names=F)
View(SIahi)

###Aim2:Sleep and EMA#####
#Sleep#
#SQI
#`sAHI_3%`
#`sAHI_4%`
#EMA#
#Mood_smiley                              
#Stress_smiley                            
#Sleepiness_sliderNegPos                  
#Fatigue_sliderNegPos
table(SIahi$birthsex)

x<-
SIdat1%>%
group_by(SI_id)
View(SIdat1)