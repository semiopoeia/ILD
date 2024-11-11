use "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Yurun\graphYRlong.dta",replace

*get the valid days 3 or more;
merge m:m IDNo Visit using "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Yurun\blsa_valdays.dta", keepusing(n_valid_days)

keep if _merge==3
drop if MCI_dement==1

keep IDNo Age PA_mse_mean CRDRot CVLtca CVLfrl DigFor DigBac DSSTot BOSCor CLK325 CLK1110 FLUCat FLULet apoe4 followupyrs_r sex educ_years white agecat bmicat comorbidcat TRATSr TRBTSr

reshape wide Age PA_mse_mean CRDRot CVLtca CVLfrl DigFor DigBac DSSTot BOSCor CLK325 CLK1110 FLUCat FLULet apoe4 sex educ_years white agecat bmicat comorbidcat TRATSr TRBTSr, i(IDNo) j(followupyrs_r)

*baseline
sem(G0->CRDRot0-FLULet0 TRATSr0 TRBTSr0,nocapslatent latent(G0) ///
cov(G0@1))
estat gof,stats(all)
estat mindices 

sem(G0->CRDRot0-FLULet0 TRATSr0 TRBTSr0,nocapslatent latent(G0) ///
cov(G0@1 e.CVLtca0*e.CVLfrl0 e.DigFor0*e.DigBac0 e.CLK3250*e.CLK11100))
estat gof,stats(all)
estat mindices 

sem(G0->CRDRot0-FLULet0 TRATSr0 TRBTSr0,nocapslatent latent(G0) ///
cov(G0@1 e.CVLtca0*e.CVLfrl0 e.DigFor0*e.DigBac0 e.CLK3250*e.CLK11100 e.FLUCat0*e.FLULet0  ///
e.FLUCat0*e.TRBTSr0 e.DSSTot0*e.TRATSr0 e.CRDRot0*e.FLUCat0 e.TRATSr0*e.TRBTSr0)) 
estat gof,stats(all)
estat mindices 
predict G0,latent

*2year.
sem(G2->CRDRot2-FLULet2 TRATSr2 TRBTSr2,nocapslatent latent(G2) ///
cov(G2@1))
estat gof,stats(all)
estat mindices 

sem(G2->CRDRot2-FLULet2 TRATSr2 TRBTSr2,nocapslatent latent(G2) ///
cov(G2@1 e.CVLtca2*e.CVLfrl2 e.DigFor2*e.DigBac2 e.CLK3252*e.CLK11102 ///
e.CVLtca2*e.FLUCat2 e.TRATSr2*e.TRBTSr2 e.CVLfrl2*e.FLUCat2 e.DigFor2*e.FLULet2 ///
e.DSSTot2*e.CLK11102 e.FLUCat2*e.FLULet2))
estat gof,stats(all)
estat mindices 
predict G2,latent

rename PA_mse_mean0 PA0
rename PA_mse_mean2 PA2

*noadj clpm G
sem (PA0 -> PA2 G2, ) (G0 -> G2 PA2, ), ///
vce(robust) standardized cov( PA0*G0 e.PA2*e.G2) nocapslatent 

*adjust clpm G
sem (PA0 -> PA2 G2, ) (G0 -> G2 PA2, ) ///
(Age0->PA0 G0 ,) (sex0->PA0 G0,) /// 
(educ_years0->PA0 G0,) (white0->PA0 G0,) ///
(bmicat0->PA0 G0,) (comorbidcat0->PA0 G0,) ///
(Age2->PA2 G2,) (sex2->PA2 G2,) /// 
(educ_years2->PA2 G2,) (white2->PA2 G2,) ///
(bmicat2->PA2 G2,) (comorbidcat2->PA2 G2,), ///
vce(robust) standardized cov( e.PA0*e.G0 e.PA2*e.G2) nocapslatent


sem (PA0 -> PA2, ) (PA0 -> G2, ) (G0 -> PA2, ) (G0 -> G2, ), ///
vce(robust) standardized cov( PA0*G0 e.PA2*e.G2) nocapslatent group(apoe40)
estat ginvariant, showpclass(scoef) class

sem (PA0 -> PA2, ) (PA0 -> G2, ) (G0 -> PA2, ) (G0 -> G2, ), ///
vce(robust) standardized cov( PA0*G0 e.PA2*e.G2) nocapslatent group(sex0)
estat ginvariant, showpclass(scoef) class


