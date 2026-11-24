# INFO ==============================================================================
# calculates % area of each kg class in contemporary rasters
# statewide, by island, by climate division, and by elevation band 

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
islands <- st_read("HI_KGC layers/hawaii_coastline_WGS84_shp/coastline_hawaii_WGS84.shp")
climate_divisions <- st_read("HI_KGC layers/HI_ClimateDivisions/ClimDiv12_polygon_clip.shp")
elev_bands <- st_read("HI_KGC layers/elev_contours/elev_bands.shp")

# transform crs 
st_transform(elev_bands, "EPSG:4326")

# read in contemporary climatologies for kgc 
contemp_temp <- load_source("contemporary_climatology/air_temperature/mean/mean_monthly/statewide",
                            "contemporary_climatology_mean_air_temperature_mean_monthly_statewide_%s.tif", 
                            "lower", "T")
contemp_prcp <- load_source("contemporary_climatology/rain/statewide",
                            "contemporary_climatology_rainfall_mean_monthly_statewide_%s.tif", 
                            "lower", "P")
contemporary_kgc <- run_kgc(contemp_temp, contemp_prcp, "results/contemporary_kgc", "Contemporary Climatologies" )
st_crs(contemporary_kgc)

# CREATE FUNCTIONS ================================================================
# calculate class areas within raster
calc_class_areas <- function(kg) { 
  areas <- terra::expanse(kg, unit="km", byValue=TRUE)
  
  key <- kgc_key
  
  out <- data.frame(
    class_code = areas$value,
    area_km_2 = round(areas$area))
  
  out$percent <- round(100 * out$area_km_2 / sum(out$area_km_2), 2)
  
  out
}

# calculate areas of raster within polygon 
calc_class_areas_by_poly <- function(shp, ID_column, ID_of_interest, raster){
  poly <- shp %>% 
    dplyr::filter(!!rlang::sym(ID_column) == ID_of_interest)  
  mask <- terra::mask(raster, poly)
  areas <- calc_class_areas(mask)
  out <- areas %>%
    select(class_code, area_km_2, percent)
  
  out 
}

# CALCULATE STATS =================================================================
# calculate area of each kg class (entire state)
kg_class_areas <- calc_class_areas(contemporary_kgc)

# calculate area of each kg class by island

kauai <- calc_class_areas_by_poly(shp = islands, 
                                     ID_column = "Name", 
                                     ID_of_interest = "Kauai", 
                                     raster = contemporary_kgc)
oahu <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "O'ahu", 
                                 raster = contemporary_kgc)
molokai <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Moloka'i", 
                                 raster = contemporary_kgc)
maui <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Maui", 
                                 raster = contemporary_kgc)
lanai <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Lana'i", 
                                 raster = contemporary_kgc)
hawaii <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Hawai'i", 
                                 raster = contemporary_kgc)
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
climdiv_stats <- lapply(climdiv_list, calc_class_areas_by_poly, shp = climate_divisions, ID_column = "gridcode", raster = contemporary_kgc)

# calculate area of each kg class by elevation band 
elev_0_300 <- calc_class_areas_by_poly(shp = elev_bands, 
                                       ID_column = "band", 
                                       ID_of_interest = "0-300", 
                                       raster = contemporary_kgc)
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
elev_stats <- list(
  "0-300" = elev_0_300, 
  "300-1000" = elev_300_1000, 
  "1000-2200" = elev_1000_2200, 
  "2200" = elev_2200
)
# EXPORT ============================================================================= 
openxlsx::write.xlsx(island_stats, file = "results/kg_island_stats_contemporary.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(climdiv_stats, file = "results/kg_climdiv_stats_contemporary.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(elev_stats, file = "results/kg_elev_stats_contemporary.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(kg_class_areas, file = "results/kg_stats_contemporary.xlsx", overwrite = TRUE)
