library(terra)
library(dplyr)
library(tidyr)
library(future.apply)

# Specify default directories
if (interactive()) {
  project_directory <- dirname(dirname(rstudioapi::getActiveDocumentContext()$path))
} else {
  project_directory <- getwd()
}

# ---- settings ----
scenarios <- c(
  "current_BAU","current_EXT10","current_EXT30","current_GTR30","current_NTLR","current_NTSR","current_SA",
  "4.5_BAU","4.5_EXT10","4.5_EXT30","4.5_GTR30","4.5_NTLR","4.5_NTSR","4.5_SA",
  "8.5_BAU","8.5_EXT10","8.5_EXT30","8.5_GTR30","8.5_NTLR","8.5_NTSR","8.5_SA"
)
years <- seq(5, 80, 5)
# presence_threshold <- 0.5  # richness = count of species with prob > threshold

# Mammals to exclude (and only those present in your .tif list will be removed)
mammals_to_exclude <- c(
  "Alces alces", "Apodemus agrarius", "Apodemus flavicollis", "Arvicola amphibius", "Arvicolinae",
  "Capreolus capreolus", "Dama dama", "Eptesicus nilssonii", "Erinaceus europaeus", "Felis catus",
  "Halichoerus grypus", "Lepus europaeus", "Lepus timidus", "Lynx lynx", "Lutra lutra", "Martes martes",
  "Meles meles", "Microtus", "Microtus agrestis", "Mus musculus", "Mustela erminea", "Mustela nivalis",
  "Myodes glareolus", "Myodes rufocanus", "Myodes rutilus", "Myotis daubentonii", "Myotis mystacinus/brandtii",
  "Myotis nattereri", "Neomys fodiens", "Neovison vison", "Nyctereutes procyonoides", "Odocoileus virginianus",
  "Ondatra zibethicus", "Oryctolagus cuniculus", "Plecotus auritus", "Pteromys volans", "Pusa hispida",
  "Rattus norvegicus", "Rangifer tarandus", "Sciurus vulgaris", "Sorex araneus", "Soricidae", "Talpa europaea",
  "Vulpes vulpes"
)

birds_to_exclude <- c(
  "Acrocephalus dumetorum",
  "Acrocephalus palustris",
  "Acrocephalus schoenobaenus",
  "Actitis hypoleucos",
  "Alauda arvensis",
  "Anas crecca",
  "Anas penelope",
  "Anas platyrhynchos",
  "Anser fabalis",
  "Anthus pratensis",
  "Asio flammeus",
  "Aythya fuligula",
  "Botaurus stellaris",
  "Bucephala clangula",
  "Calcarius lapponicus",
  "Calidris falcinellus",
  "Carduelis cannabina",
  "Carpodacus erythrinus",
  "Columba livia",
  "Crex crex",
  "Cygnus cygnus",
  "Cygnus olor",
  "Delichon urbicum",
  "Emberiza rustica",
  "Gallinago gallinago",
  "Gavia arctica",
  "Gavia stellata",
  "Grus grus",
  "Haematopus ostralegus",
  "Hirundo rustica",
  "Hydrocoloeus minutus",
  "Lagopus lagopus",
  "Larus argentatus",
  "Larus canus",
  "Larus fuscus",
  "Larus ridibundus",
  "Luscinia svecica",
  "Lymnocryptes minimus",
  "Mergus merganser",
  "Motacilla flava",
  "Numenius arquata",
  "Numenius phaeopus",
  "Phasianus colchicus",
  "Pluvialis apricaria",
  "Podiceps cristatus",
  "Sterna hirundo",
  "Sterna paradisaea",
  "Sturnus vulgaris",
  "Tringa erythropus",
  "Tringa glareola",
  "Tringa nebularia",
  "Tringa totanus",
  "Vanellus vanellus"
)


# ---- compute richness ----

# Detect number of workers from SLURM or default to 1
workers <- as.integer(Sys.getenv("SLURM_CPUS_PER_TASK", unset = "1"))

# Choose parallel plan (multicore for Linux, multisession otherwise)
if (.Platform$OS.type == "unix") {
  plan(multicore, workers = workers)
} else {
  plan(multisession, workers = workers)
}

# Create combinations of scenarios and years
combinations <- expand.grid(Scenario = scenarios, Year = years, stringsAsFactors = FALSE)

###############################################################################
# Function to compute species totals per scenario and year
###############################################################################

