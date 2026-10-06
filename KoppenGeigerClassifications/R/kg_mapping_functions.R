#load packages 
library(tmap)
library(terra)
library(tidyverse)

# create function 
map_kg_zones <- function(kg){
  
  levels(kg) <- data.frame( # add legend key 
    id = c(11, 12, 13, 21, 22, 31, 33, 51), 
    class = c("Af", "Aw", "Am", "BW", "BS", "Cf", "Cs", "ET" )
  )
  tm_shape(kg)+
    tm_raster(col.scale = tm_scale_categorical(), 
              col.legend = tm_legend(title = "Legend"))+
    tm_graticules(
      n.x = 5, 
      n.y = 5, 
      alpha = 0
    )+
    tm_title("Koeppen Geiger Climate Classifications of Hawaii")
}

map_kg_zones(kg)


# this is the code in the function: 
levels(kg) <- data.frame( # add legend key #HB NOTE: Change this to the getZone() function
  id = c(11, 12, 13, 21, 22, 31, 33, 51), 
  class = c("Af", "Aw", "Am", "BW", "BS", "Cf", "Cs", "ET" )
)
tm_shape(kg)+
  tm_raster(col.scale = tm_scale_categorical(), 
  col.legend = tm_legend(title = "Legend"))+
  tm_graticules(
    n.x = 5, 
    n.y = 5, 
    alpha = 0
  )+
  tm_title(text = "Koeppen Geiger Climate Classifications of Hawaii", 
           subtitle = "Contemporary Climatology Data") # HB NOTE: add position = () and size = ()