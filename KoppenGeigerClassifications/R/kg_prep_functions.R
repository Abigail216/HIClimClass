#creates month labels in chosen format, in calendar order
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


#Load 12 monthly rasters into one 12-layer SpatRaster
#data_dir: folder with the data files for one variable (temp or prcp)
#pattern: file name with one %s where the month goes
#prefix: layer name prefix ("P" for precipitation, "T" for temperature)

load_source <- function(data_dir, pattern, month_format, prefix) {
  files <- file.path(data_dir, sprintf(pattern, month_labels(month_format)))
  r <- terra::rast(files)
  names(r) <- paste0(prefix,"_",month.abb)
  r
}

#stack precipitation (layers 1:12) then temperature (layers 13-24) 
#creates input for classify_kg, which relies on this order
stack_prcp_temp <- function(prcp, temp) {
  if (terra::nlyr(prcp) != 12) stop("prcp must have 12 layers")
  if (terra::nlyr(temp) != 12) stop("temp must have 12 layers")
  if (!all(startsWith(names(prcp), "P_"))) stop("prcp layers should be named P_*; check argument order")
  if (!all(startsWith(names(temp), "T_"))) stop("prcp layers should be named T_*; check argument order")
  c(prcp, temp)
}

