# Install required packages if not already installed
if (!require(ggplot2)) install.packages("ggplot2")
if (!require(dplyr)) install.packages("dplyr")
if (!require(tidyr)) install.packages("tidyr")

# Load the libraries
library(ggplot2)
library(dplyr)
library(tidyr)

# Source common code
if (interactive()) {
  source(file.path(dirname(rstudioapi::getActiveDocumentContext()$path), "common.R"))
} else {
  source(file.path("analysis", "common.R"))
}

results_directory <- file.path(results_directory, "visuals_based_on_total_cohorts")
if(!dir.exists(results_directory)) {
  dir.create(results_directory)
}

# Create an empty list to store the data
all_data <- list()

# Loop through each combination of climate and management scenarios
for (climate in climate_scenarios) {
  for (management in management_scenarios) {
    file_path <- file.path(run_directory, paste0(climate, "_", management), "output", "TotalCohorts.txt")

    # Read the data if the file exists
    if (file.exists(file_path)) {
      data <- read.csv(file_path)
      data$Climate <- climate
      data$Management <- management
      all_data[[paste(climate, management, sep = "_")]] <- data
    }
  }
}


# Combine all data into a single data frame
combined_data <- bind_rows(all_data)

combined_data$Climate <- factor(combined_data$Climate, levels = climate_scenarios)
combined_data$Management <- factor(combined_data$Management, levels = management_scenarios)


############Average above-ground biomass#############################
# Filter relevant columns and reshape the data for plotting
plot_data <- combined_data %>%
  select(Time, AverageB.g.m2., Climate, Management) %>%
  pivot_longer(cols = AverageB.g.m2., names_to = "Variable", values_to = "Value")

# Open a PDF device

pdf(
  file = file.path(results_directory, "AGBiomass_by_climate.pdf"),
  width = 10,
  height = 6
)

unit <- expression(paste("AGBiomass (g/m"^2, ")"))

ggplot(
  plot_data,
  aes(x = Time, y = Value, colour = Management, group = Management)
) +
  geom_line(linewidth = 0.7) +
  facet_wrap(~ Climate) +
  scale_x_continuous(
    limits = c(5, 80),
    breaks = c(5, 30, 55, 80),
    labels = c("2025", "2050", "2075", "2100")
  ) +
  labs(
    title = "Average above-ground biomass over time (until 2100)",
    x = "Time",
    y = unit,
    colour = "Management"
  ) +
  theme_bw()

dev.off()



############Average below-ground biomass#############################
# Filter relevant columns and reshape the data for plotting
plot_data <- combined_data %>%
  select(Time, AverageBelowGround.g.m2., Climate, Management) %>%
  pivot_longer(cols = AverageBelowGround.g.m2., names_to = "Variable", values_to = "Value")

# Open a PDF device

pdf(
  file = file.path(results_directory, "BGBiomass_by_climate_management.pdf"),
  width = 10,
  height = 6
)

unit <- expression(paste("BGBiomass (g/m"^2, ")"))

ggplot(
  plot_data,
  aes(x = Time, y = Value, colour = Management, group = Management)
) +
  geom_line(linewidth = 0.7) +
  facet_wrap(~ Climate) +
  scale_x_continuous(
    limits = c(5, 80),
    breaks = c(5, 30, 55, 80),
    labels = c("2025", "2050", "2075", "2100")
  ) +
  labs(
    title = "Average below-ground biomass over time (until 2100)",
    x = "Time",
    y = unit,
    colour = "Management"
  ) +
  theme_bw()

dev.off()



############Average age#############################
# Filter relevant columns and reshape the data for plotting
plot_data <- combined_data %>%
  select(Time, AverageAge, Climate, Management) %>%
  pivot_longer(cols = AverageAge, names_to = "Variable", values_to = "Value")

# Open a PDF device
pdf(
  file = file.path(results_directory, "AvAge_by_climate.pdf"),
  width = 10,
  height = 6
)

unit <- expression(paste("Age (years)"))

ggplot(
  plot_data,
  aes(x = Time, y = Value, colour = Management, group = Management)
) +
  geom_line(linewidth = 0.7) +
  facet_wrap(~ Climate) +
  scale_x_continuous(
    limits = c(5, 80),
    breaks = c(5, 30, 55, 80),
    labels = c("2025", "2050", "2075", "2100")
  ) +
  labs(
    title = "Average age over time (until 2100)",
    x = "Time",
    y = unit,
    colour = "Management"
  ) +
  theme_bw()

dev.off()



############Woody Debris#############################
# Filter relevant columns and reshape the data for plotting
plot_data <- combined_data %>%
  select(Time, WoodyDebris.kgDW.m2., Climate, Management) %>%
  pivot_longer(cols = WoodyDebris.kgDW.m2., names_to = "Variable", values_to = "Value")

# Open a PDF device
pdf(
  file = file.path(results_directory, "WoodyDebris_by_climate_management.pdf"),
  width = 10,
  height = 6
)

unit <- expression(paste("Woody debris (kgDW/m"^2, ")"))

ggplot(
  plot_data,
  aes(x = Time, y = Value, colour = Management, group = Management)
) +
  geom_line(linewidth = 0.7) +
  facet_wrap(~ Climate) +
  scale_x_continuous(
    limits = c(5, 80),
    breaks = c(5, 30, 55, 80),
    labels = c("2025", "2050", "2075", "2100")
  ) +
  labs(
    title = "Woody debris over time (until 2100)",
    x = "Time",
    y = unit,
    colour = "Management"
  ) +
  theme_bw()

dev.off()
