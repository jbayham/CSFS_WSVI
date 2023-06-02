#
#unzip the ACS data
untar("C:/Users/Vomitadyo/OneDrive - Colostate/Desktop/testttt/safegraph_open_census_data_2019.tar.gz")

#Unzip the geometry data from acs
untar("C:/Users/Vomitadyo/OneDrive - Colostate/Desktop/TEMP/safegraph_open_census_data_2020_to_2029_geometry.tar.gz", list=TRUE)

CO <- read_sf("cbg_2020.geojson")
state_08 <- statedplyr::filter(CO,  State=='CO')%>%
  rename(census_block_group=CensusBlockGroup)
save(state_08, file = "./Build/Data/state_08.rdata")

rm('CO', 'state_08')


ggplot()+
  geom_sf(data='2017_wui.shp')


co <- read_sf('build/data/2017_wui/2017_wui.shp')

ggplot()+
  geom_sf(data=state_08)

state_081 <- state_08
st_write(state_081, "Build/data/CO_geometries/state_08.shp")


