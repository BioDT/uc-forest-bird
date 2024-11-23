if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
if (!requireNamespace("readr", quietly = TRUE)) {
  install.packages("readr")
}

# Load necessary libraries
library(dplyr)
library(readr)

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
# climate_scenarios <- c("current", "rcp45", "rcp85")
climate_scenarios <- c("rcp45", "rcp85")

# Define function to process data for each scenario
process_scenario <- function(scenario) {
  
  data_directory <- file.path(project_directory, "data", "climate", scenario, "output")
  # Load the data
  input_file <- file.path(data_directory, "tas_monthly.csv")
  data <- read_csv(input_file)
  
  # Filter for years starting from 2025, including December 2024
  data <- data %>% 
    filter(year >= 2024)
  
  # Define the target years
  target_years <- seq(2025, 2100, by = 5)
  
  # Function to calculate seasonal averages
  get_seasonal_averages <- function(data, Y) {
    # Previous summer: June-July of the previous year
    summer <- data %>% 
      filter(year == Y - 1 & month %in% c(6, 7)) %>% 
      summarise(Summer_Avg = mean(tas, na.rm = TRUE))
    
    # Winter: December of the previous year and January-February of the current year
    winter <- data %>% 
      filter((year == Y - 1 & month == 12) | (year == Y & month %in% c(1, 2))) %>%
      summarise(Winter_Avg = mean(tas, na.rm = TRUE))
    
    # Spring: April-May of the current year
    spring <- data %>%
      filter(year == Y & month %in% c(4, 5)) %>%
      summarise(Spring_Avg = mean(tas, na.rm = TRUE))
    
    # Combine results
    data.frame(year = Y, 
               Summer_Avg = summer$Summer_Avg, 
               Winter_Avg = winter$Winter_Avg, 
               Spring_Avg = spring$Spring_Avg)
  }
  
  # Calculate seasonal averages for each target year
  seasonal_averages <- lapply(target_years, function(y) get_seasonal_averages(data, y)) %>%
    bind_rows()
  
  output_file <- file.path(data_directory, paste(scenario, "temp_seasonal_averages.csv", sep = "_"))
  # Save the output to a CSV file
  write_csv(seasonal_averages, output_file)
}

# Loop through each climate scenario and run the process
for (scenario in climate_scenarios) {
  process_scenario(scenario)
}
# ==============================================================================
# END of Script
# ==============================================================================
