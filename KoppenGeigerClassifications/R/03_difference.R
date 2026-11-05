library(terra)
library (tmap)
library (macroBiome)

source("KoppenGeigerClassifications/R/functions_difference.R")

# load all of the koppen geiger classification files 
files <- list.files("KoppenGeigerClassifications/results/classifications/all", pattern = "\\.tif$", full.names = TRUE)
kg <- lapply(files, rast)
names(kg) <-  sub("_kgc$", "", tools::file_path_sans_ext(basename(files)))

major_files <- list.files("KoppenGeigerClassifications/results/classifications/major", pattern = "\\.tif$", full.names = TRUE)
kg_major <- lapply(major_files, rast)
names(kg_major) <-  sub("_major$", "", tools::file_path_sans_ext(basename(major_files)))

#mask for pixels 
valid <- Reduce(`&`, lapply(kg, \(r) !is.na(r)))
kg <- lapply(kg, mask, valid, maskvalues = 0)
kg_major <- lapply(kg_major, mask, valid, maskvalues = 0)

list2env(kg, envir = .GlobalEnv)

# define output directory 
all_output_dir <- "KoppenGeigerClassifications/results/difference_maps/all/"
major_output_dir <- "KoppenGeigerClassifications/results/difference_maps/major/"
  
#name the difference pairs to analyze 
difference_pairs <- list(
  c("legacy", "contemporary"),
  c("contemporary", "ssp126_mid"),
  c("contemporary", "ssp126_end"),
  c("contemporary", "ssp245_mid"),
  c("contemporary", "ssp245_end"),
  c("contemporary", "ssp370_mid"),
  c("contemporary", "ssp370_end"),
  c("contemporary", "ssp585_mid"),
  c("contemporary", "ssp585_end"),
  c("ssp126_mid", "ssp126_end"),
  c("ssp245_mid", "ssp245_end"),
  c("ssp370_mid", "ssp370_end"),
  c("ssp585_mid", "ssp585_end"),
  c("ssp126_mid", "ssp585_mid"),
  c("ssp126_end", "ssp585_end")
)

#call transition mapping function for three-letter classification
for (p in difference_pairs) {
  kgc_transitions(kg[[p[1]]], kg[[p[2]]], file.path(all_output_dir, paste(p[1], "to", p[2], sep = "_")), "Changes in 3-letter Koppen-Geiger Classifications of Hawaii",paste(p[1], "to", p[2]), all_key)
}

#call transition mapping function for classifications converted to major classes
for (p in difference_pairs) {
  kgc_transitions(kg_major[[p[1]]], kg_major[[p[2]]], file.path(major_output_dir, paste(p[1], "to", p[2], sep = "_")), "Changes in Major Koppen-Geiger Classifications of Hawaii",paste(p[1], "to", p[2]), major_key)
}
