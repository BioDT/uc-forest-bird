# 09_convert_landis_outputs_to_HMSC_inputs.R
# Description:
# This script converts LANDIS-II outputs in g/m2 to kg/m3. 
# Also, assigns NA to the positions which are indicated as not active in the ecoregion map.


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

## Currently, it is working on single indicated scenario below.
# Specify input and output directories
input_directory <- file.path(project_directory, "models", "LANDIS-II", "BAU", "Current")
output_directory <- file.path(project_directory, "data", "HMSC_inputs")

# Create output directory if it doesn't exist
if (!dir.exists(output_directory)) {
  dir.create(output_directory, recursive = TRUE)
}


convert_landis_output <- function(r_in) {
  
  # the projection of the raster (from original input raster)
  projection =  "+proj=utm +zone=35 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
  
  ## the x and y extent of the output Landis rasters
  r <- rast(nrows =1155 , ncols = 4441, crs=projection) 
  ext(r) <- c(116000, 560100, 6604704, 6720204)
  
  # transfer the values of the input raster into the new raster
  n <- values(r_in)
  values(r) <- n
  return(r)
}

# Read the LANDIS eco-region file
ecoregion <- rast(file.path(input_directory, "Eco-region.tif"))

# Find locations of raster cells with values below 10
below_10_positions <- which(values(ecoregion) < 10)


# Read the LANDIS output raster files for tree species
spruce <- rast(file.path(input_directory, "./output/simulationname/agbiomass/piceabies/AGBiomass100.img"))
pine <- rast(file.path(input_directory, "./output/simulationname/agbiomass/pinussyl/AGBiomass100.img"))
birch <- rast(file.path(input_directory, "./output/simulationname/agbiomass/betulaSP/AGBiomass100.img"))
other <- rast(file.path(input_directory, "./output/simulationname/agbiomass/other/AGBiomass100.img"))
avg_age <- rast(file.path(input_directory, "./output/simulationname/age-all-spp/AGE-AVG-100.img"))
med_age <- rast(file.path(input_directory, "./output/simulationname/age-all-spp/AGE-MED-100.img"))

#Convert volume to biomass
e <- convert_landis_output(spruce)
Spruce_V <- (e * 10000) / 405000  # Spruce biomass to m3
Spruce_V[below_10_positions] <- NA  # Assign NAs to positions below 10
writeRaster(Spruce_V, filename = file.path(output_directory, "Vol_Spruce.tif"), overwrite = TRUE, datatype = "INT2S")

e <- convert_landis_output(pine)
Pine_V <- (e * 10000) / 550000  # Spruce biomass to m3
Pine_V[below_10_positions] <- NA  # Assign NAs to positions below 10
writeRaster(Pine_V, filename = file.path(output_directory, "Vol_Pine.tif"), overwrite = TRUE, datatype = "INT2S")

e <- convert_landis_output(birch)
Birch_V <- (e * 10000) / 640000  # Spruce biomass to m3
Birch_V[below_10_positions] <- NA  # Assign NAs to positions below 10
writeRaster(Birch_V, filename = file.path(output_directory, "Vol_Birch.tif"), overwrite = TRUE, datatype = "INT2S")

e <- convert_landis_output(other)
Other_V <- (e * 10000) / 450000  # Spruce biomass to m3
Other_V[below_10_positions] <- NA  # Assign NAs to positions below 10
writeRaster(Other_V, filename = file.path(output_directory, "Vol_Other.tif"), overwrite = TRUE, datatype = "INT2S")

age_A <- convert_landis_output(avg_age)
age_A[below_10_positions] <- NA  # Assign NAs to positions below 10
writeRaster(age_A, filename = file.path(output_directory, "Mean_Age.tif"), overwrite = TRUE, datatype = "INT2S")

age_M <- convert_landis_output(med_age)
age_M[below_10_positions] <- NA  # Assign NAs to positions below 10
writeRaster(age_M, filename = file.path(output_directory, "Med_Age.tif"), overwrite = TRUE, datatype = "INT2S")
