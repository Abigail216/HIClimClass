library(terra)
library (tmap)
library (macroBiome)

source("KoppenGeigerClassifications/R/difference_maps.R")

contemporary <- rast("KoppenGeigerClassifications/results/contemporary_kgc.tif")
legacy <- rast("KoppenGeigerClassifications/results/legacy_kgc.tif")


diff_map <- kgc_transitions(legacy, contemporary, "KoppenGeigerClassifications/results/difference_maps/legacy_to_contemporary")