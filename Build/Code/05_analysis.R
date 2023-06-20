### Analysis
wfsvi <- readRDS('Build/Output/wfsvi.rds')

#check the fraction of CBGs that qualify and have WUI
#st_set_geometry(wfsvi_cbg,NULL) %>%
  #summarize(check=sum((qualify_svi+wui_flag)==2,na.rm=T)) 

st_set_geometry(wfsvi,NULL) %>%
  summarize(check=sum((qualify)==1,na.rm=T))

# filter qualifying CBGs
qualifying_cbg <- filter(wfsvi, qualify==1)

#Plot the qualifying CBGs. 
ggplot()+
  geom_sf(data = qualifying_cbg, fill = 'red', color = 'NA', alpha = 0.5)

print('COMPLETE')