*using actival set from 'grablast' syntax;

*compute years over visits elapsed to balance panels;
proc sort data=actival;
  by IDNo date;
run;
data timecounter;
  set actival;
  by IDNo;
if first.IDNo then contdays = 0;
	 else contdays = date - lag(date);
run;

data chek;
set timecounter;
keep IDNo Visit DOV date contdays;
format date;
run;
data check2;
set chek;
by IDNo;
lagday=lag(date);
if first.IDNo then daylong=0;
else daylong=date-lagday;
run;

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
Desktop\SoN_Proj\Yurun\years2CLPM.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=NO;
RUN;

