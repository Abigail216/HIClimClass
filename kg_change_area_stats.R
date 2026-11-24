# INFO   ==========================================================================
# calculating area of change for each scenario

# SETUP  ==========================================================================
# load packages 
library(tidyverse)
library(terra)

# read in files (all are contemporary- that scenario)
ssp1end <- rast("future climatology/KG/contemporary_to_ssp126_end.tif")
ssp1mid <- rast("future climatology/KG/contemporary_to_ssp126_mid.tif")
ssp2end <- rast("future climatology/KG/contemporary_to_ssp245_end.tif")
ssp2mid <- rast("future climatology/KG/contemporary_to_ssp245_mid.tif")
ssp3end <- rast("future climatology/KG/contemporary_to_ssp370_end.tif")
ssp3mid <- rast("future climatology/KG/contemporary_to_ssp370_mid.tif")
ssp5end <- rast("future climatology/KG/contemporary_to_ssp585_end.tif")
ssp5mid <- rast("future climatology/KG/contemporary_to_ssp585_mid.tif")

# CALCULATE % AREAS ================================================================
# area total 
total_area <- terra::expanse(ssp1mid, unit = "km")

# area changed  
calc_area <- function(raster){
  zero_to_NA <- classify(raster, cbind(0, NA))
  areas <- terra::expanse(zero_to_NA, unit = "km")
  areas
  
}

ssp1mid_change <- calc_area(ssp1mid)
ssp1end_change <- calc_area(ssp1end)
ssp2mid_change <- calc_area(ssp2mid)
ssp2end_change <- calc_area(ssp2end)
ssp3mid_change <- calc_area(ssp3mid)
ssp3end_change <- calc_area(ssp3end)
ssp5mid_change <- calc_area(ssp5mid)
ssp5end_change <- calc_area(ssp5end)

stats <- data.frame(
  scenario = c("ssp1mid", "ssp1end", "ssp2mid", "ssp2end", "ssp3mid", "ssp3end", "ssp5mid", "ssp5end"), 
  area_changed_km_2 = c(ssp1mid_change$area, ssp1end_change$area, ssp2mid_change$area, ssp2end_change$area, ssp3mid_change$area, ssp3end_change$area, ssp5mid_change$area, ssp5end_change$area), 
)

# EXPORT   ==========================================================================
write.csv(stats, "results/kg_change_areas_future.csv", row.names = FALSE)
