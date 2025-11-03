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
# presence_threshold <- 0.5  # richness = count of species with prob > threshold

# Mammals to exclude (and only those present in your .tif list will be removed)
mammals_to_exclude <- c(
  "Alces alces", "Apodemus agrarius", "Apodemus flavicollis", "Arvicola amphibius", "Arvicolinae",
  "Capreolus capreolus", "Dama dama", "Eptesicus nilssonii", "Erinaceus europaeus", "Felis catus",
  "Halichoerus grypus", "Lepus europaeus", "Lepus timidus", "Lynx lynx", "Lutra lutra", "Martes martes",
  "Meles meles", "Microtus", "Microtus agrestis", "Mus musculus", "Mustela erminea", "Mustela nivalis",
  "Myodes glareolus", "Myodes rufocanus", "Myodes rutilus", "Myotis daubentonii", "Myotis mystacinus/brandtii",
  "Myotis nattereri", "Neomys fodiens", "Neovison vison", "Nyctereutes procyonoides", "Odocoileus virginianus",
  "Ondatra zibethicus", "Oryctolagus cuniculus", "Plecotus auritus", "Pteromys volans", "Pusa hispida",
  "Rattus norvegicus", "Rangifer tarandus", "Sciurus vulgaris", "Sorex araneus", "Soricidae", "Talpa europaea",
  "Vulpes vulpes"
)

# ---- compute richness ----
richness_summary <- data.frame(Scenario = character(), Year = integer(), TotalRichness = numeric())

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
    richness <- sum(s, na.rm = TRUE)
    
    # write richness map
    #out_map <- file.path(project_directory, "results", "richness", sc, paste0("richness_", yr, ".tif"))
    #dir.create(dirname(out_map), recursive = TRUE, showWarnings = FALSE)
    #writeRaster(richness, out_map, overwrite = TRUE)
    
    # expected richness value for summary
    expected_rich <- global(richness, "sum", na.rm = TRUE)[[1]]
    
    richness_summary <- rbind(
      richness_summary,
      data.frame(Scenario = sc, Year = yr, TotalRichness = expected_rich)
    )
    
    cat("✓", sc, "Year", yr, "→ expected richness:", round(expected_rich, 3), "\n")
  }
}

# # save summary
dir.create(file.path("results"), showWarnings = FALSE)
write.csv(richness_summary, file.path(project_directory, "results", "richness_summary.csv"), row.names = FALSE)


# good_prediction_dir <- file.path(project_directory, "results", "predictions", "current_BAU", "10")
# tif_good <- list.files(good_prediction_dir, pattern="\\.tif$", full.names=TRUE)
# r_good <- rast(tif_good)
# ext(r_good); res(r_good); crs(r_good); origin(r_good)
# 
# bad_prediction_dir <- file.path(project_directory, "results", "predictions", "current_BAU", "80")
# tif_bad <- list.files(bad_prediction_dir, pattern="\\.tif$", full.names=TRUE)
# r_bad <- rast(tif_bad)
# ext(r_bad); res(r_bad); crs(r_bad); origin(r_bad)
# 
# geom_ok <- sapply(tif_bad, \(f) compareGeom(rast(f), r_good, stopOnError=FALSE))
# table(geom_ok)                       # FALSE indicates misaligned files
# basename(tif_bad[!geom_ok])[1:10]    # peek at offenders
# 
# 
# diag_folder <- file.path(project_directory, "results", "predictions", "current_BAU", "80")  # change to "10" to compare
# tifs <- list.files(diag_folder, pattern="\\.tif$", full.names=TRUE)
# s <- rast(tifs)
# 
# # 1) Pixel coverage: how many pixels have at least one non-NA across species?
# has_any <- app(s, fun=function(x) any(!is.na(x)))
# n_any   <- global(has_any, "sum", na.rm=TRUE)[[1]]
# 
# # 2) Pixels with any positive probability
# has_pos <- app(s, fun=function(x) any(x > 0, na.rm=TRUE))
# n_pos   <- global(has_pos, "sum", na.rm=TRUE)[[1]]
# 
# # 3) Per-layer basic stats (quick sanity)
# mm <- minmax(s)
# per_layer_mean <- global(s, "mean", na.rm=TRUE)  # one row per layer
# 
# # 4) Overall expected richness map summary
# richness <- sum(s, na.rm=TRUE)
# total_expected <- global(richness, "sum", na.rm=TRUE)[[1]]
# mean_expected  <- global(richness, "mean", na.rm=TRUE)[[1]]
# n_valid        <- global(!is.na(richness), "sum")[[1]]
# 
# cat("Pixels with any data:", n_any, "\n")
# cat("Pixels with any positive prob:", n_pos, "\n")
# cat("Valid pixels in richness map:", n_valid, "\n")
# cat("Total expected:", format(total_expected, big.mark=","), "\n")
# cat("Mean expected per pixel:", signif(mean_expected, 6), "\n")
# 
# # 5) How many layers are all-zero or all-NA?
# all_zero <- sapply(1:nlyr(s), function(i) { z <- global(s[[i]] > 0, "sum", na.rm=TRUE)[[1]]; is.na(z) || z == 0 })
# all_na   <- sapply(1:nlyr(s), function(i) { !is.finite(mm[1,i]) && !is.finite(mm[2,i]) })  # min & max NA
# 
# cat("Layers all-zero:", sum(all_zero), " / ", nlyr(s), "\n")
# cat("Layers all-NA  :", sum(all_na),   " / ", nlyr(s), "\n")
# 
# # 6) Print a few suspicious layers
# if (any(all_zero)) print(basename(tifs[which(all_zero)[1:min(10,sum(all_zero))]]))
# if (any(all_na))   print(basename(tifs[which(all_na)[1:min(10,sum(all_na))]]))
# 
# sp <- "Accipiter gentilis.tif"
# 
# r_bad1  <- rast(file.path(project_directory, "results", "predictions", "current_BAU", "80", sp))
# r_good1 <- rast(file.path(project_directory, "results", "predictions", "current_BAU", "10", sp))
# 
# # Check data type, min/max, and a quick value sample
# datatype(r_bad1);  datatype(r_good1)
# minmax(r_bad1);    minmax(r_good1)
# unique(values(r_bad1)[1:1000])
# 
# 
