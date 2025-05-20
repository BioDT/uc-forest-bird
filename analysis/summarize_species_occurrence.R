library(terra)

# Specify default directories
if (interactive()) {
  project_directory <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
} else {
  project_directory <- getwd()
}

# 1. Define path to predicted .tif files
prediction_directory <- file.path(project_directory, "results", "predictions", "current_BAU", "55")
files <- list.files(prediction_directory, pattern = "\\.tif$", full.names = TRUE)

# 2. Compute mean predicted value for each species
species_means <- data.frame(Species = character(), Mean = numeric())

for (f in files) {
  r <- rast(f)
  m <- global(r, fun = "mean", na.rm = TRUE)[[1]]
  species_name <- tools::file_path_sans_ext(basename(f))
  species_means <- rbind(species_means, data.frame(Species = species_name, Mean = m))
}

# 3. Sort species by mean predicted occurrence
species_means <- species_means[order(species_means$Mean, decreasing = TRUE), ]

# 4. Display results
cat("Top predicted species in Uusimaa:\n")
print(head(species_means, 5))

cat("\n Lowest predicted species in Uusimaa:\n")
print(tail(species_means, 5))

top_species <- species_means$Species[1]
cat("Top predicted species:", top_species, "\n")

# Load raster for top species
top_raster_path <- file.path(prediction_directory, paste0(top_species, ".tif"))
r <- rast(top_raster_path)

# Plot occurrence map
plot(r, main = paste0(top_species, " - Predicted Occurrence"),
     col = terrain.colors(100))

write.csv2(species_means,
          file = file.path(prediction_directory, "species_means_summary.csv"),
          row.names = FALSE)

