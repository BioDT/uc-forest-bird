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

# Specify project directory
if (interactive()) {
  project_directory <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
} else {
  project_directory <- getwd()
}
print(project_directory)


# Define paths and scenarios
base_path <- file.path(project_directory, "results/")
climate_scenarios <- c("Current", "RCP4.5", "RCP8.5")
management_scenarios <- c("BAU", "EXT10", "EXT30", "GTR30", "NTLR", "NTSR", "SA")
years <- seq(0, 100, by = 10)

# Initialize list to store data frames
all_data <- list()

# Read raster data and create a data frame
for (climate in climate_scenarios) {
  for (management in management_scenarios) {
    # Path to output directory
    # Be aware of the job ID "7188295", and do not forget to change it for different ones.
    path <- file.path(base_path, paste0("run_landis_", climate, "_", management, "_7188295"), "output", "agbiomass")
    species_folders <- list.dirs(path, recursive = FALSE, full.names = TRUE)
    
    # Initialize a data frame to store the total AGBiomass
    total_agbiomass <- data.frame(
      Climate = climate,
      Management = management,
      Year = years,
      TotalAGBiomass = numeric(length(years))
    )
    
    for (species_folder in species_folders) {
      species_name <- basename(species_folder)
      agbiomass_files <- list.files(species_folder, pattern = "AGBiomass[0-9]+\\.img$", full.names = TRUE)
      for (file in agbiomass_files) {
        year <- as.numeric(gsub("AGBiomass|.img", "", basename(file)))
        raster_data <- rast(file)
        mean_agbiomass <- global(raster_data, mean, na.rm = TRUE)[[1]]
        total_agbiomass$TotalAGBiomass[total_agbiomass$Year == year] <- total_agbiomass$TotalAGBiomass[total_agbiomass$Year == year] + mean_agbiomass
      }
    }
    all_data[[length(all_data) + 1]] <- total_agbiomass
  }
}


# Combine all data frames
df <- do.call(rbind, all_data)

# Create a single PDF file
pdf(file = file.path(base_path, "Deadwood.pdf"), width = 15, height = 5)

deadwood_unit = expression(paste("Deadwood (g/m"^2, ")"))
# Create the plot
p <- ggplot(df, aes(x = Year, y = TotalAGBiomass, color = Climate)) +
  geom_line(size = 1) +
  facet_grid(~ Management, scales = "free_x") +
  labs(title = "Deadwood over time (100 years)", x = "Year", y = deadwood_unit, color = "Climate Scenario") +
  scale_x_continuous(breaks = seq(0, 100, 25)) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 24, face = "bold"),
    axis.title = element_text(size = 20, face = "bold"),
    axis.text = element_text(size = 16),
    strip.text = element_text(size = 16, face = "bold"),
    legend.position = "bottom",
    legend.text = element_text(size = 14),
    legend.title = element_text(size = 16, face = "bold"),
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