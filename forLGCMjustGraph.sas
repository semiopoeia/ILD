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

/*proc transpose data=grapheart out=meth_wide 
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
*/
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
age_wide
;
by IDNo;
run;
**data is now set in wide format prepared for LGCM analysis;

/*PA_mse_mean CVLtca CVLfrl TRATSr TRBTSr
DSSTot DigBac DigFor BOSCor
FLUCat FLULet CRDRot CLK325 CLK1110 ActiMeth

*/

*linear model for pa, fits ok with 5 time points;
proc calis method=fiml data=wide_comb_ready outstat=ostatPA;   
   lineqs
      PA1 = 0. * Intercept +  f_palpha                 + e1,
      PA2 = 0. * Intercept +  f_palpha  +  1 * f_pbeta + e2,
      PA3 = 0. * Intercept +  f_palpha  +  2 * f_pbeta + e3;
*      PA4 = 0. * Intercept +  f_palpha  +  3 * f_pbeta + e4
*  PA5 = 0. * Intercept +  f_palpha  +  4 * f_pbeta  +e5;
*	  PA6 = 0. * Intercept + f_palpha  +  5 * f_pbeta  +e6,
*	  PA7 = 0. * Intercept + f_palpha  +  6 * f_pbeta + e7,
*      PA8 = 0. * Intercept + f_palpha  +  7 * f_pbeta + e8,
*	  PA9 = 0. * Intercept + f_palpha  +  8 * f_pbeta + e9;
   variance
      f_palpha f_pbeta,
      e1-e3;
   mean
      f_palpha f_pbeta;
   cov
      f_palpha f_pbeta;
   fitindex on=all;
run;
proc score data=wide_comb_ready score=ostatPA out=PA_LatScores;
var PA1 PA2 PA3 PA4
run;

*general cognition factors;
*time 1;
proc calis method=fiml data=wide_comb_ready outstat=ostatG1 modification;   
   lineqs
CVLtca1=0*Intercept+f_G1+eg1,
CVLfrl1=0*Intercept+b2*f_G1+eg2,
TRA1=0*Intercept+b3*f_G1+eg3,
TRB1=0*Intercept+b4*f_G1+eg4,
DSS1=0*Intercept+b5*f_G1+eg5,
DIGB1=0*Intercept+b6*f_G1+eg6,
DIGF1=0*Intercept+b7*f_G1+eg7,
BOS1=0*Intercept+b8*f_G1+eg8,
FLUC1=0*Intercept+b9*f_G1+eg9,
FLUL1=0*Intercept+b10*f_G1+eg10,
CRD1=0*Intercept+b11*f_G1+eg11,
CLK31=0*Intercept+b12*f_G1+eg12,
CLK111=0*Intercept+b13*f_G1+eg13
;
variance
      f_G1
      eg1-eg13;
   mean
      f_G1;
   cov
eg3 eg4,
eg6 eg7,
eg9 eg10,
eg12 eg13;
   fitindex on=all;
run;

/*
CVLtca
CVLfrl
TRA
TRB
DSS
DIGB
DIGF
BOS
FLUC
FLUL
CRD
CLK3
CLK11*/

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

proc corr data=wide_comb_ready alpha;
var
CVLtca1
CVLfrl1
TRA1
TRB1
DSS1
DIGB1
DIGF1
BOS1
FLUC1
FLUL1
CRD1
CLK31
CLK111;
run; 

proc corr data=wide_comb_ready alpha;
var
CVLtca4
CVLfrl4
TRA4
TRB4
DSS4
DIGB4
DIGF4
BOS4
FLUC4
FLUL4
CRD4
CLK34
CLK114;
run; 

data zGenCog;
set wide_comb_ready;
zPA1=(PA1-mean(PA1,PA2,PA3))/std(PA1,PA2,PA3);
zPA2=(PA2-mean(PA1,PA2,PA3))/std(PA1,PA2,PA3);
zPA3=(PA3-mean(PA1,PA2,PA3))/std(PA1,PA2,PA3);

