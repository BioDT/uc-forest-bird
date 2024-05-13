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

# Check if the script is being run from within RStudio
if (interactive()) {
  # Get the path of the currently running script
  script_path <- file.path(dirname(rstudioapi::getActiveDocumentContext()$path), "08_run_scenarios.R")
  
  # Print the script path
  print(script_path)
} else {
  print("Not running in interactive mode (e.g., not in RStudio).")
}

# Specify project directory
project_directory <- dirname(dirname(script_path))

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