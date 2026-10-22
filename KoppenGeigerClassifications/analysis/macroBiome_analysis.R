# load required packages
library(terra)
library(tmap)
library(macroBiome)

source("KoppenGeigerClassifications/R/macroBiome.R")

#legacy climatologies 
legacy_temp <- load_source("KoppenGeigerClassifications/data/temperature/legacy",
                            "legacy_climatology_mean_air_temperature_mean_monthly_statewide_%s.tif", 
                            "lower", "T")
legacy_prcp <- load_source("KoppenGeigerClassifications/data/rainfall/legacy",
                            "legacy_climatology_rainfall_mean_monthly_statewide_%s.tif", 
                            "lower", "P")
run_kgc(legacy_temp, legacy_prcp, "KoppenGeigerClassifications/results/legacy_kgc", "Legacy Climatologies" )

#contemporary climatologies

contemp_temp <- load_source("KoppenGeigerClassifications/data/temperature/contemporary",
                            "contemporary_climatology_mean_air_temperature_mean_monthly_statewide_%s.tif", 
                            "lower", "T")
contemp_prcp <- load_source("KoppenGeigerClassifications/data/rainfall/contemporary",
                            "contemporary_climatology_rainfall_mean_monthly_statewide_%s.tif", 
                            "lower", "P")
run_kgc(contemp_temp, contemp_prcp, "KoppenGeigerClassifications/results/contemporary_kgc", "Contemporary Climatologies" )

#ssp126 mid
run_kgc("KoppenGeigerClassifications/data/temperature/future/mid/MME_MID_ssp126_MONTHLY_tas_mean.tif", 
        "KoppenGeigerClassifications/data/rainfall/future/mid/MME_MID_ssp126_MONTHLY_pr_mean.tif", 
        "KoppenGeigerClassifications/results/ssp126_mid_kgc", 
        "SSP1-2.6 Mid-Century")


#ssp245 mid
run_kgc("KoppenGeigerClassifications/data/temperature/future/mid/MME_MID_ssp245_MONTHLY_tas_mean.tif", 
        "KoppenGeigerClassifications/data/rainfall/future/mid/MME_MID_ssp245_MONTHLY_pr_mean.tif", 
        "KoppenGeigerClassifications/results/ssp245_mid_kgc", 
        "SSP2-4.5 Mid-Century")

#ssp 370 mid
run_kgc("KoppenGeigerClassifications/data/temperature/future/mid/MME_MID_ssp370_MONTHLY_tas_mean.tif", 
        "KoppenGeigerClassifications/data/rainfall/future/mid/MME_MID_ssp370_MONTHLY_pr_mean.tif", 
        "KoppenGeigerClassifications/results/ssp370_mid_kgc", 
        "SSP3-7.0 Mid-Century")


#ssp 585 mid
run_kgc("KoppenGeigerClassifications/data/temperature/future/mid/MME_MID_ssp585_MONTHLY_tas_mean.tif", 
        "KoppenGeigerClassifications/data/rainfall/future/mid/MME_MID_ssp585_MONTHLY_pr_mean.tif", 
        "KoppenGeigerClassifications/results/ssp585_mid_kgc", 
        "SSP5-8.5 Mid-Century")

#ssp126 end
run_kgc("KoppenGeigerClassifications/data/temperature/future/end/MME_END_ssp126_MONTHLY_tas_mean.tif", 
        "KoppenGeigerClassifications/data/rainfall/future/end/MME_END_ssp126_MONTHLY_pr_mean.tif", 
        "KoppenGeigerClassifications/results/ssp126_end_kgc", 
        "SSP1-2.6 End-of-Century")

#ssp 245
run_kgc("KoppenGeigerClassifications/data/temperature/future/end/MME_END_ssp245_MONTHLY_tas_mean.tif", 
        "KoppenGeigerClassifications/data/rainfall/future/end/MME_END_ssp245_MONTHLY_pr_mean.tif", 
        "KoppenGeigerClassifications/results/ssp245_end_kgc", 
        "SSP 2-4.5 End-of-Century")

#ssp 370
run_kgc("KoppenGeigerClassifications/data/temperature/future/end/MME_END_ssp370_MONTHLY_tas_mean.tif", 
        "KoppenGeigerClassifications/data/rainfall/future/end/MME_END_ssp370_MONTHLY_pr_mean.tif", 
        "KoppenGeigerClassifications/results/ssp370_end_kgc", 
        "SSP 3-7.0 End-of-Century")

#ssp 585
run_kgc("KoppenGeigerClassifications/data/temperature/future/end/MME_END_ssp585_MONTHLY_tas_mean.tif", 
        "KoppenGeigerClassifications/data/rainfall/future/end/MME_END_ssp585_MONTHLY_pr_mean.tif", 
        "KoppenGeigerClassifications/results/ssp585_end_kgc", 
        "SSP 5-8.5 End-of-Century")