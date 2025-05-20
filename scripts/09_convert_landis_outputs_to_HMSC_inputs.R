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

# Specify input and output directories
# Be aware of the NAME and run_ID, and do not forget to change it for different ones
#run_directory <- file.path(project_directory, "runs", "NAME", "run_ID")
run_directory <- file.path(project_directory, "runs", "PAR_umol_24042025", "run_10486830")

#directory for the eco_region.tif
eco_directory <- file.path(project_directory, "runs", "PAR_umol_24042025", "landis_template")

#directory to put the results to be utilized by HMSC
results_directory <- file.path(project_directory, "data", "HMSC_inputs")

print(sprintf("run_directory = %s", run_directory))
stopifnot(dir.exists(run_directory))

print(sprintf("results_directory = %s", results_directory))
if(!dir.exists(results_directory)) {
  dir.create(results_directory)
}

convert_landis_output <- function(r_in, reference) {
  
  # the projection of the raster (from original input raster)
  #projection = "+proj=utm +zone=35 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
  
  ## the x and y extent of the output Landis rasters
  #r <- rast(nrows =1155 , ncols = 4441, crs=projection) 
  #ext(r) <- c(116000, 560100, 6604704, 6720204)
  
  r <- rast(nrows = nrow(reference), ncols = ncol(reference), crs = crs(reference))
  ext(r) <- ext(reference)
  
  # Safety: flip vertically if needed (e.g. LUMI, Linux)
  if (Sys.info()[["sysname"]] != "Windows") {
    r_in <- flip(r_in, direction = "vertical")
  }
  
  # transfer the values of the input raster into the new raster
  n <- values(r_in)
  values(r) <- n
  return(r)
}

# Read the LANDIS eco-region file for reference
ecoregion <- rast(file.path(eco_directory, "ecoregions.tif"))

# Read the Urban reference raster
urban_ref <- rast(file.path(results_directory, "prediction_layers", "Urban.tif"))  

# Find locations of raster cells with values below 10
below_10_positions <- which(values(ecoregion) < 10)

# Define scenarios
climate_scenarios <- c("current", "4.5", "8.5")
management_scenarios <- c("BAU", "EXT10", "EXT30", "GTR30", "NTLR", "NTSR", "SA")


