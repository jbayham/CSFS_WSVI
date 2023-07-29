### Monte Carlo Simulation 
### We assume the each variable in the CBGs normally distribute because most CBGs have population greater than 30,  hence we can use the cental limit theorem

wfsvi_j40 <- readRDS('Build/Output/wfsvi_j40.rds')
svi_wui <- readRDS('Build/Output/svi_wui.rds')
cbg_geo <- read_sf("Build/Cache/tl_2022_08_bg/tl_2022_08_bg.shp")%>%
  dplyr::select(GEOID)

n_iterations <- 5# Set the number of iterations
qualify_counts <- numeric(nrow(svi_wui))# Initialize a vector to store the results

# Run the simulation
for (i in 1:n_iterations) {
  
  # Generate random data
  cbg_data <- DBI::dbConnect(SQLite(), dbname='Build/Cache/cbg_data.sqlite')
  var_1 <-tbl(cbg_data,"var_1_cbg_data")%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%#convert from long to wide farmat
    mutate(poverty_percent_below_1=(C17002_002+C17002_003)/C17002_001)%>%#calculate % of pop below 1
    dplyr::select(GEOID,poverty_percent_below_1)
  
    var_2 <- tbl(cbg_data, 'var_2_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(civ_labor_force_unemployed_percent_2=B23025_005/B23025_003)%>%
    dplyr::select(GEOID,civ_labor_force_unemployed_percent_2)
  
  var_3 <- tbl(cbg_data, 'var_3_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    rename(median_hh_income_3 = B19013_001)
  
  var_4 <- tbl(cbg_data, 'var_4_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(no_hs_degree_percent_4=(B15003_002+B15003_003+B15003_004+B15003_005+B15003_006+B15003_007+B15003_008+B15003_009+B15003_010+B15003_011+B15003_012+B15003_013+B15003_014+B15003_015+B15003_016)/B15003_001)%>%
    dplyr::select(GEOID,no_hs_degree_percent_4)
  
  var_5 <- tbl(cbg_data, 'var_5_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(over_65_percent_5=(B01001_020+B01001_021+B01001_022+B01001_023+B01001_024+B01001_025+B01001_044+B01001_045+B01001_046+B01001_047+B01001_048+B01001_049)/B01001_001)%>%
    dplyr::select(GEOID,over_65_percent_5)
  
  var_5 <- tbl(cbg_data, 'var_5_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(over_65_percent_5=(B01001_020+B01001_021+B01001_022+B01001_023+B01001_024+B01001_025+B01001_044+B01001_045+B01001_046+B01001_047+B01001_048+B01001_049)/B01001_001)%>%
    dplyr::select(GEOID,over_65_percent_5)
  
  var_6 <- tbl(cbg_data, 'var_6_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(under_18_percent_6=(B01001_003+B01001_004+B01001_005+B01001_006+B01001_027+B01001_028+B01001_029+B01001_030)/B01001_001)%>%
    dplyr::select(GEOID, under_18_percent_6)
  
  var_7 <- tbl(cbg_data, 'var_7_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(disabled_adult_percent_7=(C21007_005+C21007_008+C21007_012+C21007_015+C21007_020+C21007_023+C21007_027+C21007_030)/C21007_001)%>%
    dplyr::select(GEOID,disabled_adult_percent_7)
  
  var_8 <- tbl(cbg_data, 'var_8_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(single_householder_percent_8=(B23007_021+B23007_026)/B23007_001)%>%
    dplyr::select(GEOID,single_householder_percent_8)
  
  var_9 <- tbl(cbg_data, 'var_9_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(percent_minority_9=(B02001_001-B02001_002+B03002_013)/B02001_001)%>%
    dplyr::select(GEOID,percent_minority_9)
  
  var_10 <- tbl(cbg_data, 'var_10_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(eng_proficiency=(B16004_007+B16004_008+B16004_012+B16004_013+B16004_017+B16004_018+B16004_022+B16004_023+B16004_029+B16004_030+B16004_034+B16004_035+
                              B16004_039+B16004_040+B16004_044+B16004_045+B16004_051+B16004_052+B16004_056+B16004_057+B16004_061+B16004_062+B16004_066+B16004_067)/B16004_001)%>%
    dplyr::select(GEOID,eng_proficiency)
  
  var_11 <- tbl(cbg_data, 'var_11_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(over_10=(B25024_007+B25024_008+B25024_009)/B25024_001)%>%
    dplyr::select(GEOID,over_10)
  
  var_12 <- tbl(cbg_data, 'var_12_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(mobile_units= B25024_010/B25024_001)%>%
    dplyr::select(GEOID, mobile_units)
  
  var_13 <- tbl(cbg_data, 'var_13_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(over_1_person_room_percent_13=(B25014_001-B25014_003-B25014_004-B25014_009-B25014_010)/B25014_001)%>%
    dplyr::select(GEOID,over_1_person_room_percent_13)
  
  var_14 <- tbl(cbg_data, 'var_14_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(no_vehicle_percent_14=(B25044_003+B25044_010)/B25044_001)%>%
    dplyr::select(GEOID,no_vehicle_percent_14)
  
  var_15 <- tbl(cbg_data, 'var_15_cbg_data')%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(group_quarters_percent_15 = B09019_026/B09019_001)%>%
    dplyr::select(GEOID,group_quarters_percent_15)
  
  var_16_data <- tbl(cbg_data, "var_16_cbg_data_gini")%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)
  #calculate GINI coefficient
  var_16 <- select(var_16_data, GEOID)# Create an empty vector to store the Gini coefficients
  gini_coefficients <- numeric(nrow(var_16_data))
  
  for (i in 1:nrow(var_16_data)) {
    gini_coefficients[i] <- Gini(as.vector(unlist(var_16_data[i, -1])))
  }
  var_16$Gini_income <- gini_coefficients# Add the Gini coefficients as a new column
  rm(var_16_data)
  
  var_17_data <- tbl(cbg_data, "var_17_cbg_data_gini")%>%
    as.data.frame()%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)
  #calculate GINI coefficient
  var_17 <- select(var_17_data, GEOID)# Create an empty vector to store the Gini coefficients
  gini_coefficients <- numeric(nrow(var_17_data))
  
  for (i in 1:nrow(var_17_data)) {
    gini_coefficients[i] <- Gini(as.vector(unlist(var_17_data[i, -1])))
  }
  var_17$Gini_education <- gini_coefficients# Add the Gini coefficients as a new column
  dbDisconnect(cbg_data)
  rm(var_17_data, cbg_data, gini_coefficients, i)
  
  simulated_SVI_var<-var_1%>%
    left_join(.,var_2)%>%
    left_join(.,var_3)%>%
    left_join(.,var_4)%>%
    left_join(.,var_5)%>%
    left_join(.,var_6)%>%
    left_join(.,var_7)%>%
    left_join(.,var_8)%>%
    left_join(.,var_9)%>%
    left_join(.,var_10)%>%
    left_join(.,var_11)%>%
    left_join(.,var_12)%>%
    left_join(.,var_13)%>%
    left_join(.,var_14)%>%
    left_join(.,var_15)%>%
    left_join(.,var_16)%>%
    left_join(.,var_17)
  
  # Analyze the data
  # CBG found to have wui. 
  GEOID <- svi_wui%>%
    left_join(., cbg_geo)%>%
    st_as_sf()%>%
    dplyr::select(GEOID)
  
  simulated_svi_wui <- right_join(simulated_SVI_var, GEOID)%>%
    st_drop_geometry()
  weights<- c(1.25,.75,1.25,.75,.25,.25,.5,.25,1.25,.5,0,.5,0,.25,0,1.25,1.25)
  
  #NB: Reverse direction of HH income
  simulated_wfsvi <- simulated_svi_wui%>%
    rename_with( .fn = ~paste0(., '_rank'),.cols=as.character(names(simulated_svi_wui[,2:18])))%>%
    mutate(directional_median_hh_income_3_rank=-1*median_hh_income_3_rank,.keep="unused")%>%
    mutate(across(!GEOID,percent_rank))%>%
    mutate(overall_sum=
             weights[1]*poverty_percent_below_1_rank+##Socioeconomic
             weights[2]*civ_labor_force_unemployed_percent_2_rank+
             weights[3]*directional_median_hh_income_3_rank+
             weights[4]*no_hs_degree_percent_4_rank+
             weights[5]*over_65_percent_5_rank+                ## Household Composition
             weights[6]*under_18_percent_6_rank+
             weights[7]*disabled_adult_percent_7_rank+         
             weights[8]*single_householder_percent_8_rank+
             weights[9]*percent_minority_9_rank+               ## Minority status
             weights[10]*eng_proficiency_rank+
             weights[11]*over_10_rank+         ## Housing/Transportation
             weights[12]*mobile_units_rank+
             weights[13]*over_1_person_room_percent_13_rank+
             weights[14]*no_vehicle_percent_14_rank+
             weights[15]*group_quarters_percent_15_rank+
             weights[16]*Gini_income_rank+                      ## Inequality measures
             weights[17]*Gini_education_rank,
           wfsvi=percent_rank(overall_sum))%>%
    mutate(qualifying_cbg=ifelse(wfsvi>=.75,1,0))
  
  rm(var_1,var_2,var_3,var_4,var_5,var_6,var_7,var_8,var_9,var_10,var_11,var_12,var_13,var_14,var_15,var_16,var_17)
  
  # Count the number of times each row qualifies
  qualify_counts <- ifelse(is.na(new_wfsvi$qualifying_cbg), 0, qualify_counts + new_wfsvi$qualifying_cbg)
  
}

simulated_wfsvi$qualify_counts <- qualify_counts
simulated_wfsvi$percent_qualify <- (qualify_counts/n_iterations*100)%>%
  round(1)

## Attach geometries CBG geometries and convert to sf
simulated_wfsvi_sf <- simulated_wfsvi%>%
  as.data.frame()%>%
  merge(., cbg_geo, by = 'GEOID', all.x=TRUE)%>%
  st_as_sf()

#Plot the simulation results
ggplot()+
  geom_sf(data = simulated_wfsvi_sf, aes(fill = percent_qualify), color = 'NA')

