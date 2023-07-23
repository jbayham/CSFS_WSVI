### This script downloads the J40 data set and identifies CBGs that are within any disadvantaged tracts in J40
### Justice 40 Initiative (J40) identifies disadvantaged communities using various criteria.
wfsvi <- readRDS('Build/Output/wfsvi.rds')

j40_tracts <- read.csv("Build/Cache/1.0-communities.csv")%>%
  filter(State.Territory=='Colorado')%>%
  dplyr::select(Census.tract.2010.ID, Identified.as.disadvantaged)

wfsvi$tract_ID <-  substr(wfsvi$GEOID, 2, 11)
wfsvi_j40 <- merge(wfsvi, j40_tracts, by.x= 'tract_ID', by.y='Census.tract.2010.ID', all.x=TRUE)%>%
  mutate(j40_qualify = if_else(coalesce(Identified.as.disadvantaged, 'False')=='True', 1, 0))%>%
  mutate(qualifying_cbg = if_else(wfsvi_qualify==1|j40_qualify==1, 1, 0))

saveRDS(wfsvi_j40, file='Build/Output/wfsvi_j40.rds')
rm(j40_tracts, wfsvi, wfsvi_j40)

print('COMPLETE')
