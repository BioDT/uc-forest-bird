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


# Define a function to process a monthly data file
process_monthly_file <- function(input_file) {
  # Read the CSV file
  data <- read.csv(input_file)
  
  # Extract the variable name dynamically (assumes third column is the target)
  value_column <- colnames(data)[3]  # The column after "year" and "month"
  
  # Group by month and compute the average of the variable
  monthly_avg <- data %>%
    group_by(month) %>%
    summarise(avg_value = mean(.data[[value_column]], na.rm = TRUE))  # Use dynamic column name
  
  # Create the formatted output
  formatted_output <- data.frame(
    year = "1850-2100",
    month = monthly_avg$month,
    value = monthly_avg$avg_value  # Add the correct column dynamically
  )
  
  # Rename third column correctly
  colnames(formatted_output)[3] <- value_column  
  
  # Generate output filename dynamically by adding "_average" before ".csv"
  output_file <- gsub("(\\.csv)$", "_average\\1", basename(input_file))  
  output_path <- file.path(dirname(input_file), output_file)
  
  # Save the output file with proper CSV format
  write.csv(formatted_output, output_path, row.names = FALSE, quote = FALSE)
}

data_directory <- file.path(project_directory, "data", "climate", "current", "output")

file_list <- c(
  file.path(data_directory, "co2_monthly.csv"),
  file.path(data_directory, "par_monthly.csv"),
  file.path(data_directory, "prec_monthly.csv"),
  file.path(data_directory, "tasmax_monthly.csv"),
  file.path(data_directory, "tasmin_monthly.csv")
)

# Loop through files and process each
sapply(file_list, process_monthly_file)
