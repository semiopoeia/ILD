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
run;
*bring in actigraph from excel;
PROC IMPORT OUT= WORK.actigraph 
            DATAFILE= "C:\Users\PWS5\OneDrive - University of Pittsburgh
\Desktop\SoN_Proj\Yurun\PAcog_SEM\Actigraph 2015 to 2019\PAcog_analytic_
actigraph.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="PAcog_analytic_actigraph$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
*now relabel values, and apply format;
data actigraphB;
set actigraph;
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
data actigraphF;
set actigraphB;
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
data actigraphF2;
set actigraphF;
format
sex SEXF.
agecat AGECATF.
race_cat RACE_CATF.
edugrp EDUGRPF.
bmicat BMICATF.
comorbidcat COMORBIDCATF.;
run;
*bring in n-valid to merge to last graph on id & visit;
PROC IMPORT OUT= WORK.blsa 
            DATAFILE= "C:\Users\PWS5\OneDrive - University of Pittsburgh
\Desktop\SoN_Proj\Yurun\BLSA_ACR_20210109.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;
data validay;
keep IDNo Visit n_valid_days date;
set blsa (rename=(id=IDNo visit=Visit));
run;
*merging;
proc sort data=actigraphF2;
by IDNo Visit;
run;
proc sort data=validay;
by IDNo Visit;
run;
data actigraphF3;
merge actigraphF2 validay;
by IDNo Visit;
merge actigraphF2(in=a) validay(in=b);
if a and b;
run;
data actival;
set actigraphF3;
if n_valid_days>=3;
run;

*grab the last observation in actigraph;
data lastgraph;
set actival;
by IDNo;
rec1=last.IDNo;
if rec1=1;
if MCI_dement=0;
run;

*to mplus last ob;
data mplusgraphlast;
set lastgraph;
TRATSr=300-TRATS;
TRBTSr=300-TRBTS;
keep 
IDNo 
apoe4
PA_mse_mean
CVLtca
CVLfrl
TRATSr
TRBTSr
DSSTot
DigBac
DigFor
BOSCor
FLUCat
FLULet
CRDRot
CLK325
CLK1110
Age
educ_years
white
sex
bmicat
comorbidcat
;
array repvars(*)
apoe4
PA_mse_mean
CVLtca
CVLfrl
TRATSr
TRBTSr
DSSTot
DigBac
DigFor
BOSCor
FLUCat
FLULet
CRDRot
CLK325
CLK1110
Age
educ_years
white
sex
bmicat
comorbidcat
;
   do i=1 to dim(repvars);
      if repvars[i]=. then repvars[i]=-9999;
   end;
   drop i;
   format sex bmicat comorbidcat;
run;
PROC EXPORT DATA= WORK.mplusgraphlast 
            OUTFILE= "C:\Users\PWS5\OneDrive - University of Pittsburgh\
Desktop\SoN_Proj\Yurun\lastgraph.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=NO;
RUN;

ods select MissPattern;
proc mi data=lastgraph nimpute=0;
var 
apoe4
PA_mse_mean
CVLtca
CVLfrl
TRATS
TRBTS
DSSTot
DigBac
DigFor
BOSCor
FLUCat
FLULet
CRDRot
CLK325
CLK1110
Age
educ_years
white
sex
bmicat
comorbidcat;
run;

