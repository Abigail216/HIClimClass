# INFO ==============================================================================
# purpose: create thornthwaite panel of fig 3 that shows percent area of each climate class. 

# load required packages ==============================================================
library(sf)
library(tidyverse)
library(ggplot2)
library(terra)
library(dplyr)

# SETUP ===========================================================================
# read in 
elev_bands <- st_read("HI_KGC layers/elev_contours/elev_bands.shp")
st_transform(elev_bands, "EPSG:4326")

class_key <- read.csv("future climatology/THORNTHWAITE/classes_lookup.csv") # CHANGE TO UR LOOKUP KEY PATH, THORN/HOLD

contemporary <- rast("contemporary_climatology/Contemporary_thornthwaite_classification.tif") # CHANGE TO UR LOOKUP KEY PATH, THORN/HOLD
project(contemporary, "EPSG:4326")

# CALCULATE STATS =================================================================
# create function 
calc_class_areas <- function(class) { 
  areas <- terra::expanse(class, unit = "km", byValue = TRUE)
  
  key <- class_key
  
  out <- data.frame(
    class_code = areas$value, 
    class_name = key$class_label[match(areas$value, key$color_id)], # CHANGE 'class_label' TO ID COLUMN NAME AND 'color_id' TO CODE COLUMN NAME
    area_km_2 = round(areas$area)
  )
  
  
  out$percent <- round(100 * out$area_km_2 / sum(out$area_km_2), 2)
  
  out
  
}

calc_class_areas_by_poly <- function(shp, ID_column, ID_of_interest, raster){
  poly <- shp %>% 
    dplyr::filter(!!rlang::sym(ID_column) == ID_of_interest)  
  mask <- terra::mask(raster, poly)
  areas <- calc_class_areas(mask)
  out <- areas %>%
    select(class_name, percent)
  
  out 
}


# calculate area of each class by elevation band 
elev_0_300 <- calc_class_areas_by_poly(shp = elev_bands, 
                                       ID_column = "band", 
                                       ID_of_interest = "0-300", 
                                       raster = contemporary)  
elev_300_1000 <- calc_class_areas_by_poly(shp = elev_bands, 
                                          ID_column = "band", 
                                          ID_of_interest = "300-1000", 
                                          raster = contemporary)
elev_1000_2200 <- calc_class_areas_by_poly(shp = elev_bands, 
                                           ID_column = "band", 
                                           ID_of_interest = "1000-2200", 
                                           raster = contemporary)
elev_2200 <- calc_class_areas_by_poly(shp = elev_bands, 
                                      ID_column = "band", 
                                      ID_of_interest = "2200", 
                                      raster = contemporary)

# structure df 
fig_table <- class_key%>% 
  select(class_label) %>% # CHANGE TO THE NAME OF ID COLUMN IN KEY 
  left_join(elev_0_300 %>% rename(elev_0_300 = percent), by = join_by(class_label == class_name)) %>%
  left_join(elev_300_1000 %>% rename(elev_300_1000 = percent), by = join_by(class_label == class_name)) %>%
  left_join(elev_1000_2200 %>% rename (elev_1000_2200 = percent), by = join_by(class_label == class_name)) %>%
  left_join(elev_2200 %>% rename(elev_2200 = percent), by = join_by(class_label == class_name)) %>%
  filter(if_any(c(elev_0_300, elev_300_1000, elev_1000_2200, elev_2200), ~ !is.na(.)))

# create bar chart 
fig_table_long <- fig_table %>%
  pivot_longer(cols = -class_label, # cHANGE TO NAME OF ID COLUMN IN KEY 
               names_to = "elevation", 
               values_to = "percent", 
               names_transform = list(elevation = fct_inorder)) 

# plot
fig <- ggplot(fig_table_long, aes(elevation, percent)) + 
  geom_bar(aes(fill = class_label), stat = "identity"
           ) + # CHANGE 'label' TO NAME OF ID COLUMN
  scale_x_discrete(labels = c(
    "elev_0_300" = "0 - 300", 
    "elev_300_1000" = "300 - 1000", 
    "elev_1000_2200" = "1000 - 2200", 
    "elev_2200" = "2200 - 4200"
  )) +
  labs(x = "Elevation (m)", 
         y = "Percent", 
       title = "Thornthwaite percent area elevation", # CHANGE TITLE IF NEED 
       fill = "Thornthwaite Class") + # CHANGE TITLE IF NEED 
  scale_fill_manual(
    values = c( "Saturate Torrid" = "#003B70", 
                "Wet Torrid" = "#56B4E9", 
                "Moist Torrid" = "#009E73",
                "Dry Torrid" = "#CC79A7", 
                "Semi-Arid Torrid" = "#E69F00", 
                "Arid Torrid" = "#F0E442", 
                "Saturate Hot" = "#1F5381",
                "Saturate Warm" = "#406C94",
                "Saturate Cool" = "#6689A9",
                "Saturate Cold" = "#8CA7BF",
                "Saturate Frigid" = "#B3C4D4",
                "Wet Hot" = "#6ABDEC",
                "Wet Warm" = "#80C7EF",
                "Wet Cool" = "#9AD2F2",
                "Wet Cold" = "#B3DDF5",
                "Wet Frigid" = "#CCE9F8",
                "Moist Hot" = "#1FAA84",
                "Moist Warm" = "#40B696",
                "Moist Cool" = "#8CD3C0",
                "Moist Cold" = "#A0DBCD",
                "Moist Frigid" = "#B3E2D5",
                "Dry Hot" = "#D289B2",
                "Dry Warm" = "#D99BBD",
                "Dry Cool" = "#E0AFCA",
                "Dry Cold" = "#E8C3D8",
                "Dry Frigid" = "#F0D7E5",
                "Semiarid Hot" = "#E9AB1F",
                "Semiarid Warm" = "#ECB740",
                "Semiarid Cool" = "#F0C566",
                "Semiarid Cold" = "#F4D48C",
                "Semiarid" = "#F8E2B3",
                "Arid Hot" = "#F2E759",
                "Arid Warm" = "#F4EB71",
                "Arid Cool" = "#F6EF8E",
                "Arid Cold" = "#F8F3AA",
                "Arid Frigid" = "#FBF7C6"
    ))+
  theme_classic()

# EXPORT ============================================================================= 
ggsave(filename = "results/fig3c_thorn.png", # REPLACE 'thorn' IF NEED
       plot = fig, width = 10, height = 5, units = "in", dpi = 300)
