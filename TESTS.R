#This script gets data from ACS using tidycensus. 





j40 <- read_sf("C:/Users/Vomitadyo/OneDrive - Colostate/Desktop/j4o/usa.shp")%>%
  filter(SF=='Colorado')%>%
  st_make_valid()


ggplot()+
  geom_sf(data = j40)


aaa <- tidycensus::get_acs(geography = "block", variables = "B01001_001", state = "08", year = 2021)



library(ggplot2)
library(sf)
library(dplyr)
library(tidyverse)

qual <- dplyr::filter(SVI, qualify==1)%>%
  st_as_sf()

aa <- dplyr::filter(SVI_dat, wfsvi>=0.75)
ab <- dplyr::filter(aa, WUI==1)
ggplot()+
  geom_sf(data = aa, fill = 'green', color='NA', alpha = 0.4)+
  geom_sf(data = ab, fill = 'red', color = 'NA', alpha = 0.4)


ars <- tidycensus::load_variables(2021, "acs5")

var_3 <-  tidycensus::get_acs(geography = request_geo, variables = c("B19013_001") , state = "08", year = request_year)%>% 
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%



