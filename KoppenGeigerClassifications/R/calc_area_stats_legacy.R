# load required packages ==============================================================
library(terra)
library(macroBiome)
library(sf)
library(exactextractr)
library(tidyverse)
library(openxlsx) 

source("scripts/macroBiome.R")


# SETUP ===========================================================================
# read in shps
islands <- st_read("HI_KGC layers/hawaii_coastline_shp/coast_hawaii.shp")
climate_divisions <- st_read("HI_KGC layers/HI_ClimateDivisions/ClimDiv12_polygon_clip.shp")

# transform crs 
st_transform(islands, "EPSG:4269")
st_transform(climate_divisions, "EPSG:4269")

# read in legacy climatologies 
legacy_temp <- load_source("legacy_climatology/air_temperature/mean/mean_monthly/statewide",
                           "legacy_climatology_mean_air_temperature_mean_monthly_statewide_%s.tif", 
                           "lower", "T")
legacy_prcp <- load_source("legacy_climatology/rainfall/mean_monthly/statewide",
                           "legacy_climatology_rainfall_mean_monthly_statewide_%s.tif", 
                           "lower", "P")
legacy_kgc <- run_kgc(legacy_temp, legacy_prcp, "results/legacy_kgc", "Legacy Climatologies" )
project(legacy_kgc, "EPSG:4269", method = "near")

# CALCULATE STATS =================================================================
# calculate area of each kg class (entire state)
calc_class_areas <- function(kg) { 
  areas <- terra::expanse(kg, unit="km", byValue=TRUE)
  
  key <- kgc_key
  
  out <- data.frame(
    class_code = areas$value,
    area_km_2 = round(areas$area))
  
  out$percent <- round(100 * out$area_km_2 / sum(out$area_km_2), 2)
  
  out
}

kg_class_areas <- calc_class_areas(kg=legacy_kgc)

# calculate area of each kg class by island 
calc_class_areas_by_poly <- function(shp, ID_column, ID_of_interest, raster){
  poly <- shp %>% 
    dplyr::filter(!!rlang::sym(ID_column) == ID_of_interest)  
  mask <- terra::mask(raster, poly)
  areas <- calc_class_areas(mask)
  out <- areas %>%
    select(class_code, area_km_2, percent)
  
  out 
  }

kauai <- calc_class_areas_by_poly(shp = islands, 
                                     ID_column = "Name", 
                                     ID_of_interest = "Kauai", 
                                     raster = legacy_kgc) 
oahu <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "O'ahu", 
                                 raster = legacy_kgc) 
molokai <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Moloka'i", 
                                 raster = legacy_kgc) 
maui <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Maui", 
                                 raster = legacy_kgc) 
lanai <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Lana'i", 
                                 raster = legacy_kgc) 
hawaii <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Hawai'i", 
                                 raster = legacy_kgc) 
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
climdiv_stats <- lapply(climdiv_list, calc_class_areas_by_poly, shp = climate_divisions, ID_column = "gridcode", raster = legacy_kgc)

    
# EXPORT ============================================================================= 
openxlsx::write.xlsx(island_stats, file = "results/kg_island_stats_legacy.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(climdiv_stats, file = "results/kg_climdiv_stats_legacy.xlsx", overwrite = TRUE)
