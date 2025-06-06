if (!requireNamespace("forecast", quietly = TRUE)) {
  install.packages("forecast")
}
if (!requireNamespace("tidyverse", quietly = TRUE)) {
  install.packages("tidyverse")
}

# Load necessary libraries
library(forecast)
library(tidyverse)


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
  input_file <- file.path(data_directory, "par_monthly_2089.csv")
  # Read the data
  par_data <- read.csv(input_file)
  
  # Convert year and month columns to integers (if they aren't already)
  par_data$year <- as.integer(par_data$year)
  par_data$month <- as.integer(par_data$month)
  
  # Extract the start and end year, month directly
  start_year <- min(par_data$year)
  start_month <- min(par_data$month)
  
  end_year <- max(par_data$year)
  end_month <- max(par_data$month)
  
  
  # Convert to Date column by combining year and month
  par_data <- par_data %>%
    mutate(Date = as.Date(paste(year, month, "1", sep = "-"), format = "%Y-%m-%d")) %>%
    select(Date, par)
  
  # Ensure there are no missing values in the 'par' column
  par_data <- na.omit(par_data)
  
  # Convert to time series format using the extracted start year and month
  ts_par <- ts(par_data$par, start = c(start_year, start_month), frequency = 12)
  
  # Fit a forecasting model
  fit <- auto.arima(ts_par)
  
  # Forecast for additional 48 months (2006/01 to 2010/01)
  forecasted <- forecast(fit, h = 48)
  
  # Extract forecasted values and generate corresponding dates
  forecast_dates <- seq.Date(from = as.Date("2006-01-01"), by = "month", length.out = 48)
  
  # Convert forecast dates to year and month
  forecast_year <- as.integer(format(forecast_dates, "%Y"))
  forecast_month <- as.integer(format(forecast_dates, "%m"))
  
  # Create the output data frame with year, month, and forecasted PAR values
  forecast_df <- data.frame(year = forecast_year,
                            month = forecast_month,
                            par = as.numeric(forecasted$mean))
  
  output_file <- file.path(data_directory, "predicted_PAR_2006_2010.csv")
  # Save the predictions
  write.csv(forecast_df, output_file, row.names = FALSE)
  
  # Plot the results
  plot(forecasted, main = "PAR Forecast (2006-2010)", xlab = "Year", ylab = "PAR")
}

# Loop through each climate scenario and run the process
for (scenario in climate_scenarios) {
  process_scenario(scenario)
}

# ==============================================================================
# END of Script
# ==============================================================================