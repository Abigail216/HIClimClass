# INFO ==============================================================================
# creates koppen section of fig 5

# load required packages ==============================================================
library(sf)
library(tidyverse)
library(ggplot2)
library(terra)
library(dplyr)

source("scripts/macroBiome.R")

# SETUP ===========================================================================
# read in shps
elev_bands <- st_read("HI_KGC layers/elev_contours/elev_bands.shp")

# transform crs 
st_transform(elev_bands, "EPSG:4326")

# read in contemporary climatologies (load in and reproject your climate class raster)
contemp_temp <- load_source("contemporary_climatology/air_temperature/mean/mean_monthly/statewide",
                            "contemporary_climatology_mean_air_temperature_mean_monthly_statewide_%s.tif", 
                            "lower", "T")
contemp_prcp <- load_source("contemporary_climatology/rain/statewide",
                            "contemporary_climatology_rainfall_mean_monthly_statewide_%s.tif", 
                            "lower", "P")
contemporary_kgc <- run_kgc(contemp_temp, contemp_prcp, "results/contemporary_kgc", "Contemporary Climatologies" )

# CALCULATE STATS =================================================================
# create function 
calc_class_areas <- function(kg) { 
  areas <- terra::expanse(kg, unit="km", byValue=TRUE)
  
  key <- kgc_key
  
  out <- data.frame(
    class_name = areas$value,
    area_km_2 = round(areas$area))
  
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
                                       raster = contemporary_kgc) # input your climate class raster
elev_300_1000 <- calc_class_areas_by_poly(shp = elev_bands, 
                                          ID_column = "band", 
                                          ID_of_interest = "300-1000", 
                                          raster = contemporary_kgc)
elev_1000_2200 <- calc_class_areas_by_poly(shp = elev_bands, 
                                           ID_column = "band", 
                                           ID_of_interest = "1000-2200", 
                                           raster = contemporary_kgc)
elev_2200 <- calc_class_areas_by_poly(shp = elev_bands, 
                                      ID_column = "band", 
                                      ID_of_interest = "2200", 
                                      raster = contemporary_kgc)

# structure df 
fig3_table <- kgc_key%>% # input the key to your climate classes 
  select(class_name) %>%
  left_join(elev_0_300 %>% rename(elev_0_300 = percent), by = "class_name") %>%
  left_join(elev_300_1000 %>% rename(elev_300_1000 = percent), by = "class_name") %>%
  left_join(elev_1000_2200 %>% rename (elev_1000_2200 = percent), by = "class_name") %>%
  left_join(elev_2200 %>% rename(elev_2200 = percent), by = "class_name") %>%
  filter(if_any(c(elev_0_300, elev_300_1000, elev_1000_2200, elev_2200), ~ !is.na(.)))

# create bar chart 
fig3_table_long <- fig3_table %>%
  pivot_longer(cols = -class_name, 
               names_to = "elevation", 
               values_to = "percent", 
               names_transform = list(elevation = fct_inorder)) 

# plot
fig3 <- ggplot(fig3_table_long, aes(elevation, percent)) + 
  geom_bar(aes(fill = class_name), stat = "identity"
           ) +
  scale_x_discrete(labels = c(
    "elev_0_300" = "0 - 300", 
    "elev_300_1000" = "300 - 1000", 
    "elev_1000_2200" = "1000 - 2200", 
    "elev_2200" = "2200 - 4200"
  )) +
  labs(x = "Elevation (m)", 
         y = "Percent", 
       fill = "Köppen-Geiger Class") +
  scale_fill_manual(
  values = c("Af"="#3A78B8", "Am"="#6AA2D4", "Aw"="#A6CAE9",
             "BWh"="#C4533F", "BWk"="#E58F7E", "BSh"="#E69A4A", "BSk"="#F0B27A",
             "Cfa"="#A5D8A0", "Cfb"="#6DBE8A","Cfc"="#3F9A78", "Csa"="#FAF5B0", "Csb"="#DCE57F", "Csc"="#B5C95A",
             "ET"="#BFC3CC"
  ))+
  theme_classic()


# EXPORT ============================================================================= 
ggsave(filename = "results/fig3a_kg.png", plot = fig3, width = 6, height = 4, units = "in", dpi = 300)
