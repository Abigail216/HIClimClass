library(terra)
library(ggplot2)
library(patchwork)
library(pals)


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

hold_lookup <- read.csv("Intersection/data/holdridge_lookup.csv")
pal <- setNames(hold_lookup$Hex, hold_lookup$label)

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
df_all <- df_all[df_all$kgc != "E", ]
  

df_all$kgc <- factor(df_all$kgc, levels = kgc_levels$name)
df_all$class_label <- factor(df_all$class_label,
                             levels = intersect(thorn_levels$class_label, df_all$class_label))
df_all$label <- factor(df_all$label,
                       levels = intersect(hold_levels$label, df_all$label))

kgc_area <- zonal(cellSize(kgc, unit = "km"), kgc, fun = "sum")
names(kgc_area) <- c("kgc", "area")
kgc_area$kgc <- factor(kgc_area$kgc, levels = kgc_levels$name)
kgc_area$lab <- paste0(" ", format(round(kgc_area$area), big.mark = ",", trim = TRUE), " km²")


# tallest stacked bar across all panels, so every y-axis uses the same range
# total of each stacked bar (labels on top of bars), and the tallest bar
# so every panel's y-axis uses the same range
# total of each stacked bar (labels on top of bars)
#total of each stacked bar (labels on top of bars)
bar_totals <- aggregate(area ~ kgc + class_label, data = df_all, FUN = sum)
bar_totals$lab <- scales::label_comma()(round(bar_totals$area))
y_max <- max(bar_totals$area) * 1.1   # shared y range + headroom for in-panel titles


# one plot per KGC class
plot_panel <- function(k, show_y = TRUE, show_x = TRUE){
  ggplot(df_all[df_all$kgc == k, ], aes(x = class_label, y = area, fill = label)) +
    geom_col(width = 0.75, color = "grey30", linewidth = 0.05, show.legend = TRUE) +
    geom_text(data = bar_totals[bar_totals$kgc == k, ],
              aes(x = class_label, y = area, label = lab),
              inherit.aes = FALSE, vjust = -0.5, size = 2.5) +
    # title + total, inside top-left
    annotate("text", x = Inf, y = Inf, label = paste("Köppen", k),
             hjust = 1.1, vjust = 1.4, size = 3.5, fontface = "bold") +
    annotate("text", x = Inf, y = Inf, label = kgc_area$lab[kgc_area$kgc == k],
             hjust = 1.1, vjust = 3.4, size = 2.8, colour = "grey30") +
    scale_y_continuous(limits = c(0, y_max), labels = scales::label_comma(),
                       expand = expansion(mult = c(0, 0))) +
    scale_fill_manual(values = pal, limits = levels(df_all$label)) +   # same colours + legend in every panel
    labs(x = if (show_x) "Thornthwaite Class" else NULL,
         y = if (show_y) "Area (km²)" else NULL,
         fill = "Holdridge Life Zone") +
    theme_classic(base_size = 9) +
    theme(axis.text.x  = element_text(colour = "black", angle = 90, hjust = 0.95,
                                      vjust = 0.35, size = 7.5),
          axis.text.y  = if (show_y) element_text(colour = "black", size = 7.5)
          else element_blank(),
          axis.line    = element_blank(),
          panel.border = element_rect(colour = "black", fill = NA, linewidth = 0.8),
          axis.ticks   = element_line(colour = "black", linewidth = 0.8),
          plot.margin  = margin(4, 8, 4, 8))
}

p <- wrap_plots(list(plot_panel("A"),
                     plot_panel("B", show_y = FALSE),
                     plot_panel("C")),
                ncol = 2) +
  guide_area() +
  plot_layout(guides = "collect") &
  theme(legend.position      = "bottom",
        legend.justification = c(0.5, 0.5),
        legend.title         = element_text(size = 9, hjust = 0.5),
        legend.text          = element_text(size = 7.5),
        legend.background    = element_rect(colour = "black", fill = NA, linewidth = 0.5),
        legend.key.size      = unit(4, "mm")) &
  guides(fill = guide_legend(ncol = 2, title.position = "top"))

p

ggsave("Intersection/results/kgc_intersections.png", p, width = 23, height = 22.5, units = "cm",
       dpi = 600, bg = "white", device = ragg::agg_png)
