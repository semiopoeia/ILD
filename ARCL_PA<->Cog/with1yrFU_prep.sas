PROC IMPORT OUT= WORK.ACTIGRAPHYRFU 
            DATAFILE= "C:\Users\PWS5\OneDrive - University of Pittsburgh
\Desktop\SoN_Proj\Yurun\PAcog_analytic_actigraph_followupyrs.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="PAcog_analytic_actigraph_follow$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
*set formats;
proc format;
value SEXF
1='Male'
0='Female';
value AGECATF
1='50-59'
2='60-69'
3='70-79'
4='>=80';
value RACE_CATF
1='White'
2='Black'
3='Other';
value EDUGRPF
1='less than college grad'
2='college grad'
3='beyond college grad';
value BMICATF
1='Underweight or Normal'
2='Overweight'
3='Obese';
value COMORBIDCATF
0='No conditions'
1='One Condition'
2='Two Comorbities'
3='Three or more Comorbidities';
value ACTISOURCEF
0='Actiheart'
1='Actigraph';
run;

data actiB;
set ACTIGRAPHYRFU;
if sex='1.male' then sex=1;
if sex='0.female' then sex=0;
if agecat='1.50-59' then agecat=1;
if agecat='2.60-69' then agecat=2;
if agecat='3.70-79' then agecat=3;
if agecat='4.>=80' then agecat=4;
if edugrp='1.less than college graduation' then edugrp=1;
if edugrp='2.College graduation' then edugrp=2;
if edugrp='3.>=college graduation' then edugrp=3;
edugrp=strip(edugrp);
if bmicat='1.Underweight or normal' then bmicat=1;
if bmicat='2.Overweight' then bmicat=2;
if bmicat='3.Obesity' then bmicat=3;
bmicat=strip(bmicat);
if comorbidcat='0.no conditions' then comorbidcat=0;
if comorbidcat='1.1 condition' then comorbidcat=1;
if comorbidcat='2.2 comorbidities' then comorbidcat=2;
if comorbidcat='3.>=3 comorbidities' then comorbidcat=3;
comorbidcat=strip(comorbidcat);
if race_cat='1.white' then race_cat=1;
if race_cat='2.black' then race_cat=2;
if race_cat='3.other' then race_cat=3;
run;
data actiF;
set actiB;
sexN=input(sex,8.);
agecatN=input(agecat,8.);
race_catN=input(race_cat,8.);
edugrpN=input(edugrp,8.);
bmicatN=input(bmicat,8.);
comorbidcatN=input(comorbidcat,8.);
drop 
sex agecat race_cat 
edugrp bmicat comorbidcat;
rename sexN=sex; 
rename agecatN=agecat;
rename race_catN=race_cat;
rename edugrpN=edugrp;
rename bmicatN=bmicat; 
rename comorbidcatN=comorbidcat;
run;
data actiF2;
set actiF;
format
sex SEXF.
agecat AGECATF.
race_cat RACE_CATF.
edugrp EDUGRPF.
bmicat BMICATF.
comorbidcat COMORBIDCATF.;
run;
data actiF3;
set actiF2;
TRATSr=300-TRATS;
TRBTSr=300-TRBTS;
format DOV sex bmicat comorbidcat;
run;

data actiF4;
set actiF3;
count+1;
by IDNo;
if first.IDNo then count=1;
if last.IDNo then finalVisit=1;
if count=finalVisit then delete;
run;

data mpluset;
set actiF4;
keep 
IDNo
Visit
Age
BMI
PA_mse_mean
CRDRot
CVLtca
CVLfrl
DigFor
DigBac
DSSTot
MMSTot
BOSCor
CLK325
CLK1110
FLUCat
FLULet
educ_years
MCI_dement
followupyrs
sex
TRATSr
TRBTSr
;
array repvars(*)
IDNo
Visit
Age
BMI
PA_mse_mean
CRDRot
CVLtca
CVLfrl
DigFor
DigBac
DSSTot
MMSTot
BOSCor
CLK325
CLK1110
FLUCat
FLULet
educ_years
MCI_dement
followupyrs
sex
TRATSr
TRBTSr
;
   do i=1 to dim(repvars);
      if repvars[i]=. then repvars[i]=-9999;
   end;
   drop i;
run;

PROC EXPORT DATA= WORK.mpluset 
            OUTFILE= "C:\Users\PWS5\OneDrive - University of Pittsburgh\
Desktop\SoN_Proj\Yurun\ctyrActiMPLUS.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=NO;
	 run;
proc freq data=mpluset;
table followupyrs_r;
run;

