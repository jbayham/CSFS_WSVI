#### This script tests the sensitivity of certain non-key varaibles for fire and checks for sensitivity in CBG flip.
load('./Build/Cache/SVI_data.RData')
load('./Build/Index/SVI.RData')
SVI_no_crowding<-SVI_data%>%
  dplyr::select(-units_over_10_percent_11)%>%
  mutate(directional_median_hh_income_3=-1*median_hh_income_3,.keep="unused")%>%
  mutate(across(!census_block_group,percent_rank))%>%
  mutate(overall_sum_no_crowd=rowSums(.[2:17]),
         overall_rank_no_crowd=percent_rank(overall_sum_no_crowd))
SVI_comp_crowd<-SVI%>%
  dplyr::select(census_block_group,overall_sum,overall_rank)%>%
  left_join(.,SVI_no_crowding)%>%
  mutate(qualify_state=ifelse(overall_rank>=.75,1,0),
         qualify_no_crowd=ifelse(overall_rank_no_crowd>=.75,1,0),
         flip_crowd=qualify_state-qualify_no_crowd)
### Seeing the number of counties that flipped
table(SVI_comp_crowd$flip_crowd)
if(!dir.exists("./Build/Index/")){
  dir.create("./Build/Index/")
}     
save(SVI_comp_crowd,file='./Build/Index/SVI_comp_crowd.RData')
rm(SVI_data,SVI,SVI_comp_crowd,SVI_no_crowding)
