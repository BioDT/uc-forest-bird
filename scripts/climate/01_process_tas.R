# ==============================================================================
# Script for Processing Climate Data (Mean Temperature) from NetCDF files
# ==============================================================================
# This script processes climate data stored in NetCDF format (temperature values in Kelvin),
# reprojects the data, crops it to the study region, converts it to Celsius, computes
# the monthly average temperatures, and combines the results into a single data frame.
# The processed data is saved as a CSV file for further analysis.
# ==============================================================================
# Load necessary libraries
# ------------------------------------------------------------------------------
# The following libraries are used in the script:
# - terra: For working with spatial raster data (NetCDF files).
# - dplyr: For efficient data manipulation and handling.
# - sf: For spatial data manipulation and reprojection.
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
library(dplyr)    # For data manipulation (mutate, rename, etc.)
library(sf)       # For spatial operations and reprojection of spatial data

# ==============================================================================
# 1. Specify Project Directory
# ------------------------------------------------------------------------------
# This section sets the project directory where all input data is located.
# The script dynamically adjusts the directory based on the active RStudio project,
# or uses the working directory if the script is run outside RStudio.

if (interactive()) {
  # If running in RStudio, set the project directory relative to the active document
  project_directory <- dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
} else {
  # If not running in RStudio, use the current working directory
  project_directory <- getwd()
}

# Print the project directory for verification
print(project_directory)

# ==============================================================================
# 2. Load Study Region
# ------------------------------------------------------------------------------
# This section loads the study region data in the form of a .tif file, which contains
# spatial information about the initial community's extent. The study region will be
# used to crop the climate data for the relevant area.

# Define the directory path where the study region .tif file is stored
study_region_directory <- file.path(project_directory, "data", "initial_community")

# Load the .tif file containing the study region
study_region <- rast(file.path(study_region_directory, "Initial.community.tif"))

# Extract the extent and CRS (Coordinate Reference System) of the study region
study_extent <- ext(study_region)
study_crs <- crs(study_region)

# ==============================================================================
# 3. Specify Input and Output Directories
# ------------------------------------------------------------------------------
# Define the input directory where all climate data (.nc files) are stored.
# The output directory is where the processed data will be saved.

# Define the input directory where NetCDF climate files (tas) are stored
input_directory <- file.path(project_directory, "data", "climate", "rcp45", "tas")

# Define the output directory for saving the processed data
output_directory <- file.path(project_directory, "data", "climate", "rcp45", "all_variables")

# ==============================================================================
# 4. List Climate Data Files
# ------------------------------------------------------------------------------
# This section lists all NetCDF (.nc) files in the input directory.
# The pattern matches the specific format of the climate data files.

# List all .nc files in the input directory that match the specified pattern
nc_files <- list.files(path = input_directory, 
                       pattern = "tas_Amon_HadGEM2-ES_rcp45_r2i1p1_.*\\.nc$", 
                       full.names = TRUE)

# ==============================================================================
# 5. Reproject Study Region to WGS84
# ------------------------------------------------------------------------------
# The study region's spatial reference system (CRS) is reprojected from EPSG:3067
# (Finland TM35FIN) to WGS84 (EPSG:4326) to match the projection of the NetCDF data.
# The reprojected study region is used to crop the climate data.

# Reproject the study region from EPSG:3067 to WGS84 (EPSG:4326)
study_region_reproj <- project(study_region, "EPSG:4326")

# Extract the reprojected study region's extent for cropping the climate data
study_extent <- ext(study_region_reproj)

# ==============================================================================
# 6. Initialize Empty List for Data Storage
# ------------------------------------------------------------------------------
# An empty list (`final_data_list`) is initialized to store the processed data from each
# NetCDF file during the iteration loop. The list will eventually be used to combine all the data.

final_data_list <- list()

# ==============================================================================
# 7. Loop Through Each NetCDF File
# ------------------------------------------------------------------------------
# The following loop processes each NetCDF file in the input directory:
# 1. Loads the NetCDF data.
# 2. Reprojects the data to WGS84.
# 3. Crops the data to the extent of the reprojected study region.
# 4. Converts temperature from Kelvin to Celsius.
# 5. Extracts time information from the NetCDF data.
# 6. Computes the monthly average temperatures for each file.
# 7. Stores the results in a list.

for (nc_file in nc_files) {
  
  # Load the NetCDF file using the terra package
  nc_data <- rast(nc_file)  # Load the entire NetCDF dataset
  
  # Reproject the NetCDF data to WGS84 (EPSG:4326)
  crs(nc_data) <- "EPSG:4326"
  
  # Crop the NetCDF data to the extent of the reprojected study region
  cropped_data <- crop(nc_data, study_region_reproj)
  
  # Convert the cropped raster data to a data frame (retain xy coordinates)
  cropped_df <- as.data.frame(cropped_data, xy = TRUE)
  
  # Extract the tas temperature values, ignoring the xy coordinates
  tas_values <- cropped_df[, 3:ncol(cropped_df)]
  
  # Convert temperature from Kelvin to Celsius
  tas_celsius <- tas_values - 273.15
  
  # Convert the Celsius data to a matrix for easier manipulation
  tas_matrix <- as.matrix(tas_celsius)
  
  # Compute the column-wise mean temperature (monthly average) across the study region
  tas_avg <- apply(tas_matrix, 2, mean, na.rm = TRUE)
  
  # Extract time information from the cropped NetCDF data
  time_info <- time(cropped_data)
  
  # Convert time information to a data frame and extract year and month
  year_month <- as.data.frame(time_info) %>%
    dplyr::rename(time = 1) %>%  # Rename the first column to 'time'
    mutate(year = as.numeric(format(time, "%Y")),
           month = as.numeric(format(time, "%m")))
  
  # Combine year, month, and monthly tas_avg for this file into a single data frame
  temp_data <- data.frame(
    year = year_month$year,
    month = year_month$month,
    tas = tas_avg
  )
  
  # Append this data to the final_data_list
  final_data_list[[length(final_data_list) + 1]] <- temp_data
}

# ==============================================================================
# 8. Combine All Data into One Data Frame
# ------------------------------------------------------------------------------
# After processing all the NetCDF files, combine all individual data frames into one
# large data frame containing all the processed temperature data for all time periods.

final_data <- do.call(rbind, final_data_list)

# ==============================================================================
# 9. Save Processed Data to CSV
# ------------------------------------------------------------------------------
# Save the final data frame (`final_data`) containing monthly average temperatures
# to a CSV file for easy inspection and future analysis.

write.csv(final_data, file = file.path(output_directory, "tas_monthly.csv"), row.names = FALSE)

# ==============================================================================
# END of Script
# ==============================================================================
