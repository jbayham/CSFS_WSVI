##  This script attaches CBG geometry to the SVI data
SVI_var <- readRDS('Build/Cache/SVI_var.rds')

## Load CO wide data set
cbg_geo <- read_sf("Build/Cache/tl_2022_08_bg/tl_2022_08_bg.shp")%>%
  dplyr::select(GEOID)

#Join SVI to cbg layer
SVI_geo <- SVI_var%>%
  dplyr::right_join(.,cbg_geo)

saveRDS(SVI_geo, file = 'Build/Cache/SVI_geo.rds')
rm(cbg_geo, SVI_var, SVI_geo)
###########################

print('COMPLETE')
