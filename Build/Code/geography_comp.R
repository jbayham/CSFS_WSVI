### This script compares the WUI rankings with the CO rankings
## Load CO wide dataset
load('./Build/Cache/SVI_data.RData')
## add in CO geometries
load('./Build/Data/state_08.rdata')
delist<-function(geog){
  geog%>%
    rename(census_block_group=geoid)%>%
    dplyr::left_join(.,SVI_data)
}
SVI_data<-st_out%>%
  map_dfr(.,delist)%>%
  na.omit()
rm(st_out)
## Load WUI boundary and cut out nonintersecting cbg data
WUI<-read_sf('./Build/Data/2017_wui/2017_wui.shp')%>%
  dplyr::filter(GRIDCODE==1)%>%
  st_transform(4269)%>%
  st_make_valid()%>%
  st_intersection(SVI_data)%>%
  dplyr::select(.,-ID,-GRIDCODE)%>%
  st_set_geometry(NULL)%>%
  unique()
SVI_WUI<-WUI%>%
  mutate(directional_median_hh_income_3=-1*median_hh_income_3,.keep="unused")%>%
  mutate(across(!census_block_group,percent_rank))%>%
  mutate(overall_sum=rowSums(.[2:18]),
         overall_rank=percent_rank(overall_sum))
## Remove the old stuff
rm(SVI_data,WUI)

## Merge with traditional data 
load('./Build/Index/SVI.RData')
SVI_comp<-SVI_WUI%>%
  dplyr::select(census_block_group,overall_sum,overall_rank)%>%
  rename(overall_sum_wui=overall_sum,
         overall_rank_wui=overall_rank)%>%
  right_join(.,SVI)%>%
  mutate(qualify_state=ifelse(overall_rank>=.75,1,0),
         qualify_wui=ifelse(overall_rank_wui>=.75,1,0),
         flip=qualify_state-qualify_wui)
if(!dir.exists("./Build/Index/")){
  dir.create("./Build/Index/")
}     
save(SVI_comp,file='./Build/Index/SVI_comp.RData')
rm(SVI_WUI,SVI)
