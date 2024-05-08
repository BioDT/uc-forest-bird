# 06_calculate_average_biomass.R
# Description:
# This script calculates average biomass for each tree species with the corresponding map code in the initial community map.


# Load required packages
if (!requireNamespace("terra", quietly = TRUE)) {
  install.packages("terra")
}

library(terra)

# Check if the script is being run from within RStudio
if (interactive()) {
  # Get the path of the currently running script
  script_path <- file.path(dirname(rstudioapi::getActiveDocumentContext()$path), "06_calculate_average_biomass.R")
  
  # Print the script path
  print(script_path)
} else {
  print("Not running in interactive mode (e.g., not in RStudio).")
}

# Specify project directory
project_directory <- dirname(dirname(script_path))

# Specify input and output directories
input_directory <- file.path(project_directory, "data", "initial_community")
output_directory <- file.path(project_directory, "data", "initial_community")

# Create output directory if it doesn't exist
if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}

# Function to calculate average biomass for a specific map code and tree raster
calculate_average_biomass <- function(initial_map, tree_raster, map_code) {
  # Find positions of map code in the initial community map
  map_code_positions <- which(initial_map == map_code, cells = TRUE)
  
  # Extract biomass values for the specified map code from the tree raster
  biomass_values <- extract(tree_raster, map_code_positions)
  
  # Calculate the average biomass
  average_biomass <- mean(biomass_values, na.rm = TRUE)
  
  return(average_biomass)
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


################Spruce##############################
# Define the output file path
output_file_path <- file.path(output_directory, "Spruce_average_biomass.txt")

# Open a connection to the output file
output_file <- file(output_file_path, "w")

# Iterate over unique map codes
for (map_code in unique_map_codes) {
  # Calculate average biomass for Spruce
  avg_biomass_spruce <- mean(Spruce[initial_community_map == map_code], na.rm = TRUE)
  
  # Prepare the line to write to the file
  output_line <- paste("MapCode", map_code, ": Average biomass for Spruce:", avg_biomass_spruce)
  
  # Write the line to the file
  writeLines(output_line, output_file)
}

# Close the connection to the output file
close(output_file)


################Pine##############################
# Define the output file path
output_file_path <- file.path(output_directory, "Pine_average_biomass.txt")

# Open a connection to the output file
output_file <- file(output_file_path, "w")

# Iterate over unique map codes
for (map_code in unique_map_codes) {
  # Calculate average biomass for Pine
  avg_biomass_pine <- mean(Pine[initial_community_map == map_code], na.rm = TRUE)
  
  # Prepare the line to write to the file
  output_line <- paste("MapCode", map_code, ": Average biomass for Pine:", avg_biomass_pine)
  
  # Write the line to the file
  writeLines(output_line, output_file)
}

# Close the connection to the output file
close(output_file)


################Birch##############################
# Define the output file path
output_file_path <- file.path(output_directory, "Birch_average_biomass.txt")

# Open a connection to the output file
output_file <- file(output_file_path, "w")

# Iterate over unique map codes
for (map_code in unique_map_codes) {
  # Calculate average biomass for Birch
  avg_biomass_birch <- mean(Birch[initial_community_map == map_code], na.rm = TRUE)
  
  # Prepare the line to write to the file
  output_line <- paste("MapCode", map_code, ": Average biomass for Birch:", avg_biomass_birch)
  
  # Write the line to the file
  writeLines(output_line, output_file)
}

# Close the connection to the output file
close(output_file)


################Other##############################
# Define the output file path
output_file_path <- file.path(output_directory, "Other_average_biomass.txt")

# Open a connection to the output file
output_file <- file(output_file_path, "w")

# Iterate over unique map codes
for (map_code in unique_map_codes) {
  # Calculate average biomass for Other
  avg_biomass_other <- mean(Other[initial_community_map == map_code], na.rm = TRUE)
  
  # Prepare the line to write to the file
  output_line <- paste("MapCode", map_code, ": Average biomass for Other:", avg_biomass_other)
  
  # Write the line to the file
  writeLines(output_line, output_file)
}

# Close the connection to the output file
close(output_file)