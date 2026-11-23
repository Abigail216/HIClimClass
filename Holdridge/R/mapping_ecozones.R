library(tmap)
library(terra)

source("Holdridge/R/ecological_zones_map.R")

level1_dir <- "Holdridge/data/level1"
ecozone_dir <- "Holdridge/data/ecozone"


level1_files<- list.files(level1_dir, pattern = "\\.tiff$", full.names = TRUE)

for (f in level1_files) {
  name <- sub("_hold_level1$", "", tools::file_path_sans_ext(basename(f)))
  run_reclass(rast(f), file.path(ecozone_dir, paste0(name, "_ecozone")), name)
}