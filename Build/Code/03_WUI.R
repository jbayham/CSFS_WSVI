### This script marks CBGs that contain at least some WUI.  Only these CBGs will be ranked in the WFSVI
## Load CO wide data set
load('./Build/Cache/SVI_data.RData')

##add in geometry for the census block groups from ACS.
##download shape file from: https://www.census.gov/cgi-bin/geo/shapefiles/index.php. 
cbg_geo <- read_sf("Build/data/geometry_08/tl_2022_08_bg.shp")%>%
  dplyr::select(GEOID)

SVI_data <- SVI_data%>%
  dplyr::left_join(.,cbg_geo)%>%
  st_transform(4269)%>%
  st_make_valid()
save(SVI_data, file = './Build/Cache/SVI_data.RData')
rm(cbg_geo)

## Load WUI boundary and cut out non intersecting cbg data and mark intersecting CBGs
WUI<-read_sf('Build/data/2017_wui/2017_wui.shp')%>%
  dplyr::filter(GRIDCODE==1)%>%
  st_transform(4269)%>%
  st_make_valid()%>%
  st_intersection(SVI_data)%>%
  dplyr::select(.,-ID,-GRIDCODE)%>%
  st_set_geometry(NULL)%>%
  unique()

if(!dir.exists("./Build/Cache/")){
  dir.create("./Build/Cache/")
}     
save(WUI,file='./Build/Cache/WUI_cbg.RData')
rm(SVI_data,WUI)
