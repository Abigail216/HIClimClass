#Calculate transitions from all classes to all other classes for two maps

kgc_key <- data.frame(
  class_code = 1:30,
  class_name = vegClsNumCodes$Code.KGC[!is.na(vegClsNumCodes$Code.KGC)]
)

kgc_transitions <- function(t1, t2, file_name) {
  compareGeom(t1, t2)
  
  a <- t1; b <- t2
  levels(a) <- NULL; levels(b) <- NULL
  
  transition <- ifel(a == b, 0, a * 100 + b)
  
  transition <- as.int(transition)
  
  values <- sort(unique(values(transition, na.rm=TRUE)))
  
  from <- kgc_key$class_name[match(values %/% 100, kgc_key$class_code)]
  to   <- kgc_key$class_name[match(values %% 100,  kgc_key$class_code)]
  
  levels(transition) <- data.frame(
    value = values,
    transition = ifelse(values ==0, "No Transition", paste(from,  " | ", to)))
  
  map <- tm_shape(transition) +
    tm_raster(col.scale = tm_scale_categorical(n.max = 100),
              col.legend = tm_legend(title = "Transition"))
  
  print(map)
  
  tmap_save(map, paste0(file_name, ".png"))
  
  writeRaster(transition, paste0(file_name, ".tif"), overwrite = TRUE)
  write.csv(cats(transition)[[1]], paste0(file_name, "_codes.csv"), row.names = FALSE)
  write.csv(freq(transition), paste0(file_name, "_counts.csv"), row.names = FALSE)
      
  transition
}
