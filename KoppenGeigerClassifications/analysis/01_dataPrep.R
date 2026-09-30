#load necessary packages
library(terra)
library(ClimClass)
library(tmap)

#load air temp rasters
jan_temp <- rast("KoppenGeigerClassifications/data/dataset1/temperature/contemporary_climatology_mean_air_temperature_mean_monthly_statewide_january.tif")
feb_temp <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_mean_air_temperature_mean_monthly_statewide_february.tif")
mar_temp <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_mean_air_temperature_mean_monthly_statewide_march.tif")
apr_temp <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_mean_air_temperature_mean_monthly_statewide_april.tif")
may_temp <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_mean_air_temperature_mean_monthly_statewide_may.tif")
jun_temp <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_mean_air_temperature_mean_monthly_statewide_june.tif")
jul_temp <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_mean_air_temperature_mean_monthly_statewide_july.tif")
aug_temp <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_mean_air_temperature_mean_monthly_statewide_august.tif")
sep_temp <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_mean_air_temperature_mean_monthly_statewide_september.tif")
oct_temp <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_mean_air_temperature_mean_monthly_statewide_october.tif")
nov_temp <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_mean_air_temperature_mean_monthly_statewide_november.tif")
dec_temp <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_mean_air_temperature_mean_monthly_statewide_december.tif")

#stack air temp rasters
air_temp_stack <- c(jan_temp, feb_temp, mar_temp, apr_temp, may_temp, jun_temp, jul_temp, aug_temp, sep_temp, oct_temp, nov_temp, dec_temp)
air_temp_stack

#load precipitation rasters
jan_rain <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_rainfall_mean_monthly_statewide_january.tif")
feb_rain <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_rainfall_mean_monthly_statewide_february.tif")
mar_rain <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_rainfall_mean_monthly_statewide_march.tif")
apr_rain <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_rainfall_mean_monthly_statewide_april.tif")
may_rain <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_rainfall_mean_monthly_statewide_may.tif")
jun_rain <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_rainfall_mean_monthly_statewide_june.tif")
jul_rain <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_rainfall_mean_monthly_statewide_july.tif")
aug_rain <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_rainfall_mean_monthly_statewide_august.tif")
sep_rain <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_rainfall_mean_monthly_statewide_september.tif")
oct_rain <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_rainfall_mean_monthly_statewide_october.tif")
nov_rain <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_rainfall_mean_monthly_statewide_november.tif")
dec_rain <- rast("C:/Users/phill/Desktop/KoppenGeigerClassifications/data/statewide/contemporary_climatology_rainfall_mean_monthly_statewide_december.tif")

prcp_stack <- c(jan_rain, feb_rain, mar_rain, apr_rain, may_rain, jun_rain, jul_rain, aug_rain, sep_rain, oct_rain, nov_rain, dec_rain)

prcp_temp_stack <- c(prcp_stack, air_temp_stack)

classify <- function(x) {
  if (any(is.na(x))) return(NA)
  df <- data.frame(month = 1:12,
                   P = x[1:12], 
                   Tn = x[13:24], 
                   Tx = x[13:24], 
                   Tm = x[13:24])
  koeppen_geiger(df, A_B_C_special_sub.classes = TRUE, clim.resume_verbose = TRUE, class.nr = TRUE)$class
}

test <- spatSample(temp_prcp_stack, size = 1, method = "random", na.rm = TRUE)
x <- as.numeric(test)

x

classify(x)

kg <- app(temp_prcp_stack, classify)

plot(kg)
tmap(kg)

plot(jan_rain)
