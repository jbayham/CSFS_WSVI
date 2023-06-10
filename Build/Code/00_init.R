#This is the preamble script for the CSFS project.  It loads in packages that will be used to create the WFSVI
#It should be run once each time a user begins a new R session to work on the project.

# Install pacman package if not already installed
if (!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

# List of packages needed
p_load("tidyverse", "data.table", "furrr", "conflicted",  "lubridate", "units",  "sf", "tidycensus", "ineq","terra","exactextractr",install=F)


if(!dir.exists("Build/Cache/"))  dir.create("Build/Cache/")
if(!dir.exists("Build/Data/"))  dir.create("Build/Data/")
if(!dir.exists("Build/Output/"))  dir.create("Build/Output/")
