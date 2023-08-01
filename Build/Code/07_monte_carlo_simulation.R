### Monte Carlo Simulation 
### We assume the each variable in the CBGs normally distribute because most CBGs have population greater than 30,  hence we can use the cental limit theorem

wfsvi_j40 <- readRDS('Build/Output/wfsvi_j40.rds')
svi_wui <- readRDS('Build/Output/svi_wui.rds')
cbg_geo <- read_sf("Build/Cache/tl_2022_08_bg/tl_2022_08_bg.shp")%>%
  dplyr::select(GEOID)

# Set parameters
n_iterations <- 1000
qualify_counts <- numeric(nrow(svi_wui))# Initialize a vector to store the results
wfsvi_statistics <- data.frame(matrix(NA, nrow = nrow(svi_wui), ncol = n_iterations))
set.seed(20)

#Build tables for sampling
cbg_data <- DBI::dbConnect(SQLite(), dbname='Build/Cache/cbg_data.sqlite')
tab_shell <- vector("list",17)
tab_shell <- map(1:17,function(x){
  if(x<=15){
    temp_tab <- tbl(cbg_data,paste0("var_",x,"_cbg_data")) %>%
      collect()
  } else {
    temp_tab <- tbl(cbg_data,paste0("var_",x,"_cbg_data_gini")) %>%
      collect()
  }
  
  return(temp_tab)
  })

dbDisconnect(cbg_data)

if(!dir.exists("Build/Cache/sims")) dir.create("Build/Cache/sims")

