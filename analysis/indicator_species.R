
library(dplyr)

# Specify default directories
if (interactive()) {
  project_directory <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
} else {
  project_directory <- getwd()
}


results_dir <- file.path(project_directory, "results")

species_totals <- read.csv(
  file.path(results_dir, "species_totals_by_scenario_year.csv"),
  stringsAsFactors = FALSE
)

# add Climate and Management
species_totals <- species_totals %>%
  mutate(
    Climate = case_when(
      grepl("^current", Scenario) ~ "current",
      grepl("^4\\.5", Scenario)   ~ "4.5",
      grepl("^8\\.5", Scenario)   ~ "8.5",
      TRUE                        ~ "other"
    ),
    Management = sub("^(current_|4\\.5_|8\\.5_)", "", Scenario)
  )

# for each species, climate, year, management
# find which management gives the highest total
management_pref_all <- species_totals %>%
  group_by(Species, Climate, Year, Management) %>%
  summarise(
    mean_total = mean(Total, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  group_by(Species, Climate, Year) %>%
  mutate(
    max_total = max(mean_total, na.rm = TRUE),
    is_best   = mean_total == max_total
  ) %>%
  ungroup()

# keep only combinations where this management is best in that year
# then count how many years it wins
indicator_management_all_years <- management_pref_all %>%
  filter(is_best) %>%
  count(Species, Climate, Management, name = "n_best")

# for each Climate x Management, take top 5 species by n_best
top5_mgmt_all_years <- indicator_management_all_years %>%
  group_by(Climate, Management) %>%
  arrange(desc(n_best), Species) %>%
  slice_head(n = 5) %>%
  ungroup()

top5_mgmt_all_years

write.csv(
  top5_mgmt_all_years,
  file.path(results_dir, "top5_indicator_species_by_management_all_years.csv"),
  row.names = FALSE
)

# average across managements inside each climate
climate_pref_all <- species_totals %>%
  group_by(Species, Climate, Year) %>%
  summarise(
    mean_total = mean(Total, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  group_by(Species, Year) %>%
  mutate(
    max_total = max(mean_total, na.rm = TRUE),
    is_best   = mean_total == max_total
  ) %>%
  ungroup()

# keep only climates that are best for that species in that year
# then count how many years each climate wins
indicator_climate_all_years <- climate_pref_all %>%
  filter(is_best) %>%
  count(Species, Climate, name = "n_best")

# top 5 species for each climate
top5_climate_all_years <- indicator_climate_all_years %>%
  group_by(Climate) %>%
  arrange(desc(n_best), Species) %>%
  slice_head(n = 5) %>%
  ungroup()

top5_climate_all_years

write.csv(
  top5_climate_all_years,
  file.path(results_dir, "top5_indicator_species_by_climate_all_years.csv"),
  row.names = FALSE
)

