# Load required libraries
if (!requireNamespace("ggplot2", quietly = TRUE)) {
  install.packages("ggplot2")
}
if (!requireNamespace("terra", quietly = TRUE)) {
  install.packages("terra")
}
if (!requireNamespace("gridExtra", quietly = TRUE)) {
  install.packages("gridExtra")
}

library(ggplot2)
library(dplyr)
library(tidyr)

# Specify default directories
if (interactive()) {
  project_directory <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
} else {
  project_directory <- getwd()
}

rich <- read.csv(file.path(project_directory, "results", "richness_summary.csv"))

rich2 <- rich %>%
  separate(
    col   = Scenario,
    into  = c("Climate", "Management"),
    sep   = "_",
    remove = FALSE
  )

rich2$Climate <- factor(rich2$Climate, levels = c("4.5", "8.5", "current"))

pdf(
  file = file.path(project_directory, "results", "Species_richness_all_scenarios.pdf"),
  width = 15,
  height = 10
)

p <- ggplot(rich2, aes(x = Year, y = TotalRichness, color = Climate)) +
  geom_line(size = 1) +
  facet_grid(. ~ Management, scales = "free_x") +
  labs(
    title = "Total species richness over time (until 2100)",
    x = "Time",
    y = "Species richness",
    color = ""
  ) +
  scale_color_discrete(labels = c("4.5", "8.5", "current")) +
  scale_x_continuous(breaks = seq(0, 80, 20)) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title      = element_text(size = 24, face = "bold"),
    axis.title      = element_text(size = 20, face = "bold"),
    axis.text       = element_text(size = 16),
    strip.text      = element_text(size = 16, face = "bold"),
    legend.position = "bottom",
    legend.text     = element_text(size = 14),
    legend.title    = element_blank(),
    panel.background    = element_rect(fill = "white"),
    panel.grid.major    = element_line(color = "gray90"),
    panel.grid.minor    = element_line(color = "gray95"),
    strip.background    = element_rect(fill = "gray90", color = "gray90"),
    axis.text.x         = element_text(angle = 45, hjust = 1)
  )

print(p)
dev.off()



pdf(
  file = file.path(project_directory, "results", "Species_richness_by_climate.pdf"),
  width = 15,
  height = 10
)

p2 <- ggplot(rich2, aes(x = Year, y = TotalRichness, color = Management)) +
  geom_line(size = 1) +
  facet_grid(Climate ~ .) +
  labs(
    title = "Total species richness by climate scenario (until 2100)",
    x = "Time",
    y = "Species richness",
    color = ""
  ) +
  scale_color_discrete(labels = unique(rich2$Management)) +
  scale_x_continuous(breaks = seq(0, 80, 5)) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(size = 24, face = "bold"),
    axis.title = element_text(size = 20, face = "bold"),
    axis.text = element_text(size = 16),
    strip.text = element_text(size = 16, face = "bold"),
    legend.position = "bottom",
    legend.text = element_text(size = 14),
    legend.title = element_blank(),
    panel.background = element_rect(fill = "white"),
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_line(color = "gray95"),
    strip.background = element_rect(fill = "gray90", color = "gray90"),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

print(p2)
dev.off()
