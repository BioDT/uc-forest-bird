# Load required packages
if (!requireNamespace("raster", quietly = TRUE)) {
  install.packages("raster")
}
if (!requireNamespace("rgdal", quietly = TRUE)) {
  install.packages("rgdal")
}
if (!requireNamespace("sp", quietly = TRUE)) {
  install.packages("sp")
}
if (!requireNamespace("exactextractr", quietly = TRUE)) {
  install.packages("exactextractr")
}
if (!requireNamespace("rstudioapi", quietly = TRUE)) {
  install.packages("rstudioapi")
}


library("raster")
library("rgdal")
library("sp")
library("exactextractr")
library("rstudioapi")

# Check if the script is being run from within RStudio
if (interactive()) {
  # Get the path of the currently running script
  script_path <- rstudioapi::getActiveDocumentContext()$path
  
  # Print the script path
  print(script_path)
} else {
  print("Not running in interactive mode (e.g., not in RStudio).")
}

directory <- dirname(script_path)
setwd(directory) #set the working directory as the directory of the R Script file
print(getwd())

# List all raster files in the directory
raster_files <- list.files(directory, pattern = "\\.tif$", full.names = TRUE)

# Initialize an empty vector to store mean values
mean_values <- numeric(length(raster_files))

# Loop through each raster file
for (i in seq_along(raster_files)) {
  # Read the raster file
  raster_data <- raster(raster_files[i])
  
  # Calculate the mean
  mean_values[i] <- mean(raster_data[], na.rm = TRUE)
}

# Print mean values for each raster file
for (i in seq_along(raster_files)) {
  cat("Mean value of", basename(raster_files[i]), ":", mean_values[i], "\n")
}