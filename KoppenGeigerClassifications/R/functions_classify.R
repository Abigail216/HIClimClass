#--------PACKAGES---------------------------------------------------------------
library(terra)
library(tmap)
library(macroBiome)

source("KoppenGeigerClassifications/R/00_keys.R")

#--------MAP STYLE--------------------------------------------------------------
# One place to control how all maps look (used by map_kgc and map_major).
# Change a value here and every map updates the same way.

map_style <- list(
  font_family       = "sans",       # "sans", "serif" or "mono"
  title_size        = 1.4,
  title_face        = "bold",
  subtitle_size     = 1.0,
  subtitle_face     = "italic",
  subtitle_color    = "grey30",
  legend_title_size = 0.9,
  legend_text_size  = 0.75,
  axis_label_size   = 0.65,         # lat/long labels on the graticule
  grid_color        = "grey60",
  grid_alpha        = 0.35,
  width_in          = 10,           # saved PNG size (inches)
  height_in         = 7,
  dpi               = 300
)

# Shared layout added to every map: title + subtitle, legend, light graticule,
# north arrow, scale bar, no outer frame.
#
# Inputs:
#   title        - main title
#   subtitle     - subtitle (scenario name)
#   legend_title - legend heading

map_layout <- function(title, subtitle, legend_title) {
  tm_graticules(n.x = 5, n.y = 5,
                col = map_style$grid_color, alpha = map_style$grid_alpha,
                labels.size = map_style$axis_label_size) +
    tm_title(title,
             size = map_style$title_size, fontface = map_style$title_face,
             position = tm_pos_out("center", "top")) +
    tm_title(subtitle,
             size = map_style$subtitle_size, fontface = map_style$subtitle_face,
             color = map_style$subtitle_color,
             position = tm_pos_out("center", "top")) +
    tm_compass(type = "arrow", size = 2,
               position = tm_pos_in("left", "bottom")) +
    tm_scalebar(breaks = c(0, 50, 100), text.size = 0.6,
                position = tm_pos_in("left", "bottom")) +
    tm_layout(text.fontfamily = map_style$font_family, frame = FALSE)
}

# Shared legend settings
map_legend <- function(legend_title) {
  tm_legend(title = legend_title,
            title.size = map_style$legend_title_size,
            title.fontface = "bold",
            text.size = map_style$legend_text_size,
            position = tm_pos_out("right", "center"),
            frame = FALSE)
}

# Saves a map as PNG at a fixed size so all figures match
save_map <- function(map, file_name) {
  tmap_save(map, paste0(file_name, ".png"),
            width = map_style$width_in, height = map_style$height_in,
            units = "in", dpi = map_style$dpi)
}

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
              col.legend = tm_legend(title = "Climate class"))+
            tm_title("Köppen-Geiger Climate Classification of Hawaii", 
                     size = 1.5, position = tm_pos_out("center", "top")) +
            tm_title(map_subtitle, 
                     size = 0.8, position = tm_pos_out("center", "top")) +
            tm_compass(position = tm_pos_in("RIGHT", 
                                            "TOP"))
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
      col.legend = tm_legend(title = "Major Class"))+
    tm_title("Major Köppen-Geiger Climate Classes of Hawaii", 
             size = 1.5, position = tm_pos_out("center", "top")) +
    tm_title(map_subtitle, 
             size = 0.8, position = tm_pos_out("center", "top")) +
    tm_compass(position = tm_pos_in("RIGHT", 
                                    "TOP"))
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




