#--------Setup------------------------------------------------------------------

# load required packages
library(ClimClass)
library(terra)
library(tmap)

#load functions
source("KoppenGeigerClassifications/R/kg_functions.R")


#--------Runs-------------------------------------------------------------------
contemp_prcp_contemp_temp <- run_kg_workflow(prcp_dir = "KoppenGeigerClassifications/data/rainfall/contemporary",
                prcp_pattern = "contemporary_climatology_rainfall_mean_monthly_statewide_%s.tif",
                temp_dir = "KoppenGeigerClassifications/data/temperature/contemporary",
                temp_pattern = "contemporary_climatology_mean_air_temperature_mean_monthly_statewide_%s.tif",
                subtitle = "Contemporary Precipitation  |  Contemporary Air Temperature", 
                file_name = "contemp_prcp_contemp_temp01")


legacy_prcp_legacy_temp <- run_kg_workflow(prcp_dir = "KoppenGeigerClassifications/data/rainfall/legacy",
                prcp_pattern = "legacy_climatology_rainfall_mean_monthly_statewide_%s.tif",
                temp_dir = "KoppenGeigerClassifications/data/temperature/legacy",
                temp_pattern = "legacy_climatology_mean_air_temperature_mean_monthly_statewide_%s.tif",
                subtitle = "Legacy Precipitation  |  Legacy Air Temperature", 
                file_name = "legacy_prcp_legacy_temp01")