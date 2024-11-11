 *bring in Clinical data
import excel "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Zelazny\CSSRS_03112021.xlsx", sheet("JH_CSSRS_SMU_PSQI_SLPSCID") firstrow clear
*prepping variables
*set identifier for VisitReport (baseline divides to life time and past month)
gen VisitReport=Visit+1
replace VisitReport=0 if Visit==0 & Period=="LIFE"

label define VisRep 0"Baseline/Lifetime" 1"PM_Visit1" 2"PM_Visit2" 3"PM_Visit3" 4"PM_Visit4" 5"PM_Visit5"
label values VisitReport VisRep

*assuring ideation severity score
gen Ideation= .
replace Ideation=1 if SuicideIdeation1==1
replace Ideation=2 if SuicideIdeation2==1
replace Ideation=3 if SuicideIdeation3==1
replace Ideation=4 if SuicideIdeation4==1
replace Ideation=5 if SuicideIdeation5==1
replace Ideation=0 if SuicideIdeation1==0 & SuicideIdeation2==0 & SuicideIdeation3==0 & SuicideIdeation4==0 & SuicideIdeation5==0
*check coding
tab Ideation SuicideIdeation1  
tab Ideation SuicideIdeation2 
tab Ideation SuicideIdeation3
tab Ideation SuicideIdeation4 
tab Ideation SuicideIdeation5
*note increase zero under yes for each higher suicide ideation severity variable
*drop current variable for severity, miscoded
drop SeverityIdeation
*rename to clarify clinic report
rename Ideation Ideation_C

*self-injurious behavior
gen Behavior_C=.
replace Behavior_C=1 if EngagedInNonSuicideBeh==1
replace Behavior_C=2 if Attempt==1
replace Behavior_C=0 if EngagedInNonSuicideBeh==0 & Attempt==0
*check coding
tab Behavior_C EngagedInNonSuicideBeh
tab Behavior_C Attempt
*note zeros on off-diagonal with attempt imply coding worked

*going to save as master clinical data
save "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Zelazny\ClinicalReportMaster_CSSRS.dta",replace

*create a subset to later merge to just compare ideation and behavior reports
keep ID VisitReport CSSRSdate Ideation_C Behavior_C
rename CSSRSdate DateProxy
save "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Zelazny\ClinicIdeationBehavior.dta",replace

**bring in original EMA data sheet
import excel "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Zelazny\NEW DIARY & ACTIGRAPHY WITH DEMOGRAPHICS_JZ.xlsx", sheet("NEW DIARY & ACTIGRAPHY WITH DEM") firstrow clear

*says that acti.sleep eff. miscalculated
drop SE_AC

*create the ideation and behavior scores
gen Ideation_P=.
replace Ideation_P=1 if WishDead==1
replace Ideation_P=2 if nSI==1
replace Ideation_P=3 if SuicidalPlan==1 | SuicidalPlan==2
replace Ideation_P=4 if SuicidalIntent==1
replace Ideation_P=5 if SuicidalIntent==1 & SuicidalPlan==2
replace Ideation_P=0 if WishDead==0 & nSI==0 & SuicidalPlan==0 & SuicidalIntent==0
*check coding
tab Ideation_P WishDead
tab Ideation_P nSI
tab Ideation_P SuicidalPlan
tab Ideation_P SuicidalIntent
*good

*create behavior var
gen Behavior_P=.
replace Behavior_P=1 if nSH==1
replace Behavior_P=2 if nSB==1
replace Behavior_P=0 if nSH==0 & nSB==0
*coding was fine, but only 1 person reported an actual attempt
gen DateProxy=ACMORNINGDATE
*save as a master EMA file
save "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Zelazny\EMAMaster.dta", replace

*create sub-file for just general ideation and behavior scores from both EMA and ClinEvals
keep GROUP-AC_MISSING Ideation_P Behavior_P DateProxy AGE-NicotineDependence
save "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Zelazny\EMA_IdeationBehavior.dta",replace

