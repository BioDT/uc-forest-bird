# Load required libraries
if (!requireNamespace("dplyr", quietly = TRUE)) {
  install.packages("dplyr")
}
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}

###############################################################################
# Setup
###############################################################################

library(dplyr)
library(ggplot2)

# Specify default directories
if (interactive()) {
  project_directory <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
} else {
  project_directory <- getwd()
}

results_dir <- file.path(project_directory, "results")

# Read CSVs with base R
species_totals <- read.csv(
  file.path(results_dir, "species_totals_by_scenario_year.csv"),
  stringsAsFactors = FALSE
)

species_variation <- read.csv(
  file.path(results_dir, "species_variation_across_scenarios.csv"),
  stringsAsFactors = FALSE
)

species_clusters <- read.csv(
  file.path(results_dir, "species_clusters_by_scenario_profile.csv"),
  stringsAsFactors = FALSE
)

# Parse Climate and Management from Scenario using base R
species_totals$Climate <- ifelse(
  grepl("^current", species_totals$Scenario), "current",
  ifelse(
    grepl("^4\\.5", species_totals$Scenario), "4.5",
    ifelse(grepl("^8\\.5", species_totals$Scenario), "8.5", "other")
  )
)

species_totals$Management <- sub(
  "^(current_|4\\.5_|8\\.5_)", "",
  species_totals$Scenario
)

# Add cluster info to totals and variation
species_totals <- merge(
  species_totals, species_clusters,
  by = "Species", all.x = TRUE
)

species_variation <- merge(
  species_variation, species_clusters,
  by = "Species", all.x = TRUE
)


###############################################################################
# 1. Cluster response plots
###############################################################################

cluster_summary <- species_totals %>%
  group_by(Cluster, Scenario, Climate, Management, Year) %>%
  summarise(
    mean_total = mean(Total, na.rm = TRUE),
    .groups = "drop"
  )

cluster_summary$Climate <- factor(
  cluster_summary$Climate,
  levels = c("current", "4.5", "8.5")
)

cluster_summary$Management <- factor(cluster_summary$Management)

# Common x axis scale, Year values 5, 30, 55, 80 correspond to 2025, 2050, 2075, 2100
x_scale_calendar <- scale_x_continuous(
  limits = c(5, 80),
  breaks = c(5, 30, 55, 80),
  labels = c("2025", "2050", "2075", "2100")
)

# A. All clusters in one figure, save as PDF
pdf(file.path(results_dir, "cluster_mean_totals_all_clusters.pdf"), width = 12, height = 8)

p_all <- ggplot(
  cluster_summary,
  aes(x = Year, y = mean_total, colour = Management, group = Scenario)
) +
  geom_line(linewidth = 0.7) +
  facet_grid(Cluster ~ Climate, scales = "free_y") +
  scale_x_continuous(
    limits = c(5, 80),
    breaks = c(5, 30, 55, 80),
    labels = c("2025", "2050", "2075", "2100")
  ) +
  labs(
    title = "Cluster mean abundance across climates and management",
    x = "Year",
    y = "Mean total (sum of probabilities across Finland)",
    colour = "Management"
  ) +
  theme_bw()

print(p_all)
dev.off()

# B. Separate plot per cluster, faceted by climate, coloured by management, save as PDF
unique_clusters <- sort(unique(cluster_summary$Cluster))

for (cl in unique_clusters) {
  df_cl <- cluster_summary %>% filter(Cluster == cl)
  
  pdf(
    file = file.path(
      results_dir,
      paste0("cluster_", cl, "_mean_totals_by_climate_management.pdf")
    ),
    width = 10,
    height = 6
  )
  
  p_cl <- ggplot(
    df_cl,
    aes(x = Year, y = mean_total, colour = Management, group = Scenario)
  ) +
    geom_line(linewidth = 0.7) +
    facet_wrap(~ Climate) +
    labs(
      title = paste("Cluster", cl, "response to management and climate"),
      x = "Year",
      y = "Mean total"
    ) +
    x_scale_calendar +
    theme_bw()
  
  print(p_cl)
  dev.off()
}

###############################################################################
# 2. Indicator species for management and climate
###############################################################################

# Choose a year for indicator analysis
indicator_year <- 80


#### 3a. Scenario sensitivity using range_scenarios ####

sensitivity_table <- species_variation %>%
  filter(Year == indicator_year) %>%
  arrange(desc(range_scenarios))

top_scenario_sensitive <- sensitivity_table %>%
  slice_head(n = 30)

write.csv(
  top_scenario_sensitive,
  file.path(
    results_dir,
    paste0(
      "indicator_species_top_scenario_sensitive_year",
      indicator_year,
      ".csv"
    )
  ),
  row.names = FALSE
)


