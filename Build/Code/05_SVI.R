## This script takes the raw data and ranks it all creating the final index
load('./Build/Cache/SVI_dat.RData')

SVI<-SVI_dat%>%
  filter(WUI==1)%>%
  dplyr::select(-WUI)%>%
  rename_with( .fn = ~paste0(., '_rank'),.cols=as.character(names(SVI_dat[,2:18])))%>%
  mutate(directional_median_hh_income_3_rank=-1*median_hh_income_3_rank,.keep="unused")%>%
  mutate(across(!census_block_group,percent_rank))%>%
  mutate(overall_sum=1*poverty_percent_below_1_rank+##Socioeconomic
           1*civ_labor_force_unemployed_percent_2_rank+
           1*directional_median_hh_income_3_rank+
           1*no_hs_degree_percent_4_rank+
           .5*over_65_percent_5_rank+                ## Household Compisition
           .5*under_18_percent_6_rank+
           .5*disabled_adult_percent_7_rank+         
           .5*single_householder_percent_8_rank+
           1*percent_minority_9_rank+               ## Minority status
           1*do_not_speak_english_well_percent_10_rank+
           0*units_over_10_percent_11_rank+         ## Housing/Transpotation
           1*units_mobile_percent_12_rank+
           0*over_1_person_room_percent_13_rank+
           1*no_vehicle_percent_14_rank+
           0*group_quarters_percent_15_rank+
           1*gini_income_rank+                      ## Inequality measures
           1*gini_education_rank,
         overall_rank=percent_rank(overall_sum))%>%
  right_join(.,SVI_dat,by="census_block_group")%>%
  mutate(qualify=ifelse(overall_rank>=.75,1,0))%>%
  mutate_at(vars(qualify,overall_rank,overall_sum), ~replace(., is.na(.), 0))

if(!dir.exists("./Build/Index/")){
  dir.create("./Build/Index/")
}     
save(SVI,file='./Build/Index/SVI.RData')
rm(SVI_dat,SVI)
         