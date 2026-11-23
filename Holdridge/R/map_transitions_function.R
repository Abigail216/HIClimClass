holdridge_ecozone_transitions <- function(t1, t2, file_name, title, subtitle, key) {
  compareGeom(t1, t2)
  
  a <- t1; b <- t2
  levels(a) <- NULL; levels(b) <- NULL
  
  transition <- ifel(a == b, 0, a * 100 + b)
  transition <- as.int(transition)
  
  values <- sort(unique(values(transition, na.rm=TRUE)))
  
  from <- key[[2]][match(values %/% 100, key[[1]])]
  to   <- key[[2]][match(values %% 100,  key[[1]])]
  
  levels(transition) <- data.frame(
    value = values,
    transition = ifelse(values ==0, "No Transition", paste(from,  " | ", to)))
  
  map <- tm_shape(transition) +
    tm_graticules(n.x = 5, n.y = 5, alpha = 0.6) +
    tm_raster(col.scale = tm_scale_categorical(
      values = c("grey85", hcl.colors(length(values) - 1, "Dark 3")),
      n.max = 100),
      col.legend = tm_legend(title = "Ecozone Transition")) +
    tm_title(title, 
             size = 1.5, position = tm_pos_out("center", "top")) +
    tm_title(subtitle, 
             size = 0.8, position = tm_pos_out("center", "top"))
  
  print(map)
  
  tmap_save(map, paste0(file_name, ".png"))
  
  writeRaster(transition, paste0(file_name, ".tif"), overwrite = TRUE)
  write.csv(cats(transition)[[1]], paste0(file_name, "_codes.csv"), row.names = FALSE)
  write.csv(freq(transition), paste0(file_name, "_counts.csv"), row.names = FALSE)
  
  transition
}