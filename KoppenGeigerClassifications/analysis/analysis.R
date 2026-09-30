#load prcp source and view
prcp <- load_source("rainfall", "contemporary_climatology_rainfall_mean_monthly_statewide_%s.tif", "lower","P")
prcp

#load temp source and view
temp <- load_source("temperature", "contemporary_climatology_mean_air_temperature_mean_monthly_statewide_%s.tif", "lower","T")
temp

#format data for input to ClimClass Koppen Geiger Function
formatted_data <- stack_prcp_temp(prcp, temp)

#apply cell by cell classification function to entire raster dataset
kg <- terra::app(formatted_data, classify_kg_cell)

#simple kg plot
plot(kg)