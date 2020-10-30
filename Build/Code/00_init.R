#This is the preamble script for the CSFS project.  It loads in packages that will be used to create the WFSVI
#It should be run once each time a user begins a new R session to work on the project.


#########################
#Loading and installing packages
init.pacs <- function(package.list){
  check <- unlist(lapply(package.list, require, character.only = TRUE))
  #Install if not in default library
  if(any(!check)){
    for(pac in package.list[!check]){
      install.packages(pac)
    }
    lapply(package.list, require, character.only = TRUE)
  }
}

#Loading and installing packages
init.pacs(c("tidyverse",      #shortcut to many useful packages (eg, dplyr, ggplot)
            "data.table",     #for more efficient utilities
            "furrr",          #facilitates simple implementation of parallel processing
            "future",         #support for furrr
            "conflicted",     #resolves function conflict across packages
            "lubridate",      #working with dates
            "units",
            "readr",
            "readxl",
            "progress",
            "lwgeom",
            "haven",
            "stringr",
            "mosaic",
            "purrr",
            "dbplyr",
            "RSQLite",
            "stats",
            "sf",
            "DescTools",
            "MCDA",
            "tigris",
            "imputeTS"
))


