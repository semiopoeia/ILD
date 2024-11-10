install.packages("InteractionPoweR",dep=T)
set.seed(8675309)
library(InteractionPoweR)
#assumes small to moderate interaction effects (r=0.2)
#for sex, white, and apoe the corr is r=|0.07|

#continuous
simpow<-
power_interaction(
n.iter = 1000,              
alpha = 0.05,             
N = seq(100,200,by=50),   
r.x1x2.y = .2,           
r.x1.y = -.25,           
r.x2.y = .02,              
r.x1.x2 = -.18,          
#k.x1 = 2                
)

power_estimate(simpow,"N",0.8)
 

#categorical (binary)
power_interaction(
n.iter = 1000,            #R=1000 monte carlo simulations  
alpha = 0.05,             # alpha, for the power analysis
N = 269,                  # sample sizes 250--500
r.x1x2.y = .2,           # small interaction effect to test (r=0.1)
r.x1.y = .24,              # correlation between x1 and y
r.x2.y = -.17,              # correlation between x2 and y  
r.x1.x2 = -.18,             # correlation between x1 and x2
#k.x1 = 2, 			  #x1 is binary
k.y=2				  #y is binary
)

simulation_results<-
power_interaction_r2(N=seq(100,400,by=10),alpha=0.05, r.x1.y=-.25,r.x2.y=.02,r.x1x2.y=0.2,r.x1.x2=-0.18)
power_estimate(power_data=simulation_results,x="N",power_target=.8)