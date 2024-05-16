# 05_convert_m3_to_gm2.R
# Description:
# This script converts volume in kg/m3 to biomass in g/m2.This is the unit LANDIS works.


# Load required packages
if (!requireNamespace("terra", quietly = TRUE)) {
  install.packages("terra")
}

library(terra)

# Check if the script is being run from within RStudio
if (interactive()) {
  # Get the path of the currently running script
  script_path <- file.path(dirname(rstudioapi::getActiveDocumentContext()$path), "05_convert_m3_to_gm2.R")
  
  # Print the script path
  print(script_path)
} else {
  print("Not running in interactive mode (e.g., not in RStudio).")
}

# Specify project directory
project_directory <- dirname(dirname(script_path))

# Specify input and output directories
input_directory <- file.path(project_directory, "data", "resampled_rasters")
output_directory <- file.path(project_directory, "data", "initial_community")

# Create output directory if it doesn't exist
if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}

# Read the raster files for tree species
spruce <- rast(file.path(input_directory, "Spruce.tif"))
pine <- rast(file.path(input_directory, "Pine.tif"))
birch <- rast(file.path(input_directory, "Birch.tif"))
other <- rast(file.path(input_directory, "Other.tif"))

#Convert volume to biomass
Spruce_B<-(spruce/10000)*405000
writeRaster(Spruce_B, filename = file.path(output_directory, "Spruce_B.tif"), overwrite = TRUE, datatype = "INT2S")

Pine_B<-(pine/10000)*550000
writeRaster(Pine_B, filename = file.path(output_directory, "Pine_B.tif"), overwrite = TRUE, datatype = "INT2S")

Birch_B<-(birch/10000)*640000
writeRaster(Birch_B, filename = file.path(output_directory, "Birch_B.tif"), overwrite = TRUE, datatype = "INT2S")

Other_B<-(other/10000)*450000
writeRaster(Other_B, filename = file.path(output_directory, "Other_B.tif"), overwrite = TRUE, datatype = "INT2S")