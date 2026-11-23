library(terra)
library(tmap)

lookup <- read.csv("Holdridge/data/holdridge_audebert_lvl1_lookup.csv")
lookup_lvl1 <- lookup[, c(1, 2)]
lookup_ecozone <- lookup[,c(3, 4)]

eco_levels <- unique(lookup_ecozone)

to_ecozone <- function(x, file_name) {
  if (xmin(x) > 180) x <- shift(x, dx = -360)
  reclass_scheme <- cbind(lookup$LVL1_ID, lookup$ECOZONE_ID)

  levels(x) <- NULL
  result <- classify(x, reclass_scheme, others = NA)
  levels(result) <- eco_levels
  writeRaster(result, paste0(file_name, ".tif"), overwrite = TRUE)
  result
}

#Maps a major-class classification and saves the .png
map_ecozone <- function(x, file_name, map_subtitle) {
 map <- tm_shape(x)+
   tm_graticules(n.x = 5, n.y = 5, alpha = 0.6)+
   tm_raster(col.legend = tm_legend(title = "Ecozone")) +
   tm_title("Holdridge Ecozones of Hawaii", size = 1.5, position = tm_pos_out("center", "top")) +
   tm_title(map_subtitle, size = 0.8, position = tm_pos_out("center", "top")) +
   tm_compass(position = tm_pos_in("LEFT", "BOTTOM"))
   tmap_save(map, paste0(file_name, ".png"))
   print(map)
}

run_reclass <- function(x, file_name, map_subtitle){
  result <- to_ecozone(x, file_name)
  map_ecozone(result, file_name, map_subtitle)
  result
}