*merge clinical evals with EMA
merge m:m ID DateProxy using "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Zelazny\ClinicIdeationBehavior.dta"
format DateProxy %td
save "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Zelazny\EMA_ClinicEval_comb_IdeationBehavior.dta", replace
sort ID DateProxy

*creating a month variable
gen Mth=month(DateProxy)
gen Yr=year(DateProxy)
gen MthYr = ym(Yr,Mth) 
format MthYr %tm 
replace DateProxy=DateProxy-21 if VisitReport==0
*make panel time series
tsset ID DateProxy

*create month max ideation/behavior
egen MaxIdeaMth=max(Ideation_P), by (ID MthYr)
egen MaxBehMth=max(Behavior_P), by (ID MthYr)
*create month min ideation/behavior
egen MinIdeaMth=min(Ideation_P), by (ID MthYr)
egen MinBehMth=min(Behavior_P), by (ID MthYr)
*create month mode
egen ModeIdeaMth=mode(Ideation_P), by (ID MthYr) maxmode
egen ModeBehMth=mode(Behavior_P), by (ID MthYr) maxmode
*create month median
egen MidIdeaMth=median(Ideation_P), by (ID MthYr)
egen MidBehMth=median(Behavior_P), by (ID MthYr)
*create month mean
egen MeanIdeaMth=mean(Ideation_P), by (ID MthYr)
egen MeanBehMth=mean(Behavior_P), by (ID MthYr)

*create month range
gen RangeIdeaMth=MaxIdeaMth-MinIdeaMth
gen RangeBehMth=MaxBehMth-MinBehMth
*create month standard deviation
egen SdIdeaMth=sd(Ideation_P), by (ID MthYr)
egen SdBehMth=sd(Behavior_P), by (ID MthYr)

/*
*create sub-set with matching clinical evals and EMA month summary measures
drop if Ideation_C==.
*set visit as period (to match clinical evals)
xtset ID VisitReport
sort ID VisitReport

*predict clinical eval on ideation from one lag (AR1) behind
*from max
xtologit Ideation_C L.MaxIdeaMth,or
*from mean
xtologit Ideation_C L.MeanIdeaMth,or
*from median
xtologit Ideation_C L.MidIdeaMth,or
*from mode (maximum mode)
xtologit Ideation_C L.ModeIdeaMth,or
*from range
xtologit Ideation_C L.RangeIdeaMth, or
*from stand.dev.
xtologit Ideation_C L.SdIdeaMth, or

*behavior
*from max
xtologit Behavior_C L.MaxBehMth,or
*from mean
xtologit Behavior_C L.MeanBehMth,or
*from median
xtologit Behavior_C L.MidBehMth,or
*from mode (maximum mode)
xtologit Behavior_C L.ModeBehMth,or
*from range
xtologit Behavior_C L.RangeBehMth, or
*from stand.dev.
xtologit Behavior_C L.SdBehMth, or
*/

sort ID VisitReport
by ID:gen LagMaxIdea=MaxIdeaMth[_n-1]
kap LagMaxIdea Ideation_C
by ID:gen LagMaxBeh=MaxBehMth[_n-1]
kap LagMaxBeh Behavior_C

ssc install carryforward
sort ID STUDYDAY VisitReport
gen int negdate = -DateProxy
bysort ID (negdate): carryforward Ideation_C, gen(FN_Ideation_C) back 
bysort ID (negdate): carryforward Behavior_C, gen(FN_Behavior_C) back 

bysort ID (negdate): carryforward VisitReport, gen(ReportPeriod) back

egen MaxIdeaRePer=max(Ideation_P), by (ID ReportPeriod)
egen MaxBehRePer=max(Behavior_P), by (ID ReportPeriod)


sort ID STUDYDAY VisitReport

/*check agreement with clinical assessment over past month and max report during that period from patient*/
corr MaxIdeaRePer MaxBehRePer FN_Ideation_C FN_Behavior_C

