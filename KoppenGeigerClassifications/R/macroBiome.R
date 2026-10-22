#--------PACKAGES---------------------------------------------------------------
library(terra)
library(tmap)
library(macroBiome)

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

#--------Koppen-Geiger Classifications------------------------------------------
kgc_key <- data.frame(
  class_code = 1:30,
  class_name = vegClsNumCodes$Code.KGC[!is.na(vegClsNumCodes$Code.KGC)]
)

classify_kgc <- function (temp, prcp, file_name) {
  result <- cliKoppenGrid(temp, prcp, verbose = FALSE)
  levels(result) <- kgc_key
  writeRaster(result, paste0(file_name, ".tif"), overwrite = TRUE)
  result
}

#--------PRELIMINARY MAP--------------------------------------------------------

map_kgc <- function (result, file_name, map_subtitle){
  kgc_colors <- c("#9ECAE1",  # Af  - tropical: blues
                    "#4292C6",  # Am
                    "#08519C",  # Aw
                    "#8C6D1F",  # BWh - arid: browns/yellows
                    "#D9B44A",  # BWk
                    "#E8C872",  # BSh
                    "#F6E8A6",  # BSk
                    "#FCC5C0",  # Csa - temperate: pinks/plum
                    "#FA9FB5",  # Csb
                    "#F768A1",  # Csc
                    "#DD3497",  # Cwa
                    "#C51B8A",  # Cwb
                    "#AE017E",  # Cwc
                    "#7A0177",  # Cfa
                    "#5C0069",  # Cfb
                    "#49006A",  # Cfc
                    "#E5F5E0",  # Dsa - continental: greens
                    "#C7E9C0",  # Dsb
                    "#A1D99B",  # Dsc
                    "#74C476",  # Dsd
                    "#5DB862",  # Dwa
                    "#41AB5D",  # Dwb
                    "#2E9A4E",  # Dwc
                    "#238B45",  # Dwd
                    "#13773A",  # Dfa
                    "#006D2C",  # Dfb
                    "#005A24",  # Dfc
                    "#00441B",  # Dfd
                    "#BDBDBD",  # ET  - polar: greys
                    "#636363")  # EF
                  
  map <- tm_shape(result)+
            tm_graticules(n.x = 5, n.y = 5, alpha = 0.6)+
            tm_raster(
              col.scale = tm_scale_categorical(
                values = kgc_colors,
                levels = kgc_key$class_name,
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


#--------RUN KGC----------------------------------------------------------------
run_kgc <- 
  function (temp, prcp, file_name, map_subtitle) {
  if(is.character(temp)) temp <- rast(temp)
  if(is.character(prcp)) prcp <- rast(prcp)
  if(xmin(temp) > 180) temp <- shift(temp, dx = -360)
  if(xmin(prcp) > 180) prcp <- shift(prcp, dx = -360)
  result <- classify_kgc(temp, prcp, file_name)
  map_kgc(result, file_name, map_subtitle)
}