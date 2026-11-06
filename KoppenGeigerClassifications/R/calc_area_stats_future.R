# load required packages ==============================================================
library(terra)
library(macroBiome)
library(sf)
library(exactextractr)
library(tidyverse)
library(openxlsx) 

source("scripts/macroBiome.R")

# SETUP ===========================================================================
# read in islands
islands <- st_read("HI_KGC layers/hawaii_coastline_WGS84_shp/coastline_hawaii_WGS84.shp")
st_transform(islands, "EPSG:4269")

# read in future climatologies
ssp126_mid_kgc <- run_kgc("future climatology/temperature/MME_MID_ssp126_MONTHLY_tas_mean.tif", 
                          "future climatology/rainfall/MME_MID_ssp126_MONTHLY_pr_mean.tif", 
                          "results/future_kgc/ssp126_mid_kgc", 
                          "SSP1-2.6 Mid-Century")


ssp245_mid_kgc <- run_kgc("future climatology/temperature/MME_MID_ssp245_MONTHLY_tas_mean.tif", 
                          "future climatology/rainfall/MME_MID_ssp245_MONTHLY_pr_mean.tif", 
                          "results/future_kgc/ssp245_mid_kgc", 
                          "SSP2-4.5 Mid-Century")

ssp370_mid_kgc <- run_kgc("future climatology/temperature/MME_MID_ssp370_MONTHLY_tas_mean.tif", 
                          "future climatology/rainfall/MME_MID_ssp370_MONTHLY_pr_mean.tif", 
                          "results/future_kgc/ssp370_mid_kgc", 
                          "SSP3-7.0 Mid-Century")


ssp585_mid_kgc <- run_kgc("future climatology/temperature/MME_MID_ssp585_MONTHLY_tas_mean.tif", 
                          "future climatology/rainfall/MME_MID_ssp585_MONTHLY_pr_mean.tif", 
                          "results/future_kgc/ssp585_mid_kgc", 
                          "SSP5-8.5 Mid-Century")


ssp126_end_kgc <- run_kgc("future climatology/temperature/MME_END_ssp126_MONTHLY_tas_mean.tif", 
                          "future climatology/rainfall/MME_END_ssp126_MONTHLY_pr_mean.tif", 
                          "results/future_kgc/ssp126_end_kgc", 
                          "SSP1-2.6 End-of-Century")

ssp245_end_kgc <- run_kgc("future climatology/temperature/MME_END_ssp245_MONTHLY_tas_mean.tif", 
                          "future climatology/rainfall/MME_END_ssp245_MONTHLY_pr_mean.tif", 
                          "results/future_kgc/ssp245_end_kgc", 
                          "SSP2-4.5 End-of-Century")

ssp370_end_kgc <- run_kgc("future climatology/temperature/MME_END_ssp370_MONTHLY_tas_mean.tif", 
                          "future climatology/rainfall/MME_END_ssp370_MONTHLY_pr_mean.tif", 
                          "results/future_kgc/ssp370_end_kgc", 
                          "SSP3-7.0 End-of-Century")

ssp585_end_kgc <- run_kgc("future climatology/temperature/MME_END_ssp585_MONTHLY_tas_mean.tif", 
                          "future climatology/rainfall/MME_END_ssp585_MONTHLY_pr_mean.tif", 
                          "results/future_kgc/ssp585_end_kgc", 
                          "SSP5-8.5 End-of-Century")

# reproject 
all_ssp <- list(ssp126_mid_kgc,
                ssp245_mid_kgc, 
                ssp370_mid_kgc, 
                ssp585_mid_kgc,
                ssp126_end_kgc, 
                ssp245_end_kgc, 
                ssp370_end_kgc, 
                ssp585_end_kgc)
lapply(all_ssp, project, "EPSG:4269", method = "near")

# CALCULATE STATS =================================================================
# calculate area of each kg class (statewide)
calc_class_areas <- function(kgc) { 
  areas <- terra::expanse(kgc, unit="km", byValue=TRUE)
  
  key <- kgc_key
  
  out <- data.frame(
    class_code = areas$value,
    area_km_2 = round(areas$area))
  
  out$percent <- round(100 * out$area_km_2 / sum(out$area_km_2), 2)
  
  out
}

all_ssp_stats_statewide <- lapply(all_ssp, calc_class_areas)

# EXPORT ============================================================================= 
openxlsx::write.xlsx(all_ssp_stats_statewide, file = "results/future_kgc/kg_statewide_stats_future.xlsx", overwrite = TRUE)
