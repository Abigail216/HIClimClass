# info ==============================================================================
# calculates % area of each thornthwaite class for contemporary raster. 
# calculates % area statewide, by island, by cliamte division, and by elevation band 
# run before SFIG_climdiv_thorn R script
# ====================================================================================

# load required packages ==============================================================
library(terra)
library(macroBiome)
library(sf)
library(exactextractr)
library(tidyverse)
library(openxlsx) 

# SETUP ===========================================================================
# read in shps
islands <- st_read("HI_KGC layers/hawaii_coastline_WGS84_shp/coastline_hawaii_WGS84.shp")
climate_divisions <- st_read("HI_KGC layers/HI_ClimateDivisions/ClimDiv12_polygon_clip.shp")
elev_bands <- st_read("HI_KGC layers/elev_contours/elev_bands.shp")

# transform crs 
st_transform(elev_bands, "EPSG:4326")

# read in contemporary climatologies for holdridge 
contemporary_thorn <- rast("contemporary_climatology/Contemporary_thornthwaite_classification.tif")

# read in look up key 
thorn_key <- read.csv("future climatology/THORNTHWAITE/classes_lookup.csv")

# CALCULATE STATS =================================================================
# calculate area of each kg class (entire state)
calc_class_areas <- function(thorn) { 
  areas <- terra::expanse(thorn, unit = "km", byValue = TRUE)
  
  key <- thorn_key
  
  out <- data.frame(
    class_code = areas$value, 
    class_name = key$class_label[match(areas$value, key$color_id)],
    area_km_2 = round(areas$area)
  )
  
  
  out$percent <- round(100 * out$area_km_2 / sum(out$area_km_2), 2)
  
  out
  
}

thorn_class_areas <- calc_class_areas(contemporary_thorn)

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
                                     raster = contemporary_thorn)
oahu <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "O'ahu", 
                                 raster = contemporary_thorn)
molokai <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Moloka'i", 
                                 raster = contemporary_thorn)
maui <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Maui", 
                                 raster = contemporary_thorn)
lanai <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Lana'i", 
                                 raster = contemporary_thorn)
hawaii <- calc_class_areas_by_poly(shp = islands, 
                                 ID_column = "Name", 
                                 ID_of_interest = "Hawai'i", 
                                 raster = contemporary_thorn)
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
climdiv_stats <- lapply(climdiv_list, calc_class_areas_by_poly, shp = climate_divisions, ID_column = "gridcode", raster = contemporary_thorn)

# calculate area of each kg class by elevation band 
elev_0_300 <- calc_class_areas_by_poly(shp = elev_bands, 
                                       ID_column = "band", 
                                       ID_of_interest = "0-300", 
                                       raster = contemporary_thorn)
elev_300_1000 <- calc_class_areas_by_poly(shp = elev_bands, 
                                          ID_column = "band", 
                                          ID_of_interest = "300-1000", 
                                          raster = contemporary_thorn)
elev_1000_2200 <- calc_class_areas_by_poly(shp = elev_bands, 
                                           ID_column = "band", 
                                           ID_of_interest = "1000-2200", 
                                           raster = contemporary_thorn)
elev_2200 <- calc_class_areas_by_poly(shp = elev_bands, 
                                      ID_column = "band", 
                                      ID_of_interest = "2200", 
                                      raster = contemporary_thorn)
elev_stats <- list(
  "0-300" = elev_0_300, 
  "300-1000" = elev_300_1000, 
  "1000-2200" = elev_1000_2200, 
  "2200" = elev_2200
)
# EXPORT ============================================================================= 
openxlsx::write.xlsx(island_stats, file = "results/thorn_island_stats_contemporary.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(climdiv_stats, file = "results/thorn_climdiv_stats_contemporary.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(elev_stats, file = "results/thorn_elev_stats_contemporary.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(thorn_class_areas, file = "results/thorn_stats_contemporary.xlsx", overwrite = TRUE)
