#This script gets data from ACS using tidycensus. 


j40 <- read_sf("C:/Users/Vomitadyo/OneDrive - Colostate/Desktop/j4o/usa.shp")%>%
  filter(SF=='Colorado')%>%
  st_make_valid()


ggplot()+
  geom_sf(data = j40)

#convert the WUI shapefile to rater format.   
shp <- read_sf("Build/data/2017_wui/2017_wui.shp")
WUI <- raster(shp)
writeRaster(WUI, "Build/Data/WUI.tif", format = "GTiff")
rm(WUI, shp )



library(raster)

# Read the shapefile
shapefile <- read_sf("Build/data/2017_wui/2017_wui.shp")%>%
  dplyr::filter(GRIDCODE==1)%>%
  st_transform(4269)%>%
  st_make_valid()

# Create an empty raster with the desired resolution
raster_template <- raster(extent(shapefile), resolution = 0.01)

# Rasterize the shapefile using the empty raster as a template
raster_file <- rasterize(shapefile, raster_template)

# Save the raster file
writeRaster(raster_file, "Build/Data/WUI.tif",overwrite=TRUE)



