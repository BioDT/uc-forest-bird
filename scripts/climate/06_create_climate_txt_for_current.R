if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}

# Load necessary libraries
library(dplyr)


if (interactive()) {
  # If running in RStudio, set the project directory relative to the active document
  project_directory <- dirname(dirname(dirname(rstudioapi::getActiveDocumentContext()$path)))
} else {
  # If not running in RStudio, use the current working directory
  project_directory <- getwd()
}

# Print the project directory for verification
print(project_directory)


# List of climate scenarios (e.g., "current", "rcp45", "rcp85")
climate_scenarios <- c("current")

# Define function to process data for each scenario
process_scenario <- function(scenario) {
  
  data_directory <- file.path(project_directory, "data", "climate", scenario, "output")
  # Load the data
  co2_file <- file.path(data_directory, "co2_monthly_average.csv")
  par_file <- file.path(data_directory, "par_monthly_average.csv")
  prec_file <- file.path(data_directory, "prec_monthly_average.csv")
  tasmax_file <- file.path(data_directory, "tasmax_monthly_average.csv")
  tasmin_file <- file.path(data_directory, "tasmin_monthly_average.csv")
  # Read the data
  co2_data <- read.csv(co2_file)
  par_data <- read.csv(par_file)
  prec_data <- read.csv(prec_file)
  tasmax_data <- read.csv(tasmax_file)
  tasmin_data <- read.csv(tasmin_file)
  
  # Merge datasets by year and month
  combined_data <- co2_data %>%
    rename(CO2 = co2) %>%
    left_join(par_data, by = c("year", "month")) %>%
    rename(PAR = par) %>%
    left_join(prec_data, by = c("year", "month")) %>%
    rename(Prec = prec) %>%
    left_join(tasmax_data, by = c("year", "month")) %>%
    rename(Tmax = tasmax) %>%
    left_join(tasmin_data, by = c("year", "month")) %>%
    rename(Tmin = tasmin)
  
  # Arrange the columns in the specified order
  final_data <- combined_data %>%
    select(year, month, Tmax, Tmin, PAR, Prec, CO2)
  
  climate_file <- file.path(data_directory, paste(scenario, "climate.txt", sep = "_"))
  # Write to a .txt file
  write.table(final_data, climate_file, row.names = FALSE, quote = FALSE)
}

# Loop through each climate scenario and run the process
for (scenario in climate_scenarios) {
  process_scenario(scenario)
}

# ==============================================================================
# END of Script
# ==============================================================================