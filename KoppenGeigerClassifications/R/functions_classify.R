#--------PACKAGES---------------------------------------------------------------
library(terra)
library(tmap)
library(macroBiome)

source("KoppenGeigerClassifications/R/00_keys.R")

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


#--------------3-LETTER CLASSES-------------------------------------------------
#Classifies monthly temperature and precipitation into 3-letter Koppen Geiger 
# classes (codes 1-30 and saves the .tif)
#
# Inputs:
#   temp - 12-layer monthly temperature raster
#   prcp - 12-layer monthly precipitation raster
#   file_name - output path without extension

classify_kgc <- function (temp, prcp, file_name) {
  result <- cliKoppenGrid(temp, prcp, verbose = FALSE)
  levels(result) <- all_key
  writeRaster(result, paste0(file_name, ".tif"), overwrite = TRUE)
  result
}

# Maps 3-letter classification and saves png
# Inputs: 
#   result - 3 letter classification raster (ouput of classify_kgc)
#   file_name - ouput path without extension
#   map_subtitle - map subtitle

map_kgc <- function (result, file_name, map_subtitle){
 
  map <- tm_shape(result)+
            tm_graticules(n.x = 5, n.y = 5, alpha = 0.6)+
            tm_raster(
              col.scale = tm_scale_categorical(
                values = kgc_colors,
                levels = all_key$class_name,
                levels.drop = TRUE
              ), 
              col.legend = tm_legend(title = "Legend"))+
            tm_title("Koeppen-Geiger Climate Classifications of Hawaii", 
                     size = 1.5, position = tm_pos_out("center", "top")) +
            tm_title(map_subtitle, 
                     size = 0.8, position = tm_pos_out("center", "top")) +
            tm_compass(position = tm_pos_in("LEFT", 
                                            "BOTTOM"))
  tmap_save(map, paste0(file_name, ".png"))
  print(map)
}

#--------RUN KGC---------------------------------------------------------------
# Runs the full 3 letter workflow: classifies, saves .tif map, saves .png map
#
# Inputs: 
    # temp - 12-layer monthly temperature raster
    # prcp - 12-layer monthly precip raster
    #file name - output path without extension
    # map_subtitle - map subtitle

run_kgc <- 
  function (temp, prcp, file_name, map_subtitle) {
    if(is.character(temp)) temp <- rast(temp)
    if(is.character(prcp)) prcp <- rast(prcp)
    if(xmin(temp) > 180) temp <- shift(temp, dx = -360)
    if(xmin(prcp) > 180) prcp <- shift(prcp, dx = -360)
    result <- classify_kgc(temp, prcp, file_name)
    map_kgc(result, file_name, map_subtitle)
    result
  }


#-------------------------MAJOR CLASSES-----------------------------------------
# Converts a 3-letter Koppen Geiger map (codes 1-30) to major classes (1-5)
# using the first letter of each class name
#
# Inputs: 
#   x - classification raster with codes from full_key

to_major <- function(x, file_name) {
  first_letter <- substr(all_key$class_name, 1, 1)
  major_code <- match(first_letter, major_key$class_name)
  reclass_scheme <- cbind(all_key$class_code, major_code)
  
  levels(x) <- NULL
  result <- classify(x, reclass_scheme)
  levels(result) <- major_key
  writeRaster(result, paste0(file_name, ".tif"), overwrite = TRUE)
  result
}

#Maps a major-class classification and saves the .png
map_major <- function(x, file_name, map_subtitle) {
  map <- tm_shape(x)+
    tm_graticules(n.x = 5, n.y = 5, alpha = 0.6)+
    tm_raster(
      col.scale = tm_scale_categorical(
        values = major_colors,
        levels = major_key$class_name,
        levels.drop = TRUE
      ), 
      col.legend = tm_legend(title = "Legend"))+
    tm_title("Major Koeppen-Geiger Climate Classes of Hawaii", 
             size = 1.5, position = tm_pos_out("center", "top")) +
    tm_title(map_subtitle, 
             size = 0.8, position = tm_pos_out("center", "top")) +
    tm_compass(position = tm_pos_in("LEFT", 
                                    "BOTTOM"))
  tmap_save(map, paste0(file_name, ".png"))
  print(map)
}
  
# Runs the full major class-class workflow: convert, save .tif map, save .png
#
# Inputs: 
    # x - 3-letter clasification raster
    # file_name - ouput path without extension
    # map_subtitle - map subtitle
  
run_major <- function(x, file_name, map_subtitle){
  result <- to_major(x, file_name)
  map_major(result, file_name, map_subtitle)
  result
}




