### This script marks CBGs that contain at least some WUI.  Only these CBGs will be ranked in the WFSVI
## Load CO wide data set
load('./Build/Cache/SVI.RData')

##add in geometry for the census block groups from ACS.
##download shape file from: https://www.census.gov/cgi-bin/geo/shapefiles/index.php. 
cbg_geo <- read_sf("Build/data/geometry_08/tl_2022_08_bg.shp")%>%
  dplyr::select(GEOID)

SVI_data <- SVI%>%
  dplyr::left_join(.,cbg_geo)%>%
  st_as_sf()%>%
  st_transform(4269)%>%
  st_make_valid()
save(SVI_data, file = './Build/Cache/SVI_data.RData')
rm(cbg_geo)

## Load WUI boundary and mark CBGs that contain WUI parts.
WUI<-read_sf('Build/data/2017_wui/2017_wui.shp')%>%
  dplyr::filter(GRIDCODE==1)%>%
  st_as_sf()%>%
  st_transform(4269)%>%
  st_make_valid()

cbg_with_WUI <- st_join(SVI_data, WUI, st_intersects)# intersecting polygons

#since we are only interested in selecting CBGs with a certain WUI part.
#we are not interested in knowing which specif areas intersetc
#therefore we can eliminated repeated CBGs 
unique_cbg <- subset(cbg_with_WUI, !duplicated(cbg_with_WUI$GEOID))
unique_cbg$part_of_WUI <- ifelse(is.na(unique_cbg$ID), 0, 1)
wfsvi_cbg <- dplyr::filter(unique_cbg, qualify==1 & part_of_WUI==1)#find final CBGs that qualify

if(!dir.exists("./Build/Cache/")){
  dir.create("./Build/Cache/")
}

#Plot the qualifying CBGs with WUI areas inside. . 
ggplot()+
  geom_sf(data = wfsvi_cbg, fill = 'red', color = 'NA', alpha = 0.5)

save(unique_cbg,file='./Build/Cache/wfsvi_cbg.RData')
rm(SVI_data,WUI, cbg_with_WUI, unique_cbg, SVI)

