library(terra)
library (tmap)
library (macroBiome)

source("Holdridge/R/map_transitions_function.R")
source("Holdridge/R/ecological_zones_map.R")

ecozone_files <- list.files("Holdridge/data/ecozone", pattern = "\\.tif$", full.names = TRUE)
eco <- lapply(ecozone_files, rast)
names(eco) <-  sub("_hold_lvl1_ecozone$", "", tools::file_path_sans_ext(basename(ecozone_files)))
print(names(eco))

#mask for pixels 
valid <- Reduce(`&`, lapply(eco, \(r) !is.na(r)))
eco <- lapply(eco, mask, valid, maskvalues = 0)

# define output directory 
output_dir <- "Holdridge/results/difference_maps"

#name the difference pairs to analyze 
difference_pairs <- list(
  c("contemp", "mid_ssp126"),
  c("contemp", "end_ssp126"),
  c("contemp", "mid_ssp245"),
  c("contemp", "end_ssp245"),
  c("contemp", "mid_ssp370"),
  c("contemp", "end_ssp370"),
  c("contemp", "mid_ssp585"),
  c("contemp", "end_ssp585"),
  c("mid_ssp126", "end_ssp126"),
  c("mid_ssp245", "end_ssp245"),
  c("mid_ssp370", "end_ssp370"),
  c("mid_ssp585", "end_ssp585"),
  c("mid_ssp126", "mid_ssp585"),
  c("end_ssp126", "end_ssp585")
)

#call transition mapping function for classifications converted to major classes
for (p in difference_pairs) {
  holdridge_ecozone_transitions(eco[[p[1]]], eco[[p[2]]], file.path(output_dir, paste(p[1], "to", p[2], sep = "_")), "Changes in Holdridge Ecozones of Hawaii",paste(p[1], "to", p[2]), eco_levels)
}
