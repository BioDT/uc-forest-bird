# Load required libraries
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}
if (!requireNamespace("terra", quietly = TRUE)) {
  install.packages("terra")
}
if (!requireNamespace("gridExtra", quietly = TRUE)) {
  install.packages("gridExtra")
}

library(ggplot2)
library(terra)
library(gridExtra)

# Source common code
if (interactive()) {
  source(file.path(dirname(rstudioapi::getActiveDocumentContext()$path), "common.R"))
} else {
  source(file.path("analysis", "common.R"))
}

# Initialize list to store data frames
all_data <- list()

# Read raster data and create a data frame
for (climate in climate_scenarios) {
  for (management in management_scenarios) {
    # Path to output directory
    path <- file.path(run_directory, paste0(climate, "_", management), "output", "harvest")
    harvest_files <- list.files(path, pattern = "biomass-removed-[0-9]+\\.img$", full.names = TRUE)
    for (file in harvest_files) {
      year <- as.numeric(gsub("biomass-removed-|.img", "", basename(file)))
      raster_data <- rast(file)
      mean_harvested_biomass <- global(raster_data, mean, na.rm = TRUE)[[1]]
      all_data[[length(all_data) + 1]] <- data.frame(
        Climate = climate,
        Management = management,
        Year = year,
        HBiomass = mean_harvested_biomass
      )
    }
  }
}



# Combine all data frames
df <- do.call(rbind, all_data)

df$Climate <- factor(df$Climate, levels = climate_scenarios)
df$Management <- factor(df$Management, levels = management_scenarios)

# Create a single PDF file
pdf(file = file.path(results_directory, "Harvested_biomass_by_climate.pdf"), width = 10, height = 6)

harvest_unit = expression(paste("Harvested Biomass (g/m"^2, ")"))
# Create the plot
p <- ggplot(df, aes(x = Year, y = HBiomass, colour = Management, group = Management)) +
  geom_line(linewidth = 0.7) +
  facet_wrap(~ Climate) +
  labs(title = "Harvested biomass over time (until 2100)", x = "Year", y = harvest_unit, colour = "Management") +
  scale_x_continuous(
    limits = c(5, 80),
    breaks = c(5, 30, 55, 80),
    labels = c("2025", "2050", "2075", "2100")
  ) +
  theme_bw()

# Display the plot
print(p)

# Close the PDF file
dev.off()
