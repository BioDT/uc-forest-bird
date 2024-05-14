# 03_reclassify_rasters.R
# Description:
# This script first calculates the percentage of each tree type based on the total volume of trees in each pixel using the Terra package.
# Then, it reclassifies the percentage rasters into predefined intervals and assigns corresponding values to create classified rasters for each tree type and age.
# Finally, the classified rasters are written to the directory "data/classified_rasters".


# Load required packages
if (!requireNamespace("terra", quietly = TRUE)) {
  install.packages("terra")
}

library(terra)

# Check if the script is being run from within RStudio
if (interactive()) {
  # Get the path of the currently running script
  script_path <- file.path(dirname(rstudioapi::getActiveDocumentContext()$path), "03_classify_rasters.R")
  
  # Print the script path
  print(script_path)
} else {
  print("Not running in interactive mode (e.g., not in RStudio).")
}

# Specify project directory
project_directory <- dirname(dirname(script_path))

# Specify input and output directories
input_directory <- file.path(project_directory, "data", "resampled_rasters")
output_directory <- file.path(project_directory, "data", "classified_rasters")

# Create output directory if it doesn't exist
if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}

# Function to calculate percentage raster
calculate_percentage <- function(tree_raster, total_volume_raster) {
  percentage_raster <- tree_raster / total_volume_raster * 100
  return(percentage_raster)
}

# Read the raster files for spruce, pine, birch, and other trees volumes
spruce <- rast(file.path(input_directory, "Spruce.tif"))
pine <- rast(file.path(input_directory, "Pine.tif"))
birch <- rast(file.path(input_directory, "Birch.tif"))
other <- rast(file.path(input_directory, "Other.tif"))

# Calculate the total volume of trees in each pixel
total_volume_raster <- sum(spruce, pine, birch, other)

# Calculate the percentage of each tree type relative to the total volume
spruce_percentage <- calculate_percentage(spruce, total_volume_raster)
pine_percentage <- calculate_percentage(pine, total_volume_raster)
birch_percentage <- calculate_percentage(birch, total_volume_raster)
other_percentage <- calculate_percentage(other, total_volume_raster)


# Define the reclassification intervals and values for trees
tree_intervals <- c(0, 1, 0, 
                    1, 25, 1,
                    25, 50, 2,
                    50, 75, 3,
                    75, 100, 4)
tree_matrix <- matrix(tree_intervals, ncol=3, byrow=TRUE)

# Define the intervals and corresponding values for classification for age
age_intervals <- c(0, 1, 0,
                   1, 10, 1,
                   10, 41, 2,
                   41, 60, 3,
                   60, 120, 4,
                   120, 500, 5)

age_matrix <- matrix(age_intervals, ncol=3, byrow=TRUE)


# Read the raster files for age
age <- rast(file.path(input_directory, "Age.tif"))

# Reclassify each percentage raster
spruce_reclass <- classify(spruce_percentage, tree_matrix)
pine_reclass <- classify(pine_percentage, tree_matrix)
birch_reclass <- classify(birch_percentage, tree_matrix)
other_reclass <- classify(other_percentage, tree_matrix)

# Reclassify age raster
age_reclass <- classify(age, age_matrix)

# Write the reclassified rasters to the output directory
writeRaster(spruce_reclass, filename = file.path(output_directory, "Spruce.tif"), overwrite = TRUE)
writeRaster(pine_reclass, filename = file.path(output_directory, "Pine.tif"), overwrite = TRUE)
writeRaster(birch_reclass, filename = file.path(output_directory, "Birch.tif"), overwrite = TRUE)
writeRaster(other_reclass, filename = file.path(output_directory, "Other.tif"), overwrite = TRUE)
writeRaster(age_reclass, filename = file.path(output_directory, "Age.tif"), overwrite = TRUE)



