### This script marks CBGs that contain at least some WUI.  Only these CBGs will be ranked in the WFSVI
## Load CO wide dataset
load('./Build/Cache/SVI_data.RData')

###########################################
## add in CO geometries
load('./Build/Data/state_08.rdata')
delist<-function(geog){
  geog%>%
    rename(census_block_group=geoid)%>%
    dplyr::left_join(.,SVI_data)
}
st_out<-SVI_data%>%
  map_dfr(.,delist)%>%
  na.omit()
rm(st_out)




############################################

##add in CO geometries from a ACS shape file of census block groups.
CO_geometries <- read_sf("Build/data/CO_geometries/state_08.shp")%>%
  st_transform(4269)%>%
  rename(census_block_group=CnssBlG)

SVI_data_geo <- merge(SVI_data, CO_geometries, all.x=TRUE)%>%#attach geometry to SVI_data
  st_as_sf()%>%
  st_transform(4269)
save(SVI_data_geo, file = './Build/Cache/SVI_data_geo.RData')
rm(CO_geometries, SVI_data)

## Load WUI boundary and cut out nonintersecting cbg data and mark intersecting CBGs
WUI<-read_sf('./Build/Data/2017_wui/2017_wui.shp')%>%
  dplyr::filter(GRIDCODE==1)%>%
  st_transform(4269)%>%
  st_make_valid()%>%
  st_intersection(SVI_data_geo)%>%
  dplyr::select(.,-ID,-GRIDCODE)%>%
  st_set_geometry(NULL)%>%
  unique()


if(!dir.exists("./Build/Cache/")){
  dir.create("./Build/Cache/")
}     
save(WUI,file='./Build/Index/WUI_cbg.RData')
rm(SVI_data,WUI)
