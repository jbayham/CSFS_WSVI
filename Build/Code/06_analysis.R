
### Analysis
wfsvi_j40 <- readRDS('Build/Output/wfsvi_j40.rds')

#check the fraction of CBGs that qualify and have WUI
st_set_geometry(wfsvi_j40,NULL)%>%
  summarize(check=sum((qualifying_cbg)==1,na.rm=T))

# filter qualifying CBGs
qualifying_cbg <- filter(wfsvi_j40, qualifying_cbg==1)

#Plot the qualifying CBGs. 
ggplot()+
  geom_sf(data = qualifying_cbg, fill = 'red', color = 'NA', alpha = 0.5)

rm(qualifying_cbg, wfsvi_j40)

print('COMPLETE')
