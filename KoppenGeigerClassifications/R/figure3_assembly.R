# load required packages ==============================================================
library(sf)
library(tidyr)
library(ggplot2)
library(terra)
library(dplyr)

source("scripts/macroBiome.R")

# SETUP ===========================================================================
# read in shps
elev_bands <- st_read("HI_KGC layers/elev_contours/elev_bands.shp")

# transform crs 
st_transform(elev_bands, "EPSG:4269")

# read in contemporary climatologies (load in and reproject your climate class raster)
contemp_temp <- load_source("contemporary_climatology/air_temperature/mean/mean_monthly/statewide",
                            "contemporary_climatology_mean_air_temperature_mean_monthly_statewide_%s.tif", 
                            "lower", "T")
contemp_prcp <- load_source("contemporary_climatology/rain/statewide",
                            "contemporary_climatology_rainfall_mean_monthly_statewide_%s.tif", 
                            "lower", "P")
contemporary_kgc <- run_kgc(contemp_temp, contemp_prcp, "results/contemporary_kgc", "Contemporary Climatologies" )
project(contemporary_kgc, "EPSG:4269", method = "near")

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
fig3_table_long <- gather(fig3_table, elevation, percent, -class_name)
fig3 <- ggplot(fig3_table_long, aes(elevation, percent)) + 
  geom_bar(aes(fill = class_name), 
           stat = "identity", 
           position = "dodge")

# EXPORT ============================================================================= 
ggsave(filename = "results/fig3_PARTIAL.png", plot = fig3, width = 6, height = 4, units = "in", dpi = 300)
