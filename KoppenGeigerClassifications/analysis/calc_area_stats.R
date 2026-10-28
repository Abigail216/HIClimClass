# load required packages
library(terra)
library(tmap)
library(macroBiome)
library(sf)
library(exactextractr)

source("scripts/macroBiome.R")

#contemporary climatologies

contemp_temp <- load_source("contemporary_climatology/air_temperature/mean/mean_monthly/statewide",
                            "contemporary_climatology_mean_air_temperature_mean_monthly_statewide_%s.tif", 
                            "lower", "T")
contemp_prcp <- load_source("contemporary_climatology/rain/statewide",
                            "contemporary_climatology_rainfall_mean_monthly_statewide_%s.tif", 
                            "lower", "P")
kg <- run_kgc(contemp_temp, contemp_prcp, "results/contemporary_kgc", "Contemporary Climatologies" )


# calculate statistics 
# climate class areas 
calc_class_areas <- function(kg) { 
  areas <- terra::expanse(kg, unit="km", byValue=TRUE)
  
  key <- kgc_key
  
  out <- data.frame(
    class_code = areas$value,
    class_name = key$class_name[match(areas$value, key$class_code)],
    area_km_2 = round(areas$area))
  
  out$percent <- round(100 * out$area_km_2 / sum(out$area_km_2), 2)
  
  out
}
kg_class_areas <- calc_class_areas(kg)

# calculate areas each island 
st_transform(each_island, "EPSG:4269")
project(kg, "EPSG:4269", method = "near")

specific_polygon <- each_island[each_island$COAST_GEO_ == "2", ]
clipped  <- mask(kg, specific_polygon)
island_2_kg_areas <- calc_class_areas(clipped)

# calc areas each clim div 
climate_divisions <- st_read("HI_KGC layers/HI_ClimateDivisions/ClimDiv12_polygon_clip.shp")
st_crs(climate_divisions)
st_transform(climate_divisions, "EPSG:4269")

specific_polygon <- climate_divisions[climate_divisions$gridcode == "1", ]
clipped  <- mask(kg, specific_polygon)
climdiv_1_kg_areas <- calc_class_areas(clipped)

# to change about this script: 
# turn it into a function so that can run for each polygon
# add elevation stats (have to reclassify dem raster)
# perform these calcs for legacy and future maps

