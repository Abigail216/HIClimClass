library(tmap)
library(terra)
library(macroBiome)

source("KoppenGeigerClassifications/R/functions_classify.R")

major_dir <- "KoppenGeigerClassifications/results/classifications/major"

all_files <- list.files("KoppenGeigerClassifications/results/classifications/all", pattern = "\\.tif$", full.names = TRUE)

for (f in all_files) {
  name <- sub("_kgc$", "", tools::file_path_sans_ext(basename(f)))
  run_major(rast(f), file.path(major_dir, paste0(name, "_major")), name)
}