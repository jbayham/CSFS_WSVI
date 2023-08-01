## This script takes the raw data and ranks it all creating the final index.  First it takes the weights that
## have been assigned to the variables and rescale them so that they sum to 1. Then it carries out the 
## percent ranking as discussed in the data section of the readme.  It saves the Final index rankings in the
## cache folder. 
svi_wui <- readRDS('Build/Output/svi_wui.rds')
cbg_geo <- read_sf("Build/Cache/tl_2022_08_bg/tl_2022_08_bg.shp")%>%
  dplyr::select(GEOID)%>%
  filter(GEOID %in% svi_wui$GEOID) 

weights<- c(.122,.0731,.122,.0731,.0244,.0244,.0244,.0244,.122,.0488,0,.0488,0,.0244,0,.122,.122)

#NB: Reverse direction of HH income
wfsvi <- svi_wui%>%
  dplyr::select(-wui_flag)%>%
  rename_with( .fn = ~paste0(., '_rank'),.cols=as.character(names(svi_wui[,2:18])))%>%
  mutate(directional_median_hh_income_3_rank=-1*median_hh_income_3_rank,.keep="unused")%>%
  mutate(across(!GEOID,percent_rank))%>%
  mutate(overall_sum=
           weights[1]*poverty_percent_below_1_rank+##Socioeconomic
           weights[2]*civ_labor_force_unemployed_percent_2_rank+
           weights[3]*directional_median_hh_income_3_rank+
           weights[4]*no_hs_degree_percent_4_rank+
           weights[5]*over_65_percent_5_rank+                ## Household Composition
           weights[6]*under_18_percent_6_rank+
           weights[7]*disabled_adult_percent_7_rank+         
           weights[8]*single_householder_percent_8_rank+
           weights[9]*percent_minority_9_rank+               ## Minority status
           weights[10]*eng_proficiency_rank+
           weights[11]*over_10_rank+         ## Housing/Transportation
           weights[12]*mobile_units_rank+
           weights[13]*over_1_person_room_percent_13_rank+
           weights[14]*no_vehicle_percent_14_rank+
           weights[15]*group_quarters_percent_15_rank+
           weights[16]*Gini_income_rank+                      ## Inequality measures
           weights[17]*Gini_education_rank,
         wfsvi=percent_rank(overall_sum))%>%
  mutate(wfsvi_qualify=ifelse(wfsvi>=.75,1,0))%>%
  left_join(., cbg_geo)%>%
  st_as_sf()

saveRDS(wfsvi,file='Build/Output/wfsvi.rds')
saveRDS(weights,file='Build/Cache/weights.rds')
rm(weights, svi_wui, wfsvi, cbg_geo)

print('COMPLETE')



