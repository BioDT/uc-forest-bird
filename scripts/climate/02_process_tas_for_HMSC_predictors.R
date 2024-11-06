# ==============================================================================
# Script for Processing Climate Data for HMSC Model with Seasonal Predictors
# ==============================================================================

# Load necessary libraries
if (!requireNamespace("terra", quietly = TRUE)) {
  install.packages("terra")
}
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
if (!requireNamespace("sf", quietly = TRUE)) {
  install.packages("sf")
}
library(terra)    # For raster operations and handling NetCDF files
library(dplyr)    # For data manipulation
library(sf)       # For spatial operations

# ==============================================================================
# Set up directories
# ==============================================================================
project_directory <- getwd()  # Set working directory, adjust as needed

# Input and output directories
input_directory <- file.path(project_directory, "data", "climate", "rcp45", "tas")
output_directory <- file.path(project_directory, "data", "climate", "rcp45", "HMSC_temp_predictors")
dir.create(output_directory, recursive = TRUE, showWarnings = FALSE)

# ==============================================================================
# Load Study Region
# ==============================================================================
study_region_directory <- file.path(project_directory, "data", "initial_community")
study_region <- rast(file.path(study_region_directory, "Initial.community.tif"))



# Reproject the study region from EPSG:3067 to WGS84 (EPSG:4326)
study_region_reproj <- project(study_region, "EPSG:4326")
study_crs <- crs(study_region_reproj)

# Extract the reprojected study region's extent for cropping the climate data
study_extent <- ext(study_region_reproj)


# ==============================================================================
# Load Multi-Year Climate Data
# ==============================================================================
# Load both historical and future scenario .nc files
historical_file <- file.path(input_directory, "tas_Amon_HadGEM2-ES_historical_r2i1p1_198412-200512.nc")
future_file <- file.path(input_directory, "tas_Amon_HadGEM2-ES_rcp45_r2i1p1_200512-203011.nc")

# Combine the historical and future data for seamless access
historical_data <- rast(historical_file)
future_data <- rast(future_file)
climate_data <- c(historical_data, future_data)  # Concatenate for continuous data access
crs(climate_data) <- study_crs


# ==============================================================================
# Define Helper Functions for Seasonal Calculation
# ==============================================================================

# Function to extract and average data for specified months and year
get_seasonal_mean <- function(data, year, months) {
  # Convert year and months to numeric
  year <- as.numeric(year)
  months <- as.numeric(months)
  
  # Extract year and month from the time series of the data
  data_years <- as.numeric(format(time(data), "%Y"))
  data_months <- as.numeric(format(time(data), "%m"))
  
  # Find indices matching the specified year and months
  time_indices <- which(data_years == year & data_months %in% months)
  if (length(time_indices) > length(months)) {  # Check for duplicates
    time_indices <- time_indices[1:length(months)] # Keep only the first occurrences
  }
  
  seasonal_rasters <- data[[time_indices]]
  
  # Crop, reproject, and average rasters
  seasonal_rasters <- crop(seasonal_rasters, study_extent)
  seasonal_rasters <- project(seasonal_rasters, study_crs)
  seasonal_mean <- mean(seasonal_rasters)
  
  # Resample to study region's resolution and extent
  seasonal_mean_resampled <- resample(seasonal_mean,
                                      study_region_reproj,
                                      method = "bilinear")
  
  # Project back to the study region's projection
  seasonal_mean_reproj <- project(seasonal_mean_resampled, crs(study_region))
  
  return(seasonal_mean_reproj)
}

# ==============================================================================
# Process and Save Seasonal Averages as .tif Files
# ==============================================================================

for (year in 2006:2023) {
  
  # 1. Previous summer (June-July of previous year)
  summer_mean <- get_seasonal_mean(climate_data, as.character(year - 1), c(6, 7))
  summer_mean_celsius <- summer_mean - 273.15
  writeRaster(summer_mean_celsius, filename = file.path(output_directory, paste0("summer_", year, ".tif")), overwrite = TRUE)
  
  # 2. Winter (December of previous year, January-February of current year)
  winter_mean_dec <- get_seasonal_mean(climate_data, as.character(year - 1), 12)
  winter_mean_jan_feb <- get_seasonal_mean(climate_data, as.character(year), c(1, 2))
  winter_mean <- mean(c(winter_mean_dec, winter_mean_jan_feb))  
  winter_mean_celsius <- winter_mean - 273.15
  writeRaster(winter_mean_celsius, filename = file.path(output_directory, paste0("winter_", year, ".tif")), overwrite = TRUE)
  
  # 3. Spring (April-May of current year)
  spring_mean <- get_seasonal_mean(climate_data, as.character(year), c(4, 5))
  spring_mean_celsius <- spring_mean - 273.15
  writeRaster(spring_mean_celsius, filename = file.path(output_directory, paste0("spring_", year, ".tif")), overwrite = TRUE)
}

