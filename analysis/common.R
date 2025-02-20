# Specify default directories
if (interactive()) {
  project_directory <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
} else {
  project_directory <- getwd()
}
# Be aware of the job ID "7188295", and do not forget to change it for different ones; or use command-line argument
run_directory <- file.path(project_directory, "runs", "NAME", "run_7188295")
results_directory <- file.path(project_directory, "results/")

# Read directories from command-line argument
args = commandArgs(trailingOnly=TRUE)
if (length(args) > 0) {
  run_directory <- args[1]
}
if (length(args) > 1) {
  results_directory <- args[2]
}

print(sprintf("run_directory = %s", run_directory))
stopifnot(dir.exists(run_directory))

print(sprintf("results_directory = %s", results_directory))
if(!dir.exists(results_directory)) {
  dir.create(results_directory)
}

# Define scenarios
climate_scenarios <- c("current", "4.5", "8.5")
management_scenarios <- c("BAU", "EXT10", "EXT30", "GTR30", "NTLR", "NTSR", "SA")
years <- seq(0, 100, by = 10)

