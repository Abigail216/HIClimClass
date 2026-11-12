library(terra)


kgc <- rast("Intersection/data/kgc_contemporary_major.tif")
kgc_levels <- data.frame(
  id = c(1, 2, 3, 5), 
  name = c("A", "B", "C", "E")
)
levels(kgc) <- kgc_levels


thorn <- rast("Intersection/data/Contemporary_thornthwaite_classification.tif")
thorn_levels <- read.csv("Intersection/data/classes_lookup.csv")[, c("color_id", "class_label")]
levels(thorn) <- thorn_levels

                         
hold <- rast("Intersection/data/holdridge_contemporary.tif")
hold_levels <- read.csv("Intersection/data/holdridge_lookup.csv")[, c("ID", "label")]
levels(hold) <- hold_levels


masked_stacked_bar <- function(kgc_contemp, thorn_contemp, 
                               hold_contemp, kgc_class){
  #create a mask from KGC class of interest
  mask <- kgc_contemp == kgc_class
  mask[!mask] <- NA
  
  #mask holdrige and thornthwaite to KGC class of interest
  thorn_masked <- mask(thorn_contemp, mask)
  hold_masked <- mask(hold_contemp, mask)
  
  #crosstab maksed thornthwaite and masked holdridge
  ct <- crosstab(c(thorn_masked, hold_masked))
  
  df_long <- as.data.frame(ct)
  
  df_long
  
  ggplot(df_long, aes(x = class_label, y = Freq, fill = label)) +
    geom_col() + # Uses pre-counted values directly
    labs(title = "E Climate intersections",
         x = "Thornthwaite Class",
         y = "Number of Pixels") +
   ylim(0, 4000) +
   theme_minimal()
}



