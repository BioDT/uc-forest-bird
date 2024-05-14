# 07_calculate_average_age.R
# Description:
# This script calculates average age with the corresponding map code in the initial community map.


# Load required packages
if (!requireNamespace("terra", quietly = TRUE)) {
  install.packages("terra")
}

library(terra)

# Check if the script is being run from within RStudio
if (interactive()) {
  # Get the path of the currently running script
  script_path <- file.path(dirname(rstudioapi::getActiveDocumentContext()$path), "07_calculate_average_age.R")
  
  # Print the script path
  print(script_path)
} else {
  print("Not running in interactive mode (e.g., not in RStudio).")
}

# Specify project directory
project_directory <- dirname(dirname(script_path))

# Specify input and output directories
input_directory <- file.path(project_directory, "data")
output_directory <- file.path(project_directory, "data", "initial_community")

# Create output directory if it doesn't exist
if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}

# Read the raster files for age
Age <- rast(file.path(input_directory, "resampled_rasters", "Age.tif"))

# Read the initial community map
initial_community_map <- rast(file.path(input_directory, "initial_community", "Initial.community.tif"))

# Get unique map codes in the initial community map
unique_map_codes <- 0:147

# Function to calculate average age for each map code
calculate_avg_age <- function(age_raster, output_directory, initial_community_map, unique_map_codes) {
  # Define the output file path
  output_file_path <- file.path(output_directory, "age_average.txt")
  
  # Open a connection to the output file
  output_file <- file(output_file_path, "w")
  
  # Iterate over unique map codes
  for (map_code in unique_map_codes) {
    # Calculate average biomass for the species
    avg_age <- mean(age_raster[initial_community_map == map_code], na.rm = TRUE)
    
    # Prepare the line to write to the file
    output_line <- paste("MapCode", map_code, ": Average age:", avg_age)
    
    # Write the line to the file
    writeLines(output_line, output_file)
  }
  
  # Close the connection to the output file
  close(output_file)
}

# Calculate average age for each map code
calculate_avg_age(Age, output_directory, initial_community_map, unique_map_codes)
