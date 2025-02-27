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


############Average above-ground biomass#############################
# Filter relevant columns and reshape the data for plotting
plot_data <- combined_data %>%
  select(Time, AverageB.g.m2., Climate, Management) %>%
  pivot_longer(cols = AverageB.g.m2., names_to = "Variable", values_to = "Value")

# Open a PDF device

# Create a single PDF file
pdf(file = file.path(results_directory, "AGBiomass_all_species.pdf"), width = 15, height = 5)

unit = expression(paste("AGBiomass (g/m"^2, ")"))

# Create the plot
ggplot(plot_data, aes(x = Time, y = Value, color = Climate, group = Climate)) +
  geom_line(size = 1) +
  facet_wrap(~ Management, ncol = 7, scales = "free_x") +
  scale_x_continuous(breaks = seq(0, 80, 20)) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 24, face = "bold"),
    axis.title = element_text(size = 20),
    axis.text = element_text(size = 16),
    strip.text = element_text(size = 16),
    legend.position = "bottom",
    legend.text = element_text(size = 16),
    legend.title = element_blank(),
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_line(color = "gray95"),
    strip.background = element_rect(fill = "gray90", color = "gray90"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  labs(title = "Average above-ground biomass over time (until 2100)", x = "Time", y = unit)

# Close the PDF device
dev.off()


############Average below-ground biomass#############################
# Filter relevant columns and reshape the data for plotting
plot_data <- combined_data %>%
  select(Time, AverageBelowGround.g.m2., Climate, Management) %>%
  pivot_longer(cols = AverageBelowGround.g.m2., names_to = "Variable", values_to = "Value")

# Open a PDF device

# Create a single PDF file
pdf(file = file.path(results_directory, "BGBiomass_all_species.pdf"), width = 15, height = 5)

unit = expression(paste("BGBiomass (g/m"^2, ")"))

# Create the plot
ggplot(plot_data, aes(x = Time, y = Value, color = Climate, group = Climate)) +
  geom_line(size = 1) +
  facet_wrap(~ Management, ncol = 7, scales = "free_x") +
  scale_x_continuous(breaks = seq(0, 80, 20)) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 24, face = "bold"),
    axis.title = element_text(size = 20),
    axis.text = element_text(size = 16),
    strip.text = element_text(size = 16),
    legend.position = "bottom",
    legend.text = element_text(size = 16),
    legend.title = element_blank(),
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_line(color = "gray95"),
    strip.background = element_rect(fill = "gray90", color = "gray90"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  labs(title = "Average below-ground biomass over time (until 2100)", x = "Time", y = unit)

# Close the PDF device
dev.off()



############Average age#############################
# Filter relevant columns and reshape the data for plotting
plot_data <- combined_data %>%
  select(Time, AverageAge, Climate, Management) %>%
  pivot_longer(cols = AverageAge, names_to = "Variable", values_to = "Value")

# Open a PDF device

# Create a single PDF file
pdf(file = file.path(results_directory, "AvAge_all_species.pdf"), width = 15, height = 5)

unit = expression(paste("Age (years)"))

# Create the plot
ggplot(plot_data, aes(x = Time, y = Value, color = Climate, group = Climate)) +
  geom_line(size = 1) +
  facet_wrap(~ Management, ncol = 7, scales = "free_x") +
  scale_x_continuous(breaks = seq(0, 80, 20)) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 24, face = "bold"),
    axis.title = element_text(size = 20),
    axis.text = element_text(size = 16),
    strip.text = element_text(size = 16),
    legend.position = "bottom",
    legend.text = element_text(size = 16),
    legend.title = element_blank(),
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_line(color = "gray95"),
    strip.background = element_rect(fill = "gray90", color = "gray90"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  labs(title = "Average age over time (until 2100)", x = "Time", y = unit)

# Close the PDF device
dev.off()


############Woody Debris#############################
# Filter relevant columns and reshape the data for plotting
plot_data <- combined_data %>%
  select(Time, WoodyDebris.kgDW.m2., Climate, Management) %>%
  pivot_longer(cols = WoodyDebris.kgDW.m2., names_to = "Variable", values_to = "Value")

# Open a PDF device

# Create a single PDF file
pdf(file = file.path(results_directory, "WoodyDebris_all_species.pdf"), width = 15, height = 5)

unit = expression(paste("Woody Debris (kgDW/m"^2, ")"))

# Create the plot
ggplot(plot_data, aes(x = Time, y = Value, color = Climate, group = Climate)) +
  geom_line(size = 1) +
  facet_wrap(~ Management, ncol = 7, scales = "free_x") +
  scale_x_continuous(breaks = seq(0, 80, 20)) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 24, face = "bold"),
    axis.title = element_text(size = 20),
    axis.text = element_text(size = 16),
    strip.text = element_text(size = 16),
    legend.position = "bottom",
    legend.text = element_text(size = 16),
    legend.title = element_blank(),
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_line(color = "gray95"),
    strip.background = element_rect(fill = "gray90", color = "gray90"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  labs(title = "Woody debris over time (until 2100)", x = "Time", y = unit)

# Close the PDF device
dev.off()
