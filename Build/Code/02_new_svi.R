## This script takes the raw data and ranks it all creating the final index.  First it takes the weights that
## have been assigned to the variables and rescale them so that they sum to 1. Then it carries out the 
## percent ranking as discussed in the data section of the readme.  It saves the Final index rankings in the
## Index folder. 
load('./Build/Cache/SVI_var.RData')
weights<- c(1.25,.75,1.25,.75,.25,.25,.5,.25,1.25,.5,0,.5,0,.25,0,1.25,1.25)

###############
#Innocent new codes. 
#NB: Reverse direction of HH income

SVI <- SVI_var%>%
  mutate(overall_sum_SVI = ((weights[1]*poverty_percent_below_1)+
                              (weights[2]*civ_labor_force_unemployed_percent_2)+
                              (weights[3]*-1*median_hh_income_3)+
           (weights[4]*no_hs_degree_percent_4)+
           (weights[5]*over_65_percent_5)+
           (weights[6]*under_18_percent_6)+
           (weights[7]*disabled_adult_percent_7)+
           (weights[8]*single_householder_percent_8)+
           (weights[9]*percent_minority_9)+
           (weights[10]*eng_proficiency)+
           (weights[11]*over_10)+
           (weights[12]*mobile_units)+
           (weights[13]*over_1_person_room_percent_13)+
           (weights[14]*no_vehicle_percent_14)+
           (weights[15]*group_quarters_percent_15)+
           (weights[16]*gini_income)+
           (weights[17]*gini_education)))%>%
  mutate(wfsvi = percent_rank(overall_sum_SVI))%>%
  mutate(qualify=ifelse(wfsvi>=0.75,1,0))

if(!dir.exists("./Build/Cache/")){
  dir.create("./Build/Cache/")
}     


save(SVI,file='./Build/Cache/SVI.RData')
save(weights,file='./Build/Cache/weights.RData')
rm(SVI_var,SVI,weights)
