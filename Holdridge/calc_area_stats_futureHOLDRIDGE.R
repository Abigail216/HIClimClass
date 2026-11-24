# INFO ================================================================================
# calculates area stats of future scenarios for holdridge. 
# must be run before
# Table 5 assembly.

# load required packages ==============================================================
library(terra)
library(sf)
library(tidyverse)
library(openxlsx)

# SETUP ===========================================================================
# read in islands
islands <- st_read("HI_KGC layers/hawaii_coastline_WGS84_shp/coastline_hawaii_WGS84.shp")
st_transform(islands, "EPSG:4326")

# read in future climatologies
ssp126_mid_hold <- rast("future climatology/HOLDRIDGE/holdridge_mid_SSP126.tif")

ssp245_mid_hold <- rast("future climatology/HOLDRIDGE/holdridge_mid_SSP245.tif")

ssp370_mid_hold <- rast("future climatology/HOLDRIDGE/holdridge_mid_SSP370.tif")

ssp585_mid_hold <- rast("future climatology/HOLDRIDGE/holdridge_mid_SSP585.tif")

ssp126_end_hold <- rast("future climatology/HOLDRIDGE/holdridge_end_SSP126.tif")

ssp245_end_hold <- rast("future climatology/HOLDRIDGE/holdridge_end_SSP245.tif")

ssp370_end_hold <- rast("future climatology/HOLDRIDGE/holdridge_end_SSP370.tif")

ssp585_end_hold <- rast("future climatology/HOLDRIDGE/holdridge_end_SSP585.tif")

# reproject 
all_ssp <- list(ssp126_mid_hold,
                ssp245_mid_hold, 
                ssp370_mid_hold, 
                ssp585_mid_hold,
                ssp126_end_hold, 
                ssp245_end_hold, 
                ssp370_end_hold, 
                ssp585_end_hold)
lapply(all_ssp, project, "EPSG:4326", method = "near")

# CALCULATE STATS =================================================================
# create holdridge key 
hold_key <- read.csv("future climatology/HOLDRIDGE/holdridge_lookup.csv")

# calculate area of each hold class (statewide)
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

all_ssp_stats_statewide <- lapply(all_ssp, calc_class_areas)

# EXPORT ============================================================================= 
openxlsx::write.xlsx(all_ssp_stats_statewide, file = "results/hold_statewide_stats_future.xlsx", overwrite = TRUE)
