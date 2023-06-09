#This is the master script which can load and all the other scripts in the prefered order

source("Build/Code/00_init.R")# 1. run script 00_init.R load packages
source("Build/Code/01_get_data.R")# 2. script 02_get_data. download and organize data from ACS
source("Build/Code/02_new_svi.R")# 3. script 02_new_svi creat the final index.  
source("Build/Code/03_wfsvi.R")# 4. filter CBGs that qualify

# 5. Plot the final qualifying CBGs
counties <- read_sf("Build/data/county_map/cb_2018_us_county_500k.shp")%>%
  dplyr::filter(STATEFP=='08')

ggplot()+
  geom_sf(data = wfsvi_cbg, fill = 'red', color = 'NA', alpha = 0.5)+
  geom_sf(data = counties, fill= "Transparent")+
  geom_sf_text(data = counties, aes(label=NAME), size=1.5, nudge_x = -0.09, nudge_y = 0.09)