compute_species_totals <- function(sc, yr,
                                   project_directory,
                                   mammals_to_exclude) {
  
  prediction_dir <- file.path(project_directory, "results", "predictions", sc, yr)
  tif_files <- list.files(prediction_dir, pattern = "\\.tif$", full.names = TRUE)
  
  if (length(tif_files) == 0) {
    warning("No .tif files in: ", prediction_dir)
    return(NULL)
  }
  
  species_names <- tools::file_path_sans_ext(basename(tif_files))
  
  # only birds, remove mammals that are in mammals_to_exclude
  keep_idx <- !(species_names %in% mammals_to_exclude | species_names %in% birds_to_exclude)
  tif_files <- tif_files[keep_idx]
  species_names <- species_names[keep_idx]
  
  if (length(tif_files) == 0) {
    warning("All files excluded as mammals in: ", prediction_dir)
    return(NULL)
  }
  
  # stack of species probability rasters
  s <- rast(tif_files)
  names(s) <- species_names
  
  # global sum for each species, expected abundance or richness contribution
  totals <- global(s, "sum", na.rm = TRUE)
  
  out <- data.frame(
    Scenario = sc,
    Year = yr,
    Species = rownames(totals),
    Total = totals$sum,
    row.names = NULL,
    stringsAsFactors = FALSE
  )
  
  cat("✓", sc, "Year", yr, "species:", nrow(out), "\n")
  flush(stdout())
  
  out
}


###############################################################################
# Build full Species x Scenario x Year table
###############################################################################

# all scenario year combinations
combos <- expand.grid(
  Scenario = scenarios,
  Year = years,
  stringsAsFactors = FALSE
)

species_totals_list <- future_lapply(seq_len(nrow(combos)), function(i) {
  compute_species_totals(
    sc = combos$Scenario[i],
    yr = combos$Year[i],
    project_directory = project_directory,
    mammals_to_exclude = mammals_to_exclude
  )
})

species_totals <- do.call(rbind, species_totals_list)

# remove any rows that are completely NA
species_totals <- species_totals %>%
  filter(!is.na(Total))

# save to disk
dir.create(file.path(project_directory, "results"), showWarnings = FALSE)
write.csv(
  species_totals,
  file.path(project_directory, "results", "species_totals_by_scenario_year.csv"),
  row.names = FALSE
)


###############################################################################
# Quantify variability of each species across scenarios
###############################################################################

# separate climate and management parts of the scenario names
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

# variability across all scenarios for each species and year
species_variation <- species_totals %>%
  group_by(Species, Year) %>%
  summarise(
    mean_total = mean(Total, na.rm = TRUE),
    sd_scenarios = sd(Total, na.rm = TRUE),
    range_scenarios = max(Total, na.rm = TRUE) - min(Total, na.rm = TRUE),
    .groups = "drop"
  )

# save variability table
write.csv(
  species_variation,
  file.path(project_directory, "results", "species_variation_across_scenarios.csv"),
  row.names = FALSE
)


###############################################################################
# Cluster species by multi scenario response profile
###############################################################################

# average over years first, to get one value per Species x Scenario
species_by_scenario <- species_totals %>%
  group_by(Species, Scenario) %>%
  summarise(
    Total = mean(Total, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  tidyr::pivot_wider(
    names_from = Scenario,
    values_from = Total,
    values_fill = 0
  )

# matrix for clustering, rows are species, columns are scenarios
mat <- as.matrix(species_by_scenario[ , -1, drop = FALSE])
rownames(mat) <- species_by_scenario$Species

# standardise each species profile to zero mean and unit variance
# this focuses on relative response rather than absolute abundance
mat_scaled <- t(scale(t(mat)))

# distance and hierarchical clustering
dist_mat <- dist(mat_scaled)
hc <- hclust(dist_mat, method = "ward.D2")

# choose number of clusters
k <- 4   # you can change this
cluster_assignments <- cutree(hc, k = k)

cluster_df <- data.frame(
  Species = rownames(mat_scaled),
  Cluster = cluster_assignments,
  stringsAsFactors = FALSE
)

# save cluster membership
write.csv(
  cluster_df,
  file.path(project_directory, "results", "species_clusters_by_scenario_profile.csv"),
  row.names = FALSE
)

# optional quick summary, how many species per cluster
#cluster_summary <- cluster_df %>%
 # group_by(Cluster) %>%
 # summarise(n_species = n(), .groups = "drop")

#print(cluster_summary)


