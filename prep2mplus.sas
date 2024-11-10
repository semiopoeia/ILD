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

*make to mplus;
libname cai "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Yurun";
run;
proc sort data=cai.combine_actigraph_heart_1;
by IDNo Visit;
run;
data mplus21;
set cai.combine_actigraph_heart_1;
by IDNo;
rec1=first.IDNo;
if rec1=1;
keep 
IDNo 
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
CLK1110;
array repvars(*)
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
CLK1110;
   do i=1 to dim(repvars);
      if repvars[i]=. then repvars[i]=-9999;
   end;
   drop i;
run;

proc corr data=cai.combine_actigraph_heart_1;
var 
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
;
run;


PROC EXPORT DATA= WORK.MPLUS21 
            OUTFILE= "C:\Users\PWS5\OneDrive - University of Pittsburgh\
Desktop\SoN_Proj\Yurun\ACTIMPLUS1.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=NO;
RUN;
