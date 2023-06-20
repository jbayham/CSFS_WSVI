### Analysis

wfsvi <- readRDS('Build/Output/wfsvi.rds')

#check the fraction of CBGs that qualify and have WUI
st_set_geometry(wfsvi_cbg,NULL) %>%
  summarize(check=sum((qualify_svi+wui_flag)==2,na.rm=T)) 

st_set_geometry(wfsvi_cbg,NULL) %>%
  summarize(check=sum((qualify_svi)==1,na.rm=T))

#Plot the qualifying CBGs with WUI areas inside. . 
ggplot()+
  geom_sf(data = wfsvi_cbg, fill = 'red', color = 'NA', alpha = 0.5)