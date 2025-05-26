library(Hmsc)
library(terra)
library(abind)

# Specify project directory
if (interactive()) {
  project_directory <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
} else {
  project_directory <- getwd()
}
print(project_directory)

# Specify the scenario and prediction year
scenario <- "4.5_NTLR"   # e.g., current_BAU, 4.5_EXT10
year <- 40                  # e.g., 5, 10, 50

# Override scenario and year from command-line argument
args = commandArgs(trailingOnly=TRUE)
if (length(args) > 0) {
  split_arg = strsplit(args[1], "/")[[1]]
  scenario = split_arg[1]
  year = as.numeric(split_arg[2])
}

# --- Setup paths
source1_dir <- file.path(project_directory, "data", "HMSC_inputs", scenario, year)
source2_dir <- file.path(project_directory, "data", "HMSC_inputs", "prediction_layers")
climate_dir <- file.path(project_directory, "data", "HMSC_inputs", "climate")
out_dir <- file.path(project_directory, "results", "predictions", scenario, year)
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

if (!dir.exists(source1_dir)) stop(paste("Source directory not found:", source1_dir))

# --- Load HMSC model ---
model_path <- file.path(project_directory, "models", "HMSC")
model_file <- "RF_models_thin_10_samples_250_chains_4.Rdata"
load(file.path(model_path, model_file))
m <- models$pa
model.name <- "pa"

# Reduce posterior samples
postList = list()
for(i in 1:4){
  a = list()
  for(j in 1:5){
    a[[j]] = m$postList[[i]][[50*j]]
  }
  postList[[i]] = a
}
m$postList = postList

# --- Load predictor rasters ---
files <- list.files(c(source1_dir, source2_dir), pattern = ".tif$", full.names=TRUE)
allData <- lapply(files, rast)
names(allData) <- sub(".tif$", "", basename(files))

# --- Select valid cells ---
sel <- intersect(cells(allData$Acricultural_Land), cells(allData$Stand_Age))
n <- length(sel)

# --- PCA projection ---
pca_file <- "pca.RData"
load(file.path(model_path, pca_file))
vars.pca[vars.pca == "Sub.xeric_forest"] <- "Sub-xeric_forest"
ma <- match(vars.pca, names(allData))
toPCA <- lapply(seq_along(ma), function(i) allData[[ma[i]]] - res.pca$center[i])

PCA <- list()
for (i in 1:5) {
  PCA[[i]] <- Reduce(`+`, Map(`*`, toPCA, res.pca$rotation[, i]))
}
names(PCA) <- paste0("VMI_PC", 1:5)
allData <- c(allData, PCA)

# --- Prepare XData grid ---
xy.grid <- xyFromCell(allData[[1]], sel)
XData.grid <- matrix(NA, nrow = n, ncol = ncol(m$XData))
colnames(XData.grid) <- colnames(m$XData)

orig <- which(names(allData) %in% colnames(XData.grid))
target <- match(names(allData)[orig], colnames(XData.grid))
for (i in seq_along(target)) {
  XData.grid[, target[i]] <- values(allData[[orig[i]]])[sel, 1]
}

# Set constants and temperatures
XData.grid[, "DecFeb"] <- XData.grid[, "DecFeb"] - 273.15
XData.grid[, "AprMay"] <- XData.grid[, "AprMay"] - 273.15
XData.grid[, "JunJul"] <- XData.grid[, "JunJul"] - 273.15
XData.grid[, "linelength"] <- mean(m$XData$linelength)
XData.grid[, "duration"] <- mean(m$XData$duration)
XData.grid[, "year"] <- 0
XData.grid <- as.data.frame(XData.grid)


# --- Load climate values ---
climate_code <- strsplit(scenario, "_")[[1]][1]  # e.g., "current", "4.5"
climate_file <- switch(climate_code,
                       "4.5" = "rcp45_temp_seasonal_averages.csv",
                       "8.5" = "rcp85_temp_seasonal_averages.csv",
                       "current" = "current_temp_seasonal_averages.csv")


climatic_scenarios <- read.csv(file.path(climate_dir, climate_file))
climatic_values <- climatic_scenarios[climatic_scenarios$year == 2020 + year, ]
XData.grid$JunJul <- climatic_values$Summer_Avg
XData.grid$AprMay <- climatic_values$Spring_Avg
XData.grid$DecFeb <- climatic_values$Winter_Avg


# --- Run prediction ---
Gradient <- prepareGradient(m, XDataNew = XData.grid, sDataNew = list(route = xy.grid))

cat("Starting predictions...\n")
predY <- predict(m, Gradient = Gradient, predictEtaMeanField = TRUE, expected = TRUE)
cat("Predictions complete.\n")

# The following line is elegant but memory-intensive and causes out-of-memory errors
# EpredY <- exp(apply(abind(lapply(predY, log), along = 3), c(1, 2), mean))

# --- Memory-efficient mean log aggregation ---
n_species <- ncol(predY[[1]])
n_cells <- nrow(predY[[1]])
EpredY <- matrix(NA, nrow = n_cells, ncol = n_species)
colnames(EpredY) <- colnames(predY[[1]])

for (i in 1:n_species) {
  log_preds <- sapply(predY, function(p) log(p[, i]))  # n_cells × n_samples
  EpredY[, i] <- exp(rowMeans(log_preds))
}

save(EpredY, file = file.path(out_dir, paste0(model.name, "_predictions.RData")))

# Write raster layers
for (i in 1:ncol(EpredY)) {
  a <- allData[[1]]
  a[cells(a)] <- NA
  a[sel] <- EpredY[, i]
  writeRaster(a, filename = file.path(out_dir, paste0(colnames(EpredY)[i], ".tif")), overwrite = TRUE)
}

cat(paste("Finished:", scenario, "Year:", year, "\n"))
