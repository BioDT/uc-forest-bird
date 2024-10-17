# Load necessary libraries
library(terra)    # For working with spatial raster data
library(dplyr)    # For data manipulation
library(sf)       # For spatial data manipulation and reprojection

# Specify project directory
if (interactive()) {
  project_directory <- dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
} else {
  project_directory <- getwd()
}
print(project_directory)

# Loading the study region .tif file and extract its extent, initial community's extent is used for the study region
study_region_directory <- file.path(project_directory, "data", "initial_community")

study_region <- rast(file.path(study_region_directory, "Initial.community.tif"))

# Input directory where all .nc files are stored
input_directory <- file.path(project_directory, "data", "climate", "rcp45", "tasmax")
output_directory <- file.path(project_directory, "data", "climate", "rcp45", "all_variables")

# List all the .nc files in the input directory
nc_files <- list.files(path = input_directory, 
                       pattern = "tasmax_Amon_HadGEM2-ES_rcp45_r2i1p1_.*\\.nc$", 
                       full.names = TRUE)

# Extract the extent and CRS of the study region
study_extent <- ext(study_region)
study_crs <- crs(study_region)

# Reproject the study region from EPSG:3067 to WGS84 (EPSG:4326)
study_region_reproj <- project(study_region, "EPSG:4326")

# Check the reprojected study region's extent
study_extent <- ext(study_region_reproj)
#print(study_extent)

# Initialize an empty list to store final data
final_data_list <- list()

# Loop through each NetCDF file
for (nc_file in nc_files) {
  
  # Load the NetCDF file using terra
  nc_data <- rast(nc_file)  # Load the entire NetCDF dataset
  
  # Reproject the NetCDF data to WGS84 (EPSG:4326)
  crs(nc_data) <- "EPSG:4326"
  
  # Crop the NetCDF data to the extent of the reprojected study region
  cropped_data <- crop(nc_data, study_region_reproj)
  
    # Convert the cropped raster data to a data frame
  cropped_df <- as.data.frame(cropped_data, xy = TRUE)
  
  # Extract the tasmax values (ignoring the x and y coordinates)
  tasmax_values <- cropped_df[, 3:ncol(cropped_df)]
  
  
  tasmax_celsius <- tasmax_values - 273.15
  tasmax_matrix <- as.matrix(tasmax_celsius)
  tasmax_avg <- apply(tasmax_matrix, 2, mean, na.rm = TRUE)
  
  # Extract time information from the cropped NetCDF data
  time_info <- time(cropped_data) # Extract time information
  
  year_month <- as.data.frame(time_info) %>%
    dplyr::rename(time = 1) %>%  # Rename the first column to 'time' explicitly
    mutate(year = as.numeric(format(time, "%Y")),
           month = as.numeric(format(time, "%m")))
  
  # Combine year, month, and tasmax_avg for this file
  temp_data <- data.frame(
    year = year_month$year,
    month = year_month$month,
    tasmax = tasmax_avg
  )
  
  # Add this data to the list of all data
  final_data_list[[length(final_data_list) + 1]] <- temp_data
}

# Combine all temp_data into a single data frame after the loop
final_data <- do.call(rbind, final_data_list)

# Saving to a CSV file for easy inspection
write.csv(final_data, file = file.path(output_directory, "tasmax_monthly.csv"), row.names = FALSE)

