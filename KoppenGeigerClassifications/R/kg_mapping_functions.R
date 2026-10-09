#load packages 
library(tmap)
library(terra)
library(tidyverse)

# create function 
map_kg_zones <- function(kg){
  tm_shape(kg)+
    tm_raster(col.scale = tm_scale_categorical(labels = kg %>%
                                                 values() %>%
                                                 unique() %>%
                                                 sort() %>%
                                                 getZone()), 
              col.legend = tm_legend(title = "Legend"))+
    tm_graticules(
      n.x = 5, 
      n.y = 5, 
      alpha = 0
    )+
    tm_title("Koeppen Geiger Climate Classifications of Hawaii")+
    tm_title("Using contemporary rainfall and precip datasets", 
             size = 0.8)+
    tm_compass(position = tm_pos_in("LEFT", 
                                    "BOTTOM"))
}

# run function
map_of_kg_zones <- map_kg_zones(kg)

# save as PNG and TIFF 
tmap_save(tm = map_of_kg_zones, filename = "results/kg_zones_HI_map.png") # input your file path
tmap_save(tm = map_of_kg_zones, filename = "results/kg_zones_HI_map.tiff") # input your file path
