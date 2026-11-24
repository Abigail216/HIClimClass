# INFO ===================================================================================
# calculates the % area of each kg class for each future scenario. must be run 
# before SFIG_future_stats_byisland_assembly.

# load required packages ==============================================================
library(terra)
library(macroBiome)
library(sf)
library(exactextractr)
library(tidyverse)
library(openxlsx) 

source("scripts/macroBiome.R")

# SETUP ===========================================================================
islands <- st_read("HI_KGC layers/hawaii_coastline_WGS84_shp/coastline_hawaii_WGS84.shp")

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

# CREATE FUNCTIONS  ====================================================================
# calculate area of each class statewide
calc_class_areas <- function(kgc) { 
  areas <- terra::expanse(kgc, unit="km", byValue=TRUE)

  out <- data.frame(
    class_code = areas$value,
    area_km_2 = round(areas$area))
  
  out$percent <- round(100 * out$area_km_2 / sum(out$area_km_2), 2)
  
  out
}

# calculate area of each class by a polygon within a shp (AKA island within islands)
calc_class_areas_by_poly <- function(shp, raster, ID_column, ID_of_interest){
  poly <- shp %>% 
    dplyr::filter(!!rlang::sym(ID_column) == ID_of_interest)  
  mask <- terra::mask(raster, poly)
  areas <- calc_class_areas(mask)
  out <- areas %>%
    select(class_code, area_km_2, percent)
  
  out 
}

# CALCULATE STATS =================================================================
# calculate area of each kg class (statewide)
all_ssp <- list(ssp126_mid_kgc,
                ssp245_mid_kgc,
                ssp370_mid_kgc,
                ssp585_mid_kgc,
                ssp126_end_kgc,
                ssp245_end_kgc,
                ssp370_end_kgc,
                ssp585_end_kgc
)

all_ssp_stats_statewide <- lapply(all_ssp, calc_class_areas)

kauai <- lapply(all_ssp, calc_class_areas_by_poly, shp = islands, ID_column = "Name", ID_of_interest = "Kauai")
oahu <- lapply(all_ssp, calc_class_areas_by_poly, shp = islands, ID_column = "Name", ID_of_interest = "O'ahu")
molokai <- lapply(all_ssp, calc_class_areas_by_poly, shp = islands, ID_column = "Name", ID_of_interest = "Moloka'i")
maui <- lapply(all_ssp, calc_class_areas_by_poly, shp = islands, ID_column = "Name", ID_of_interest = "Maui")
lanai <- lapply(all_ssp, calc_class_areas_by_poly, shp = islands, ID_column = "Name", ID_of_interest = "Lana'i")
hawaii <- lapply(all_ssp, calc_class_areas_by_poly, shp = islands, ID_column = "Name", ID_of_interest = "Hawai'i")

# EXPORT ============================================================================= 
openxlsx::write.xlsx(all_ssp_stats_statewide, file = "results/future_kgc/kg_stats_future_statewide.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(kauai, file = "results/future_kgc/kg_stats_future_kauai.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(oahu, file = "results/future_kgc/kg_stats_future_oahu.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(molokai, file = "results/future_kgc/kg_stats_future_molokai.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(maui, file = "results/future_kgc/kg_stats_future_maui.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(lanai, file = "results/future_kgc/kg_stats_future_lanai.xlsx", overwrite = TRUE)
openxlsx::write.xlsx(hawaii, file = "results/future_kgc/kg_stats_future_hawaii.xlsx", overwrite = TRUE)
