#This script gets data from Census ACS using tidycensus and organizes the variables for the next scripts. Set API key using census_api_key("key",install = TRUE)
#Variable in the ACS database names are preserved. 
#variable codes and description can be found by running the command: tidycensus::load_variables(year, "acs5")
#vars <- tidycensus::load_variables(2021, "acs5")
#if CBG level data is missing, tract level values will be used insteady. 

#geometries for census tract and CBGs
tract_geo <- read_sf("Build/Cache/tl_2022_08_tract/tl_rd22_08_tract.shp")%>%
  dplyr::select(GEOID)
cbg_geo <- read_sf("Build/Cache/tl_2022_08_bg/tl_2022_08_bg.shp")%>%
  dplyr::select(GEOID)
cbg_geo_centre <- st_centroid(cbg_geo)#centre points of CBG which will be used to find CBG within certain census tracts

#define parameters
request_geo1 <- "block group" #geography for downloading CBG level data
request_geo2 <- "tract" #geography for downloading census tract level data
request_year <- 2018

##Define function for replacing missing values
replace_missing <- function(df, var_name) {
  df %>%
    mutate(!!var_name := coalesce(!!sym(paste0(var_name, ".x")), !!sym(paste0(var_name, ".y")))) %>%
    select(-c(paste0(var_name, ".x"), paste0(var_name, ".y")))
}
#create sqlite data base to store data for simulation
cbg_data <- dbConnect(SQLite(), dbname='cbg_data.sqlite')

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------
### Percentage of poverty status checked individuals who are below poverty line
### NB: poverty_pop_checked = C17002e1, poverty_pop_under_50 = C17002e2  and poverty_pop_50_99 = C17002e3
var_1_cbg_data <- tidycensus::get_acs(geography = request_geo1, variables = c("C17002_001", "C17002_002", "C17002_003"), state = "08", year = request_year)
dbWriteTable(conn = cbg_data, name = "var_1_cbg_data", value = var_1_cbg_data, row.names = FALSE,overwrite = TRUE) #save for simulation

var_1_cbg <- dplyr::select(var_1_cbg_data, GEOID, variable, estimate)%>%#select relevant var
  pivot_wider(names_from = variable, values_from = estimate)%>%#convert from long to wide farmat
  mutate(poverty_percent_below_1=(C17002_002+C17002_003)/C17002_001)%>%#calculate % of pop below 1
  dplyr::select(GEOID,poverty_percent_below_1)