sem (PA0 -> PA2, ) (PA0 -> G2, ) (G0 -> PA2, ) (G0 -> G2, ), ///
vce(robust) standardized cov( PA0*G0 e.PA2*e.G2) nocapslatent group(agecat2)
estat ginvariant, showpclass(scoef) class
*/

*memory
sem(MEM0->CVLtca0 CVLfrl0,nocapslatent latent(MEM0) ///
cov(MEM0@1 e.CVLtca0@r e.CVLfrl0@r))
estat gof,stats(all)
predict MEM0,latent

sem(MEM2->CVLtca2 CVLfrl2,nocapslatent latent(MEM2) ///
cov(MEM2@1 e.CVLtca2@r e.CVLfrl2@r))
estat gof,stats(all)
predict MEM2,latent

*clpm
sem (PA0 -> PA2, ) (PA0 -> MEM2, ) (MEM0 -> PA2, ) (MEM0 -> MEM2, ), ///
vce(robust) standardized cov( PA0*MEM0 e.PA2*e.MEM2) nocapslatent

*adjusted
sem (PA0 -> PA2 MEM2, ) (MEM0 -> MEM2 PA2, ) ///
(Age0->PA0 MEM0 ,) (sex0->PA0 MEM0,) /// 
(educ_years0->PA0 MEM0,) (white0->PA0 MEM0,) ///
(bmicat0->PA0 MEM0,) (comorbidcat0->PA0 MEM0,) ///
(Age2->PA2 MEM2,) (sex2->PA2 MEM2,) /// 
(educ_years2->PA2 MEM2,) (white2->PA2 MEM2,) ///
(bmicat2->PA2 MEM2,) (comorbidcat2->PA2 MEM2,), ///
vce(robust) standardized cov( e.PA0*e.MEM0 e.PA2*e.MEM2) nocapslatent

*ef
sem(EF0->DigFor0 DigBac0 DSSTot0 TRATSr0 TRBTSr0,nocapslatent latent(EF0) ///
cov(EF0@1))
estat gof,stats(all)
estat mindices

sem(EF0->DigFor0 DigBac0 DSSTot0 TRATSr0 TRBTSr0,nocapslatent latent(EF0) ///
cov(EF0@1 e.DigFor0*e.DigBac0))
estat gof,stats(all)
predict EF0,latent

sem(EF2->DigFor2 DigBac2 DSSTot2 TRATSr2 TRBTSr2,nocapslatent latent(EF2) ///
cov(EF2@1))
estat gof,stats(all)
estat mindices

sem(EF2->DigFor2 DigBac2 DSSTot2 TRATSr2 TRBTSr2,nocapslatent latent(EF2) ///
cov(EF2@1 e.DigFor2*e.DigBac2))
estat gof,stats(all)
predict EF2, latent

*clpm
sem (PA0 -> PA2, ) (PA0 -> EF2, ) (EF0 -> PA2, ) (EF0 -> EF2, ), ///
vce(robust) standardized cov( PA0*EF0 e.PA2*e.EF2) nocapslatent 


sem (PA0 -> PA2, ) (PA0 -> EF2, ) (EF0 -> PA2, ) (EF0 -> EF2, ), ///
vce(robust) standardized cov( PA0*EF0 e.PA2*e.EF2) nocapslatent group(apoe40)
estat ginvariant, showpclass(scoef) class

sem (PA0 -> PA2, ) (PA0 -> EF2, ) (EF0 -> PA2, ) (EF0 -> EF2, ), ///
vce(robust) standardized cov( PA0*EF0 e.PA2*e.EF2) nocapslatent group(sex0)
estat ginvariant, showpclass(scoef) class

sem (PA0 -> PA2, ) (PA0 -> EF2, ) (EF0 -> PA2, ) (EF0 -> EF2, ), ///
vce(robust) standardized cov( PA0*EF0 e.PA2*e.EF2) nocapslatent group(agecat2)
estat ginvariant, showpclass(scoef) class
*/

*adjusted 
sem (PA0 -> PA2 EF2, ) (EF0 -> EF2 PA2, ) ///
(Age0->PA0 EF0 ,) (sex0->PA0 EF0,) /// 
(educ_years0->PA0 EF0,) (white0->PA0 EF0,) ///
(bmicat0->PA0 EF0,) (comorbidcat0->PA0 EF0,) ///
(Age2->PA2 EF2,) (sex2->PA2 EF2,) /// 
(educ_years2->PA2 EF2,) (white2->PA2 EF2,) ///
(bmicat2->PA2 EF2,) (comorbidcat2->PA2 EF2,), ///
vce(robust) standardized cov( e.PA0*e.EF0 e.PA2*e.EF2) nocapslatent

