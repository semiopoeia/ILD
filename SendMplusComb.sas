proc reg data=base;
model PA_mse_mean= black raceother;
run;
*apply reverse codes for seconds to complete under EF (TRATS and TRBTS);
proc means data=comb_graph_heart;
var TRATS TRBTS;
run;
proc sort data=comb_graph_heart;
by ACTIMETH; run;
proc corr data=comb_graph_heart;
by ACTIMETH;
var PA_mse_mean age white black raceother sex;
run;

data comb_graph_heart2;
set comb_graph_heart;
TRATSr=300-TRATS;
TRBTSr=300-TRBTS;
if ActiMeth=0 then delete;
run;
*to MPLUS combined;
proc sort data=comb_graph_heart2;
by IDNo Visit;
run;
data comb_graph_heart3;
set comb_graph_heart2;
count+1;
by IDNo;
if first.IDNo then count=1;
if last.IDNo then finalVisit=1;
if count=finalVisit then delete;
run;
data mpluset;
set comb_graph_heart3;
keep 
IDNo
Visit
DOV
Age
white
black
raceother
sex
BMI
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
ActiMeth;
array repvars(*)
IDNo
Visit
DOV
Age
white
black
raceother
sex
BMI
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
ActiMeth;
   do i=1 to dim(repvars);
      if repvars[i]=. then repvars[i]=-9999;
   end;
   drop i;
   format DOV ActiMeth sex;
run;

PROC EXPORT DATA= WORK.mpluset 
            OUTFILE= "C:\Users\PWS5\OneDrive - University of Pittsburgh\
Desktop\SoN_Proj\Yurun\CombActiMPLUS.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=NO;
RUN;

data mplusGet;
set mpluset;
if ActiMeth=0 then delete;
run;

PROC EXPORT DATA= WORK.mpluset 
            OUTFILE= "C:\Users\PWS5\OneDrive - University of Pittsburgh\
Desktop\SoN_Proj\Yurun\GraphLongMPLUS.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=NO;


proc sort data=mpluset;
by IDNo Visit;
run;
data base;
set mpluset;
by IDNo;
rec1=first.IDNo;
if rec1=1;
drop rec1;
run;

PROC EXPORT DATA= WORK.base 
            OUTFILE= "C:\Users\PWS5\OneDrive - University of Pittsburgh\
Desktop\SoN_Proj\Yurun\BaseActiMPLUS.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=NO;
RUN;

