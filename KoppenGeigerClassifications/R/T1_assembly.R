# # load required packages 
# library(terra)
# library(macroBiome)
# library(sf)
# library(exactextractr)
library(tidyverse)
library(readxl)
# library(openxlsx) 

# read in files 
statewide <- read_excel("results/kg_stats_contemporary.xlsx")
kauai <- read_excel("results/kg_island_stats_contemporary.xlsx", sheet = 1)
oahu <- read_excel("results/kg_island_stats_contemporary.xlsx", sheet = 2)
molokai <- read_excel("results/kg_island_stats_contemporary.xlsx", sheet = 3)
maui <- read_excel("results/kg_island_stats_contemporary.xlsx", sheet = 4)
lanai <- read_excel("results/kg_island_stats_contemporary.xlsx", sheet = 5)
hawaii <- read_excel("results/kg_island_stats_contemporary.xlsx", sheet = 6)

# writing function 
format_stats <- function(polygon, column) {
  polygon %>% 
    mutate({{ column }} := paste0(area_km_2, " (", percent, ")")) %>% 
    select(class_code, {{ column }})
}

# flow 
statewide <- format_stats(polygon = statewide, column = "Statewide")
kauai <- format_stats(polygon = kauai, column = "Kaua'i")
oahu <- format_stats(polygon = oahu, column = "O'ahu")
molokai <- format_stats(polygon = molokai, column = "Moloka'i")
maui <- format_stats(polygon = maui, column = "Maui")
lanai <- format_stats(polygon = lanai, column = "Lana'i")
hawaii <- format_stats(polygon = hawaii, column = "Hawai'i")

# export
all_columns <- list(statewide, kauai, oahu, molokai, maui, lanai, hawaii)

t1 <- all_columns %>% 
  reduce(left_join, by = "class_code")

write.csv(t1, "results/t1_PARTIAL.csv", row.names = FALSE)