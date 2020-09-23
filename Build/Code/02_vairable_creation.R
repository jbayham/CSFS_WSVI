## This script pulls variables of interesrt in making the final variables used in this analysis.
## opening connection to all variables
ACS_persons <- DBI::dbConnect(SQLite(), dbname='ACS_persons.sqlite')
### Percent of poverty status checked individuals who are below povert line.   Income is reported as ratio of line (numbers referenced here is percent of line)
var_1<-tbl(ACS_persons,"attributes_c17")%>%
  dplyr::select(census_block_group,starts_with('C17002e'))%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(poverty_pop_checked=C17002e1,
         poverty_pop_under_50=C17002e2,
         poverty_pop_50_99 =C17002e3)%>%
  mutate(poverty_percent_below_1=(poverty_pop_under_50+poverty_pop_50_99)/poverty_pop_checked)%>%
  dplyr::select(census_block_group,poverty_percent_below_1)
### Percent of the Civilian population 16 and older who are unemoployed.  These are classified as people in the workforce (IE are actively seeking work)
var_2<-tbl(ACS_persons,"attributes_b23")%>%
  dplyr::select(census_block_group,starts_with('B23025e'))%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(civ_labor_force=B23025e3,
         civ_labor_force_unemployed=B23025e5)%>%
  mutate(civ_labor_force_unemployed_percent_2=civ_labor_force_unemployed/civ_labor_force)%>%
  dplyr::select(census_block_group,civ_labor_force_unemployed_percent_2)
### Per capita income is being replaced by median household income, which I prefer as a measure as it is not suseptible to upward bias from a few incomes
var_3<-tbl(ACS_persons,"attributes_b19")%>%
  dplyr::select(census_block_group,B19013e1)%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(median_hh_income_3=B19013e1)
  
### Percent no HS diploma, this is only measured for those over 25 years old.  I am including a GED as HS diploma
var_4<-tbl(ACS_persons,"attributes_b15")%>%
  dplyr::select(census_block_group,starts_with(('B15003e')))%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(pop_over_25=B15003e1,
         no_schooling=B15003e2,
         nursery=B15003e3,
         kindergarten=B15003e4,
         grade_1=B15003e5,
         grade_2=B15003e6,
         grade_3=B15003e7,
         grade_4=B15003e8,
         grade_5=B15003e9,
         grade_6=B15003e10,
         grade_7=B15003e11,
         grade_8=B15003e12,
         grade_9=B15003e13,
         grade_10=B15003e14,
         grade_11=B15003e15,
         grade_12=B15003e16)%>%
  mutate(no_hs_degree_percent_4=(no_schooling+nursery+kindergarten+grade_1+grade_2+grade_3+grade_4+grade_5+grade_6+grade_7+grade_8+grade_9+grade_10+grade_11+grade_12)/pop_over_25)%>%
  dplyr::select(census_block_group,no_hs_degree_percent_4)
### Percent over 65 years old
var_5<-tbl(ACS_persons,"attributes_b01")%>%
  dplyr::select(census_block_group,starts_with(('B01001e')))%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(total_pop=B01001e1,
         male_65_66=B01001e20,
         male_67_69=B01001e21,
         male_70_74=B01001e22,
         male_75_79=B01001e23,
         male_80_84=B01001e24,
         male_85_up=B01001e25,
         fem_65_66=B01001e44,
         fem_67_69=B01001e45,
         fem_70_74=B01001e46,
         fem_75_79=B01001e47,
         fem_80_84=B01001e48,
         fem_85_up=B01001e49)%>%
  mutate(over_65_percent_5=(male_65_66+male_67_69+male_70_74+male_75_79+male_80_84+male_85_up+
                            fem_65_66+fem_67_69+fem_70_74+fem_75_79+fem_80_84+fem_85_up)/total_pop)%>%
  dplyr::select(census_block_group,over_65_percent_5)
### Percent under 18 years old
var_6<-tbl(ACS_persons,"attributes_b01")%>%
  dplyr::select(census_block_group,starts_with(('B01001e')))%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(total_pop=B01001e1,
         male_under_5=B01001e3,
         male_5_9=B01001e4,
         male_10_14=B01001e5,
         male_15_17=B01001e6,
         fem_under_5=B01001e27,
         fem_5_9=B01001e28,
         fem_10_14=B01001e29,
         fem_15_17=B01001e30)%>%
   mutate(under_18_percent_6=(male_under_5+male_5_9+male_10_14+male_15_17+
                      fem_under_5+fem_5_9+fem_10_14+fem_15_17)/total_pop)%>%
  dplyr::select(census_block_group,under_18_percent_6)
