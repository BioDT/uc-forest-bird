# 06_calculate_average_biomass.R
# Description:
# This script calculates average biomass for each tree species with the corresponding map code in the initial community map.


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
input_directory <- file.path(project_directory, "data", "initial_community")
output_directory <- file.path(project_directory, "data", "initial_community")

# Create output directory if it doesn't exist
if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}

# Read the raster files for tree species
Spruce <- rast(file.path(input_directory, "Spruce_B.tif"))
Pine <- rast(file.path(input_directory, "Pine_B.tif"))
Birch <- rast(file.path(input_directory, "Birch_B.tif"))
Other <- rast(file.path(input_directory, "Other_B.tif"))


# Read the initial community map
initial_community_map <- rast(file.path(input_directory, "Initial.community.tif"))

# Get unique map codes in the initial community map
unique_map_codes <- 0:147

# Function to calculate average biomass for a given species
calculate_avg_biomass <- function(species_raster, species_name, output_directory, initial_community_map, unique_map_codes) {
  # Define the output file path
  output_file_path <- file.path(output_directory, paste0(species_name, "_average_biomass.txt"))
  
  # Open a connection to the output file
  output_file <- file(output_file_path, "w")
  
  # Iterate over unique map codes
  for (map_code in unique_map_codes) {
    # Calculate average biomass for the species
    avg_biomass <- mean(species_raster[initial_community_map == map_code], na.rm = TRUE)
    
    # Prepare the line to write to the file
    output_line <- paste("MapCode", map_code, ": Average biomass for", species_name, ":", avg_biomass)
    
    # Write the line to the file
    writeLines(output_line, output_file)
  }
  
  # Close the connection to the output file
  close(output_file)
}

# Calculate average biomass for each species
calculate_avg_biomass(Spruce, "Spruce", output_directory, initial_community_map, unique_map_codes)
calculate_avg_biomass(Pine, "Pine", output_directory, initial_community_map, unique_map_codes)
calculate_avg_biomass(Birch, "Birch", output_directory, initial_community_map, unique_map_codes)
calculate_avg_biomass(Other, "Other", output_directory, initial_community_map, unique_map_codes)
