#--------DATA LOADING-----------------------------------------------------------

# Creates month labels in chosen format
#
# Inputs: 
#   month_format - month format that appears in desired files

month_labels <- function(month_format) {
  switch(month_format,
         lower     = tolower(month.name),     # january
         title     = month.name,              # January
         abb_lower = tolower(month.abb),      # jan
         abb       = month.abb,               # Jan
         num2      = sprintf("%02d", 1:12),   # 01
         num       = as.character(1:12),      # 1
         stop("Unknown month_format: ", month_format)
  )
}

# Loads 12 monthly rasters for climate variable into one 12-layer SpatRaster
#
# Inputs: 
#   data_dir - Folder with the data files for variable (temp or prcp)
#   pattern - file name with one %s where the month goes
#   prefix - layer name prefix ("P" for precipitation, "T" for temperature)


load_source <- function(data_dir, pattern, month_format, prefix) {
  files <- file.path(data_dir, sprintf(pattern, month_labels(month_format)))
  r <- terra::rast(files)
  names(r) <- paste0(prefix,"_",month.abb)
  r
}


# Stacks precipitation (layers 1:12) and temperature (layers 13:24)
#
# Inputs: 
#   prcp - precipitation SpatRaster
#   temp - temperature SpatRaster


stack_prcp_temp <- function(prcp, temp) {
  if (terra::nlyr(prcp) != 12) stop("prcp must have 12 layers")
  if (terra::nlyr(temp) != 12) stop("temp must have 12 layers")
  if (!all(startsWith(names(prcp), "P_"))) stop("prcp layers should be named P_*; check argument order")
  if (!all(startsWith(names(temp), "T_"))) stop("temp layers should be named T_*; check argument order")
  c(prcp, temp)
}


#--------CLIMATE CLASSIFICATION-------------------------------------------------

# Classifies one cell's climate as a Koppen-Geiger climate zone 
#
# Inputs:
#   kg_inputs - numeric vector of length 24 - precipitation (mm) Jan-Dec,
#     then temperature (C) Jan-Dec, one cell's values from stack_prcp_temp
#
# Note: ClimClass only uses Tm; Tn and Tx are filled with mean temperature as placeholders

classify_kg_cell <- function(kg_inputs) {
  if (any(is.na(kg_inputs))) return(NA)
  df <- data.frame(month = 1:12,
                   P = kg_inputs[1:12], 
                   Tn = kg_inputs[13:24], 
                   Tx = kg_inputs[13:24], 
                   Tm = kg_inputs[13:24])
  ClimClass::koeppen_geiger(df, A_B_C_special_sub.classes = TRUE, clim.resume_verbose = FALSE, class.nr = TRUE)$class
}


# Classifies all cells in a raster as a Koppen-Geiger climate zone 
#
# Inputs:
#   kg_inputs - 24 layer Spatraster from stack_prcp_temp of precipitation (mm) Jan-Dec,  
#     then temperature (C) Jan-Dec

classify_kg <- function(kg_inputs) {
  kg <- terra::app(kg_inputs, classify_kg_cell)
  names(kg) <- "kg_class"
  kg
}


#--------MAPPING----------------------------------------------------------------
clim_classes_key <- data.frame(
  class_code = c(11, 12, 13, 21, 22, 31, 32, 33, 41, 42, 43, 51, 52),
  class_name = c("Af", "Aw", "Am", "BW", "BS", "Cs", "Cw", "Cf", "Ds", "Dw", "Df", "ET", "EF")
)
map_kg_zones <- function(kg, subtitle){
  
  levels(kg) <- clim_classes_key
  
  kg_colors <- c("#9ECAE1",  # Af
                 "#4292C6",  # Aw
                 "#08519C",  # Am
                 "#D9B44A",  # BW
                 "#F6E8A6",  # BS
                 "#FCC5C0",  # Cs  - temperate: pinks/plum
                 "#F768A1",  # Cw
                 "#AE017E",  # Cf
                 "#C7E9C0",  # Ds  - continental: greens (not present in Hawaii)
                 "#74C476",  # Dw
                 "#238B45",  # Df
                 "#BDBDBD",  # ET 
                 "#636363")  # EF
  
  tm_shape(kg)+
    tm_graticules(n.x = 5, n.y = 5, alpha = 0.6)+
    tm_raster(
      col.scale = tm_scale_categorical(
        values = kg_colors,
        levels = clim_classes_key$class_name,
        levels.drop = TRUE
      ), 
      col.legend = tm_legend(title = "Legend"))+
    tm_title("Koeppen-Geiger Climate Classifications of Hawaii", 
             size = 1.5, position = tm_pos_out("center", "top")) +
    tm_title(subtitle, 
             size = 0.8, position = tm_pos_out("center", "top")) +
    tm_compass(position = tm_pos_in("LEFT", 
                                    "BOTTOM"))
}


#--------AREA CALCULATIONS------------------------------------------------------
calc_class_areas <- function(kg) {
  areas <- terra::expanse(kg, unit="km", byValue=TRUE)
  
  key <- clim_classes_key
  
  out <- data.frame(
    class_code = areas$value,
    class_name = key$class_name[match(areas$value, key$class_code)],
    area_km_2 = round(areas$area))
    
    out$percent <- round(100 * out$area_km_2 / sum(out$area_km_2), 2)
    
    out
}

#--------FULL WORKFLOW----------------------------------------------------------
run_kg_workflow <- function(prcp_dir, prcp_pattern, temp_dir, temp_pattern, subtitle, file_name,
                            output_dir = "KoppenGeigerClassifications/results",
                            save_png = TRUE, save_geotiff = TRUE, calculate_areas = TRUE) {
  
  #load prcp and temperature source
  prcp <- load_source(prcp_dir, prcp_pattern, "lower","P")
  temp <- load_source(temp_dir, temp_pattern , "lower","T")
  
  #classify
  formatted_data <- stack_prcp_temp(prcp, temp)
  kg <- classify_kg(formatted_data)
  
  #map
  kg_map <- map_kg_zones(kg, subtitle)
  print(kg_map)
  
  #create output directory
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  
  #save png
  if (save_png) {
    tmap_save(kg_map, file.path(output_dir, paste0(file_name, ".png")))
  }
  
  #save geotiff
  if (save_geotiff) {
    writeRaster(kg, file.path(output_dir, paste0(file_name, ".tif")), overwrite = TRUE)
  }
  
  if (calculate_areas) {
    areas <- calc_class_areas(kg)
    print(areas)
  }
  
  #return raster
  kg
}

