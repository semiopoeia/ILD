#install.packages(c("psych","MASS"), dependencies=T)

my_n2 <- 1000                                       
# Specify sample size

my_mu2 <- c(5, 2, 8)                                
# Specify the means of the variables

my_Sigma2 <- matrix(c(10, 5, 2, 3, 7, 1, 1, 8, 3),ncol = 3)  
# Specify the covariance matrix of the variables
  
library(MASS)
dat<-mvrnorm(n = my_n2, mu = my_mu2, Sigma = my_Sigma2)  
# Random sample from bivariate normal distribution

R<-rep(1:20,50)
dat2<-cbind(R,dat)

library(psych)
ICC(dat)

install.packages("lme4",dep=T)
library(lme4)
m1<-lmer(V4~1+V2+V3+(1|R),dat2,REML=F)
m0<-lm(V4~1+V2+V3,dat2)


#approxiate to t-value
sqrt(Chi2)

#find pr(t<x) with df=n-p=1000-5=995
dt(x=t,df=995)

summary(m1)

install.packages("pwrss")

library(pwrss)
library(pwr)
lambda<-2.25/(1/15)
power.f.test(lambda, 299,4200,0.05,
             plot = TRUE, plot.main = NULL, plot.sub = NULL)
tICC<-1.5/2.5

install.packages("ICC.Sample.Size")
library(ICC.Sample.Size)
calculateAchievablep0(0.51,15,0.05,2,0.8,300)
calculateIccPower(0.562,0.5,7,0.05,1,300,0.8)


  #small to medium 0.2=b; medium 0.3=d; medium to large 0.4=d
n<-300
p<-11
b<-0.164
ncp<-(b/(1/sqrt(n)))
df<-n-p
power.t.test(ncp, df, 0.05, "not equal",
             plot = TRUE, plot.main = NULL, plot.sub = NULL)