
###Download geometries.

##add in geometry for the census block groups from ACS.
##download shape file from: https://www.census.gov/cgi-bin/geo/shapefiles/index.php. 
###################  

#Move this chunk to its own script or function because it only needs to be done once.
download.file(url="ftp://ftp2.census.gov/geo/tiger/TIGER2022/BG/tl_2022_08_bg.zip",
              destfile = "Build/Cache/tl_2022_08_bg.zip")

unzip("Build/Cache/tl_2022_08_bg.zip",exdir = "Build/Cache/tl_2022_08_bg")
###################
