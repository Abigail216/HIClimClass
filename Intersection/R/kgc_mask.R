library(terra)
library(ggplot2)
library(patchwork)


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


masked_area <- function(kgc_contemp, thorn_contemp, 
                               hold_contemp, kgc_class){
  #create a mask from KGC class of interest
  mask <- kgc_contemp == kgc_class
  mask[!mask] <- NA
  
  #mask holdrige and thornthwaite to KGC class of interest
  thorn_masked <- mask(thorn_contemp, mask)
  hold_masked <- mask(hold_contemp, mask)
  
  df <- zonal(cellSize(kgc_contemp, unit="km"), c(thorn_masked, hold_masked), fun = "sum", wide = FALSE)
  df$kgc <- kgc_class
  
  df
} 


df_list <- lapply(kgc_levels$name, function(k) masked_area(kgc, thorn, hold, k))
df_all <- do.call(rbind, df_list)
  

df_all$kgc <- factor(df_all$kgc, levels = kgc_levels$name)
df_all$class_label <- factor(df_all$class_label,
                             levels = intersect(thorn_levels$class_label, df_all$class_label))
df_all$label <- factor(df_all$label,
                       levels = intersect(hold_levels$label, df_all$label))

kgc_area <- zonal(cellSize(kgc, unit = "km"), kgc, fun = "sum")
names(kgc_area) <- c("kgc", "area")
kgc_area$kgc <- factor(kgc_area$kgc, levels = kgc_levels$name)
kgc_area$lab <- paste0("Total: ", format(round(kgc_area$area), big.mark = ",", trim = TRUE), " km²")


# tallest stacked bar across all panels, so every y-axis uses the same range
# total of each stacked bar (labels on top of bars), and the tallest bar
# so every panel's y-axis uses the same range
bar_totals <- aggregate(area ~ kgc + class_label, data = df_all, FUN = sum)
bar_totals$lab <- scales::label_comma()(round(bar_totals$area))
y_max <- max(bar_totals$area) * 1.1

# one plot per KGC class
plot_panel <- function(k){
  ggplot(df_all[df_all$kgc == k, ], aes(x = class_label, y = area, fill = label)) +
    geom_col(show.legend = TRUE) +
    geom_text(data = bar_totals[bar_totals$kgc == k, ],
              aes(x = class_label, y = area, label = lab),
              inherit.aes = FALSE, angle = 0, hjust = 0.5, vjust = -0.5, size = 3) +
    annotate("text", x = Inf, y = Inf, label = kgc_area$lab[kgc_area$kgc == k],
             hjust = 1.05, vjust = 1.5, size = 3.5) +
    scale_y_continuous(limits = c(0, y_max), labels = scales::label_comma()) +
    scale_fill_discrete(limits = levels(df_all$label)) +   # same colours + legend in every panel
    labs(title = paste("K\u00f6ppen", k),
         x = "Thornthwaite Class",
         y = "Area (square km)",
         fill = "Holdridge Life Zone") +
    theme_minimal() +
    theme(panel.border = element_rect(colour = "grey60", fill = NA),
          plot.title   = element_text(colour = "black",face = "bold", size = 16, hjust = 0.5),
          axis.text.x  = element_text(colour = "black", angle = 90, hjust = 1, vjust = 0.5))
}

p <- wrap_plots(lapply(kgc_levels$name, plot_panel), ncol = 2) +
  plot_layout(guides = "collect") &
  theme(legend.position = "bottom", aspect.ratio = 1/2) &
  guides(fill = guide_legend(ncol = 10, title.position = "top"))

p

ggsave("kgc_intersections.png", p, width = 12, height = 11, bg = "white",
       device = ragg::agg_png)
