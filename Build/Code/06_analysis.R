# Compare 

library(pacman)
p_load(yardstick,xtable)

wfsvi_all_coes %>%
  st_drop_geometry() %>%
  group_by(coes_DIC) %>%
  summarize(wfsvi=mean(wfsvi,na.rm=T))

wfsvi_all_coes %>%
  st_drop_geometry() %>%
  with(.,table(j40,coes_DIC))

conf <- wfsvi_all_coes %>%
  st_drop_geometry() %>%
  mutate(across(c(coes_DIC,wfsvi_qualify),factor)) %>%
  conf_mat(data=.,truth = coes_DIC,estimate = wfsvi_qualify)

print(xtable(conf$table,
             caption = c("Confusion matrix. "),
             #label = "tab:confusion_matrix_state_all",
             digits = 0,
             auto = TRUE),
      #add.to.row = list(pos=list(5),command="\\hline \\\\\n \\multicolumn{6}{l}{\\footnotesize{Note that states are classified based on the following ranges: Very Low (0-20\\%], Low (20-40\\%], Moderate (40-60\\%], High (60-80\\%], Very High (80-100\\%]} }"),
      hline.after = c(-1,0)
)

# ### Analysis
# wfsvi_j40 <- readRDS('Build/Output/wfsvi_j40.rds')
# 
# #check the fraction of CBGs that qualify and have WUI
# st_set_geometry(wfsvi_j40,NULL)%>%
#   summarize(check=sum((qualifying_cbg)==1,na.rm=T))
# 
# # filter qualifying CBGs
# qualifying_cbg <- filter(wfsvi_j40, qualifying_cbg==1)
# 
# #Plot the qualifying CBGs. 
# ggplot()+
#   geom_sf(data = qualifying_cbg, fill = 'red', color = 'NA', alpha = 0.5)
# 
# rm(qualifying_cbg, wfsvi_j40)
# 
# print('COMPLETE')