zCVLtcal1=(CVLtca1-mean(CVLtca1,CVLtca2,CVLtca3))/std(CVLtca1,CVLtca2,CVLtca3);
zCVLfrl1=(CVLfrl1-mean(CVLfrl1,CVLfrl2,CVLfrl3))/std(CVLfrl1,CVLfrl2,CVLfrl3);
zTRA1=(TRA1-mean(TRA1,TRA2,TRA3))/std(TRA1,TRA2,TRA3);
zTRB1=(TRB1-mean(TRB1,TRB2,TRB3))/std(TRB1,TRB2,TRB3);
zDSS1=(DSS1-mean(DSS1,DSS2,DSS3))/std(DSS1,DSS2,DSS3);
zDIGB1=(DIGB1-mean(DIGB1,DIGB2,DIGB3))/std(DIGB1,DIGB2,DIGB3);
zDIGF1=(DIGF1-mean(DIGF1,DIGF2,DIGF3))/std(DIGF1,DIGF2,DIGF3);
zBOS1=(BOS1-mean(BOS1,BOS2,BOS3))/std(BOS1,BOS2,BOS3);
zFLUC1=(FLUC1-mean(FLUC1,FLUC2,FLUC3))/std(FLUC1,FLUC2,FLUC3);
zFLUL1=(FLUL1-mean(FLUL1,FLUL2,FLUL3))/std(FLUL1,FLUL2,FLUL3);
zCRD1=(CRD1-mean(CRD1,CRD2,CRD3))/std(CRD1,CRD2,CRD3);
zCLK31=(CLK31-mean(CLK31,CLK32,CLK33))/std(CLK31,CLK32,CLK33);
zCLK111=(CLK111-mean(CLK111,CLK112,CLK113))/std(CLK111,CLK112,CLK113);
G1=mean(zCVLtca11,zCVLfrl1,zTRA1,zTRB1,zDSS1,zDIGB1,zDIGF1,zBOS1,zFLUC1,zFLUL1,zCRD1,zCLK31,zCLK111);

zCVLtca2=(CVLtca2-mean(CVLtca1,CVLtca2,CVLtca3))/std(CVLtca1,CVLtca2,CVLtca3);
zCVLfrl2=(CVLfrl2-mean(CVLfrl1,CVLfrl2,CVLfrl3))/std(CVLfrl1,CVLfrl2,CVLfrl3);
zTRA2=(TRA2-mean(TRA1,TRA2,TRA3))/std(TRA1,TRA2,TRA3);
zTRB2=(TRB2-mean(TRB1,TRB2,TRB3))/std(TRB1,TRB2,TRB3);
zDSS2=(DSS2-mean(DSS1,DSS2,DSS3))/std(DSS1,DSS2,DSS3);
zDIGB2=(DIGB2-mean(DIGB1,DIGB2,DIGB3))/std(DIGB1,DIGB2,DIGB3);
zDIGF2=(DIGF2-mean(DIGF1,DIGF2,DIGF3))/std(DIGF1,DIGF2,DIGF3);
zBOS2=(BOS2-mean(BOS1,BOS2,BOS3))/std(BOS1,BOS2,BOS3);
zFLUC2=(FLUC2-mean(FLUC1,FLUC2,FLUC3))/std(FLUC1,FLUC2,FLUC3);
zFLUL2=(FLUL2-mean(FLUL1,FLUL2,FLUL3))/std(FLUL1,FLUL2,FLUL3);
zCRD2=(CRD2-mean(CRD1,CRD2,CRD3))/std(CRD1,CRD2,CRD3);
zCLK32=(CLK32-mean(CLK31,CLK32,CLK33))/std(CLK31,CLK32,CLK33);
zCLK112=(CLK112-mean(CLK111,CLK112,CLK113))/std(CLK111,CLK112,CLK113);
G2=mean(zCVLtca2,zCVLfrl2,zTRA2,zTRB2,zDSS2,zDIGB2,zDIGF2,zBOS2,zFLUC2,zFLUL2,zCRD2,zCLK32,zCLK112);

