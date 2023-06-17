##  This script attaches CBG geometry to the SVI data

## Load CO wide data set
SVI <- readRDS('Build/Cache/SVI.rds')

cbg_geo <- read_sf("Build/Cache/tl_2022_08_bg/tl_2022_08_bg.shp")%>%
  dplyr::select(GEOID)

#Join SVI to cbg layer
SVI_geo <- SVI%>%
  dplyr::left_join(cbg_geo,.)

saveRDS(SVI_geo, file = 'Build/Cache/SVI_geo.rds')
rm(cbg_geo)

SVI_geo <- readRDS('Build/Cache/SVI_geo.rds')

###########################
