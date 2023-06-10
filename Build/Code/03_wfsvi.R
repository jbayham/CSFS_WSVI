### This script marks CBGs that contain at least some WUI.  Only these CBGs will be ranked in the WFSVI
## Load CO wide data set
SVI <- readRDS('Build/Cache/SVI.rds')

##add in geometry for the census block groups from ACS.
##download shape file from: https://www.census.gov/cgi-bin/geo/shapefiles/index.php. 
###################  
#Move this chunk to its own script or function because it only needs to be done once.
download.file(url="ftp://ftp2.census.gov/geo/tiger/TIGER2022/BG/tl_2022_08_bg.zip",
              destfile = "Build/Cache/tl_2022_08_bg.zip")

unzip("Build/Cache/tl_2022_08_bg.zip",exdir = "Build/Cache/tl_2022_08_bg")
###################
cbg_geo <- read_sf("Build/Cache/tl_2022_08_bg/tl_2022_08_bg.shp") %>%
  dplyr::select(GEOID)

#Join SVI to cbg layer
SVI_geo <- SVI %>%
  dplyr::left_join(cbg_geo,.)


saveRDS(SVI_geo, file = 'Build/Cache/SVI_geo.rds')
rm(cbg_geo)

SVI_geo <- readRDS('Build/Cache/SVI_geo.rds')

###########################
##
#This section should be moved to a script (e.g., 03_wui.R)
##
#Connect to the raster file
wui <- rast("Build/Data/WUI.tif") %>% 
  terra::project(x=.,y=terra::crs(SVI_geo),threads=T)

#reclassify zeros as NA
NAflag(WUI) <- 0

#count the number of non-NA (any WUI) cells in each CBG
cbg_wui <- exact_extract(wui_reclass,cbg_geo,
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

###################
#move to analysis
#check the fraction of CBGs that qualify and have WUI
st_set_geometry(wfsvi_cbg,NULL) %>%
  summarize(check=sum((qualify_svi+wui_flag)==2,na.rm=T)) 

st_set_geometry(wfsvi_cbg,NULL) %>%
  summarize(check=sum((qualify_svi)==1,na.rm=T))

#Plot the qualifying CBGs with WUI areas inside. . 
ggplot()+
  geom_sf(data = wfsvi_cbg, fill = 'red', color = 'NA', alpha = 0.5)