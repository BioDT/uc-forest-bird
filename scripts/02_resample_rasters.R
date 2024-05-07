# 02_resample_rasters.R
# Description:
# This script resamples raster files from the "data/processed_rasters" directory to a resolution of 100m x 100m 
# using mean aggregation. The resampled raster files are then written to the "data/resampled_rasters" directory.


# Load required packages
if (!requireNamespace("terra", quietly = TRUE)) {
  install.packages("terra")
}

library(terra)

# Check if the script is being run from within RStudio
if (interactive()) {
  # Get the path of the currently running script
  script_path <- file.path(dirname(rstudioapi::getActiveDocumentContext()$path), "02_resample_rasters.R")
  
  # Print the script path
  print(script_path)
} else {
  print("Not running in interactive mode (e.g., not in RStudio).")
}

# Specify project directory
project_directory <- dirname(dirname(script_path))

# Specify input and output directories
input_directory <- file.path(project_directory, "data", "processed_rasters")
output_directory <- file.path(project_directory, "data", "resampled_rasters")

# Create output directory if it doesn't exist
if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}

# Function to resample raster files to 100m x 100m using mean aggregation
resample_rasters_mean <- function(input_directory, output_directory) {
  # Create a list of raster file paths in the input directory
  rastlist <- list.files(path = input_directory, pattern = ".tif$", full.names = TRUE)
  
  # Function to process each raster file
  process_raster <- function(raster_file_path) {
    # Load the raster file
    r <- rast(raster_file_path)
    
    # Create a new temp raster
    r2 <- r
    
    res(r2) <- 100 #rescale temp raster to new resolution
    
    # Resample the raster to 100m x 100m using mean aggregation
    r_resampled <- resample(r, r2, method = "average")
    
    # Define the output file path
    output_file <- file.path(output_directory, basename(raster_file_path))
    
    # Write the resampled raster to a new file with integer data type INT2S
    writeRaster(r_resampled, filename = output_file, overwrite = TRUE, datatype = "INT2S")
    
    # Remove the raster object to avoid memory problems
    remove(r)
  }
  
  # Apply the processing function to all raster files in the input directory
  lapply(rastlist, process_raster)
}


# Execute the function to resample raster files to 100m x 100m using mean aggregation
resample_rasters_mean(input_directory, output_directory)
