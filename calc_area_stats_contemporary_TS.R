# info ==============================================================================
# this script assembles table 1 of our paper. 
# relies on reading in files generated in the 
# calc_area_stats_contemporaryTHORNTHWAITE R script
# ====================================================================================
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
elev_bands <- st_read("HI_KGC layers/elev_contours/elev_bands.shp")

# transform crs 
st_transform(islands, "EPSG:4269")
st_transform(climate_divisions, "EPSG:4269")
st_transform(elev_3, "EPSG:4269")

# read in contemporary climatologies
contemp_temp <- load_source("contemporary_climatology/air_temperature/mean/mean_monthly/statewide",
                            "contemporary_climatology_mean_air_temperature_mean_monthly_statewide_%s.tif", 
                            "lower", "T")
contemp_prcp <- load_source("contemporary_climatology/rain/statewide",
                            "contemporary_climatology_rainfall_mean_monthly_statewide_%s.tif", 
                            "lower", "P")
contemporary_kgc <- run_kgc(contemp_temp, contemp_prcp, "results/contemporary_kgc", "Contemporary Climatologies" )
project(contemporary_kgc, "EPSG:4269", method = "near")

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
kg_class_areas <- calc_class_areas(contemporary_kgc)

# hb ts new function for diff table format 
elev_3$Id <- NULL
rownames(elev_3) <- elev_3$Contour

stats_by_island <- data.frame(class_code = class_codes, # structure for stats by island output 
                   island1 = island1_values, 
                   island2 = island2_values, 
                   island3 = island3_values, 
                   island4 = island4_values, 
                   island5 = island5_values, 
                   island6 = island6_values)

stats_by_elev <- data.frame(class_code = class_codes, # structure for stats by elev band output 
                            band0_300 = band0_300_values, 
                            band300_1000 = band300_1000_values, 
                            band1000_2200 = band1000_2200_values)

# calculate area of each kg class by island 
calc_class_areas_by_poly <- function(shp, ID_column, ID_of_interest, raster){
  poly <- shp %>%
  dplyr::filter(!!rlang::sym(ID_column) == ID_of_interest)
  mask <- terra::mask(raster, shp)
  areas <- calc_class_areas(mask)
  out <- areas %>%
    select(class_code, area_km_2, percent)
  
  out 
  }

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
# first need to make it so that the polygon situation is each band is a diff row. with a group by. 
elev_grouped <- elev_3 %>%
  distinct(Contour, .keep_all = TRUE)
plot(elev_3)
plot(elev_grouped)
# EXPORT ============================================================================= 
openxlsx::write.xlsx(island_stats, file = "results/kg_island_stats_contemporary.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(climdiv_stats, file = "results/kg_climdiv_stats_contemporary.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(elev2_stats, file = "results/kg_elev2_stats_contemporary.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(kg_class_areas, file = "results/kg_stats_contemporary.xlsx", overwrite = TRUE)

