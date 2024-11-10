use "C:\Users\PWS5\OneDrive - University of Pittsburgh\Desktop\SoN_Proj\Yurun\graphYRlong.dta"

*create reverse codes.
gen TRATSr=301-TRATS
gen TRBTSr=301-TRBTS

*keep baseline and year 2 only.
keep if followupyrs_r==0 | followupyrs_r==2

*establish as panel data.
xtset IDNo followupyrs_r

**For the general cognition.
*fit facotr model unmodified.
sem(G->CRDRot CVLtca CVLfrl DigFor DigBac DSSTot BOSCor CLK325 CLK1110 FLUCat FLULet TRATSr TRBTSr,nocapslatent latent(G) var(G@1)) 
estat gof, stats(all)
estat mindices

*add in round 1 modification.
sem(G->CRDRot CVLtca CVLfrl DigFor DigBac DSSTot BOSCor CLK325 CLK1110 FLUCat FLULet TRATSr TRBTSr,nocapslatent latent(G) cov(G@1 e.CVLtca*e.CVLfrl e.DigFor*e.DigBac e.CLK325*e.CLK1110 e.TRATSr*e.TRBTSr)) 
estat gof, stats(all)
estat mindices

*add in additional modifications.
sem(G->CRDRot CVLtca CVLfrl DigFor DigBac DSSTot BOSCor CLK325 CLK1110 FLUCat FLULet TRATSr TRBTSr,nocapslatent latent(G) cov(G@1 e.CVLtca*e.CVLfrl e.DigFor*e.DigBac e.CLK325*e.CLK1110 e.TRATSr*e.TRBTSr e.DSSTot*e.TRATSr e.CRDRot*e.FLUCat)) 
estat gof, stats(all)
*generate factor scores from grand fit modified model.
predict G,latent

*we use random-effects to get within-person estimates and add an additional control for residual correlation across time points within a person through using robust clustered standard errors.
*fit model predicting change in PA.
xtreg PA_mse_mean followupyrs_r,vce(cluster IDNo) 
*fit model predicting change in G.
xtreg G followupyrs_r,vce(cluster IDNo)
*fit main effect model predicting G from PA.
xtreg G PA_mse_mean,vce(cluster IDNo)
*fit main effect model predicting G from PA while controlling for change across years.
xtreg G PA_mse_mean followupyrs_r,vce(cluster IDNo)
*fit model having interaction capturing the influence of changes in PA on changes in G over time.
xtreg G c.PA_mse_mean##c.followupyrs_r if misflg<14,vce(cluster IDNo)
margins, at (followupyrs_r=(0 2) PA_mse_mean=(.3 .66 1.02))
marginsplot 

*moderate by apoe.
xtreg G c.PA_mse_mean##c.followupyrs_r##apoe4,vce(cluster IDNo)
*moderate by sex.
xtreg G c.PA_mse_mean##c.followupyrs_r##sex,vce(cluster IDNo)
*moderate by agecat.
xtreg G c.PA_mse_mean##c.followupyrs_r##c.agecat,vce(cluster IDNo)
margins, at (followupyrs_r=(0 2) PA_mse_mean=(.3 .66 1.02) agecat=(4))
marginsplot 



**For the memory.
*fit facotr model unmodified.
sem(MEM->CVLtca CVLfrl,nocapslatent latent(MEM) var(MEM@1)) 
estat gof, stats(all)
*has perfect fit.
predict MEM,latent

*run the model.
xtreg MEM c.PA_mse_mean##c.followupyrs_r,vce(cluster IDNo)

*EF.
*fit facotr model unmodified.
sem(EF->DigFor DigBac DSSTot TRATSr TRBTSr,nocapslatent latent(EF) var(EF@1)) 
estat gof, stats(all)
estat mindices
*round 1 modification.
sem(EF->DigFor DigBac DSSTot TRATSr TRBTSr,nocapslatent latent(EF) cov(EF@1 e.DigFor*e.DigBac)) 
estat gof, stats(all)
*fit is good now.
predict EF,latent
*run the model.
xtreg EF c.PA_mse_mean##c.followupyrs_r if misflg<14,vce(cluster IDNo)

*LANG.
*fit factor model unmodified.
sem(LANG->BOSCor FLUCat FLULet,nocapslatent latent(LANG) var(LANG@1)) 
estat gof,stats(all)
predict LANG,latent
*run the model.
xtreg LANG c.PA_mse_mean##c.followupyrs_r,vce(cluster IDNo)

*VS.
*fit unmodified model.
sem(VS->CRDRot CLK325 CLK1110 ,nocapslatent latent(VS) var(VS@1)) 
estat gof, stats(all)
predict VS,latent
*run the model.
xtreg VS c.PA_mse_mean##c.followupyrs_r,vce(cluster IDNo)

*compare general to specific.
sem(G->CRDRot CVLtca CVLfrl DigFor DigBac DSSTot BOSCor CLK325 CLK1110 FLUCat FLULet TRATSr TRBTSr,nocapslatent latent(G) cov(G@1 e.CVLtca*e.CVLfrl e.DigFor*e.DigBac e.CLK325*e.CLK1110 e.TRATSr*e.TRBTSr e.DSSTot*e.TRATSr e.CRDRot*e.FLUCat)) 
estat gof, stats(all)
estimates store unidim

sem(MEM->CVLtca CVLfrl,) (EF->DigFor DigBac DSSTot TRATSr TRBTSr,) (VS->CRDRot CLK325 CLK1110,) (LANG->BOSCor FLUCat FLULet,), nocapslatent latent(MEM EF VS LANG) cov(MEM@1 EF@1 VS@1 LANG@1) 
estat gof, stats(all)
estat mindices


sem(MEM->CVLtca CVLfrl,) (EF->DigFor DigBac DSSTot TRATSr TRBTSr,) (VS->CRDRot CLK325 CLK1110,) (LANG->BOSCor FLUCat FLULet,), nocapslatent latent(MEM EF VS LANG) cov(MEM@1 EF@1 VS@1 LANG@1 e.DigFor*e.DigBac e.CLK325*e.CLK1110) 
estat gof, stats(all)
estimates store multidim

lrtest unidim multidim