zCVLtca3=(CVLtca3-mean(CVLtca1,CVLtca2,CVLtca3))/std(CVLtca1,CVLtca2,CVLtca3);
zCVLfrl3=(CVLfrl3-mean(CVLfrl1,CVLfrl2,CVLfrl3))/std(CVLfrl1,CVLfrl2,CVLfrl3);
zTRA3=(TRA3-mean(TRA1,TRA2,TRA3))/std(TRA1,TRA2,TRA3);
zTRB3=(TRB3-mean(TRB1,TRB2,TRB3))/std(TRB1,TRB2,TRB3);
zDSS3=(DSS3-mean(DSS1,DSS2,DSS3))/std(DSS1,DSS2,DSS3);
zDIGB3=(DIGB3-mean(DIGB1,DIGB2,DIGB3))/std(DIGB1,DIGB2,DIGB3);
zDIGF3=(DIGF3-mean(DIGF1,DIGF2,DIGF3))/std(DIGF1,DIGF2,DIGF3);
zBOS3=(BOS3-mean(BOS1,BOS2,BOS3))/std(BOS1,BOS2,BOS3);
zFLUC3=(FLUC3-mean(FLUC1,FLUC2,FLUC3))/std(FLUC1,FLUC2,FLUC3);
zFLUL3=(FLUL3-mean(FLUL1,FLUL2,FLUL3))/std(FLUL1,FLUL2,FLUL3);
zCRD3=(CRD3-mean(CRD1,CRD2,CRD3))/std(CRD1,CRD2,CRD3);
zCLK33=(CLK33-mean(CLK31,CLK32,CLK33))/std(CLK31,CLK32,CLK33);
zCLK113=(CLK113-mean(CLK111,CLK112,CLK113))/std(CLK111,CLK112,CLK113);
G3=mean(zCVLtca3,zCVLfrl3,zTRA3,zTRB3,zDSS3,zDIGB3,zDIGF3,zBOS3,zFLUC3,zFLUL3,zCRD3,zCLK33,zCLK113);

MEM1=mean(zCVLtca1,zCVLfrl1);
MEM2=mean(zCVLtca2,zCVLfrl2);
MEM3=mean(zCVLtca3,zCVLfrl3);

EF1=mean(zTRA1,zTRB1,zDSS1,zDIGB1,zDIGF1);
EF2=mean(zTRA2,zTRB2,zDSS2,zDIGB2,zDIGF2);
EF3=mean(zTRA3,zTRB3,zDSS3,zDIGB3,zDIGF3);

LANG1=mean(zBOS1,zFLUC1,zFLUL1);
LANG2=mean(zBOS2,zFLUC2,zFLUL2);
LANG3=mean(zBOS3,zFLUC3,zFLUL3);

VS1=mean(zCRD1,zCLK31,zCLK111);
VS2=mean(zCRD2,zCLK32,zCLK112);
VS3=mean(zCRD3,zCLK33,zCLK113);

run;

proc means data=zGenCog;
var 
G1 G2 G3
MEM1 MEM2 MEM3
EF1 EF2 EF3
LANG1 LANG2 LANG3
VS1 VS2 VS3
PA1 PA2 PA3; 
run;

data grabsum;
set zGenCog;
keep IDNo
PA1 PA2 PA3 
G1 G2 G3
MEM1 MEM2 MEM3
EF1 EF2 EF3
LANG1 LANG2 LANG3
VS1 VS2 VS3
AGE1;
run;

*send to MPLUS;
data mplusLGCM;
set grabsum;
	array num_array _numeric_;
	do over num_array;
		if missing(num_array) then num_array = -9999;
	end;
run;

PROC EXPORT DATA= WORK.mplusLGCM 
            OUTFILE= "C:\Users\PWS5\OneDrive - University of Pittsburgh\
Desktop\SoN_Proj\Yurun\LGCMplusGraph3.txt" 
            DBMS=TAB REPLACE;
     PUTNAMES=NO;
RUN;
