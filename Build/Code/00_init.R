#This is the preamble script for the CSFS project.  It loads in packages that will be used to create the WFSVI
#It should be run once each time a user begins a new R session to work on the project.

# Install pacman package if not already installed
if (!require(pacman)) {
  install.packages("pacman")
  library(pacman)
}

# List of packages needed
packages <- c("tidyverse",      #shortcut to many useful packages (eg, dplyr, ggplot)
              "data.table",     #for more efficient utilities
              "furrr",          #facilitates simple implementation of parallel processing
              "conflicted",     #resolves function conflict across packages
              "lubridate",      #working with dates
              "units",
              "sf",
              "Tidycensus",
              "ineq")

# load or install packages
p_load(packages)

