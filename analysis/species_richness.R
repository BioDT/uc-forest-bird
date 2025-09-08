library(terra)

# Specify default directories
if (interactive()) {
  project_directory <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
} else {
  project_directory <- getwd()
}

# ---- settings ----
scenarios <- c(
  "current_BAU","current_EXT10","current_EXT30","current_GTR30","current_NTLR","current_NTSR","current_SA",
  "4.5_BAU","4.5_EXT10","4.5_EXT30","4.5_GTR30","4.5_NTLR","4.5_NTSR","4.5_SA",
  "8.5_BAU","8.5_EXT10","8.5_EXT30","8.5_GTR30","8.5_NTLR","8.5_NTSR","8.5_SA"
)
years <- seq(5, 80, 5)
presence_threshold <- 0.5  # richness = count of species with prob > threshold

# Mammals to exclude (and only those present in your .tif list will be removed)
mammals_to_exclude <- c(
  "Alces alces",
  "Capreolus capreolus",
  "Lepus europaeus",
  "Lepus timidus",
  "Odocoileus virginianus"
)

# ---- compute richness ----
richness_summary <- data.frame(Scenario = character(), Year = integer(), MeanRichness = numeric())

for (sc in scenarios) {
  for (yr in years) {
    
    prediction_dir <- file.path(project_directory, "results", "predictions", sc, yr)
    tif_files <- list.files(prediction_dir, pattern = "\\.tif$", full.names = TRUE)
    
    if (length(tif_files) == 0) {
      warning("No .tif files in: ", prediction_dir)
      next
    }
    
    # species names from filenames (without extension)
    species_names <- tools::file_path_sans_ext(basename(tif_files))
    
    # keep only birds (exclude mammals that are present)
    keep_idx <- !(species_names %in% mammals_to_exclude)
    tif_files_birds <- tif_files[keep_idx]
    
    if (length(tif_files_birds) == 0) {
      warning("All files excluded (mammals) in: ", prediction_dir)
      next
    }
    
    # stack and compute richness
    s <- rast(tif_files_birds)
    richness <- sum(s > presence_threshold, na.rm = TRUE)
    
    # write richness map
    #out_map <- file.path(project_directory, "results", "richness", sc, paste0("richness_", yr, ".tif"))
    #dir.create(dirname(out_map), recursive = TRUE, showWarnings = FALSE)
    #writeRaster(richness, out_map, overwrite = TRUE)
    
    # mean richness value for summary
    mean_rich <- global(richness, "mean", na.rm = TRUE)[[1]]
    
    richness_summary <- rbind(
      richness_summary,
      data.frame(Scenario = sc, Year = yr, MeanRichness = mean_rich)
    )
    
    cat("✓", sc, "Year", yr, "→ mean richness:", round(mean_rich, 3), "\n")
  }
}

# save summary
dir.create(file.path("results"), showWarnings = FALSE)
write.csv(richness_summary, file.path(project_directory, "results", "richness_summary.csv"), row.names = FALSE)
