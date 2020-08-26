## This script takes the raw data and ranks it all creating the final index
load('./Build/Cache/SVI_data.RData')
SVI<-SVI_data%>%
  mutate(directional_median_hh_income_3=-1*median_hh_income_3,.keep="unused")%>%
  mutate(across(!census_block_group,percent_rank))%>%
  mutate(overall_sum=rowSums(.[2:16]),
         overall_rank=percent_rank(overall_sum))
if(!dir.exists("./Build/Index/")){
  dir.create("./Build/Index/")
}     
save(SVI,file='./Build/Index/SVI.RData')
rm(SVI_data,SVI)
         