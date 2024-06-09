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
years <- seq(10, 100, by = 10)

# Initialize list to store data frames
all_data <- list()



# Read raster data and create a data frame
for (climate in climate_scenarios) {
  for (management in management_scenarios) {
    # Path to output directory
    # Be aware of the job ID "7188295", and do not forget to change it for different ones.
    path <- file.path(base_path, paste0("run_landis_", climate, "_", management, "_7188295"), "output", "age-all-spp")
    age_files <- list.files(path, pattern = "AGE-AVG-[0-9]+\\.img$", full.names = TRUE)
    for (file in age_files) {
      year <- as.numeric(gsub("AGE-AVG-|.img", "", basename(file)))
      raster_data <- rast(file)
      mean_age <- global(raster_data, mean, na.rm = TRUE)[[1]]
      all_data[[length(all_data) + 1]] <- data.frame(
        Climate = climate,
        Management = management,
        Year = year,
        MAge = mean_age
      )
    }
  }
}



# Combine all data frames
df <- do.call(rbind, all_data)

# Create a single PDF file
pdf(file = file.path(base_path, "Mean_Age_All_Species.pdf"), width = 15, height = 5)

age_unit = expression(paste("Mean Age (years)"))
# Create the plot
p <- ggplot(df, aes(x = Year, y = MAge, color = Climate)) +
  geom_line(size = 1) +
  facet_grid(~ Management, scales = "free_x") +
  labs(title = "Mean age over time (100 years)", x = "Year", y = age_unit, color = "Climate Scenario") +
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