sort ID STUDYDAY VisitReport

egen misidea=rowmiss(MaxIdeaRePer FN_Ideation)

gen AgreeIdea=1 if FN_Ideation_C==MaxIdeaRePer
replace AgreeIdea=0 if FN_Ideation_C!=MaxIdeaRePer
replace AgreeIdea=. if FN_Ideation_C==. | MaxIdeaRePer==.

gen AgreeBeh=1 if FN_Behavior_C==MaxBehRePer
replace AgreeBeh=0 if FN_Behavior_C!=MaxBehRePer
replace AgreeBeh=. if FN_Behavior_C==. | MaxBehRePer==.

* create var for time between max ideation and clinical assessment
gen MaxIdeaDate=.
replace MaxIdeaDate=DateProxy if Ideation_P==MaxIdeaRePer
format MaxIdeaDate %td
replace MaxIdeaDate=MaxIdeaDate[_n-1] if missing(MaxIdeaDate)

gen ClinRepIdeaDate=.
replace ClinRepIdeaDate=DateProxy if Ideation_C!=.
format ClinRepIdeaDate %td
replace ClinRepIdeaDate=ClinRepIdeaDate[_n-1] if missing(ClinRepIdeaDate)

gen Days_Max_ClinI=ClinRepIdeaDate-MaxIdeaDate

gen maxP_C_IdeaDiff=Ideation_C-MaxIdeaRePer

gen absIdeaDiff=abs(maxP_C_IdeaDiff)

gen DirIdeaDiff=0 if maxP_C_IdeaDiff==0
replace DirIdeaDiff=-1 if maxP_C_IdeaDiff<0
replace DirIdeaDiff=1 if maxP_C_IdeaDiff>0
replace DirIdeaDiff=. if maxP_C_IdeaDiff==.
label define direction -1"Clinician UnderReports Patient Max" 0"Agreement" 1"Clinician OverReports Patient Max"
label values DirIdeaDiff direction

* create var for time between max behavior and clinical assessment
gen MaxBehDate=.
replace MaxBehDate=DateProxy if Behavior_P==MaxBehRePer
format MaxBehDate %td
replace MaxBehDate=MaxBehDate[_n-1] if missing(MaxBehDate)

gen ClinRepBehDate=.
replace ClinRepBehDate=DateProxy if Behavior_C!=.
format ClinRepBehDate %td
replace ClinRepBehDate=ClinRepBehDate[_n-1] if missing(ClinRepBehDate)

gen Days_Max_ClinB=ClinRepBehDate-MaxBehDate

gen maxP_C_BehDiff=Behavior_C-MaxBehRePer

gen absBehDiff=abs(maxP_C_BehDiff)

gen DirBehDiff=0 if maxP_C_BehDiff==0
replace DirBehDiff=-1 if maxP_C_BehDiff<0
replace DirBehDiff=1 if maxP_C_BehDiff>0
replace DirBehDiff=. if maxP_C_BehDiff==.
label values DirBehDiff direction

*save as full compiled with all EMA and Clinical Reports
save "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Zelazny\EMA_ClinRepLong.dta", replace
bysort ID ReportPeriod:gen EMAper=_N

*make a dataset matched to clinical assessment date and per month max from patient
keep if VisitReport>0 & VisitReport!=.
save "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Zelazny\MatchClinPat.dta", replace

egen wnDyadSD_IdeaDif=sd(maxP_C_IdeaDiff),by(ID)
egen wnDyadAbsM_IdeaDif=mean(absIdeaDiff),by(ID)
gen personCidea=absIdeaDiff-wnDyadAbsM_IdeaDif

gen RaceCat= .
replace RaceCat=2 if race=="Asian" 
replace RaceCat=3 if race=="Black or African American" 
replace RaceCat=4 if race=="Other Specify"        
replace RaceCat=1 if race=="White or Caucasian" 

label define racelab 1"White" 2"Asian" 3"Black" 4"Other"
label values RaceCat racelab
save "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Zelazny\MatchClinPat.dta", replace


