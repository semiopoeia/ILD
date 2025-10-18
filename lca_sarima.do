tab group,gen(g)

hist seasonal_ar_order
hist intercept
gen interceptsgn=sign(intercept)
gen interceptt=interceptsgn+1
*sparse, remove

hist ar1
gen ar1sgn=sign(ar1)
gen ar1t=ar1sgn+1
hist ar2
gen ar2sgn=sign(ar2)
gen ar2t=ar2sgn+1
*somewhat sparse

hist sar1
gen sar1sgn=sign(sar1)
gen sar1t=sar1sgn+1
hist sar2
gen sar2sgn=sign(sar2)
gen sar2t=sar2sgn+1
hist ma2
gen ma2sgn=sign(ma2)
gen ma2t=ma2sgn+1
*somewhat sparse

hist sma1
gen sma1sgn=sign(sma1)
gen sma1t=sma1sgn+1
hist sma2
gen sma2sgn=sign(sma2)
gen sma2t=sma2sgn+1
*sparse,remove

 
gsem (seasonal_ar_order <- _cons, family(poisson) link(log)) ///
(intercept ar1t ar2t sar1t sma1t sma2t ma2t <- _cons,family(gaussian) link(identity)), lclass(A 1) startvalues(randomid)
estat ic

gsem (seasonal_ar_order <- _cons, family(poisson) link(log)) ///
(interceptsgn ar1sgn ar2sgn sar1sgn sma1sgn sma2sgn ma2sgn <- _cons,family(gaussian) link(identity)), lclass(A 2) startvalues(randomid)
estat ic
predict ppr*,classpost
corr g1 g2 g3 g4 ppr1 ppr2
gsem (seasonal_ar_order <- _cons, family(poisson) link(log)) ///
(interceptsgn ar1sgn ar2sgn sar1sgn sma1sgn sma2sgn ma2sgn <- _cons,family(gaussian) link(identity)), lclass(A 3) startvalues(randomid)
estat ic


ssc install profileplot
profileplot ar_order ma_order seasonal_ar_order seasonal_ma_order d seasonal_d, by(c1)
