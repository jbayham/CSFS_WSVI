##This script adds the WUI indicator from step 3 to the data.  This adds the last variable needed before 
## Calculating the WFSVI
load('./Build/Cache/SVI_data.RData')
load('./Build/Cache/WUI_cbg.RData')

#only add a column which indicates if the GEOID (block group) is inside  or intersect the WUI
WUI_new <- WUI%>%
  select(GEOID)
WUI_new$WUI <- 1 #indicate if the GOEID is in WUI

SVI_dat<-SVI_data%>%
  as.data.frame()%>%
  left_join(.,WUI_new)%>%
  mutate_at(vars(all_of(names(WUI_new))), ~replace(., is.na(.), 0))%>%
  st_as_sf()%>%
  st_transform(4269)

save(SVI_dat,file='./Build/Cache/SVI_dat.RData')  

rm(SVI_data,SVI_dat,WUI,WUI_new)
