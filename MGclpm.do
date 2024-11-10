
*moderate by sex.
sem (PA0 -> PA2 VS2, ) (VS0 -> VS2 PA2, ) ///
(Age0->PA0 VS0 ,)  /// 
(educ_years0->PA0 VS0,) (white0->PA0 VS0,) ///
(bmicat0->PA0 VS0,) (comorbidcat0->PA0 VS0,) ///
(Age2->PA2 VS2,) /// 
(educ_years2->PA2 VS2,) (white2->PA2 VS2,) ///
(bmicat2->PA2 VS2,) (comorbidcat2->PA2 VS2,), ///
vce(robust) standardized cov( e.PA0*e.VS0 e.PA2*e.VS2) nocapslatent group(sex0)
estat ginvariant, showpclass(scoef) class

*moderate by apoe4
sem (PA0 -> PA2 VS2, ) (VS0 -> VS2 PA2, ) ///
(Age0->PA0 VS0 ,) (sex0->PA0 VS0,) /// 
(educ_years0->PA0 VS0,) (white0->PA0 VS0,) ///
(bmicat0->PA0 VS0,) (comorbidcat0->PA0 VS0,) ///
(Age2->PA2 VS2,) (sex2->PA2 VS2,) /// 
(educ_years2->PA2 VS2,) (white2->PA2 VS2,) ///
(bmicat2->PA2 VS2,) (comorbidcat2->PA2 VS2,), ///
vce(robust) standardized cov( e.PA0*e.VS0 e.PA2*e.VS2) nocapslatent group(apoe40)
estat ginvariant, showpclass(scoef) class