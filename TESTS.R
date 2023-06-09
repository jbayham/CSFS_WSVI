#This script gets data from ACS using tidycensus. 


j40 <- read_sf("C:/Users/Vomitadyo/OneDrive - Colostate/Desktop/j4o/usa.shp")%>%
  filter(SF=='Colorado')%>%
  st_make_valid()


ggplot()+
  geom_sf(data = j40)