### Percent with disability over 18, this is as a percent of people who have been examined for poverty status determination
var_7<-tbl(ACS_persons,"attributes_b21")%>%
  dplyr::select(census_block_group,starts_with('C21007e'))%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(poverty_determined_pop=C21007e1,
         vet_disabled_18_64_below=C21007e5,
         vet_disabled_18_64_above=C21007e8,
         non_vet_disabled_18_64_below=C21007e12,
         non_vet_disabled_18_64_above=C21007e15,
         vet_disabled_over_65_below=C21007e20,
         vet_disabled_over_65_above=C21007e23,
         non_vet_disabled_over_65_below=C21007e27,
         non_vet_disabled_over_65_above=C21007e30
         )%>%
    mutate(disabled_adult_percent_7=(vet_disabled_18_64_below+vet_disabled_18_64_above+
                                     non_vet_disabled_18_64_below+non_vet_disabled_18_64_above+
                                     vet_disabled_over_65_below+vet_disabled_over_65_above+
                                     non_vet_disabled_over_65_below+non_vet_disabled_over_65_above)/poverty_determined_pop)%>%
    dplyr::select(census_block_group,disabled_adult_percent_7)
### Percent single parent households of households with childeren under 18
var_8<-tbl(ACS_persons,"attributes_b23")%>%
  dplyr::select(census_block_group,starts_with('B23007e'))%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(households_with_own_childeren=B23007e1,
         male_single_householder=B23007e21,
         fem_single_householder=B23007e26)%>%
  mutate(single_householder_percent_8=(male_single_householder+fem_single_householder)/households_with_own_childeren)%>%
  dplyr::select(census_block_group,single_householder_percent_8)
### Percent Minority
var_9_race<-tbl(ACS_persons,"attributes_b02")%>%
  dplyr::select(census_block_group,starts_with('B02001e'))%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(pop=B02001e1,
         white=B02001e2)
var_9<-tbl(ACS_persons,"attributes_b03")%>%
  dplyr::select(census_block_group,B03002e13)%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(white_hsp=B03002e13)%>%
  left_join(.,var_9_race)%>%
  mutate(percent_minority_9=(pop-white+white_hsp)/pop)%>%
  dplyr::select(census_block_group,percent_minority_9)
rm(var_9_race)
#### Percent of people who spead Englist less than "well"
var_10<-tbl(ACS_persons,"attributes_c16")%>%
  dplyr::select(census_block_group,starts_with('B16004e'))%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(pop_over_5=B16004e1,
         spanish_5_17_not_well=B16004e7,
         spanish_5_17_not=B16004e8,
         euro_5_17_not_well=B16004e12,
         euro_5_17_not=B16004e13,
         asian_5_17_not_well=B16004e17,
         asian_5_17_not=B16004e18,
         other_5_17_not_well=B16004e22,
         other_5_17_not=B16004e23,
         spanish_18_64_not_well=B16004e29,
         spanish_18_64_not=B16004e30,
         euro_18_64_not_well=B16004e34,
         euro_18_64_not=B16004e35,
         asian_18_64_not_well=B16004e39,
         asian_18_64_not=B16004e40,
         other_18_64_not_well=B16004e44,
         other_18_64_not=B16004e45,
         spanish_65_up_not_well=B16004e51,
         spanish_65_up_not=B16004e52,
         euro_65_up_not_well=B16004e56,
         euro_65_up_not=B16004e57,
         asian_65_up_not_well=B16004e61,
         asian_65_up_not=B16004e62,
         other_65_up_not_well=B16004e66,
         other_65_up_not=B16004e67
         )%>%
  mutate(do_not_speak_english_well_percent_10=(spanish_5_17_not_well+spanish_5_17_not+euro_5_17_not_well+euro_5_17_not+asian_5_17_not_well+asian_5_17_not+other_5_17_not_well+other_5_17_not+
                                      spanish_18_64_not_well+spanish_18_64_not+euro_18_64_not_well+euro_18_64_not+asian_18_64_not_well+asian_18_64_not+other_18_64_not_well+other_18_64_not+
                                      spanish_65_up_not_well+spanish_65_up_not+euro_65_up_not_well+euro_65_up_not+asian_65_up_not_well+asian_65_up_not+other_65_up_not_well+other_65_up_not)/pop_over_5)%>%
  dplyr::select(census_block_group,do_not_speak_english_well_percent_10)

attributes_b25<-read.csv("./Build/Data/safegraph_open_census_data/data/cbg_b25.csv")%>%
  mutate(.,census_block_g=paste("0",as.character(census_block_group),sep=""))%>%
  dplyr::select(-census_block_group)%>%
  rename(census_block_group=census_block_g)%>%
  dplyr::filter(str_detect(census_block_group,"^08"))
#### Percent housing units with 10 or more units in structure
var_11<-attributes_b25%>%
  dplyr::select(census_block_group,starts_with('B25024e'))%>%
  rename(total_units=B25024e1,
         units_10_19=B25024e7,
         units_20_49=B25024e8,
         units_50_plus=B25024e9)%>%
  mutate(units_over_10_percent_11=(units_10_19+units_20_49+units_50_plus)/total_units)%>%
  dplyr::select(census_block_group,units_over_10_percent_11)

#### Percent houses that are mobile homes
var_12<-attributes_b25%>%
  dplyr::select(census_block_group,starts_with('B25024e'))%>%
  rename(total_units=B25024e1,
         units_mobile=B25024e10)%>%
  mutate(units_mobile_percent_12=units_mobile/total_units)%>%
  dplyr::select(census_block_group,units_mobile_percent_12)

