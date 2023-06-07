##This script adds the WUI indicator from step 3 to the data.  This adds the last variable needed before 
## Calculating the WFSVI
load('./Build/Cache/SVI_data.RData')
load('./Build/Cache/WUI_cbg.RData')

WUI_new <-WUI%>%
  as.data.frame()


SVI_dat<-SVI_data%>%
  as.data.frame()%>%
  left_join(.,WUI)%>%
  mutate_at(vars(WUI), ~replace(., is.na(.), 0))
if(!dir.exists("./Build/ICache/")){
  dir.create("./Build/Cache/")
}     
save(SVI_dat,file='./Build/Cache/SVI_dat.RData')
rm(SVI_data,SVI_dat,WUI)


##########

#try this new code
#only add i column which indicates if the GEOID (block group) is inside  or intersect the WUI
WUI_new <- WUI%>%
  select(GEOID)
WUI_new$WUI <- 1

SVI_dat<-SVI_data%>%
  as.data.frame()%>%
  left_join(.,WUI_new)%>%
  mutate_at(vars(all_of(names(WUI_new))), ~replace(., is.na(.), 0))

save(SVI_dat,file='./Build/Cache/SVI_dat.RData')  
rm(SVI_data,SVI_dat,WUI,WUI_new)

