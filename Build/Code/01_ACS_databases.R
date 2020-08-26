## This script reads the different tables that Safegraph has organized the Block group level American Community Survey into.
## The ACS that is used is the five year average 2016. It is stored here as an SQlite databaseto save space and variables will be pulled 
## in a later script.  When downloading the Safegraph data the csv with the variable name key is in the gz file. It is called name codes
## and is preserved in this database.
ACS_persons <- dbConnect(SQLite(), dbname='ACS_persons.sqlite')
### Variable needed for this analysis
#### This table has basic demographic compisitions such as age
# Variables: 5,6
attributes_b01<-read_csv("./Build/Data/safegraph_open_census_data/data/cbg_b01.csv")
dbWriteTable(conn = ACS_persons, name = "attributes_b01", value = attributes_b01, row.names = FALSE,overwrite = TRUE)
rm("attributes_b01")
#### This table has racial demographics
# Variables: 9
attributes_b02<-read_csv("./Build/Data/safegraph_open_census_data/data/cbg_b02.csv")
dbWriteTable(conn = ACS_persons, name = "attributes_b02", value = attributes_b02, row.names = FALSE,overwrite = TRUE)
rm("attributes_b02")
#### This table has hispanic demographics
# Variables: 9
attributes_b03<-read_csv("./Build/Data/safegraph_open_census_data/data/cbg_b03.csv")
dbWriteTable(conn = ACS_persons, name = "attributes_b03", value = attributes_b03, row.names = FALSE,overwrite = TRUE)
rm("attributes_b03")
#### This table household type including group quarter data
# Variables: 15
attributes_b09<-read_csv("./Build/Data/safegraph_open_census_data/data/cbg_b09.csv")
dbWriteTable(conn = ACS_persons, name = "attributes_b09", value = attributes_b09, row.names = FALSE,overwrite = TRUE)
rm("attributes_b09")
#### This table has household breakdown including family type by own childern
# Variables: 8
attributes_b11<-read_csv("./Build/Data/safegraph_open_census_data/data/cbg_b11.csv")
dbWriteTable(conn = ACS_persons, name = "attributes_b11", value = attributes_b11, row.names = FALSE,overwrite = TRUE)
rm("attributes_b11")
#### This table has education data for those over 25
# Variables: 4,17
attributes_b15<-read_csv("./Build/Data/safegraph_open_census_data/data/cbg_b15.csv")
dbWriteTable(conn = ACS_persons, name = "attributes_b15", value = attributes_b15, row.names = FALSE,overwrite = TRUE)
rm("attributes_b15")
#### This table has Ability to speak English variables that can be aggregated to determine engligh speakers as a percent
#Variable: 10
attributes_c16<-read_csv("./Build/Data/safegraph_open_census_data/data/cbg_c16.csv")
dbWriteTable(conn = ACS_persons, name = "attributes_c16", value = attributes_c16, row.names = FALSE,overwrite = TRUE)
rm("attributes_c16")
#### This table has what is needed to construct households in poverty to aquire percent households in poverty
# Variables: 1,16
attributes_c17<-read_csv("./Build/Data/safegraph_open_census_data/data/cbg_c17.csv")
dbWriteTable(conn = ACS_persons, name = "attributes_c17", value = attributes_c17, row.names = FALSE,overwrite = TRUE)
rm("attributes_c17")
### This table has income data by cateogry as well as median measures
# Variables:3
attributes_b19<-read_csv("./Build/Data/safegraph_open_census_data/data/cbg_b19.csv")
dbWriteTable(conn = ACS_persons, name = "attributes_b19", value = attributes_b19, row.names = FALSE,overwrite = TRUE)
rm("attributes_b19")
#### This table has disability data for all adults
attributes_b21<-read_csv("./Build/Data/safegraph_open_census_data/data/cbg_b21.csv")
dbWriteTable(conn = ACS_persons, name = "attributes_b21", value = attributes_b21, row.names = FALSE,overwrite = TRUE)
rm("attributes_b21")
#### This table has individual poverty data as well as employment data, it also has breakdowns of distability status
# Variables: 1,2,7,8
attributes_b23<-read_csv("./Build/Data/safegraph_open_census_data/data/cbg_b23.csv")
dbWriteTable(conn = ACS_persons, name = "attributes_b23", value = attributes_b23, row.names = FALSE,overwrite = TRUE)
rm("attributes_b23")
dbDisconnect(ACS_persons)
rm(ACS_persons)

##This ACS db focuses on the structure data
#### This table has housing structure and occupancy data (including mobile home and vehicle data)
# Variables: 11,12,13,14
ACS_structures <- dbConnect(SQLite(), dbname='ACS_structures.sqlite')
attributes_b25<-read.csv("./Build/Data/safegraph_open_census_data/data/cbg_b25.csv")
dbWriteTable(conn = ACS_structures, name = "attributes_b25", value = attributes_b25, row.names = FALSE,overwrite = TRUE)
rm("attributes_b25")
dbDisconnect(ACS_structures)
rm(ACS_structures)



