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
  unique()%>%
  mutate(WUI=1)%>%
  dplyr::select(census_block_group,WUI)

if(!dir.exists("./Build/Cache/")){
  dir.create("./Build/Cache/")
}     
save(WUI,file='./Build/Cache/WUI_cbg.RData')
rm(SVI_data,WUI)
