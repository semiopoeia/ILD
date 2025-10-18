PROC IMPORT OUT= WORK.NEWFILE1 
            DATAFILE= "C:\Users\SHHS_SymptomProgression_CVD_02212022.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
proc freq data=newfile1;
table Include_ahi_symp_cv;run;
proc means data=newfile1 mean std clm;
class Include_ahi_symp_cv;
var age_s1 bmi_s1 ahi_a0h4_s1;run;
proc ttest data=newfile1;
class Include_ahi_symp_cv;
var age_s1 bmi_s1 ahi_a0h4_s1;run;
proc freq data=newfile1;
table Include_ahi_symp_cv*(gender race_s1 ethnicity_s1)
/chisq;
run;

data newfile;
set newfile1;
if Include_ahi_symp_cv="FALSE" then delete;
run;
*effectively forcing no-OSA out of respective analyses;
data osa1;
set newfile;
if osa_category_s1=2;run;
proc lca 
data=osa1
outpost=postprob
outest=paramest
;
NCLASS 4; 
ITEMS 
rested12_s1 sleepyday12_s1 phystired12_s1 sleepinvol12_s1 sleeptv12_s1 _pper12_s1 nose12_s1 
doze12_s1 dis12_s1 ema12_s1 dms12_s1 cantbreathe12_s1 snore12_s1 ess_cat_s1
; 
CATEGORIES
2 2 2 2 2 2 2 2 2 2 2 2 2 4; 
ID nsrrid;
CORES 16;
SEED 8675309;
RUN;
data status1;
set postprob;
LS1=BEST;
run;
data osa2;
set newfile;
if osa_category_s2=2;run;
proc lca 
data=osa2
outpost=postprob
outest=paramest
;
NCLASS 4; 
ITEMS 
rested12_s2 sleepyday12_s2 phystired12_s2 sleepinvol12_s2 sleeptv12_s2 _pper12_s2 nose12_s2 
doze12_s2 dis12_s2 ema12_s2 dms12_s2 cantbreathe12_s2 snore12_s2 ess_cat_s2
; 
CATEGORIES
2 2 2 2 2 2 2 2 2 2 2 2 2 4; 
ID nsrrid;
CORES 16;
SEED 8675309;
RUN;
data status2;
set postprob;
LS2=BEST;
run;

proc sort data=newfile;
by nsrrid;
run;
proc sort data=status1;
by nsrrid;
run;
proc sort data=status2;
by nsrrid;
run;
data together;
merge newfile status1;
by nsrrid; run;
data together2;
merge together status2;
by nsrrid; run;

data together3;
set together2;
if osa_category_s1=1 then LS1=5;
if osa_category_s2=1 then LS2=5;
LT12=cats(LS1,LS2);
if LS1='.' | LS2='.' then delete;
run;
proc format;
value OSAcLab
1="Disturbed"
2="Excessive"
3="Moderate"
4="Minimal"
5="No_OSA"; run;
data together3;
set together3;
FORMAT LS1 OSAcLab. LS2 OSAcLab.;
run;
proc freq data=together3;
table LS1*LS2;run;
data ready;
set together3;
if COPD_s1="No" then copd1=0;
if COPD_s1="Ye" then copd1=1;
if dm01_s1="No" then dm1=0;
if dm01_s1="Yes" then dm1=1;
if htn01_s1="No" then htn1=0;
if htn01_s1="Yes" then htn1=1;
bmi5=bmi_s1/5;
bmi5_2=bmi_s2/5;
ahi10=ahi_a0h4_s1/10;
ahi10_2=ahi_a0h4_s2/10;
age5=age_s1/5;
dbmi=bmi5_2-bmi5;
dahi=ahi10_2-ahi10;
dpct=pctlt90_s2 -pctlt90_s1;
dslptime=slptime_s2-slptime_s1;
dslpeff=slpeffp_s2-slpeffp_s1;
dslpatp=slplatp_s2-slplatp_s1;
dtimestlp=timest1p_s2-timest1p_s1;
dtimest2p=timest2p_s2 -timest2p_s1;
dtimes34p=times34p_s2- times34p_s1;
drimeremp=timeremp_s2 -timeremp_s1;
dai_all=ai_all_s2 -ai_all_s1;
run;

proc means data=ready;
var age_s1 bmi_s1 ahi_a0h4_s1 hdl_s1 chol_s1
trig_s1 slptime_s1; run;

proc freq data=ready;
table LS1*LS2/ norow nocol; run;

data ready1;
set ready;
if LS1=1;run;
data ready2;
set ready;
if LS1=2;run;
data ready3;
set ready;
if LS1=3;run;
data ready4;
set ready;
if LS1=4;run;
data ready5;
set ready;
if LS1=5;run;

proc freq data=ready;
table gender*LS1*LS2/
nocol nocum nopercent norow;
run;

data ready1_osa;
set ready1;
if LS2^=5;
run;

data ready2_osa;
set ready2;
if LS2^=5;
run;

data ready3_osa;
set ready3;
if LS2^=5;
run;

data ready4_osa;
set ready4;
if LS2^=5;
run;


data ready2_osa_nomin2;
set ready2_osa;
if LS2^=4;
run;


data ready2_osa_min;
set ready2_osa;
if LS2=4 or LS2=2;
run;

data ready1_nosa;
set ready1;
if LS2=5 or LS2=1;
run;

data ready2_nosa;
set ready2;
if LS2=5 or LS2=2;
run;

data ready3_nosa;
set ready3;
if LS2=5 or LS2=3;
run;

data ready4_nosa;
set ready4;
if LS2=5 or LS2=4;
run;

ods pdf file="C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SleepHUB\JonnaMorris\outsMay5th23.pdf";
proc freq data=ready;
table LS1*LS2/chisq agree;
run;

proc freq data=ready;
tables LS1*(gender race_s1 ethnicity_s1) 
LS2*(gender race_s1 ethnicity_s1)/chisq;
run;

proc means data=ready mean std clm min p25 median p75 max;
*class LS1;
var ahi_a0h4_s1;run;

proc means data=ready mean std clm;
class LS2;
var age_s1 bmi_s1 ahi_a0h4_s1;run;
ods pdf close;

data checker;
set Newfile1;
years=days_s2/365;
run;

proc means data=checker;
var years;run;

proc sgplot data=ready;
    vbox ahi_a0h4_s1 / category=LS1;
run;

data groupOSA;
set ready;
if ahi_a0h4_s1<5 then OSAcat4_s1=1;
if ((ahi_a0h4_s1>=5) & (ahi_a0h4_s1<15)) then OSAcat4_s1=2;
if ((ahi_a0h4_s1>=15) & (ahi_a0h4_s1<30)) then OSAcat4_s1=3;
if ahi_a0h4_s1>=30 then OSAcat4_s1=4;
if ahi_a0h4_s2<5 then OSAcat4_s2=1;
if ((ahi_a0h4_s2>=5) & (ahi_a0h4_s2<15)) then OSAcat4_s2=2;
if ((ahi_a0h4_s2>=15) & (ahi_a0h4_s2<30)) then OSAcat4_s2=3;
if ahi_a0h4_s2>=30 then OSAcat4_s2=4;
run;

proc freq data=groupOSA;
tables OSAcat4_s1 OSAcat4_s2;
run;

