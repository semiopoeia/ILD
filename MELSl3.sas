proc sort data=SImPath out=SImPath;
by si_idx ElapseDay ElapseHr;run;
data SImPath1;
set SImPath;
if questionlistname="Morning Survey" then EMA=1;
if questionlistname="Afternoon Survey" then EMA=2;
if questionlistname="Evening Survey" then EMA=3;
run;

PROC NLMIXED DATA=SImPath1 GCONV=1e-13;
PARMS beta0 beta1   beta2 beta3  
      lbd0   lbd1                       
      alpha0 alpha1 alpha2           
      tau0   tau1 tau2 tau3  
      covgw   varw;                    
BOUNDS varw>0;
*****Common for all conditional logLik;
varg = EXP(lbd0 + lbd1*x3);
varu = EXP(alpha0 + alpha1*x2 + alpha2*x3);
*****1st conditional logLik;
xbeta1 = beta0 + beta1*x1_1 + beta2*x2 + beta3*x3;
vare1  = EXP(tau0 + tau1*x1_1 + tau2*x2 + tau3*x3 + w);
eta1 = xbeta1 + gamma;
var1 = varu + vare1;
z1 = -0.5*LOG(2*3.1415926*var1) - 0.5*(y_1-eta1)**2/var1;
*****2nd conditional logLik;
t1=1; l1=vare1; k1=varu*t1+l1;
p1 = y_1 - xbeta1 - gamma;
xbeta2 = beta0 + beta1*x1_2 + beta2*x2 + beta3*x3;
vare2  = EXP(tau0 + tau1*x1_2 + tau2*x2 + tau3*x3 + w);
eta2 = xbeta2 + gamma + (varu/k1)*(p1);
var2 = varu + vare2 - varu**2*t1/k1;
z2  = -0.5*LOG(2*3.1415926*var2) - 0.5*(y_2-eta2)**2/var2;
*****3rd conditional logLik;
t21=t1*vare2; t22=l1;
t2=t21+t22; l2=l1*vare2; k2=varu*t2+l2;
p2 = y_2 - xbeta2 - gamma;
xbeta3 = beta0 + beta1*x1_3 + beta2*x2 + beta3*x3;
vare3  = EXP(tau0 + tau1*x1_3 + tau2*x2  + tau3*x3 + w);
eta3 = xbeta3 + gamma + (varu/k2)*( t21*p1+t22*p2);
var3 = varu + vare3 - varu**2*t2/k2;
z3 = -0.5*LOG(2*3.1415926*var3) - 0.5*(y_3-eta3)**2/var3;
*****4th conditional loglik;
t31=t21*vare3; t32=t22*vare3; t33=l2;
t3=t31+t32+t33; l3=l2*vare3; k3=varu*t3+l3; 
p3 = y_3 - xbeta3 - gamma;
xbeta4 = beta0 + beta1*x1_4 + beta2*x2 + beta3*x3;
vare4  = EXP(tau0 + tau1*x1_4 + tau2*x2  + tau3*x3 + w);
eta4 = xbeta4 + gamma + (varu/k3)*(t31*p1+t32*p2+t33*p3);
var4 = varu + vare4 - (varu**2*t3)/k3;
z4 = -0.5*LOG(2*3.1415926*var4) - 0.5*(y_4-eta4)**2/var4;
*****Overall loglik;
IF freq=1 THEN ll=z1;
ELSE IF freq=2 THEN ll=z1+z2;
ELSE IF freq=3 THEN ll=z1+z2+z3;
ELSE IF freq=4 THEN ll=z1+z2+z3+z4;
*****Model statement;
MODEL  y_1 ~GENERAL(ll);
RANDOM gamma w~NORMAL([0,0],[varg,covgw,varw]) SUBJECT=SubjectID;  RUN;
