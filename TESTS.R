
#####################################################################################################
#create raster file from a shape file
# Read the shapefile
shapefile <- read_sf("Build/data/2017_wui/2017_wui.shp")%>%
  dplyr::filter(GRIDCODE==1)%>%
  st_transform(4269)%>%
  st_make_valid()

raster_template <- raster(extent(shapefile), resolution = 0.01)# Create an empty raster with the desired resolution
raster_file <- rasterize(shapefile, raster_template)# Rasterize the shapefile using the empty raster as a template
writeRaster(raster_file, "Build/Data/WUI.tif",overwrite=TRUE)# Save the raster file
#####################################################################################################





#####################################################################################################
#  code for downloading cbg and tract data and replace missing values with  values from tract data
#geometries for census tract
tract_geo <- read_sf("Build/Cache/tl_2022_08_tract/tl_rd22_08_tract.shp")%>%
  dplyr::select(GEOID)

#define parameters
cbg_geo_centre <- st_centroid(cbg_geo) #centre points of CBG which will be used to find CBG within certain census tracts
request_geo1 <- "block group" #geography for downloading CBG level data
request_geo2 <- "tract" #geography for downloading census tract level data
request_year <- 2021

### Percentage of poverty status checked individuals who are below poverty line
### NB: poverty_pop_checked = C17002e1, poverty_pop_under_50 = C17002e2  and poverty_pop_50_99 = C17002e3
var_1_cbg <- tidycensus::get_acs(geography = request_geo, variables = c("C17002_001", "C17002_002", "C17002_003"), state = "08", year = request_year)%>%
  dplyr::select(GEOID, variable, estimate)%>%#select relevant var
  pivot_wider(names_from = variable, values_from = estimate)%>%#convert from long to wide farmat
  mutate(poverty_percent_below_1 = as.numeric(C17002_002+C17002_003)/C17002_001)%>%#calculate % of pop below 1
  dplyr::select(GEOID,poverty_percent_below_1)

#Download and calculate variable for census tract level
var_1_ct <- tidycensus::get_acs(geography = request_geo2, variables = c("C17002_001", "C17002_002", "C17002_003"), state = "08", year = request_year)%>%
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
#Define a function to replace missing values in a single variable
replace_missing <- function(df, var_name) {
  df %>%
    mutate(!!var_name := coalesce(!!sym(paste0(var_name, ".x")), !!sym(paste0(var_name, ".y")))) %>%
    select(-c(paste0(var_name, ".x"), paste0(var_name, ".y")))
}

# Define a list of variables to replace missing values for
var_list <- c("poverty_percent_below_1")

# Loop through the list of variables and replace missing values
var_1 <- reduce(var_list, replace_missing, .init = left_join(var_1, var_1_replacement, by = "GEOID"))
##############################################################################################################



################################################################################################################
#Monte Carlo Simulation 

# Set the estimate and margin of error
estimate <- 100
margin_of_error <- 5

# Set the confidence level
confidence_level <- 0.95

# Calculate the z-value
z_value <- qnorm((1 + confidence_level) / 2)

# Calculate the standard deviation
standard_deviation <- margin_of_error / z_value

# Create a normal distribution with the estimate as the mean and the standard deviation
# calculated from the margin of error and confidence level
simulated_data <- rnorm(1000, mean = estimate, sd = standard_deviation)

###################################################################################################################




################################################################################################################################

## imputing missing values using missForest package

# Load the missForest package
library(missForest)

# Read in the data set
data <- SVI_var
data$GEOID <- as.factor(data$GEOID)
missing_cols <- which(sapply(data, function(x) any(is.na(x))))# Identify columns with missing values
imputed_data <- missForest(data[,missing_cols], maxiter = 10, ntree = 100, replace = TRUE)# Impute missing values










library(missForest)
library(randomForest)

# Load your data (let's assume it's in a data frame called "my_data")
# Get the names of all the variables
my_data <- select(SVI_var, -GEOID)


library(randomForest)

# Load your data (let's assume it's in a data frame called "my_data")
# Get the names of all the variables
all_vars <- colnames(my_data)

# Create an empty list to store the models and predictions
models <- list()
predictions <- list()

# Fit a separate random forest model for each column
for (col in all_vars) {
  # Specify the response variable as the current column
  response_var <- col
  
  # Specify the predictor variables as all the other columns
  predictor_vars <- setdiff(all_vars, col)
  
  # Fit the random forest model with the current column as the response variable
  models[[col]] <- randomForest(x = my_data[, predictor_vars], y = my_data[, response_var], ntree = 500)
  
  # Make predictions with the current model
  predictions[[col]] <- predict(models[[col]], newdata = my_data[, predictor_vars])
}

# Evaluate the performance of each model
performance_metrics <- sapply(1:length(all_vars), function(i) {
  mean((predictions[[i]] - my_data[, i])^2)
})



