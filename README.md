## Wildfire Social Vulnerability Index (WFSVI)

This repository contains the code to build the Wildfire Social Vulnerability Index (WFSVI) for the Colorado State Forest Service. The WSVI is used to identify communities with “fewer resources,” which qualifies for a reduced match requirement for the FRWRM grant program. Before running the scripts, manually download/get the Wildland Urban Interface (WUI) data and save it in the folder “Build/Data” in Tiff format. All other required data files will be automatically downloaded when running the scripts. Census data is queried from the API. We suggest registering for an API key by following these [instructions](https://walker-data.com/tidycensus/reference/census_api_key.html). Data frames or objects produced in each script are saved in the Cache folder. 

## Running the scripts

The scripts are found in the folder “Build/Code/” and should be run in the ascending order of the script numbers (from 00_init to 08_maps) as described below. 

**00_init**: This script installs, if not installed already, loads the necessary packages, and creates the required folders in the project directory. This should be run at least once every time the user opens the project.

**00_download geometries**: This script downloads the required shapefiles and the J40-tract data and saves them in the folders created in 00_init. The user can run this script only once when they open the project for the first time. 

**01_get_data**: This script downloads data from ACS and calculates variables required for computing WFSVI. Users can define parameters such as year and geography. Users can calculate the WFSVI for any year by changing the variable “year” in line 17. 

**02_cbg_geo**: This script attaches CBG geometry to the WFSVI variables generated above.

**03_svi_wui**: This script filters CBGs containing at least some WUI.

**04_wfsvi**: This script takes the raw data, ranks it all, applies the weights, and generates the final index for all CBGs filtered above. It flags CBGs that are above the 75 percentile.

**05_J40_tract**: This script merges the WFSVI and the J40 initiative data. All CBGs above the 75 percentile or reported as disadvantaged in the J40 initiative are flagged as qualifying CBGs. 

**06_analysis**: This script filters qualifying CBGs and plots a map. 

**07_monte_carlo_simulation**: This script generates data using the estimates and margin of errors from ACS and calculates the WFSVI for each CBG. It records the times each CBG qualifies per a given number of iterations. The simulation process identifies CBGs that qualify but otherwise would be less likely to qualify.

**08_maps**: This script generates the interactive map to display the layer. 

