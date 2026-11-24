# INFO ==============================================================================
# calculates % area of each holdridge class in contemporary rasters
# statewide, by island, by climate division, and by elevation band 
# must be run before SFIG_climdiv_hold R script

# load required packages ==============================================================
library(terra)
library(macroBiome)
library(sf)
library(exactextractr)
library(tidyverse)
library(openxlsx) 

# SETUP ===========================================================================
# read in key 
hold_key <- read.csv("future climatology/HOLDRIDGE/holdridge_lookup.csv")
# read in shps
islands <- st_read("HI_KGC layers/hawaii_coastline_WGS84_shp/coastline_hawaii_WGS84.shp")
climate_divisions <- st_read("HI_KGC layers/HI_ClimateDivisions/ClimDiv12_polygon_clip.shp")
elev_bands <- st_read("HI_KGC layers/elev_contours/elev_bands.shp")

# transform crs 
st_transform(elev_bands, "EPSG:4326")

# read in contemporary climatologies for holdridge 
contemporary_hold <- rast("contemporary_climatology/holdridge_contemporary.tif")

# CALCULATE STATS =================================================================
# calculate area of each hold class (entire state)
calc_class_areas <- function(hold) { 
  areas <- terra::expanse(hold, unit = "km", byValue = TRUE)
  
  key <- hold_key
  
  out <- data.frame(
    class_code = areas$value, 
    class_name = key$label[match(areas$value, key$ID)],
    area_km_2 = round(areas$area)
  )
  
  out$percent <- round(100 * out$area_km_2 / sum(out$area_km_2), 2)
  
  out
  
}

hold_class_areas <- calc_class_areas(contemporary_hold)


# calculate area of each hold class by island 
calc_class_areas_by_poly <- function(shp, ID_column, ID_of_interest, raster){
  poly <- shp %>% 
    dplyr::filter(!!rlang::sym(ID_column) == ID_of_interest)  
  mask <- terra::mask(raster, poly)
  areas <- calc_class_areas(mask)
  out <- areas %>%
    select(class_name, area_km_2, percent)
  
  out 
  }

kauai <- calc_class_areas_by_poly(shp = islands, 
                                     ID_column = "Name", 
                                     ID_of_interest = "Kauai", 
                                     raster = contemporary_hold)
oahu <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "O'ahu", 
                                 raster = contemporary_hold)
molokai <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Moloka'i", 
                                 raster = contemporary_hold)
maui <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Maui", 
                                 raster = contemporary_hold)
lanai <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Lana'i", 
                                 raster = contemporary_hold)
hawaii <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Hawai'i", 
                                 raster = contemporary_hold)
island_stats <- list(
  "Kaua'i" = kauai, 
  "O'ahu" = oahu, 
  "Moloka'i" = molokai, 
  "Maui" = maui, 
  "Lana'i" = lanai, 
  "Hawai'i" = hawaii
)

# calculate area of each kg class by climate division 
climdiv_list <- 1:12
climdiv_stats <- lapply(climdiv_list, calc_class_areas_by_poly, shp = climate_divisions, ID_column = "gridcode", raster = contemporary_hold)

# calculate area of each kg class by elevation band 
elev_0_300 <- calc_class_areas_by_poly(shp = elev_bands, 
                                       ID_column = "band", 
                                       ID_of_interest = "0-300", 
                                       raster = contemporary_hold)
elev_300_1000 <- calc_class_areas_by_poly(shp = elev_bands, 
                                          ID_column = "band", 
                                          ID_of_interest = "300-1000", 
                                          raster = contemporary_hold)
elev_1000_2200 <- calc_class_areas_by_poly(shp = elev_bands, 
                                           ID_column = "band", 
                                           ID_of_interest = "1000-2200", 
                                           raster = contemporary_hold)
elev_2200 <- calc_class_areas_by_poly(shp = elev_bands, 
                                      ID_column = "band", 
                                      ID_of_interest = "2200", 
                                      raster = contemporary_hold)
elev_stats <- list(
  "0-300" = elev_0_300, 
  "300-1000" = elev_300_1000, 
  "1000-2200" = elev_1000_2200, 
  "2200" = elev_2200
)
# EXPORT ============================================================================= 
openxlsx::write.xlsx(island_stats, file = "results/hold_island_stats_contemporary.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(climdiv_stats, file = "results/hold_climdiv_stats_contemporary.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(elev_stats, file = "results/hold_elev_stats_contemporary.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(hold_class_areas, file = "results/hold_stats_contemporary.xlsx", overwrite = TRUE)
