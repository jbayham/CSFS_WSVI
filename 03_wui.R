### This script marks CBGs that contain at least some WUI.  Only these CBGs will be ranked in the WFSVI

#Connect to the raster file
wui <- raster("Build/Data/WUI.tif")%>% 
  terra::project(x=.,y=terra::crs(SVI_geo),threads=T)

#reclassify zeros as NA
NAflag(wui) <- 0

#count the number of non-NA (any WUI) cells in each CBG
cbg_wui <- exact_extract(wui,cbg_geo,
                         'count',append_cols="GEOID",progress=T)

#create flag=1 if there is any WUI in the cbg
cbg_wui_flag <- cbg_wui %>% 
  mutate(wui_flag=as.numeric(count>0)) %>%
  select(-count)

#Join the wui flag back to the SVI data
wfsvi_cbg <- inner_join(SVI_geo,cbg_wui_flag,by = "GEOID") %>%
  mutate(qualify_wui=as.numeric((qualify_svi+wui_flag)==2))

#Save output layer
saveRDS(wfsvi_cbg,file='Build/Output/wfsvi_cbg.rds')
st_write(wfsvi_cbg,"Build/Output/wfsvi_cbg.gpkg")