#Download and calculate variable for census tract level
var_1_tract <- tidycensus::get_acs(geography = request_geo2, variables = c("C17002_001", "C17002_002", "C17002_003"), state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%#select relevant var
  pivot_wider(names_from = variable, values_from = estimate)%>%#convert from long to wide farmat
  mutate(poverty_percent_below_1=(C17002_002+C17002_003)/C17002_001)%>%#calculate % of pop below 1
  dplyr::select(GEOID,poverty_percent_below_1)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%#remove tract GEOID
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% #find cbgs within census tract and attach cbg GEOID. 
  st_drop_geometry() #this is final data of tract level with cbg GEOIDs

#Replace missing values of cgb data with tract values. 
var_list <- c("poverty_percent_below_1")# Define a list of variables to replace missing values for
var_1 <- reduce(var_list, replace_missing, .init = left_join(var_1_cbg, var_1_tract, by = "GEOID"))# Loop through variables and replace missing values
rm(var_1_cbg, var_1_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Percent of the Civilian population 16 and older who are unemployed.  These are classified as people in the workforce (IE are actively seeking work)
### civilian labor force = B23025e3; civilian labor force unemployed = B23025e5)
var_2_cbg <- tidycensus::get_acs(geography = request_geo1, variables = c("B23025_003", "B23025_005") , state = "08", year = request_year)%>% 
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(civ_labor_force_unemployed_percent_2=B23025_005/B23025_003)%>%
  dplyr::select(GEOID,civ_labor_force_unemployed_percent_2)

#Download and calculate variable for census tract level
var_2_tract <- tidycensus::get_acs(geography = request_geo2, variables = c("B23025_003", "B23025_005"), state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(civ_labor_force_unemployed_percent_2=B23025_005/B23025_003)%>%
  dplyr::select(GEOID,civ_labor_force_unemployed_percent_2)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%#remove tract GEOID
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% #find cbgs within census tract and attach cbg GEOID. 
  st_drop_geometry() #this is final data of tract level with cbg GEOIDs

#Replace missing cgb values with tract values. 
var_list <- c("civ_labor_force_unemployed_percent_2")# Define a list of variables to replace missing values for
var_2 <- reduce(var_list, replace_missing, .init = left_join(var_2_cbg, var_2_tract, by = "GEOID"))# Loop through variables and replace missing values
rm(var_2_cbg, var_2_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Per capita income is being replaced by median household income, which I prefer as a measure as it is not suseptible to upward bias from a few incomes
### median household income = B19013_001
var_3_cbg <-  tidycensus::get_acs(geography = request_geo1, variables = c("B19013_001") , state = "08", year = request_year)%>% 
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  rename(median_hh_income_3 = B19013_001)
  
var_3_tract <-  tidycensus::get_acs(geography = request_geo2, variables = c("B19013_001") , state = "08", year = request_year)%>% 
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  rename(median_hh_income_3 = B19013_001)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

var_list <- c("median_hh_income_3")
var_3 <- reduce(var_list, replace_missing, .init = left_join(var_3_cbg, var_3_tract, by = "GEOID"))
rm(var_3_cbg, var_3_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Percent no HS diploma, this is only measured for those over 25 years old.  I am including a GED as HS diploma
### variables below show percentage who didn't attain from nursery to grade 12
var_download <- c("B15003_001","B15003_002","B15003_003","B15003_004","B15003_005","B15003_006","B15003_007","B15003_008","B15003_009","B15003_010","B15003_011","B15003_012","B15003_013","B15003_014","B15003_015","B15003_016")
var_4_cbg <- tidycensus::get_acs(geography = request_geo1, variables = var_download , state = "08", year = request_year)%>% 
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(no_hs_degree_percent_4=(B15003_002+B15003_003+B15003_004+B15003_005+B15003_006+B15003_007+B15003_008+B15003_009+B15003_010+B15003_011+B15003_012+B15003_013+B15003_014+B15003_015+B15003_016)/B15003_001)%>%
  dplyr::select(GEOID,no_hs_degree_percent_4)

var_4_tract <- tidycensus::get_acs(geography = request_geo2, variables = var_download , state = "08", year = request_year)%>% 
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(no_hs_degree_percent_4=(B15003_002+B15003_003+B15003_004+B15003_005+B15003_006+B15003_007+B15003_008+B15003_009+B15003_010+B15003_011+B15003_012+B15003_013+B15003_014+B15003_015+B15003_016)/B15003_001)%>%
  dplyr::select(GEOID,no_hs_degree_percent_4)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

var_list <- c("no_hs_degree_percent_4")
var_4 <- reduce(var_list, replace_missing, .init = left_join(var_4_cbg, var_4_tract, by = "GEOID"))
rm(var_download, var_4_cbg, var_4_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------
 
### Percent over 65 years old
var1_download <- c("B01001_001","B01001_020","B01001_021","B01001_022","B01001_023","B01001_024","B01001_025","B01001_044","B01001_045","B01001_046","B01001_047","B01001_048","B01001_049")
var_5_cbg <- tidycensus::get_acs(geography = request_geo1, variables = var1_download , state = "08", year = request_year)%>% 
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(over_65_percent_5=(B01001_020+B01001_021+B01001_022+B01001_023+B01001_024+B01001_025+B01001_044+B01001_045+B01001_046+B01001_047+B01001_048+B01001_049)/B01001_001)%>%
  dplyr::select(GEOID,over_65_percent_5)

var_5_tract <- tidycensus::get_acs(geography = request_geo2, variables = var1_download , state = "08", year = request_year)%>% 
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(over_65_percent_5=(B01001_020+B01001_021+B01001_022+B01001_023+B01001_024+B01001_025+B01001_044+B01001_045+B01001_046+B01001_047+B01001_048+B01001_049)/B01001_001)%>%
  dplyr::select(GEOID,over_65_percent_5)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

var_list <- c("over_65_percent_5")
var_5 <- reduce(var_list, replace_missing, .init = left_join(var_5_cbg, var_5_tract, by = "GEOID"))
rm(var1_download, var_5_cbg, var_5_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Percent under 18 years old
### variables listed below shows number of people within certain age category.  
var2_download <- c("B01001_001", "B01001_003", "B01001_004", "B01001_005", "B01001_006", "B01001_027", "B01001_028", "B01001_029", "B01001_030")
var_6_cbg <- tidycensus::get_acs(geography = request_geo1, variables = var2_download,  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(under_18_percent_6=(B01001_003+B01001_004+B01001_005+B01001_006+B01001_027+B01001_028+B01001_029+B01001_030)/B01001_001)%>%
  dplyr::select(GEOID, under_18_percent_6)

var_6_tract <- tidycensus::get_acs(geography = request_geo2, variables = var2_download,  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(under_18_percent_6=(B01001_003+B01001_004+B01001_005+B01001_006+B01001_027+B01001_028+B01001_029+B01001_030)/B01001_001)%>%
  dplyr::select(GEOID, under_18_percent_6)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

var_list <- c("under_18_percent_6")
var_6 <- reduce(var_list, replace_missing, .init = left_join(var_6_cbg, var_6_tract, by = "GEOID"))
rm(var2_download, var_6_cbg, var_6_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Percent with disability over 18, this is as a percent of people who have been examined for poverty status determination
var3_download <- c("C21007_001", "C21007_005", "C21007_008", "C21007_012","C21007_015", "C21007_020", "C21007_023", "C21007_027", "C21007_030")
var_7_cbg <- tidycensus::get_acs(geography = request_geo1, variables = var3_download,  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(disabled_adult_percent_7=(C21007_005+C21007_008+C21007_012+C21007_015+C21007_020+C21007_023+C21007_027+C21007_030)/C21007_001)%>%
  dplyr::select(GEOID,disabled_adult_percent_7)


var_7_tract <- tidycensus::get_acs(geography = request_geo2, variables = var3_download,  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(disabled_adult_percent_7=(C21007_005+C21007_008+C21007_012+C21007_015+C21007_020+C21007_023+C21007_027+C21007_030)/C21007_001)%>%
  dplyr::select(GEOID,disabled_adult_percent_7)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

var_list <- c("disabled_adult_percent_7")
var_7 <- reduce(var_list, replace_missing, .init = left_join(var_7_cbg, var_7_tract, by = "GEOID"))
rm(var3_download, var_7_cbg, var_7_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Percent single parent households of households with children under 18
### households with own children = B23007_001, male single householder = B23007e21, fem_single_householder=B23007e26
var_8_cbg <- tidycensus::get_acs(geography = request_geo1, variables = c("B23007_001", "B23007_021", "B23007_026"),  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(single_householder_percent_8=(B23007_021+B23007_026)/B23007_001)%>%
  dplyr::select(GEOID,single_householder_percent_8)

var_8_tract <- tidycensus::get_acs(geography = request_geo2, variables = c("B23007_001", "B23007_021", "B23007_026"),  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(single_householder_percent_8=(B23007_021+B23007_026)/B23007_001)%>%
  dplyr::select(GEOID,single_householder_percent_8)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

var_list <- c("single_householder_percent_8")
var_8 <- reduce(var_list, replace_missing, .init = left_join(var_8_cbg, var_8_tract, by = "GEOID"))
rm(var_8_cbg, var_8_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Percent of Minority people
###estimate total = B02001_001, white alone=B02001_002, white_hispanic=B03002_013 
var_9_cbg <- tidycensus::get_acs(geography = request_geo1, variables = c("B02001_001", "B02001_002", "B03002_013"),  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(percent_minority_9=(B02001_001-B02001_002+B03002_013)/B02001_001)%>%
  dplyr::select(GEOID,percent_minority_9)

var_9_tract <- tidycensus::get_acs(geography = request_geo2, variables = c("B02001_001", "B02001_002", "B03002_013"),  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(percent_minority_9=(B02001_001-B02001_002+B03002_013)/B02001_001)%>%
  dplyr::select(GEOID,percent_minority_9)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

var_list <- c("percent_minority_9")
var_9 <- reduce(var_list, replace_missing, .init = left_join(var_9_cbg, var_9_tract, by = "GEOID"))
rm(var_9_cbg, var_9_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

#### Percent of people who speak English less than "well"
### variables are for people from different backgrounds who do not speak English "well"
var_download <- c("B16004_001", "B16004_007", "B16004_008", "B16004_012", "B16004_013", "B16004_017", "B16004_018", "B16004_022", "B16004_023", "B16004_029",
                  "B16004_030", "B16004_034", "B16004_035", "B16004_039", "B16004_040", "B16004_044", "B16004_045", "B16004_051", "B16004_052", "B16004_056",
                  "B16004_057", "B16004_061", "B16004_062", "B16004_066", "B16004_067")
var_10_cbg <-  tidycensus::get_acs(geography = request_geo1, variables = var_download,  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(eng_proficiency=(B16004_007+B16004_008+B16004_012+B16004_013+B16004_017+B16004_018+B16004_022+B16004_023+B16004_029+B16004_030+B16004_034+B16004_035+
                            B16004_039+B16004_040+B16004_044+B16004_045+B16004_051+B16004_052+B16004_056+B16004_057+B16004_061+B16004_062+B16004_066+B16004_067)/B16004_001)%>%
  dplyr::select(GEOID,eng_proficiency)

var_10_tract <-  tidycensus::get_acs(geography = request_geo2, variables = var_download,  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(eng_proficiency=(B16004_007+B16004_008+B16004_012+B16004_013+B16004_017+B16004_018+B16004_022+B16004_023+B16004_029+B16004_030+B16004_034+B16004_035+
                            B16004_039+B16004_040+B16004_044+B16004_045+B16004_051+B16004_052+B16004_056+B16004_057+B16004_061+B16004_062+B16004_066+B16004_067)/B16004_001)%>%
  dplyr::select(GEOID,eng_proficiency)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

var_list <- c("eng_proficiency")
var_10 <- reduce(var_list, replace_missing, .init = left_join(var_10_cbg, var_10_tract, by = "GEOID"))
rm(var_10_cbg, var_10_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

#### Percentage of housing units with 10 or more units in structure
var_11_cbg <- tidycensus::get_acs(geography = request_geo1, variables = c("B25024_001", "B25024_007", "B25024_008", "B25024_009"),  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(over_10=(B25024_007+B25024_008+B25024_009)/B25024_001)%>%
  dplyr::select(GEOID,over_10)

var_11_tract <- tidycensus::get_acs(geography = request_geo2, variables = c("B25024_001", "B25024_007", "B25024_008", "B25024_009"),  state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(over_10=(B25024_007+B25024_008+B25024_009)/B25024_001)%>%
  dplyr::select(GEOID,over_10)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

var_list <- c("over_10")
var_11 <- reduce(var_list, replace_missing, .init = left_join(var_11_cbg, var_11_tract, by = "GEOID"))
rm(var_11_cbg, var_11_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

#### Percentage of houses that are mobile homes
var_12_cbg <- tidycensus::get_acs(geography = request_geo1, variables = c("B25024_001",  "B25024_010"), state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(mobile_units= B25024_010/B25024_001)%>%
  dplyr::select(GEOID, mobile_units)

var_12_tract <- tidycensus::get_acs(geography = request_geo2, variables = c("B25024_001",  "B25024_010"), state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(mobile_units= B25024_010/B25024_001)%>%
  dplyr::select(GEOID, mobile_units)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

var_list <- c("mobile_units")
var_12 <- reduce(var_list, replace_missing, .init = left_join(var_12_cbg, var_12_tract, by = "GEOID"))
rm(var_12_cbg, var_12_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

#### Percent of homes with more than  one occupant per room
###total_units=B25014_001, owner_less_50=B25014_003, owner_51_100=B25014_004, renter_less_50=B25014_009, renter_51_100=B25014_010
var_13_cbg <- tidycensus::get_acs(geography=request_geo1, variables=c("B25014_001","B25014_003","B25014_004","B25014_009","B25014_010"), state="08", year=request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(over_1_person_room_percent_13=(B25014_001-B25014_003-B25014_004-B25014_009-B25014_010)/B25014_001)%>%
  dplyr::select(GEOID,over_1_person_room_percent_13)

var_13_tract <- tidycensus::get_acs(geography=request_geo2, variables=c("B25014_001","B25014_003","B25014_004","B25014_009","B25014_010"), state="08", year=request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(over_1_person_room_percent_13=(B25014_001-B25014_003-B25014_004-B25014_009-B25014_010)/B25014_001)%>%
  dplyr::select(GEOID,over_1_person_room_percent_13)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

var_list <- c("over_1_person_room_percent_13")
var_13 <- reduce(var_list, replace_missing, .init = left_join(var_13_cbg, var_13_tract, by = "GEOID"))
rm(var_13_cbg, var_13_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Percent of households with no vehicle
### total_units=B25044_001, owner_no_vehicle=B25044_003, renter_no_vehicle=B25044_0010
var_14_cbg <- tidycensus::get_acs(geography = request_geo1, variables = c("B25044_001","B25044_003","B25044_010"), state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(no_vehicle_percent_14=(B25044_003+B25044_010)/B25044_001)%>%
  dplyr::select(GEOID,no_vehicle_percent_14)

var_14_tract <- tidycensus::get_acs(geography = request_geo2, variables = c("B25044_001","B25044_003","B25044_010"), state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(no_vehicle_percent_14=(B25044_003+B25044_010)/B25044_001)%>%
  dplyr::select(GEOID,no_vehicle_percent_14)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

var_list <- c("no_vehicle_percent_14")
var_14 <- reduce(var_list, replace_missing, .init = left_join(var_14_cbg, var_14_tract, by = "GEOID"))
rm(var_14_cbg, var_14_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Percent of the population that lives in group quarters
### households= B09019_001, group_quarters = B09019_026
var_15_cbg <- tidycensus::get_acs(geography = request_geo1, variables = c("B09019_001", "B09019_026"), state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(group_quarters_percent_15 = B09019_026/B09019_001)%>%
  dplyr::select(GEOID,group_quarters_percent_15)

var_15_tract <- tidycensus::get_acs(geography = request_geo2, variables = c("B09019_001", "B09019_026"), state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(group_quarters_percent_15 = B09019_026/B09019_001)%>%
  dplyr::select(GEOID,group_quarters_percent_15)%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

var_list <- c("group_quarters_percent_15")
var_15 <- reduce(var_list, replace_missing, .init = left_join(var_15_cbg, var_15_tract, by = "GEOID"))
rm(var_15_cbg, var_15_tract)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

### Creating GINI coefficient for income.
##### Gathering the household income bins to calculate GINI coefficient for Income
var_download <- c( "B19001_001","B19001_002","B19001_003","B19001_004","B19001_005","B19001_006", "B19001_007","B19001_008",
                   "B19001_009","B19001_010","B19001_011","B19001_012","B19001_013","B19001_014", "B19001_015","B19001_016","B19001_017")
#cbg level
var_16_cbg_data <- tidycensus::get_acs(geography = request_geo1, variables = var_download, state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)

#calculate GINI coefficient
var_16_cbg <- select(var_16_cbg_data, GEOID)# Create an empty vector to store the Gini coefficients
gini_coefficients <- numeric(nrow(var_16_cbg_data))

# Loop through each row/area.
for (i in 1:nrow(var_16_cbg_data)) {
  gini_coefficients[i] <- Gini(as.vector(unlist(var_16_cbg_data[i, -1])))
}
var_16_cbg$Gini_income <- gini_coefficients# Add the Gini coefficients as a new column

#tract level
var_16_tract_data <- tidycensus::get_acs(geography = request_geo2, variables = var_download, state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)

#calculate GINI coefficient
var_16_tract <- select(var_16_tract_data, GEOID)# Create an empty vector to store the Gini coefficients
gini_coefficients <- numeric(nrow(var_16_tract_data))

# Loop through each row/area.
for (i in 1:nrow(var_16_tract_data)) {
  gini_coefficients[i] <- Gini(as.vector(unlist(var_16_tract_data[i, -1])))
}
var_16_tract$Gini_income <- gini_coefficients# Add the Gini coefficients as a new column

var_16_tract_new <- var_16_tract%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

#replace cbg Gini values with tract Gini values.
var_list <- c("Gini_income")
var_16 <- reduce(var_list, replace_missing, .init = left_join(var_16_cbg, var_16_tract_new, by = "GEOID"))
rm(var_download, gini_coefficients,i, var_16_cbg, var_16_tract, var_16_tract_new, var_16_cbg,var_16_cbg_data, var_16_tract_data)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

#### GINI for education
##### Collecting and calculating the education Gini  This is done by years of schooling for those over age 25
var_download <- c("B15003_001","B15003_002","B15003_003","B15003_004","B15003_005","B15003_006","B15003_007","B15003_008","B15003_009","B15003_010","B15003_011","B15003_012",
                  "B15003_013","B15003_014","B15003_015","B15003_016","B15003_017","B15003_018","B15003_019","B15003_020","B15003_021","B15003_022","B15003_023","B15003_024","B15003_025") 
#cbg level GINI coeficient
var_17_cbg_data <- tidycensus::get_acs(geography = request_geo1, variables = var_download, state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)

var_17_cbg <- select(var_17_cbg_data, GEOID)# Create an empty vector to store the Gini coefficients
gini_coefficients <- numeric(nrow(var_17_cbg_data))

# Loop through each row/area.
for (i in 1:nrow(var_17_cbg_data)) {
  gini_coefficients[i] <- Gini(as.vector(unlist(var_17_cbg_data[i, -1])))
}
var_17_cbg$Gini_education <- gini_coefficients# Add the Gini coefficients as a new column

#tract level GINI coeficient
var_17_tract_data <- tidycensus::get_acs(geography = request_geo2, variables = var_download, state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)

var_17_tract <- select(var_17_tract_data, GEOID)# Create an empty vector to store the Gini coefficients
gini_coefficients <- numeric(nrow(var_17_tract_data))

# Loop through each row/area.
for (i in 1:nrow(var_17_tract_data)) {
  gini_coefficients[i] <- Gini(as.vector(unlist(var_17_tract_data[i, -1])))
}
var_17_tract$Gini_education <- gini_coefficients# Add the Gini coefficients as a new column

var_17_tract_new <- var_17_tract%>%
  right_join(., tract_geo)%>%
  dplyr::select(-GEOID)%>%
  st_as_sf()%>%
  st_join(., cbg_geo_centre)%>% 
  st_drop_geometry()

#replace cbg Gini values with tract Gini values.
var_list <- c("Gini_education")
var_17 <- reduce(var_list, replace_missing, .init = left_join(var_17_cbg, var_17_tract_new, by = "GEOID"))
rm(var_download, gini_coefficients,i, var_17_cbg, var_17_tract, var_17_tract_new, var_17_cbg_data, var_17_tract_data)
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------

SVI_var<-var_1%>%
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

saveRDS(SVI_var,file='Build/Cache/SVI_var.rds')
rm(var_1,var_2,var_3,var_4,var_5,var_6,var_7,var_8,var_9,var_10,var_11,var_12,var_13,var_14,var_15,var_16,var_17,SVI_var)
rm(request_geo1, request_geo2, request_year, tract_geo, cbg_geo, cbg_geo_centre, var_list, replace_missing)

print("COMPLETE")
