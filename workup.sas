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
*import actiheart; 
PROC IMPORT OUT= WORK.actiheart 
            DATAFILE= "C:\Users\PWS5\OneDrive - University of Pittsburgh
\Desktop\SoN_Proj\Yurun\PAcog_SEM\Actiheart 2009 to 2014\PAcog_analytic_
actiheart.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="PAcog_analytic_actiheart$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;
*now relabel values, and apply format;
data actiheartB;
set actiheart;
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
data actiheartF;
set actiheartB;
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
data actiheartF2;
set actiheartF;
format
sex SEXF.
agecat AGECATF.
race_cat RACE_CATF.
edugrp EDUGRPF.
bmicat BMICATF.
comorbidcat COMORBIDCATF.;
run;
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
************************************************************
*grab the first observation in each actigraph and actiheart;
proc sort data=actiheartF2;
by IDNo Visit;
run;
proc sort data=actigraphF2;
by IDNo Visit;
run;
data baseheart;
set actiheartF2;
by IDNo;
rec1=first.IDNo;
if rec1=1;
run;
data basegraph;
set actigraphF2;
by IDNo;
rec1=first.IDNo;
if rec1=1;
run;
***************************************************************
*append datasets and impute values from one to the other;
data comb_actigraph_actiheart;
set actiheartf2 actigraphf2;
if SourceID='ACTIHEART' then ActiMeth=0;
if SourceID='ACTIGRAPH' then ActiMeth=1;
format
ActiMeth ACTISOURCEF.;
run;

proc sort data=comb_actigraph_actiheart;
by IDNo Visit;
run;

*carry one forward;
data comb_graph_heart;
set comb_actigraph_actiheart;
by IDNo;
retain previous_value;
if first.IDNo then do;
previous_value=.;
end;
if missing(apoe4) then do;
apoe4=previous_value;
end;
previous_value=apoe4;
drop previous_value;
run;

proc sort data=comb_graph_heart;
by IDNo Visit;
run;

proc freq data=comb_graph_heart;
table Visit;run;