#### 3b. Indicator species for management within each climate ####

management_pref <- species_totals %>%
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

management_pref_year <- management_pref %>%
  filter(Year == indicator_year, is_best)

management_indicator <- management_pref_year %>%
  count(Species, Climate, Management, name = "n_best") %>%
  arrange(Climate, Management, desc(n_best))

write.csv(
  management_indicator,
  file.path(
    results_dir,
    paste0("indicator_species_management_year", indicator_year, ".csv")
  ),
  row.names = FALSE
)

# Example: species that most often prefer SA for each climate
indicator_SA <- management_indicator %>%
  filter(Management == "SA") %>%
  group_by(Climate) %>%
  slice_max(order_by = n_best, n = 20, with_ties = FALSE) %>%
  ungroup()

write.csv(
  indicator_SA,
  file.path(
    results_dir,
    paste0("indicator_species_SA_year", indicator_year, ".csv")
  ),
  row.names = FALSE
)


#### 3c. Indicator species for climate within each management ####

climate_pref <- species_totals %>%
  group_by(Species, Management, Year, Climate) %>%
  summarise(
    mean_total = mean(Total, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  group_by(Species, Management, Year) %>%
  mutate(
    max_total = max(mean_total, na.rm = TRUE),
    is_best   = mean_total == max_total
  ) %>%
  ungroup()

climate_pref_year <- climate_pref %>%
  filter(Year == indicator_year, is_best)

climate_indicator <- climate_pref_year %>%
  count(Species, Management, Climate, name = "n_best") %>%
  arrange(Management, Climate, desc(n_best))

write.csv(
  climate_indicator,
  file.path(
    results_dir,
    paste0("indicator_species_climate_year", indicator_year, ".csv")
  ),
  row.names = FALSE
)

# Example: species that most often prefer each climate under BAU
indicator_BAU <- climate_indicator %>%
  filter(Management == "BAU") %>%
  group_by(Climate) %>%
  slice_max(order_by = n_best, n = 20, with_ties = FALSE) %>%
  ungroup()

write.csv(
  indicator_BAU,
  file.path(
    results_dir,
    paste0("indicator_species_BAU_climate_year", indicator_year, ".csv")
  ),
  row.names = FALSE
)

###############################################################################
# End of script
###############################################################################

species_variation <- read.csv(
  file.path(results_dir, "species_variation_across_scenarios.csv"),
  stringsAsFactors = FALSE
)

species_variation <- merge(species_variation, species_clusters, by = "Species")

# pick a year for ranking
rank_year <- 80

top5_sensitive <- lapply(
  sort(unique(species_variation$Cluster)),
  function(cl) {
    species_variation %>%
      dplyr::filter(Cluster == cl, Year == rank_year) %>%
      dplyr::arrange(desc(range_scenarios)) %>%
      dplyr::slice(1:5)
  }
)

names(top5_sensitive) <- paste0("Cluster_", sort(unique(species_variation$Cluster)))

top5_sensitive


species_totals <- read.csv(
  file.path(results_dir, "species_totals_by_scenario_year.csv"),
  stringsAsFactors = FALSE
)

species_clusters <- read.csv(
  file.path(results_dir, "species_clusters_by_scenario_profile.csv"),
  stringsAsFactors = FALSE
)

species_totals <- merge(species_totals, species_clusters, by = "Species")

species_totals_mean <- species_totals %>%
  dplyr::group_by(Species, Cluster) %>%
  dplyr::summarise(
    mean_total = mean(Total, na.rm = TRUE),
    .groups = "drop"
  )

top5_abundant <- lapply(
  sort(unique(species_totals_mean$Cluster)),
  function(cl) {
    species_totals_mean %>%
      dplyr::filter(Cluster == cl) %>%
      dplyr::arrange(desc(mean_total)) %>%
      dplyr::slice(1:5)
  }
)

names(top5_abundant) <- paste0("Cluster_", sort(unique(species_totals_mean$Cluster)))

top5_abundant

# Convert the list of data frames into one data frame
top5_abundant_df <- do.call(rbind, lapply(names(top5_abundant), function(nm) {
  df <- top5_abundant[[nm]]
  df$ClusterLabel <- nm
  df
}))

# Reorder columns so ClusterLabel appears first
top5_abundant_df <- top5_abundant_df[, c("ClusterLabel", "Species", "Cluster", "mean_total")]

# Save as CSV
write.csv(
  top5_abundant_df,
  file.path(results_dir, "top5_abundant_species_per_cluster.csv"),
  row.names = FALSE
)



