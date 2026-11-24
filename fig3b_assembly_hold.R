# INFO ==============================================================================
# purpose: create supplemental figures that show percent area of each climate class  
# usable for holdridge and thornthwaite. 

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

class_key <- read.csv("future climatology/HOLDRIDGE/holdridge_lookup.csv") # CHANGE TO UR LOOKUP KEY PATH, THORN/HOLD

contemporary <- rast("contemporary_climatology/holdridge_contemporary.tif") # CHANGE TO UR LOOKUP KEY PATH, THORN/HOLD
project(contemporary, "EPSG:4326")

# CALCULATE STATS =================================================================
# create function 
calc_class_areas <- function(class) { 
  areas <- terra::expanse(class, unit = "km", byValue = TRUE)
  
  key <- class_key
  
  out <- data.frame(
    class_code = areas$value, 
    class_name = key$label[match(areas$value, key$ID)], # CHANGE 'class_label' TO ID COLUMN NAME AND 'color_id' TO CODE COLUMN NAME
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


# calculate area of each kg class by elevation band 
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
  select(label) %>% # CHANGE TO THE NAME OF ID COLUMN IN KEY 
  left_join(elev_0_300 %>% rename(elev_0_300 = percent), by = join_by(label == class_name)) %>%
  left_join(elev_300_1000 %>% rename(elev_300_1000 = percent), by = join_by(label == class_name)) %>%
  left_join(elev_1000_2200 %>% rename (elev_1000_2200 = percent), by = join_by(label == class_name)) %>%
  left_join(elev_2200 %>% rename(elev_2200 = percent), by = join_by(label == class_name)) %>%
  filter(if_any(c(elev_0_300, elev_300_1000, elev_1000_2200, elev_2200), ~ !is.na(.)))

# create bar chart 
fig_table_long <- fig_table %>%
  pivot_longer(cols = -label, # cHANGE TO NAME OF ID COLUMN IN KEY 
               names_to = "elevation", 
               values_to = "percent", 
               names_transform = list(elevation = fct_inorder)) 

# plot
fig <- ggplot(fig_table_long, aes(elevation, percent)) + 
  geom_bar(aes(fill = label), stat = "identity"
           ) + # CHANGE 'label' TO NAME OF ID COLUMN
  scale_x_discrete(labels = c(
    "elev_0_300" = "0 - 300", 
    "elev_300_1000" = "300 - 1000", 
    "elev_1000_2200" = "1000 - 2200", 
    "elev_2200" = "2200 - 4200"
  )) +
  labs(x = "Elevation (m)", 
         y = "Percent", 
       title = "Holdridge percent area elevation",  
       fill = "Holdridge Class") + 
  scale_fill_manual(
    values = c("Bare soil and no vegetation"=	"#E8F5F2",
               "Cool temperate desert scrub"=	"#F4F8FF",
              "Boreal dry scrub"=	"#D6D6D6",
              "Cool temperate steppe"=	"#DCEBFF",
              "Cool temperate moist forest" =	"#B6D5FF",
              "Cool temperate wet forest" =	"#83B9FF",
              "Cool temperate rain forest"= "#4C99FF",
              "Warm temperate thorn steppe"=	"#FFF5EA",
              "Subtropical desert scrub"	= "#F3FFF4",
              "Tropical desert scrub" =	"#FFF4FC",
               "Warm temperate dry Forest" =	"#FFE1C3",
              "Subtropical thorn woodland" =	"#DDF8E2",
              "Tropical thorn woodland" =	"#F8DDF0",
               "Warm temperate moist forest"	= "#FFC28E",
              "Subtropical dry forest" =	"#C4EFCB"	,
              "Tropical very dry forest"	= "#F0BCE3",
               "Warm temperate wet forest" =	"#FF9D5B",
              "Subtropical moist forest"	= "#A2E4B0",
              "Tropical dry forest" = "#E697D3",
               "Warm temperate rain forest"	= "#FF792D",
              "Subtropical wet forest"	= "#76D88E",
              "Tropical moist forest" =	"#D86CC2",
               "Subtropical rain forest" =	"#43C96B",
              "Tropical wet forest"  =	"#C844AE", 
              "Warm temperate dry forest" = "#FFE1C3"
    ))+
  theme_classic()

# EXPORT ============================================================================= 
ggsave(filename = "results/fig3b_hold.png", 
       plot = fig, width = 10, height = 5, units = "in", dpi = 300)
