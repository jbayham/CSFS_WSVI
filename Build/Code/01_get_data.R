#This script gets data from Census ACS using tidycensus and organises the variables for the next scripts 
#Variable in the ACS database names are preserved

library(tidycensus)

#Set parameters
request_geo <- "block group"
request_year <- 2021

### Percentage of poverty status checked individuals who are below poverty line
### NB: poverty_pop_checked = C17002e1, poverty_pop_under_50 = C17002e2  and poverty_pop_50_99 = C17002e3
poverty <- tidycensus::get_acs(geography = request_geo, variables = c("C17002_001", "C17002_002", "C17002_003"), state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%#select relevant var
  pivot_wider(names_from = variable, values_from = estimate)%>%#convert from long to wide farmat
  mutate(poverty_percent_below_1=(C17002_002+C17002_003)/C17002_001)%>%#calculate % of pop below 1
  dplyr::select(GEOID,poverty_percent_below_1)

### Percent of the Civilian population 16 and older who are unemployed.  These are classified as people in the workforce (IE are actively seeking work)
### civilian labor force = B23025e3; civilian labor force unemployed = B23025e5)
unemoployed <- tidycensus::get_acs(geography = request_geo, variables = c("B23025_003", "B23025_005") , state = "08", year = request_year)%>% 
  dplyr::select(GEOID, variable, estimate)%>%
  pivot_wider(names_from = variable, values_from = estimate)%>%
  mutate(civ_labor_force_unemployed_percent_2=B23025_005/B23025_003)%>%
  dplyr::select(GEOID,civ_labor_force_unemployed_percent_2)

### Per capita income is being replaced by median household income, which I prefer as a measure as it is not suseptible to upward bias from a few incomes





var_3<-tbl(ACS_persons,"attributes_b19")%>%
  dplyr::select(census_block_group,B19013e1)%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(median_hh_income_3=B19013e1)%>%
  na_mean()


