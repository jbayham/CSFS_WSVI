#This is the master script which can load and all the other scripts in the prefered order

# 1. run script 00_init.R to load packages
source("Build/Code/00_init.R")

# 2. Run script 02_get_data to download data from ACS and create a data frame with SVI variables
source("Build/Code/01_get_data.R")

# 3. Run script 02_new_svi which takes the raw data and ranks it all creating the final index.  
source("Build/Code/02_new_svi.R")

# 4. filter CBGs that qualify and plot
source("Build\Code\03_wfsvi.R")
