*set from "workup" program;
proc sort data=actigraphF2;
by IDNo Visit;
run;

data grapheart;
  set actigraphF2;
  occasion + 1;
  by IDNo;
  if first.IDNo then occasion = 1;
  TRATSr=300-TRATS;
  TRBTSr=300-TRBTS;
  format ActiMeth;
run;

proc freq data=grapheart;
table Visit*occasion;run;

proc transpose data=grapheart out=pa_wide 
prefix= PA;
    by IDNo ;
    id occasion;
    var PA_mse_mean;
run;
proc sort data=pa_wide;
by IDNo;
run;
data pa_wide;set pa_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=cvlt_wide 
prefix= CVLtca;
    by IDNo ;
    id occasion;
    var CVLtca;
run;
proc sort data=cvlt_wide;
by IDNo;
run;
data cvlt_wide;set cvlt_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=cvlf_wide 
prefix= CVLfrl;
    by IDNo ;
    id occasion;
    var CVLfrl;
run;
proc sort data=cvlf_wide;
by IDNo;
run;
data cvlf_wide;set cvlf_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=trats_wide 
prefix= TRA;
    by IDNo ;
    id occasion;
    var TRATSr;
run;
proc sort data=trats_wide;
by IDNo;
run;
data trats_wide;set trats_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=trbts_wide 
prefix= TRB;
    by IDNo ;
    id occasion;
    var TRBTSr;
run;
proc sort data=trbts_wide;
by IDNo;
run;
data trbts_wide;set trbts_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=dss_wide 
prefix= DSS;
    by IDNo ;
    id occasion;
    var DSSTot;
run;
proc sort data=dss_wide;
by IDNo;
run;
data dss_wide;set dss_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=digb_wide 
prefix= DIGB;
    by IDNo ;
    id occasion;
    var DigBac;
run;
proc sort data=digb_wide;
by IDNo;
run;
data digb_wide;set digb_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=digf_wide 
prefix= DIGF;
    by IDNo ;
    id occasion;
    var DigFor;
run;
proc sort data=digf_wide;
by IDNo;
run;
data digf_wide;set digf_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=bosc_wide 
prefix= BOS;
    by IDNo ;
    id occasion;
    var BOSCor;
run;
proc sort data=bosc_wide;
by IDNo;
run;
data bosc_wide;set bosc_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=fluc_wide 
prefix= FLUC;
    by IDNo ;
    id occasion;
    var FLUCat;
run;
proc sort data=fluc_wide;
by IDNo;
run;
data fluc_wide;set fluc_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=flulet_wide 
prefix= FLUL;
    by IDNo ;
    id occasion;
    var FLULet;
run;
proc sort data=flulet_wide;
by IDNo;
run;
data flulet_wide;set flulet_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=CRDRot_wide 
prefix= CRD;
    by IDNo ;
    id occasion;
    var CRDRot;
run;
proc sort data=CRDRot_wide;
by IDNo;
run;
data CRDRot_wide;set CRDRot_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=clk3_wide 
prefix= CLK3;
    by IDNo ;
    id occasion;
    var CLK325;
run;
proc sort data=clk3_wide;
by IDNo;
run;
data clk3_wide;set clk3_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=clk11_wide 
prefix= CLK11;
    by IDNo ;
    id occasion;
    var CLK1110;
run;
proc sort data=clk11_wide;
by IDNo;
run;
data clk11_wide;set clk11_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=meth_wide 
prefix= ACTI;
    by IDNo ;
    id occasion;
    var ActiMeth;
run;
proc sort data=meth_wide;
by IDNo;
run;
data meth_wide;set meth_wide;
drop _NAME_ _LABEL_;run;

proc transpose data=grapheart out=age_wide 
prefix= AGE;
    by IDNo ;
    id occasion;
    var Age;
run;
proc sort data=age_wide;
by IDNo;
run;
data age_wide;set age_wide;
drop _NAME_ _LABEL_;run;

data wide_comb_ready;
merge
pa_wide
cvlt_wide cvlf_wide
trats_wide trbts_wide digb_wide digf_wide dss_wide
bosc_wide fluc_wide flulet_wide
clk11_wide clk3_wide crdrot_wide
meth_wide age_wide
;
by IDNo;
run;
**data is now set in wide format prepared for LGCM analysis;

/*PA_mse_mean CVLtca CVLfrl TRATSr TRBTSr
DSSTot DigBac DigFor BOSCor
FLUCat FLULet CRDRot CLK325 CLK1110 ActiMeth

*/

*linear model for pa, fits ok with 5 time points;
proc calis method=mlr data=wide_comb_ready;   
   lineqs
      PA1 = 0. * Intercept +  f_palpha                 + e1,
      PA2 = 0. * Intercept +  f_palpha  +  1 * f_pbeta + e2,
      PA3 = 0. * Intercept +  f_palpha  +  2 * f_pbeta + e3,
      PA4 = 0. * Intercept +  f_palpha  +  3 * f_pbeta + e4;
*  PA5 = 0. * Intercept +  f_palpha  +  4 * f_pbeta  +e5;
*	  PA6 = 0. * Intercept + f_palpha  +  5 * f_pbeta  +e6,
*	  PA7 = 0. * Intercept + f_palpha  +  6 * f_pbeta + e7,
*      PA8 = 0. * Intercept + f_palpha  +  7 * f_pbeta + e8,
*	  PA9 = 0. * Intercept + f_palpha  +  8 * f_pbeta + e9;
   variance
      f_palpha f_pbeta,
      e1-e4;
   mean
      f_palpha f_pbeta;
   cov
      f_palpha f_pbeta;
   fitindex on=all;
