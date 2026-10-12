#load packages 
library(tmap)
library(terra)
library(tidyverse)

# create a key for kg climate class numerical codes (based on ClimClass package)
clim_classes_key <- data.frame(
  class_code = c(11, 12, 13, 21, 22, 31, 32, 33, 41, 42, 43, 51, 52),
  class_name = c("Af", "Aw", "Am", "BW", "BS", "Cs", "Cw", "Cf", "Ds", "Dw", "Df", "ET", "EF"),
  stringsAsFactors = FALSE
)

# create an object to pass for labels 
legend_labels <- clim_classes_key$class_name[match(unique(kg)[, 1], clim_classes_key$class_code)]

# create mapping function 
map_kg_zones <- function(kg){
  tm_shape(kg)+
    tm_raster(col.scale = tm_scale_categorical(labels = legend_labels),
              col.legend = tm_legend(title = "Legend"))+
    tm_graticules(
      n.x = 5, 
      n.y = 5, 
      alpha = 0
    )+
    tm_title("Koeppen Geiger Climate Classifications of Hawaii", 
             size = 1.5)+
    tm_title("Using contemporary rainfall and precip datasets", 
             size = 0.8)+
    tm_compass(position = tm_pos_in("LEFT", 
                                    "BOTTOM"))
}

# run function
map_of_kg_zones <- map_kg_zones(kg)

map_kg_zones(kg)

# save as PNG and TIFF 
tmap_save(tm = map_of_kg_zones, filename = "results/kg_zones_HI_map.png") # input your file path
tmap_save(tm = map_of_kg_zones, filename = "results/kg_zones_HI_map.tiff") # input your file path
