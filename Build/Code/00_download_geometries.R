
###Download geometries.

##add in geometry for the census block groups from ACS.
##download shape file from: https://www.census.gov/cgi-bin/geo/shapefiles/index.php. 

## CBG geometry  
download.file(url="ftp://ftp2.census.gov/geo/tiger/TIGER2022/BG/tl_2022_08_bg.zip",
              destfile = "Build/Cache/tl_2022_08_bg.zip")

unzip("Build/Cache/tl_2022_08_bg.zip",exdir = "Build/Cache/tl_2022_08_bg")


## Census Tract geometry
download.file(url="ftp://ftp2.census.gov/geo/tiger/TIGER_RD18/STATE/08_COLORADO/08/tl_rd22_08_tract.zip",
              destfile = "Build/Cache/tl_2022_08_tract.zip")

unzip("Build/Cache/tl_2022_08_tract.zip",exdir = "Build/Cache/tl_2022_08_tract")
###################

## Download J40 Data in csv format
download.file("https://static-data-screeningtool.geoplatform.gov/data-versions/1.0/data/score/downloadable/1.0-communities.csv",
              destfile = file.path("Build/Cache/1.0-communities.csv"), 
              method = "auto")















