library(terra)

# Specify default directories
if (interactive()) {
  project_directory <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
} else {
  project_directory <- getwd()
}

# Specify the scenario and prediction year
scenario <- "8.5_NTLR"   # e.g., current_BAU, 4.5_EXT10
year <- 40                  # e.g., 5, 10, 50

# 1. Define path to predicted .tif files
prediction_directory <- file.path(project_directory, "results", "predictions", scenario, year)
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


# --- Community-Level Change Map (Mean of All Species) ----
files1 <- list.files(file.path(project_directory, "results/predictions/8.5_NTLR/40"), pattern = "\\.tif$", full.names = TRUE)
files2 <- list.files(file.path(project_directory, "results/predictions/4.5_NTLR/40"), pattern = "\\.tif$", full.names = TRUE)

r1_stack <- rast(files1)
r2_stack <- rast(files2)

community_diff <- sum(r2_stack) - sum(r1_stack)
plot(community_diff, main = "Community-Level Change (4.5_NTLR - 8.5_NTLR)",
     col = colorRampPalette(c("red", "white", "blue"))(100))


# --- Mean Occurrence Comparison Across All Species ---
# Load species mean summaries (from CSVs)
means1 <- read.csv2(file.path(project_directory, "results/predictions/8.5_NTLR/40/species_means_summary.csv"))
means2 <- read.csv2(file.path(project_directory, "results/predictions/4.5_NTLR/40/species_means_summary.csv"))

# Merge and compute differences
merged <- merge(means1, means2, by = "Species", suffixes = c("_8.5", "_4.5"))
merged$Difference <- merged$Mean_4.5 - merged$Mean_8.5

# Top gainers/losers
head(merged[order(-merged$Difference), ], 5)  # Species that increased most
head(merged[order(merged$Difference), ], 5)   # Species that decreased most
