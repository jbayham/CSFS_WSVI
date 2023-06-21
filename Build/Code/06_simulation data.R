### Monte Carlo Simulation 
### We will assume a zero-inflated lognormal distribution. Thus is because the data is a mixture of zeros and positive values. 
### This script will use the sqlite database to minimize data simulation time.

library(RSQLite)
cbg_data <- DBI::dbConnect(SQLite(), dbname='cbg_data.sqlite')
var_1_cbg_data<-tbl(cbg_data,"var_1_cbg_data")%>%
  as.data.frame()

