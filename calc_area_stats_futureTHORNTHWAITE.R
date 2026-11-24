# INFO ================================================================================
# calculates area stats of future scenarios for thornthwaite. 
# must be run before
# Table 6 assembly. 

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
ssp126_mid_thorn <- rast("future climatology/THORNTHWAITE/MID_ssp126_thornthwaite_classification.tif")

ssp245_mid_thorn <- rast("future climatology/THORNTHWAITE/MID_ssp245_thornthwaite_classification.tif")

ssp370_mid_thorn <- rast("future climatology/THORNTHWAITE/MID_ssp370_thornthwaite_classification.tif")

ssp585_mid_thorn <- rast("future climatology/THORNTHWAITE/MID_ssp585_thornthwaite_classification.tif")

ssp126_end_thorn <- rast("future climatology/THORNTHWAITE/END_ssp126_thornthwaite_classification.tif")

ssp245_end_thorn <- rast("future climatology/THORNTHWAITE/END_ssp245_thornthwaite_classification.tif")

ssp370_end_thorn <- rast("future climatology/THORNTHWAITE/END_ssp370_thornthwaite_classification.tif")

ssp585_end_thorn <- rast("future climatology/THORNTHWAITE/END_ssp585_thornthwaite_classification.tif")


# reproject 
all_ssp <- list(ssp126_mid_thorn,
                ssp245_mid_thorn, 
                ssp370_mid_thorn, 
                ssp585_mid_thorn,
                ssp126_end_thorn, 
                ssp245_end_thorn, 
                ssp370_end_thorn, 
                ssp585_end_thorn)
lapply(all_ssp, project, "EPSG:4326", method = "near")

# CALCULATE STATS =================================================================
# create thornthwaite key 
thorn_key <- read.csv("future climatology/THORNTHWAITE/classes_lookup.csv")

# calculate area of each hold class (statewide)
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

all_ssp_stats_statewide <- lapply(all_ssp, calc_class_areas)

# EXPORT ============================================================================= 
openxlsx::write.xlsx(all_ssp_stats_statewide, file = "results/thorn_statewide_stats_future.xlsx", overwrite = TRUE)
