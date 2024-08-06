
###Download geometries.

##add in geometry for the census block groups from ACS.
##download shape file from: https://www.census.gov/cgi-bin/geo/shapefiles/index.php. 

## CBG geometry  
download.file(url="https://www2.census.gov/geo/tiger/TIGER2023/BG/tl_2023_08_bg.zip",
              destfile = "Build/Cache/tl_2023_08_bg.zip")

unzip("Build/Cache/tl_2023_08_bg.zip",exdir = "Build/Cache/tl_2023_08_bg")


## Census Tract geometry
download.file(url="https://www2.census.gov/geo/tiger/TIGER2023/TRACT/tl_2023_08_tract.zip",
              destfile = "Build/Cache/tl_2023_08_tract.zip")

unzip("Build/Cache/tl_2023_08_tract.zip",exdir = "Build/Cache/tl_2023_08_tract")
###################

## Download J40 Data in csv format
download.file("https://static-data-screeningtool.geoplatform.gov/data-versions/1.0/data/score/downloadable/1.0-communities.csv",
              destfile = file.path("Build/Cache/1.0-communities.csv"), 
              method = "auto")


#Download CO Enviroscreen data from https://data-cdphe.opendata.arcgis.com/datasets/c9c666475d884afbbf62dd3acedbdbb4_0/explore?location=38.930621%2C-105.550850%2C7.32