# Run the simulation
#for (j in 1:n_iterations) {
plan(multisession(workers = 10))
future_walk(c(1:n_iterations),
           function(x){
             
  set.seed(x)
  # Generate random data
  var_1 <-tab_shell[[1]] %>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%#convert from long to wide farmat
    mutate(poverty_percent_below_1=(C17002_002+C17002_003)/C17002_001)%>%#calculate % of pop below 1
    dplyr::select(GEOID,poverty_percent_below_1)
  
  var_2 <- tab_shell[[2]]%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(civ_labor_force_unemployed_percent_2=B23025_005/B23025_003)%>%
    dplyr::select(GEOID,civ_labor_force_unemployed_percent_2)
  
  var_3 <- tab_shell[[3]]%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    rename(median_hh_income_3 = B19013_001)
  
  var_4 <- tab_shell[[4]]%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(no_hs_degree_percent_4=(B15003_002+B15003_003+B15003_004+B15003_005+B15003_006+B15003_007+B15003_008+B15003_009+B15003_010+B15003_011+B15003_012+B15003_013+B15003_014+B15003_015+B15003_016)/B15003_001)%>%
    dplyr::select(GEOID,no_hs_degree_percent_4)
  
  var_5 <- tab_shell[[5]]%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(over_65_percent_5=(B01001_020+B01001_021+B01001_022+B01001_023+B01001_024+B01001_025+B01001_044+B01001_045+B01001_046+B01001_047+B01001_048+B01001_049)/B01001_001)%>%
    dplyr::select(GEOID,over_65_percent_5)
  
  var_6 <- tab_shell[[6]]%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(under_18_percent_6=(B01001_003+B01001_004+B01001_005+B01001_006+B01001_027+B01001_028+B01001_029+B01001_030)/B01001_001)%>%
    dplyr::select(GEOID, under_18_percent_6)
  
  var_7 <- tab_shell[[7]]%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(disabled_adult_percent_7=(C21007_005+C21007_008+C21007_012+C21007_015+C21007_020+C21007_023+C21007_027+C21007_030)/C21007_001)%>%
    dplyr::select(GEOID,disabled_adult_percent_7)
  
  var_8 <- tab_shell[[8]]%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(single_householder_percent_8=(B23007_021+B23007_026)/B23007_001)%>%
    dplyr::select(GEOID,single_householder_percent_8)
  
  var_9 <- tab_shell[[9]]%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(percent_minority_9=(B02001_001-B02001_002+B03002_013)/B02001_001)%>%
    dplyr::select(GEOID,percent_minority_9)
  
  var_10 <- tab_shell[[10]]%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(eng_proficiency=(B16004_007+B16004_008+B16004_012+B16004_013+B16004_017+B16004_018+B16004_022+B16004_023+B16004_029+B16004_030+B16004_034+B16004_035+
                              B16004_039+B16004_040+B16004_044+B16004_045+B16004_051+B16004_052+B16004_056+B16004_057+B16004_061+B16004_062+B16004_066+B16004_067)/B16004_001)%>%
    dplyr::select(GEOID,eng_proficiency)
  
  var_11 <- tab_shell[[11]]%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(over_10=(B25024_007+B25024_008+B25024_009)/B25024_001)%>%
    dplyr::select(GEOID,over_10)
  
  var_12 <- tab_shell[[12]]%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(mobile_units= B25024_010/B25024_001)%>%
    dplyr::select(GEOID, mobile_units)
  
  var_13 <- tab_shell[[13]]%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(over_1_person_room_percent_13=(B25014_001-B25014_003-B25014_004-B25014_009-B25014_010)/B25014_001)%>%
    dplyr::select(GEOID,over_1_person_room_percent_13)
  
  var_14 <- tab_shell[[14]]%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(no_vehicle_percent_14=(B25044_003+B25044_010)/B25044_001)%>%
    dplyr::select(GEOID,no_vehicle_percent_14)
  
  var_15 <- tab_shell[[15]]%>%
    mutate(simulated = abs((rnorm(n(), mean = estimate, sd=(moe/1.645)))))%>%
    dplyr::select(GEOID, variable, simulated)%>%#select relevant var
    pivot_wider(names_from = variable, values_from = simulated)%>%
    mutate(group_quarters_percent_15 = B09019_026/B09019_001)%>%
    dplyr::select(GEOID,group_quarters_percent_15)
  
  var_16_data <- tab_shell[[16]]%>%
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
  
  var_17_data <- tab_shell[[17]]%>%
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
  
  rm(var_17_data, gini_coefficients, i)
  
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
  

  simulated_svi_wui <- inner_join(simulated_SVI_var, select(svi_wui,GEOID))
  
  weights<- c(.122,.0731,.122,.0731,.0244,.0244,.0244,.0244,.122,.0488,0,.0488,0,.0244,0,.122,.122)
  
  #NB: Reverse direction of HH income
  simulated_wfsvi <- simulated_svi_wui%>%
    rename_with( .fn = ~paste0(., '_rank'),.cols=as.character(names(simulated_svi_wui[,2:18])))%>%
    mutate(directional_median_hh_income_3_rank=-1*median_hh_income_3_rank,.keep="unused")%>%
    mutate(across(-GEOID,percent_rank))%>%
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
    mutate(qualifying_cbg=ifelse(wfsvi>=.75,1,0),
           run=x)%>%
    select(GEOID,wfsvi,qualifying_cbg,run)
 
  #return(simulated_wfsvi)
  saveRDS(simulated_wfsvi,paste0("Build/Cache/sims/run_",x,".rds"))
  #qualify_counts <- ifelse(is.na(simulated_wfsvi$qualifying_cbg), 0, qualify_counts + simulated_wfsvi$qualifying_cbg)# Count the number of times each row qualifies
  #wfsvi_statistics[, j] <- simulated_wfsvi$wfsvi# Save the wfsvi values in a separate data frame
  #print(paste("Completed iteration", j, "of", n_iterations))# print progress
},.progress = TRUE) 

#Read all cached simulations
sim_results <- list.files("Build/Cache/sims",pattern = ".rds",full.names = T) %>%
  map_dfr(readRDS) %>%
  mutate(qualifying_cbg = ifelse(is.na(qualifying_cbg) | is.nan(qualifying_cbg),0,qualifying_cbg))


## Simulation results 
sim_results_summary <- sim_results %>%
  group_by(GEOID) %>%
  summarize(percent_qualify = sum(qualifying_cbg)/n_distinct(run),
            wfsvi_mean = mean(wfsvi,na.rm=T),
            wfsvi_l95 = stats::quantile(wfsvi,probs = .05,na.rm = T),
            wfsvi_u95 = stats::quantile(wfsvi,probs = .95,na.rm = T))


saveRDS(sim_results_summary,file='Build/Cache/final_simulated_results.rds')


print('COMPLETE')
