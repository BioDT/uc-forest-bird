# 08_run_scenarios.R
# Description:
# This script runs multiple scenarios of the model located in the "models/LANDIS-II" directory. 
# It first identifies the scenario directories (e.g., "BAU/Current", "BAU/RCP4.5", "BAU/RCP8.5") 
# under the "models/LANDIS-II" directory and then executes the scenario.bat file in each scenario directory.

# Load required packages
if (!requireNamespace("utils", quietly = TRUE)) {
  install.packages("utils")
}
library(utils)

# Specify project directory
if (interactive()) {
  project_directory <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
} else {
  project_directory <- getwd()
}
print(project_directory)

# Function to run scenarios
run_scenarios <- function(scenario_names) {
  # Loop through each scenario
  for (scenario_name in scenario_names) {
    # Print the scenario being run
    print(paste("Scenario", scenario_name, "is running..."))
    
    # Get the full path to the scenario directory
    scenario_path <- file.path(project_directory, "models", "LANDIS-II", scenario_name)
    
    # Set the working directory to the scenario directory
    setwd(scenario_path)
    
    # Run the scenario.bat file
    scenario_bat <- file.path(scenario_path, "scenario.bat")
    
    # Check if the scenario.bat file exists
    if (file.exists(scenario_bat)) {
      # Execute the scenario.bat file
      system(scenario_bat, wait = TRUE)
    } else {
      print(paste("No scenario.bat file found in", scenario_name))
    }
  }
}


# Manually specify the scenario names
# scenario_names <- c("BAU/Current", "BAU/RCP4.5", "BAU/RCP8.5")
scenario_names <- c("BAU/Current")

# Run scenarios
run_scenarios(scenario_names)