*running models for discrepancy analysis
*Agreement on Ideation
melogit AgreeIdea Ideation_C Ideation_P,or||ID:
local Icov "Days_Max_ClinI AgeConsent GENDER i.RaceCat PSR_Depression GeneralizedAnxietyDisorder Ideation_P Ideation_C"
foreach p of local Icov{
	melogit AgreeIdea `p',or||ID:
}

*difference score ideation
mixed maxP_C_IdeaDiff Ideation_C Ideation_P||ID:
local Icov "Days_Max_ClinI AgeConsent GENDER i.RaceCat PSR_Depression GeneralizedAnxietyDisorder Ideation_P Ideation_C"
foreach p of local Icov{
	mixed maxP_C_IdeaDiff `p'||ID:
}

*absolute value ideation
mixed absIdeaDiff Ideation_C Ideation_P||ID:
local Icov "Days_Max_ClinI AgeConsent GENDER i.RaceCat PSR_Depression GeneralizedAnxietyDisorder Ideation_P Ideation_C"
foreach p of local Icov{
	mixed absIdeaDiff `p'||ID:
}

*direction ideation
mlogit DirIdeaDiff Ideation_C Ideation_P, vce(cluster ID) baseoutcome(0) rr
local Icov "Days_Max_ClinI AgeConsent GENDER i.RaceCat PSR_Depression GeneralizedAnxietyDisorder Ideation_P Ideation_C"
foreach p of local Icov{
	mlogit DirIdeaDiff `p', vce(cluster ID) baseoutcome(0) rr
}

*Agreement on Behavior
melogit AgreeBeh Behavior_C Behavior_P,or||ID:
local Bcov "Days_Max_ClinB AgeConsent GENDER i.RaceCat PSR_Depression GeneralizedAnxietyDisorder Behavior_P Behavior_C"
foreach p of local Bcov{
	melogit AgreeBeh `p',or||ID:
}

*difference score Behavior
mixed maxP_C_BehDiff Behavior_C Behavior_P||ID:
local Bcov "Days_Max_ClinB AgeConsent GENDER i.RaceCat PSR_Depression GeneralizedAnxietyDisorder Behavior_P Behavior_C"
foreach p of local Bcov{
	mixed maxP_C_BehDiff `p'||ID:
}

*absolute value behavior
mixed absBehDiff Behavior_C Behavior_P||ID:
local Bcov "Days_Max_ClinB AgeConsent GENDER i.RaceCat PSR_Depression GeneralizedAnxietyDisorder Behavior_P Behavior_C"
foreach p of local Bcov{
	mixed absBehDiff `p'||ID:
}

*direction behavior
mlogit DirBehDiff Behavior_C Behavior_P, vce(cluster ID) baseoutcome(0) rr
local Bcov "Days_Max_ClinB AgeConsent GENDER i.RaceCat PSR_Depression GeneralizedAnxietyDisorder Behavior_P Behavior_C"
foreach p of local Bcov{
	mlogit DirBehDiff `p', vce(cluster ID) baseoutcome(0) rr
}

*built out models
melogit AgreeIdea Ideation_C Ideation_P Days_Max_ClinI GeneralizedAnxietyDisorder||ID:,or

mixed absIdeaDiff Ideation_C Ideation_P GeneralizedAnxietyDisorder||ID:

mlogit DirIdeaDiff Ideation_C Ideation_P Days_Max_ClinI AgeConsent i.RaceCat PSR_Depression GeneralizedAnxietyDisorder, vce(cluster ID) baseoutcome(0) rr

melogit AgreeBeh Behavior_C GENDER i.RaceCat||ID: ,or

mixed absBehDiff Behavior_C Behavior_P ||ID:

mlogit DirBehDiff Behavior_C Behavior_P GENDER AgeConsent i.RaceCat PSR_Depression, vce(cluster ID) baseoutcome(0) rr
