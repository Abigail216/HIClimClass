# info ==============================================================================
# this script assembles table 5 of our paper. 
# relies on reading in files generated in the calc_area_stats_future_HOLDRIDGE R script
# ====================================================================================

# load required packages 

library(tidyverse)
library(readxl)
library(officer)

# read in files 
ssp1mid <- read_excel("results/hold_statewide_stats_future.xlsx", sheet = 1)
ssp2mid <- read_excel("results/hold_statewide_stats_future.xlsx", sheet = 2)
ssp3mid <- read_excel("results/hold_statewide_stats_future.xlsx", sheet = 3)
ssp5mid <- read_excel("results/hold_statewide_stats_future.xlsx", sheet = 4)
ssp1end <- read_excel("results/hold_statewide_stats_future.xlsx", sheet = 5)
ssp2end <- read_excel("results/hold_statewide_stats_future.xlsx", sheet = 6)
ssp3end <- read_excel("results/hold_statewide_stats_future.xlsx", sheet = 7)
ssp5end <- read_excel("results/hold_statewide_stats_future.xlsx", sheet = 8)

# writing function so that the value of area(percent area) is in each cell
format_stats <- function(data, column_name) {
  data %>% 
    mutate({{ column_name }} := paste0(area_km_2, " (", percent, ")")) %>% 
    select(class_name, {{ column_name }})
}

# flow 
ssp1mid <- format_stats(data = ssp1mid, column_name = "SSP1-2.5 Mid-Century")
ssp2mid <- format_stats(data = ssp2mid, column_name = "SSP2-4.5 Mid-Century")
ssp3mid <- format_stats(data = ssp3mid, column_name = "SSP3-7.0 Mid-Century")
ssp5mid <- format_stats(data = ssp5mid, column_name = "SSP5-8.5 Mid-Century")
ssp1end <- format_stats(data = ssp1end, column_name = "SSP1-2.5 End-of-Century")
ssp2end <- format_stats(data = ssp2end, column_name = "SSP2-4.5 End-of-Century")
ssp3end <- format_stats(data = ssp3end, column_name = "SSP3-7.0 End-of-Century")
ssp5end <- format_stats(data = ssp5end, column_name = "SSP5-8.5 End-of-Century")

# create table 
all_columns <- list(ssp1mid, ssp2mid, ssp3mid, ssp5mid, ssp1end, ssp2end, ssp3end, ssp5end)
t5 <- all_columns %>% 
  reduce(left_join, by = "class_name") %>%
  rename("Holdridge Climate Class" = "class_name")

# export as a table in word doc with officer package
t5_doc <- body_add_table(read_docx(), value = (t5), style = "table_template")
print(t5_doc, target = "results/Table_5.docx")
