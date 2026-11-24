# info ==============================================================================
# assembles supplementary table of % area within climate divisions for thornthwaite  
# relies on reading in files generated in the 
# calc_area_stats_contemporaryTHORNTHWAITE R script
# ====================================================================================

# load required packages 

library(tidyverse)
library(readxl)
library(officer)

# read in files 
climdiv_1 <- read_excel("results/thorn_climdiv_stats_contemporary.xlsx", sheet = 1)
climdiv_2 <- read_excel("results/thorn_climdiv_stats_contemporary.xlsx", sheet = 2)
climdiv_3 <- read_excel("results/thorn_climdiv_stats_contemporary.xlsx", sheet = 3)
climdiv_4 <- read_excel("results/thorn_climdiv_stats_contemporary.xlsx", sheet = 4)
climdiv_5 <- read_excel("results/thorn_climdiv_stats_contemporary.xlsx", sheet = 5)
climdiv_6 <- read_excel("results/thorn_climdiv_stats_contemporary.xlsx", sheet = 6)
climdiv_7 <- read_excel("results/thorn_climdiv_stats_contemporary.xlsx", sheet = 7)
climdiv_8 <- read_excel("results/thorn_climdiv_stats_contemporary.xlsx", sheet = 8)
climdiv_9 <- read_excel("results/thorn_climdiv_stats_contemporary.xlsx", sheet = 9)
climdiv_10 <- read_excel("results/thorn_climdiv_stats_contemporary.xlsx", sheet = 10)
climdiv_11 <- read_excel("results/thorn_climdiv_stats_contemporary.xlsx", sheet = 11)
climdiv_12 <- read_excel("results/thorn_climdiv_stats_contemporary.xlsx", sheet = 12)

# writing function 
format_stats <- function(polygon, column) {
  polygon %>% 
    mutate({{ column }} := paste0(area_km_2, " (", percent, ")")) %>% 
    select(class_code, {{ column }})
}

# flow 
climdiv_1 <- format_stats(polygon = climdiv_1, column = "climdiv_1")
climdiv_2 <- format_stats(polygon = climdiv_2, column = "climdiv_2")
climdiv_3 <- format_stats(polygon = climdiv_3, column = "climdiv_3")
climdiv_4 <- format_stats(polygon = climdiv_4, column = "climdiv_4")
climdiv_5 <- format_stats(polygon = climdiv_5, column = "climdiv_5")
climdiv_6 <- format_stats(polygon = climdiv_6, column = "climdiv_6")
climdiv_7 <- format_stats(polygon = climdiv_7, column = "climdiv_7")
climdiv_8 <- format_stats(polygon = climdiv_8, column = "climdiv_8")
climdiv_9 <- format_stats(polygon = climdiv_9, column = "climdiv_9")
climdiv_10 <- format_stats(polygon = climdiv_10, column = "climdiv_10")
climdiv_11 <- format_stats(polygon = climdiv_11, column = "climdiv_11")
climdiv_12 <- format_stats(polygon = climdiv_12, column = "climdiv_12")

# create table 
all_columns <- list(climdiv_1, climdiv_2, climdiv_3, climdiv_4, climdiv_5, climdiv_6, climdiv_7, climdiv_8, climdiv_9, climdiv_10, climdiv_11, climdiv_12)
sfig <- all_columns %>% 
  reduce(left_join, by = "class_code") %>%
  rename("Thornthwaite Climate Class" = "class_code")

# export as a table in word doc with officer package
sfig_doc <- body_add_table(read_docx(), value = (sfig), style = "table_template")
print(sfig_doc, target = "results/SFIG_climdiv_thorn.docx")