*lang
sem(LANG0->BOSCor0 FLUCat0 FLULet0,nocapslatent latent(LANG0) ///
cov(LANG0@1))
estat gof, stats(all)
predict LANG0,latent

sem(LANG2->BOSCor2 FLUCat2 FLULet2,nocapslatent latent(LANG2) ///
cov(LANG2@1))
estat gof, stats(all)
predict LANG2,latent

*clpm
sem (PA0 -> PA2, ) (PA0 -> LANG2, ) (LANG0 -> PA2, ) (LANG0 -> LANG2, ), ///
vce(robust) standardized cov( PA0*LANG0 e.PA2*e.LANG2) nocapslatent

*adjusted
sem (PA0 -> PA2 LANG2, ) (LANG0 -> LANG2 PA2, ) ///
(Age0->PA0 LANG0 ,) (sex0->PA0 LANG0,) /// 
(educ_years0->PA0 LANG0,) (white0->PA0 LANG0,) ///
(bmicat0->PA0 LANG0,) (comorbidcat0->PA0 LANG0,) ///
(Age2->PA2 LANG2,) (sex2->PA2 LANG2,) /// 
(educ_years2->PA2 LANG2,) (white2->PA2 LANG2,) ///
(bmicat2->PA2 LANG2,) (comorbidcat2->PA2 LANG2,), ///
vce(robust) standardized cov( e.PA0*e.LANG0 e.PA2*e.LANG2) nocapslatent

*moderate by sex.
sem (PA0 -> PA2 LANG2, ) (LANG0 -> LANG2 PA2, ) ///
(Age0->PA0 LANG0 ,)  /// 
(educ_years0->PA0 LANG0,) (white0->PA0 LANG0,) ///
(bmicat0->PA0 LANG0,) (comorbidcat0->PA0 LANG0,) ///
(Age2->PA2 LANG2,) /// 
(educ_years2->PA2 LANG2,) (white2->PA2 LANG2,) ///
(bmicat2->PA2 LANG2,) (comorbidcat2->PA2 LANG2,), ///
vce(robust) standardized cov( e.PA0*e.LANG0 e.PA2*e.LANG2) nocapslatent group(sex0)
estat ginvariant, showpclass(scoef) class

*moderate by apoe4
sem (PA0 -> PA2 LANG2, ) (LANG0 -> LANG2 PA2, ) ///
(Age0->PA0 LANG0 ,) (sex0->PA0 LANG0,) /// 
(educ_years0->PA0 LANG0,) (white0->PA0 LANG0,) ///
(bmicat0->PA0 LANG0,) (comorbidcat0->PA0 LANG0,) ///
(Age2->PA2 LANG2,) (sex2->PA2 LANG2,) /// 
(educ_years2->PA2 LANG2,) (white2->PA2 LANG2,) ///
(bmicat2->PA2 LANG2,) (comorbidcat2->PA2 LANG2,), ///
vce(robust) standardized cov( e.PA0*e.LANG0 e.PA2*e.LANG2) nocapslatent group(apoe4)
estat ginvariant, showpclass(scoef) class


*vs
sem(VS0->CRDRot0 CLK3250 CLK11100,nocapslatent latent(VS0) ///
cov(VS0@1))
estat gof, stats(all)
predict VS0,latent

sem(VS2->CRDRot2 CLK3252 CLK11102, nocapslatent latent(VS2) ///
cov(VS2@1 e.CLK11102@r e.CLK3252@r))
estat gof, stats(all)
predict VS2,latent

*clpm
sem (PA0 -> PA2, ) (PA0 -> VS2, ) (VS0 -> PA2, ) (VS0 -> VS2, ), ///
vce(robust) standardized cov( PA0*VS0 e.PA2*e.VS2) nocapslatent 

*adjusted
sem (PA0 -> PA2 VS2, ) (VS0 -> VS2 PA2, ) ///
(Age0->PA0 VS0 ,) (sex0->PA0 VS0,) /// 
(educ_years0->PA0 VS0,) (white0->PA0 VS0,) ///
(bmicat0->PA0 VS0,) (comorbidcat0->PA0 VS0,) ///
(Age2->PA2 VS2,) (sex2->PA2 VS2,) /// 
(educ_years2->PA2 VS2,) (white2->PA2 VS2,) ///
(bmicat2->PA2 VS2,) (comorbidcat2->PA2 VS2,), ///
vce(robust) standardized cov( e.PA0*e.VS0 e.PA2*e.VS2) nocapslatent

save "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Yurun\WideGraphYR.dta",replace


