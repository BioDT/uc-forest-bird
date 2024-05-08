# 01_replace_no_data_values.R
# Description:
# This script processes raster files by replacing no-data values with NA (Not Available) values. 
# It first loads raster files from the "data/original_rasters" directory, identifies pixels with no-data values (e.g., zeros, 32766 or 32767), 
# and replaces them with NA. The modified raster files are then written to the "data/processed_rasters" directory.


# Load required packages
if (!requireNamespace("terra", quietly = TRUE)) {
  install.packages("terra")
}

library(terra)

# Specify project directory
if (interactive()) {
  project_directory <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
} else {
  project_directory <- getwd()
}
print(project_directory)

# Specify input and output directories
input_directory <- file.path(project_directory, "data", "original_rasters")
output_directory <- file.path(project_directory, "data", "processed_rasters")

# Create output directory if it doesn't exist
if (!dir.exists(output_directory)) {
  dir.create(output_directory)
}

replace_no_data_with_NAs <- function(input_directory, output_directory) {
  # Create a list of raster file paths in the input directory
  rastlist <- list.files(path = input_directory, pattern = ".tif$", full.names = TRUE)
  
  # Function to process each raster file
  process_raster <- function(raster_file_path) {
    # Load the raster file
    r <- rast(raster_file_path)
    
    # Replace all zeros and negative values with N/A
    r[r <= 0] <- NA
    
    # Replace all no-data values (32766 & 32767) with N/A
    r[r == 32767] <- NA
    r[r == 32766] <- NA
    
    # Define the output file path
    output_file <- file.path(output_directory, basename(raster_file_path))
    
    # Write the modified raster to a new file
    writeRaster(r, filename = output_file, overwrite=TRUE)
    
    # Remove the raster object to avoid memory problems
    remove(r)
  }
  
  # Apply the processing function to all raster files in the input directory
  lapply(rastlist, process_raster)
}

replace_no_data_with_NAs(input_directory, output_directory)
