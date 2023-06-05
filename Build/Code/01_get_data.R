#This script gets data from Census ACS using tidycensus and organizes the variables for the next scripts 
#Variable in the ACS database names are preserved. 
#variable codes and description can be found by running the command: tidyselect::load_variables(year, "acs5")


#Set parameters
request_geo <- "block group"
request_year <- 2021

### Percentage of poverty status checked individuals who are below poverty line
### NB: poverty_pop_checked = C17002e1, poverty_pop_under_50 = C17002e2  and poverty_pop_50_99 = C17002e3
var_1 <- tidycensus::get_acs(geography = request_geo, variables = c("C17002_001", "C17002_002", "C17002_003"), state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%#select relevant var
  pivot_wider(names_from = variable, values_from = estimate)%>%#convert from long to wide farmat
  mutate(poverty_percent_below_1=(C17002_002+C17002_003)/C17002_001)%>%#calculate % of pop below 1
  dplyr::select(GEOID,poverty_percent_below_1)

### Percent of the Civilian population 16 and older who are unemployed.  These are classified as people in the workforce (IE are actively seeking work)
### civilian labor force = B23025e3; civilian labor force unemployed = B23025e5)
var_2 <- tidycensus::get_acs(geography = request_geo, variables = c("B23025_003", "B23025_005") , state = "08", year = request_year)%>% 
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(civ_labor_force_unemployed_percent_2=B23025_005/B23025_003)%>%
  dplyr::select(GEOID,civ_labor_force_unemployed_percent_2)

### Per capita income is being replaced by median household income, which I prefer as a measure as it is not suseptible to upward bias from a few incomes
### median household income = B19013_001
var_3 <-  tidycensus::get_acs(geography = request_geo, variables = c("B19013_001") , state = "08", year = request_year)%>% 
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  rename(median_hh_income_3=B19013_001)

### Percent no HS diploma, this is only measured for those over 25 years old.  I am including a GED as HS diploma
### variables below show percentage who didn't attain from nursery to grade 12
var_download <- c("B15003_001","B15003_002","B15003_003","B15003_004","B15003_005","B15003_006","B15003_007","B15003_008","B15003_009","B15003_010","B15003_011","B15003_012","B15003_013","B15003_014","B15003_015","B15003_016")
var_4 <- tidycensus::get_acs(geography = request_geo, variables = var_download , state = "08", year = request_year)%>% 
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(no_hs_degree_percent_4=(B15003_002+B15003_003+B15003_004+B15003_005+B15003_006+B15003_007+B15003_008+B15003_009+B15003_010+B15003_011+B15003_012+B15003_013+B15003_014+B15003_015+B15003_016)/B15003_001)%>%
  dplyr::select(GEOID,no_hs_degree_percent_4)
rm(var_download)

### Percent over 65 years old
var1_download <- c("B01001_001","B01001_020","B01001_021","B01001_022","B01001_023","B01001_024","B01001_025","B01001_044","B01001_045","B01001_046","B01001_047","B01001_048","B01001_049")
var_5 <- tidycensus::get_acs(geography = request_geo, variables = var1_download , state = "08", year = request_year)%>% 
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(over_65_percent_5=(B01001_020+B01001_021+B01001_022+B01001_023+B01001_024+B01001_025+B01001_044+B01001_045+B01001_046+B01001_047+B01001_048+B01001_049)/B01001_001)%>%
  dplyr::select(GEOID,over_65_percent_5)
rm(var1_download)


### Percent under 18 years old
### variables listed below shows number of people within certain age category.  
var2_download <- c("B01001_001", "B01001_003", "B01001_004", "B01001_005", "B01001_006", "B01001_027", "B01001_028", "B01001_029", "B01001_030")
var_6 <- tidycensus::get_acs(geography = request_geo, variables = var2_download,  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(under_18_percent_6=(B01001_003+B01001_004+B01001_005+B01001_006+B01001_027+B01001_028+B01001_029+B01001_030)/B01001_001)%>%
  dplyr::select(GEOID, under_18_percent_6)
rm(var2_download)  

### Percent with disability over 18, this is as a percent of people who have been examined for poverty status determination
var3_download <- c("C21007_001", "C21007_005", "C21007_008", "C21007_012","C21007_015", "C21007_020", "C21007_023", "C21007_027", "C21007_030")
var_7 <- tidycensus::get_acs(geography = request_geo, variables = var3_download,  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(disabled_adult_percent_7=(C21007_005+C21007_008+C21007_012+C21007_015+C21007_020+C21007_023+C21007_027+C21007_030)/C21007_001)%>%
  dplyr::select(GEOID,disabled_adult_percent_7)
rm(var3_download)




### Percent single parent households of households with children under 18
### households with own children = B23007_001, male single householder = B23007e21, fem_single_householder=B23007e26
var_8<- tidycensus::get_acs(geography = request_geo, variables = c("B23007_001", "B23007_021", "B23007_026"),  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(single_householder_percent_8=(B23007_021+B23007_026)/B23007_001)%>%
  dplyr::select(GEOID,single_householder_percent_8)
  
### Percent of Minority people
###estimate total = B02001_001, white alone=B02001_002, white_hispanic=B03002_013 
var_9 <- tidycensus::get_acs(geography = request_geo, variables = c("B02001_001", "B02001_002", "B03002_013"),  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(percent_minority_9=(B02001_001-B02001_002+B03002_013)/B02001_001)%>%
  dplyr::select(GEOID,percent_minority_9)

#### Percent of people who speak English less than "well"
### variables are for people from different backgrounds who do not speak English "well"
var_download <- c("B16004_001", "B16004_007", "B16004_008", "B16004_012", "B16004_013", "B16004_017", "B16004_018", "B16004_022", "B16004_023", "B16004_029",
                  "B16004_030", "B16004_034", "B16004_035", "B16004_039", "B16004_040", "B16004_044", "B16004_045", "B16004_051", "B16004_052", "B16004_056",
                  "B16004_057", "B16004_061", "B16004_062", "B16004_066", "B16004_067")
var_10 <-  tidycensus::get_acs(geography = request_geo, variables = var_download,  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(eng_proficiency=(B16004_007+B16004_008+B16004_012+B16004_013+B16004_017+B16004_018+B16004_022+B16004_023+B16004_029+B16004_030+B16004_034+B16004_035+
                            B16004_039+B16004_040+B16004_044+B16004_045+B16004_051+B16004_052+B16004_056+B16004_057+B16004_061+B16004_062+B16004_066+B16004_067)/B16004_001)%>%
  dplyr::select(GEOID,eng_proficiency)
rm(var_download)

#### Percentage of housing units with 10 or more units in structure
var_11 <- tidycensus::get_acs(geography = request_geo, variables = c("B25024_001", "B25024_007", "B25024_008", "B25024_009"),  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(over_10=(B25024_007+B25024_008+B25024_009)/B25024_001)%>%
  dplyr::select(GEOID,over_10)

#### Percentage of houses that are mobile homes
var_12 <- tidycensus::get_acs(geography = request_geo, variables = c("B25024_001",  "B25024_010"), state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(mobile_units= B25024_010/B25024_001)%>%
  dplyr::select(GEOID, mobile_units)

#### Percent of homes with more than  one occupant per room
###total_units=B25014_001, owner_less_50=B25014_003, owner_51_100=B25014_004, renter_less_50=B25014_009, renter_51_100=B25014_010
var_13 <- tidycensus::get_acs(geography=request_geo, variables=c("B25014_001","B25014_003","B25014_004","B25014_009","B25014_010"), state="08", year=request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(over_1_person_room_percent_13=(B25014_001-B25014_003-B25014_004-B25014_009-B25014_010)/B25014_001)%>%
  dplyr::select(GEOID,over_1_person_room_percent_13)

#### Percent of households with no vehicle
### total_units=B25044_001, owner_no_vehicle=B25044_003, renter_no_vehicle=B25044_0010
var_14 <- tidycensus::get_acs(geography = request_geo, variables = c("B25044_001","B25044_003","B25044_010"), state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(no_vehicle_percent_14=(B25044_003+B25044_010)/B25044_001)%>%
  dplyr::select(GEOID,no_vehicle_percent_14)


### Percent of the population that lives in group quarters
### households= B09019_001, group_quarters = B09019_026
var_15 <- tidycensus::get_acs(geography = request_geo, variables = c("B09019_001", "B09019_026"), state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(group_quarters_percent_15 = B09019_026/B09019_001)%>%
  dplyr::select(GEOID,group_quarters_percent_15)

### Creating GINI coefficient for income.
##### Gathering the household income bins to calculate GINI coefficient for Income
var_download <- c( "B19001_001","B19001_002","B19001_003","B19001_004","B19001_005","B19001_006", "B19001_007","B19001_008",
                   "B19001_009","B19001_010","B19001_011","B19001_012","B19001_013","B19001_014", "B19001_015","B19001_016","B19001_017")
var_16_data <- tidycensus::get_acs(geography = request_geo, variables = var_download, state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)

var_16<-data.frame(1:nrow(var_16_data),1:nrow(var_16_data))%>%
  rename(GEOID=X1.nrow.var_16_data.,
         gini_income=X1.nrow.var_16_data..1)
#calculate GINI coefficient
for (i in 1:nrow(var_16_data)) {
  var_16[i, 1] <- as.character(var_16_data[i, 1])
  incomes <- c(0, 10, 15, 20, 25, 30, 35, 40, 45, 50, 60, 75, 100, 125, 150, 200)
  frequencies <- as.numeric(var_16_data[i, 3:18])
  var_16[i, 2] <- ineq::Gini(incomes, frequencies)
}
rm(var_16_data,var_download, incomes, frequencies)

  
#### GINI for education
##### Collecting and calculating the education Gini  This is done by years of schooling for those over age 25
var_download <- c("B15003_001","B15003_002","B15003_003","B15003_004","B15003_005","B15003_006","B15003_007","B15003_008","B15003_009","B15003_010","B15003_011","B15003_012",
                  "B15003_013","B15003_014","B15003_015","B15003_016","B15003_017","B15003_018","B15003_019","B15003_020","B15003_021","B15003_022","B15003_023","B15003_024","B15003_025") 

var_17_data <- tidycensus::get_acs(geography = request_geo, variables = var_download, state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)

var_17<-data.frame(1:nrow(var_17_data),1:nrow(var_17_data))%>%
  rename(GEOID=X1.nrow.var_17_data.,
         gini_education=X1.nrow.var_17_data..1)
###calculate GINI coefficient
for (i in 1:nrow(var_17_data)) {
  var_17[i, 1] <- as.character(var_17_data[i, 1])
  ed_weights <- c(0,.5,1,2,3,4,5,6,7,8,9,10,11,12,13,13,13,13.5,14,14,16,18,20,20)
  frequencies <- as.numeric(var_17_data[i, 3:26])
  var_17[i, 2] <- ineq::Gini(ed_weights, frequencies)
}
rm(var_17_data, incomes, frequencies, ed_weights, var_download)

SVI_data<-var_1%>%
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
if(!dir.exists("./Build/Cache/")){
  dir.create("./Build/Cache/")
}     

### Removing non WUI CBGs
save(SVI_data,file='./Build/Cache/SVI_data.RData')
rm(var_1,var_2,var_3,var_4,var_5,var_6,var_7,var_8,var_9,var_10,var_11,var_12,var_13,var_14,var_15,var_16,var_17,var_16_data,var_17_data,ed_weights,SVI_data,i)
rm(request_geo, request_year)















