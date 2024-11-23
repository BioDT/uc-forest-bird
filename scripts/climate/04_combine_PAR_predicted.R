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
climate_scenarios <- c("current", "rcp45", "rcp85")

# Define function to process data for each scenario
process_scenario <- function(scenario) {
  
  data_directory <- file.path(project_directory, "data", "climate", scenario, "output")
  # Load the data
  par_file <- file.path(data_directory, "par_monthly_2089.csv")
  par_predicted_file <- file.path(data_directory, "predicted_PAR_2090_2100.csv")

  
  # Read the data
  par_predicted_data <- read.csv(par_predicted_file)
  par_data <- read.csv(par_file)
  
  
  # Combine the data
  combined_data <- rbind(par_data, par_predicted_data)
  
  output_file <- file.path(data_directory, "par_monthly.csv")
  # Write the result to a new CSV file
  write.csv(combined_data, output_file, row.names = FALSE)

}

# Loop through each climate scenario and run the process
for (scenario in climate_scenarios) {
  process_scenario(scenario)
}

# ==============================================================================
# END of Script
# ==============================================================================