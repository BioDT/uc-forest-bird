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
    path <- file.path(run_directory, paste0(climate, "_", management), "output", "agbiomass")
    species_folders <- list.dirs(path, recursive = FALSE, full.names = TRUE)
    for (species_folder in species_folders) {
      species_name <- basename(species_folder)
      agbiomass_files <- list.files(species_folder, pattern = "AGBiomass[0-9]+\\.img$", full.names = TRUE)
      for (file in agbiomass_files) {
        year <- as.numeric(gsub("AGBiomass|.img", "", basename(file)))
        raster_data <- rast(file)
        mean_agbiomass <- global(raster_data, mean, na.rm = TRUE)[[1]]
        all_data[[length(all_data) + 1]] <- data.frame(
          Climate = climate,
          Management = management,
          Species = species_name,
          Year = year,
          AGBiomass = mean_agbiomass
        )
      }
    }
  }
}


# Combine all data frames
df <- do.call(rbind, all_data)

# Create a single PDF file
pdf(file = file.path(results_directory, "AGBiomass_all_species.pdf"), width = 15, height = 10)

ag_unit = expression(paste("AGBiomass (g/m"^2, ")"))
# Create the plot
p <- ggplot(df, aes(x = Year, y = AGBiomass, color = Species)) +
  geom_line(size = 1) +
  facet_grid(Climate ~ Management, scales = "free_x") +
  labs(title = "Above-ground biomass over time (until 2100)", x = "Year", y = ag_unit, color = "") +
  scale_color_discrete(labels = unique(df$Species)) +
  scale_x_continuous(breaks = seq(0, 80, 20)) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 24, face = "bold"),
    axis.title = element_text(size = 20, face = "bold"),
    axis.text = element_text(size = 16),
    strip.text = element_text(size = 16, face = "bold"),
    legend.position = "bottom",
    legend.text = element_text(size = 14),
    legend.title = element_blank(),
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_line(color = "gray95"),
    strip.background = element_rect(fill = "gray90", color = "gray90"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

# Display the plot
print(p)

# Close the PDF file
dev.off()