# Read raster data and create a data frame
for (climate in climate_scenarios) {
  for (management in management_scenarios) {
    # Path to output directory
    path <- file.path(run_directory, paste0(climate, "_", management), "output", "agbiomass")
    output_directory <-file.path(results_directory, paste0(climate, "_", management))
    if(!dir.exists(output_directory)) {
      dir.create(output_directory)
    }
    # Path to spruce agbiomass files
    spruce_path <-file.path(path, "piceabies")
    spruce_files <- list.files(spruce_path, pattern = "AGBiomass[0-9]+\\.img$", full.names = TRUE)
    #SPRUCE volume
    for (spruce_file in spruce_files) {
      year <- as.numeric(gsub("AGBiomass|.img", "", basename(spruce_file)))
      output_directory_year <-file.path(output_directory, year)
      #print(sprintf("output_directory = %s", output_directory_year))
      if(!dir.exists(output_directory_year)) {
        dir.create(output_directory_year)
      }
      spruce_data <- rast(spruce_file)
      spruce <- convert_landis_output(spruce_data, ecoregion)
      Spruce_V <- (spruce * 10000) / 405000  # Spruce biomass to m3
      Spruce_V[below_10_positions] <- NA  # Assign NAs to positions below 10
      # Match urban grid
      Spruce_V <- terra::project(Spruce_V, urban_ref)
      Spruce_V <- crop(Spruce_V, ext(urban_ref))
      writeRaster(Spruce_V, filename = file.path(output_directory_year, "Spruce_Volume.tif"), overwrite = TRUE, gdal=c("COMPRESS=NONE"), datatype='INT4S')
    }
    #Path to pine agbiomass files
    pine_path <-file.path(path, "pinussyl")
    pine_files <- list.files(pine_path, pattern = "AGBiomass[0-9]+\\.img$", full.names = TRUE)
    #PINE volume
    for (pine_file in pine_files) {
      year <- as.numeric(gsub("AGBiomass|.img", "", basename(pine_file)))
      output_directory_year <-file.path(output_directory, year)
      #print(sprintf("output_directory = %s", output_directory_year))
      if(!dir.exists(output_directory_year)) {
        dir.create(output_directory_year)
      }
      pine_data <- rast(pine_file)
      pine <- convert_landis_output(pine_data, ecoregion)
      Pine_V <- (pine * 10000) / 550000  # Pine biomass to m3
      Pine_V[below_10_positions] <- NA  # Assign NAs to positions below 10
      Pine_V <- terra::project(Pine_V, urban_ref)
      Pine_V <- crop(Pine_V, ext(urban_ref))
      writeRaster(Pine_V, filename = file.path(output_directory_year, "Pine_Volume.tif"), overwrite = TRUE, gdal=c("COMPRESS=NONE"), datatype='INT4S')
    }
    # Path to birch agbiomass files
    birch_path <-file.path(path, "betulaSP")
    birch_files <- list.files(birch_path, pattern = "AGBiomass[0-9]+\\.img$", full.names = TRUE)
    #BIRCH volume
    for (birch_file in birch_files) {
      year <- as.numeric(gsub("AGBiomass|.img", "", basename(birch_file)))
      output_directory_year <-file.path(output_directory, year)
      #print(sprintf("output_directory = %s", output_directory_year))
      if(!dir.exists(output_directory_year)) {
        dir.create(output_directory_year)
      }
      birch_data <- rast(birch_file)
      birch <- convert_landis_output(birch_data, ecoregion)
      Birch_V <- (birch * 10000) / 640000  # Birch biomass to m3
      Birch_V[below_10_positions] <- NA  # Assign NAs to positions below 10
      Birch_V <- terra::project(Birch_V, urban_ref)
      Birch_V <- crop(Birch_V, ext(urban_ref))
      writeRaster(Birch_V, filename = file.path(output_directory_year, "Birch_Volume.tif"), overwrite = TRUE, gdal=c("COMPRESS=NONE"), datatype='INT4S')
    }
    # Path to other agbiomass files
    other_path <-file.path(path, "other")
    other_files <- list.files(other_path, pattern = "AGBiomass[0-9]+\\.img$", full.names = TRUE)
    #OTHER volume
    for (other_file in other_files) {
      year <- as.numeric(gsub("AGBiomass|.img", "", basename(other_file)))
      output_directory_year <-file.path(output_directory, year)
      #print(sprintf("output_directory = %s", output_directory_year))
      if(!dir.exists(output_directory_year)) {
        dir.create(output_directory_year)
      }
      other_data <- rast(other_file)
      other <- convert_landis_output(other_data, ecoregion)
      Other_V <- (other * 10000) / 450000  # Other biomass to m3
      Other_V[below_10_positions] <- NA  # Assign NAs to positions below 10
      Other_V <- terra::project(Other_V, urban_ref)
      Other_V <- crop(Other_V, ext(urban_ref))
      writeRaster(Other_V, filename = file.path(output_directory_year, "Other_Deciduous_Volume.tif"), overwrite = TRUE, gdal=c("COMPRESS=NONE"), datatype='INT4S')
    }
    # Path to mean age files
    age_path <-file.path(run_directory, paste0(climate, "_", management), "output", "age-all-spp")
    age_files <- list.files(age_path, pattern = "AGE-AVG-[0-9]+\\.img$", full.names = TRUE)
    # MEAN AGE projection
    for (age_file in age_files) {
      year <- as.numeric(gsub("AGE-AVG-|.img", "", basename(age_file)))
      output_directory_year <-file.path(output_directory, year)
      #print(sprintf("output_directory = %s", output_directory_year))
      if(!dir.exists(output_directory_year)) {
        dir.create(output_directory_year)
      }
      age_data <- rast(age_file)
      age_A <- convert_landis_output(age_data, ecoregion)
      age_A[below_10_positions] <- NA  # Assign NAs to positions below 10
      age_A <- terra::project(age_A, urban_ref)
      age_A <- crop(age_A, ext(urban_ref))
      writeRaster(age_A, filename = file.path(output_directory_year, "Stand_Age.tif"), overwrite = TRUE, gdal=c("COMPRESS=NONE"), datatype='INT4S')
    }
  }
}