#### Percent of homes with more than  one occupant per room 
var_13<-attributes_b25%>%
  dplyr::select(census_block_group,starts_with('B25014e'))%>%
  rename(total_units=B25014e1,
         owner_less_50=B25014e3,
         owner_51_100=B25014e4,
         renter_less_50=B25014e9,
         renter_51_100=B25014e10)%>%
  mutate(over_1_person_room_percent_13=(total_units-owner_less_50-owner_51_100-renter_less_50-renter_51_100)/total_units)%>%
  dplyr::select(census_block_group,over_1_person_room_percent_13)

#### Percent of households with no vehicle
var_14<-attributes_b25%>%
  dplyr::select(census_block_group,starts_with('B25044e'))%>%
  rename(total_units=B25044e1,
         owner_no_vehicle=B25044e3,
         renter_no_vehicle=B25044e10)%>%
  mutate(no_vehicle_percent_14=(owner_no_vehicle+renter_no_vehicle)/total_units)%>%
  dplyr::select(census_block_group,no_vehicle_percent_14)

### Percent of the population that lives in group quarters
var_15<-tbl(ACS_persons,"attributes_b09")%>%
  dplyr::select(census_block_group,starts_with('B09019e'))%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(households=B09019e1,
         group_quarters=B09019e38)%>%
  mutate(group_quarters_percent_15=group_quarters/households)%>%
  dplyr::select(census_block_group,group_quarters_percent_15)

##### Gathering the household income bins to calculate GINI coefficient for Income
var_16_data<-tbl(ACS_persons,"attributes_b19")%>%
  dplyr::select(census_block_group,starts_with('B19001e'))%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(total_hh=B19001e1,
        hh_under_10k=B19001e2,
        hh_10_15k=B19001e3,
        hh_15_20k=B19001e4,
        hh_20_25k=B19001e5,
        hh_25_30k=B19001e6,
        hh_30_35k=B19001e7,
        hh_35_40k=B19001e8,
        hh_40_45k=B19001e9,
        hh_45_50k=B19001e10,
        hh_50_60k=B19001e11,
        hh_60_75k=B19001e12,
        hh_75_100k=B19001e13,
        hh_100_125k=B19001e14,
        hh_125_150k=B19001e15,
        hh_150_200k=B19001e16,
        hh_200k_up=B19001e17)
var_16<-data.frame(1:nrow(var_16_data),1:nrow(var_16_data))%>%
  rename(census_block_group=X1.nrow.var_16_data.,
         gini_income=X1.nrow.var_16_data..1)
for(i in 1:nrow(var_16_data) ){
  var_16[i,1]<-var_16_data[i,1]%>%as.character()
  var_16[i,2]<-Gini(c(0,10,15,20,25,30,35,40,45,50,60,75,100,125,150,200),n=var_16_data[i,3:18])
}

##### Collecting and calculting the education Gini  This is done by years of schooling for those over age 25
var_17_data<-tbl(ACS_persons,"attributes_b15")%>%
  dplyr::select(census_block_group,starts_with(('B15003e')))%>%
  collect()%>%
  dplyr::filter(str_detect(census_block_group,"^08"))%>%
  rename(pop_over_25=B15003e1,
         no_schooling=B15003e2,
         nursery=B15003e3,
         kindergarten=B15003e4,
         grade_1=B15003e5,
         grade_2=B15003e6,
         grade_3=B15003e7,
         grade_4=B15003e8,
         grade_5=B15003e9,
         grade_6=B15003e10,
         grade_7=B15003e11,
         grade_8=B15003e12,
         grade_9=B15003e13,
         grade_10=B15003e14,
         grade_11=B15003e15,
         grade_12=B15003e16,
         High_school_Diploma=B15003e17,
         GED_or_equiv=B15003e18,
         Some_college_less_12_months=B15003e19,
         Some_college_more_12_months=B15003e20,
         Associates=B15003e21,
         Bachelors=B15003e22,
         Masters=B15003e23,
         Professional_Degree=B15003e24,
         Doctorate=B15003e25)
var_17<-data.frame(1:nrow(var_17_data),1:nrow(var_17_data))%>%
  rename(census_block_group=X1.nrow.var_17_data.,
         gini_education=X1.nrow.var_17_data..1)
##The weights here represent my estimate of the number of years of school a person has attended
ed_weights<-c(0,.5,1,2,3,4,5,6,7,8,9,10,11,12,13,13,13,13.5,14,14,16,18,20,20)
for( i in 1:nrow(var_17_data) ){
  var_17[i,1]<-var_17_data[i,1]%>%as.character()
  var_17[i,2]<-Gini(ed_weights,n=var_17_data[i,3:26])
}
dbDisconnect(ACS_persons)
rm(ACS_persons)

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
rm(var_1,var_2,var_3,var_4,var_5,var_6,var_7,var_8,var_9,var_10,var_11,var_12,var_13,var_14,var_15,var_16,var_17,var_16_data,var_17_data,ed_weights,attributes_b25,SVI_data,i)
