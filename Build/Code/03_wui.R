### This script marks CBGs that contain at least some WUI.  Only these CBGs will be ranked in the WFSVI
SVI_geo <- readRDS('Build/Cache/SVI_geo.rds')%>%
  st_as_sf()

cbg_geo <- read_sf("Build/Cache/tl_2022_08_bg/tl_2022_08_bg.shp")%>%
  dplyr::select(GEOID)%>%
  filter(GEOID %in% SVI_geo$GEOID)#filter GEOIDs in the SVI data only.

#Connect to the raster file
#wui_raster <- raster("Build/Data/WildlandUrbanInterface_COWRA22/WildlandUrbanInterface_COWRA22.tif")

# Convert the raster to a SpatRaster object and reproject
wui_spat <- terra::rast("Build/Data/WildlandUrbanInterface_COWRA22/WildlandUrbanInterface_COWRA22.tif")
wui <- terra::project(wui_spat, terra::crs(SVI_geo))

#reclassify zeros as NA
terra::NAflag(wui) <- 0

#count the number of non-NA (any WUI) cells in each CBG
cbg_wui <- exact_extract(wui,cbg_geo,
                         'count',append_cols="GEOID",progress=T)

#create flag=1 if there is any WUI in the cbg
cbg_wui_flag <- cbg_wui %>% 
  mutate(wui_flag=as.numeric(count>0)) %>%
  select(-count)

#Join the wui flag back to the SVI data
svi_wui <- inner_join(SVI_geo,cbg_wui_flag,by = "GEOID")%>%
  dplyr::filter(wui_flag==1)%>%
  st_drop_geometry()

#Save output layer
saveRDS(svi_wui,file='Build/Output/svi_wui.rds')
st_write(svi_wui,"Build/Output/svi_wui.gpkg",append=F)

rm(cbg_geo, cbg_wui, cbg_wui_flag, svi_wui, SVI_geo, wui, wui_raster, wui_spat)

print('COMPLETE')

