## This script takes the raw data and ranks it all creating the final index
load('./Build/Cache/SVI_dat.RData')
weight<- c(1.25,.75,1.25,.75,.25,.25,.5,.25,1.25,.5,0,.5,0,.25,0,1.25,1.25)
weights<-data.frame(c(names(SVI_dat%>%dplyr::select(-census_block_group,-WUI))),
                    c('socioeconomic','socioeconomic','socioeconomic','socioeconomic'
                      ,'Household Composition/Disability','Household Composition/Disability','Household Composition/Disability','Household Composition/Disability'
                      ,'Minority Status/Language','Minority Status/Language'
                      ,'Housing/Transportation','Housing/Transportation','Housing/Transportation','Housing/Transportation','Housing/Transportation'
                      ,'Equity','Equity'),
                    weight/sum(weight))
names(weights)<-c('category','categoty','weight')
SVI<-SVI_dat%>%
  dplyr::filter(WUI==1)%>%
  dplyr::select(-WUI)%>%
  rename_with( .fn = ~paste0(., '_rank'),.cols=as.character(names(SVI_dat[,2:18])))%>%
  mutate(directional_median_hh_income_3_rank=-1*median_hh_income_3_rank,.keep="unused")%>%
  mutate(across(!census_block_group,percent_rank))%>%
  mutate(overall_sum=
           weights$weight[1]*poverty_percent_below_1_rank+##Socioeconomic
           weights$weight[2]*civ_labor_force_unemployed_percent_2_rank+
           weights$weight[3]*directional_median_hh_income_3_rank+
           weights$weight[4]*no_hs_degree_percent_4_rank+
           weights$weight[5]*over_65_percent_5_rank+                ## Household Compisition
           weights$weight[6]*under_18_percent_6_rank+
           weights$weight[7]*disabled_adult_percent_7_rank+         
           weights$weight[8]*single_householder_percent_8_rank+
           weights$weight[9]*percent_minority_9_rank+               ## Minority status
           weights$weight[10]*do_not_speak_english_well_percent_10_rank+
           weights$weight[11]*units_over_10_percent_11_rank+         ## Housing/Transpotation
           weights$weight[12]*units_mobile_percent_12_rank+
           weights$weight[13]*over_1_person_room_percent_13_rank+
           weights$weight[14]*no_vehicle_percent_14_rank+
           weights$weight[15]*group_quarters_percent_15_rank+
           weights$weight[16]*gini_income_rank+                      ## Inequality measures
           weights$weight[17]*gini_education_rank,
         overall_rank=percent_rank(overall_sum))%>%
  right_join(.,SVI_dat,by="census_block_group")%>%
  mutate(qualify=ifelse(overall_rank>=.75,1,0))%>%
  mutate_at(vars(qualify,overall_rank,overall_sum), ~replace(., is.na(.), 0))

if(!dir.exists("./Build/Index/")){
  dir.create("./Build/Index/")
}     
save(SVI,file='./Build/Index/SVI.RData')
save(weights,file='./Build/Index/weights.RData')
rm(SVI_dat,SVI,weight,weights)
         