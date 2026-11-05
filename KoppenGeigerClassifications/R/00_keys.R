#----------3-letter classes (codes 1-30 as output by cliKoppenGrid)-------------

library(macroBiome)

all_key <- data.frame(
  class_code = 1:30,
  class_name = vegClsNumCodes$Code.KGC[!is.na(vegClsNumCodes$Code.KGC)]
)

#-------------Major Koppen Geiger class codes-----------------------------------

major_key <- data.frame(
  class_code = 1:5,
  class_name = c("A", "B", "C", "D", "E")
)


#--------------Colors for 3-letter classes--------------------------------------
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


#----------------Colors for major classes---------------------------------------
major_colors <- c("#4292C6",  # A - tropical: blue
                  "#D9B44A",  # B - arid: brown/yellow
                  "#C51B8A",  # C - temperate: pink/plum
                  "#41AB5D",  # D - continental: green
                  "#BDBDBD")  # E - polar: grey