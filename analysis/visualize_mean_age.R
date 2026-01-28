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
    path <- file.path(run_directory, paste0(climate, "_", management), "output", "age-all-spp")
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

df$Climate <- factor(df$Climate, levels = climate_scenarios)
df$Management <- factor(df$Management, levels = management_scenarios)

pdf(
  file = file.path(results_directory, "Mean_Age_by_climate.pdf"),
  width = 10,
  height = 6
)

age_unit <- expression(paste("Mean age (years)"))

ggplot(
  df,
  aes(x = Year, y = MAge, colour = Management, group = Management)
) +
  geom_line(linewidth = 0.7) +
  facet_wrap(~ Climate, scales = "free_y") +
  scale_x_continuous(breaks = seq(0, 80, 20)) +
  labs(
    title = "Mean age over time (until 2100)",
    x = "Year",
    y = age_unit,
    colour = "Management"
  ) +
  theme_bw()

dev.off()