run;


*unstructured curve with 5 time points 
indicates ceiling where slope betas top off (l3 and l4 round to 3)
also note strong negative correlation between intercept and slope;
proc calis method=fiml data=wide_comb_ready;   
   lineqs
      PA1 = 0. * Intercept +  f_palpha                 + e1,
      PA2 = 0. * Intercept +  f_palpha  +  1 * f_pbeta + e2,
      PA3 = 0. * Intercept +  f_palpha  +  l2 * f_pbeta + e3,
      PA4 = 0. * Intercept +  f_palpha  +  l3 * f_pbeta + e4,
      PA5 = 0. * Intercept +  f_palpha  +  l4 * f_pbeta  +e5;
*	  PA6 = 0. * Intercept + f_palpha  +  5 * f_pbeta  +e6,
*	  PA7 = 0. * Intercept + f_palpha  +  6 * f_pbeta + e7,
*      PA8 = 0. * Intercept + f_palpha  +  7 * f_pbeta + e8,
*	  PA9 = 0. * Intercept + f_palpha  +  8 * f_pbeta + e9;
   variance
      f_palpha f_pbeta,
      e1-e5;
   mean
      f_palpha f_pbeta;
   cov
      f_palpha f_pbeta;
   fitindex on=all;
run;

*quadratic (for ceiling) has nice fit with 5 time points;
proc calis method=fiml data=wide_comb_ready plots=pathdiagram;   
   lineqs
      PA1 = 0. * Intercept +  f_palpha                 + e1,
      PA2 = 0. * Intercept +  f_palpha  +  1 * f_pbeta + 1 * f_qpbeta + e2,
      PA3 = 0. * Intercept +  f_palpha  +  2 * f_pbeta + 4 * f_qpbeta + e3,
      PA4 = 0. * Intercept +  f_palpha  +  3 * f_pbeta + 9 * f_qpbeta + e4,
      PA5 = 0. * Intercept +  f_palpha  +  4 * f_pbeta + 16 * f_qpbeta +e5;
*	  PA6 = 0. * Intercept + f_palpha  +  5 * f_pbeta + 25 * f_qpbeta +e6,
*	  PA7 = 0. * Intercept + f_palpha  +  6 * f_pbeta + e7,
*      PA8 = 0. * Intercept + f_palpha  +  7 * f_pbeta + e8,
*	  PA9 = 0. * Intercept + f_palpha  +  8 * f_pbeta + e9;
   variance
      f_palpha f_pbeta f_qpbeta,
      e1-e5;
   mean
      f_palpha f_pbeta f_qpbeta;
   cov
      f_palpha f_pbeta f_qpbeta;
   fitindex on=all;
run;
/*incorporating tvc are proving problematic in sas;
proc calis method=ml data=wide_comb_ready plots=pathdiagram;   
   lineqs
      PA1 = 0. * Intercept +  bg1*AGE1+ f_palpha                + e1,
      PA2 = 0. * Intercept +  bg2*AGE2 + f_palpha  +  1 * f_pbeta + 1 * f_qpbeta  + e2,
      PA3 = 0. * Intercept +  bg3*AGE3 + f_palpha  +  2 * f_pbeta + 4 * f_qpbeta  + e3,
      PA4 = 0. * Intercept +  bg4*AGE4 + f_palpha  +  3 * f_pbeta + 9 * f_qpbeta  + e4,
      PA5 = 0. * Intercept +  bg5*AGE5 + f_palpha  +  4 * f_pbeta + 16 * f_qpbeta  + e5;
         variance
       f_palpha f_pbeta f_qpbeta,
      e1-e5;
mean
       f_palpha f_pbeta f_qpbeta;
   cov
        f_palpha f_pbeta f_qpbeta,
AGE1 AGE2 =0,
AGE1 AGE3=0,
AGE1 AGE4=0,
AGE1 AGE5=0,
AGE2 AGE3=0,
AGE2 AGE4=0,
AGE2 AGE5=0,
AGE3 AGE4=0,
AGE3 AGE5=0,
AGE4 AGE5=0,
AGE1 f_palpha=0, 
AGE2 f_palpha=0,
AGE3 f_palpha=0,
AGE4 f_palpha=0,
AGE5 f_palpha=0,
AGE1 f_pbeta=0, 
AGE2 f_pbeta=0,
AGE3 f_pbeta=0,
AGE4 f_pbeta=0,
AGE5 f_pbeta=0,
AGE1 f_qpbeta=0, 
AGE2 f_qpbeta=0,
AGE3 f_qpbeta=0,
AGE4 f_qpbeta=0,
AGE5 f_qpbeta=0;
   fitindex on=all;
run;
*/

*send to MPLUS;
data mplusLGCM;
set wide_comb_ready;
	array num_array _numeric_;
	do over num_array;
		if missing(num_array) then num_array = -9999;
	end;
run;
PROC EXPORT DATA= WORK.mplusLGCM 
            OUTFILE= "C:\Users\PWS5\OneDrive - University of Pittsburgh\
Desktop\SoN_Proj\Yurun\LGCMplus.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=NO;
RUN;
