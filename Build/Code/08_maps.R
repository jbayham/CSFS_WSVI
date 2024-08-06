#This script generates the interactive map to display the layer

#Read data
sim_results <- readRDS("Build/Cache/final_simulated_results.rds") 

wfsvi_j40 <- readRDS('Build/Output/wfsvi_j40.rds') %>%
  st_transform(4326) %>%
  mutate(q_indicator=ifelse(qualifying_cbg==1,"Qualifying","Not Qualifying"),
         across(c(poverty_percent_below_1_rank:wfsvi),~round(.,digits = 2))) %>%
  #inner_join(select(sim_results,GEOID,percent_qualify)) 
  inner_join(sim_results) 



#Set color scale
color_scale <- colorFactor(palette = "viridis",domain = c("Qualifying","Not Qualifying"))

#################
# Create the map
map <- leaflet(data = slice_sample(wfsvi_j40,n=200)) %>%
  addTiles() %>%
  setView(lng = -105.5509, lat = 39.5501, zoom = 7)  # Set initial map view to Colorado

# Add census block groups as polygons
map <- map %>%
  addPolygons(group = "qualifying",
              fillColor = ~color_scale(q_indicator), 
              fillOpacity = 0.4,
              color = "white", 
              weight = 1,
              popup = ~paste0("<b>Block Group ID:</b> ", GEOID,
                              "<br><b>WFSVI:</b> ", wfsvi,
                              "<br><b>Qualifying Frequency:</b> ", percent(percent_qualify,accuracy=1),
                              "<br><b>J40 Qualifying:</b> ", Identified.as.disadvantaged,
                              "<br><b>Poverty (12%):</b> ", poverty_percent_below_1_rank,
                              "<br><b>Unemployed (7%):</b> ", civ_labor_force_unemployed_percent_2_rank,
                              "<br><b>Household Income (12%):</b> ", directional_median_hh_income_3_rank,
                              "<br><b>Education (7%):</b> ", no_hs_degree_percent_4_rank,
                              "<br><b>Over 65 (2%):</b> ", over_65_percent_5_rank,
                              "<br><b>Under 18 (2%):</b> ", under_18_percent_6_rank,
                              "<br><b>Disability (2%):</b> ", disabled_adult_percent_7_rank,
                              "<br><b>Single-parent Family (2%):</b> ", single_householder_percent_8_rank,
                              "<br><b>Minority (12%):</b> ", percent_minority_9_rank,
                              "<br><b>English-speaking (5%):</b> ", eng_proficiency_rank,
                              "<br><b>Mobile Housing (5%):</b> ", mobile_units_rank,
                              "<br><b>No Vehicle (2%):</b> ", no_vehicle_percent_14_rank,
                              "<br><b>Income Inequality (12%):</b> ", Gini_income_rank,
                              "<br><b>Education Inequality (12%):</b> ", Gini_education_rank))

map <- map %>%
  addLegend("bottomright", pal = color_scale, values = c("Qualifying","Not Qualifying"),
            title = NULL) %>%
  addLayersControl(
    overlayGroups = c("qualifying"),
    options = layersControlOptions(collapsed = TRUE)
  )
map
###########################

mapshot(map,url="docs/WFSVI_2024.html")

#Notes for map:
#- the categories in the popup window correspond to the index components described here: original report doc
#- the value reported indicates the percentile where 1 represents the most disadvantaged
#- the percentage reported for each index component represents the weight of the component in the overall WFSVI. Note that the percentages are rounded and may not add to one