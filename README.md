# HIClimClass: Köppen-Geiger Climate Classification of Hawaiʻi

The code classifies every grid cell in Hawaiʻi into a
**Köppen-Geiger climate zone** using mean monthly rainfall and mean monthly air temperature
maps. It does this for the **legacy** and **contemporary** climatologies and for **eight future
climate scenarios** (four SSPs, each for mid-century and end of century). It then simplifies the
maps to the five major classes, maps how classes change between scenarios, and calculates area
statistics for the paper's tables and figures.

![Contemporary Köppen-Geiger map](KoppenGeigerClassifications/results/classifications/all/contemporary_kgc.png)

## What the code does

The Köppen-Geiger system groups climates by their yearly cycle of temperature and precipitation.
Examples are tropical rainforest (Af), monsoon (Am), and hot steppe (BSh). The workflow has a
main pipeline of three numbered steps, followed by analysis scripts for the paper.

**Main pipeline**

1. **Classify** (`01_classify.R`). Loads monthly rainfall and temperature as 12-layer rasters
   and classifies them with `macroBiome::cliKoppenGrid()` into the full 3-letter Köppen-Geiger
   classes (for example `Cfb`, `BSh`, `Csa`). Future rasters with 0–360° longitudes are first
   shifted to −180–180°. This is done for all 10 scenarios. Each result is saved as a GeoTIFF
   and a PNG map.
2. **Convert to major classes** (`02_convert.R`). Reduces every 3-letter map to the five major
   classes (A tropical, B dry, C temperate, D continental, E polar) using the first letter of
   each class. Each result is saved as a GeoTIFF and a PNG map.
3. **Map differences** (`03_difference.R`). Restricts all maps to the cells that are classified
   in every scenario. It then calculates which class each cell changes to between scenarios,
   for both the 3-letter and the major classes, and saves transition maps and tables.

**Analysis for the paper**

- **Area statistics** (`calc_area_stats_contemporary.R`, `calc_area_stats_future.R`). Area
  (km² and %) of each class statewide, by island, and by climate division.
- **Table 1** (`T1_assembly.R`). Combines the contemporary statewide and island statistics into
  one table: area (km² and %) of each class for the state and for Kauaʻi, Oʻahu, Molokaʻi,
  Maui, Lānaʻi and Hawaiʻi Island.
- **Figure 3** (`figure3_assembly.R`). Area of each contemporary climate class by elevation
  band.

## Data

The data files are **not stored on GitHub** because they are too large. Get them from the
project's shared OneDrive folder: **HCDP** for the legacy and contemporary data,
**Thrasher_etal_Projections** for the future data, and **GISLayers** for the shapefiles used
by the analysis scripts.

**Legacy and contemporary climatologies.** The file names suggest these come from the Hawaiʻi
Climate Data Portal (HCDP).

| Folder | Variable | Units | File name pattern |
|---|---|---|---|
| `data/rainfall/contemporary/` | Rainfall | mm | `contemporary_climatology_rainfall_mean_monthly_statewide_<month>.tif` |
| `data/rainfall/legacy/` | Rainfall | mm | `legacy_climatology_rainfall_mean_monthly_statewide_<month>.tif` |
| `data/temperature/contemporary/` | Mean air temperature | °C | `contemporary_climatology_mean_air_temperature_mean_monthly_statewide_<month>.tif` |
| `data/temperature/legacy/` | Mean air temperature | °C | `legacy_climatology_mean_air_temperature_mean_monthly_statewide_<month>.tif` |

`<month>` is the lowercase full month name (`january` … `december`).

**Future projections.** These are multi-model ensemble (MME) monthly means from the Thrasher
et al. projections. Each file holds 12 monthly layers.

| Folder | Variable | File name pattern |
|---|---|---|
| `data/rainfall/future/mid/` | Rainfall | `MME_MID_<ssp>_MONTHLY_pr_mean.tif` |
| `data/rainfall/future/end/` | Rainfall | `MME_END_<ssp>_MONTHLY_pr_mean.tif` |
| `data/temperature/future/mid/` | Mean air temperature | `MME_MID_<ssp>_MONTHLY_tas_mean.tif` |
| `data/temperature/future/end/` | Mean air temperature | `MME_END_<ssp>_MONTHLY_tas_mean.tif` |

`<ssp>` is `ssp126`, `ssp245`, `ssp370`, or `ssp585`. **SSP** (Shared Socioeconomic Pathway) is
the standard set of IPCC/CMIP6 future scenarios. The first number is the socioeconomic
storyline (1 = sustainability … 5 = fossil-fueled development). The second is the radiative
forcing in 2100 in W/m²; higher means more warming. **MID** and **END** are mid-century and end
of century.

**GIS layers** (used by the area statistics and Figure 3 scripts).

| Shapefile | Used for |
|---|---|
| `hawaii_coastline_shp/coast_hawaii.shp`, `hawaii_coastline_WGS84_shp/coastline_hawaii_WGS84.shp` | Island boundaries (statistics by island) |
| `HI_ClimateDivisions/ClimDiv12_polygon_clip.shp` | Climate divisions (statistics by division) |
| `elev_contours/elev_bands.shp` | Elevation bands (Figure 3) |

## Repository structure

```
HIClimClass/
├── hawaii_climate_classification.Rproj   # RStudio project (sets working directory to repo root)
├── README.md
├── LICENSE
└── KoppenGeigerClassifications/
    ├── R/
    │   ├── 00_keys.R                        # class codes, names and colors
    │   ├── functions_classify.R             # loading, classification, major classes, maps
    │   ├── functions_difference.R           # class transitions between two maps
    │   ├── 01_classify.R                    # step 1: classify all 10 scenarios
    │   ├── 02_convert.R                     # step 2: convert to major classes
    │   ├── 03_difference.R                  # step 3: transition maps between scenarios
    │   ├── calc_area_stats_contemporary.R   # area stats: statewide, island, climate division
    │   ├── calc_area_stats_future.R         # area stats: future scenarios, statewide
    │   ├── T1_assembly.R                    # Table 1
    │   └── figure3_assembly.R               # Figure 3 (area by elevation band)
    ├── data/                                # not on GitHub (see Data)
    └── results/                             # created by the scripts
        ├── classifications/
        │   ├── all/      # <scenario>_kgc.tif / .png   (3-letter classes)
        │   └── major/    # <scenario>_major.tif / .png (major classes)
        └── difference_maps/
            ├── all/      # transitions between 3-letter classes
            └── major/    # transitions between major classes
```

`<scenario>` is `legacy`, `contemporary`, or `ssp<126|245|370|585>_<mid|end>`.

## Functions

**`R/00_keys.R`** (lookup tables, not functions)

| Object | Contents |
|---|---|
| `all_key` | The 30 Köppen-Geiger classes (codes 1–30, as output by `cliKoppenGrid()`) |
| `major_key` | The 5 major classes (A, B, C, D, E) |
| `kgc_colors`, `major_colors` | Map colors for the 3-letter and major classes |

**`R/functions_classify.R`**

| Function | Purpose |
|---|---|
| `month_labels(month_format)` | Returns the 12 month names in the format used in the file names (`"lower"` → `january`, `"abb"` → `Jan`, `"num2"` → `01`, and others). |
| `load_source(data_dir, pattern, month_format, prefix)` | Reads 12 monthly GeoTIFFs into one 12-layer `SpatRaster`, with layers named `<prefix>_Jan … <prefix>_Dec`. |
| `classify_kgc(temp, prcp, file_name)` | Classifies with `macroBiome::cliKoppenGrid()`, attaches the class names from `all_key`, and saves `<file_name>.tif`. |
| `map_kgc(result, file_name, map_subtitle)` | Draws the 3-letter class map with `tmap` and saves `<file_name>.png`. |
| `run_kgc(temp, prcp, file_name, map_subtitle)` | Full 3-letter workflow for one scenario: load (if given file paths), shift longitudes if needed, classify, map, save. |
| `to_major(x, file_name)` | Reclassifies a 3-letter map (codes 1–30) to major classes (1–5) and saves `<file_name>.tif`. |
| `map_major(x, file_name, map_subtitle)` | Draws the major class map and saves `<file_name>.png`. |
| `run_major(x, file_name, map_subtitle)` | Full major class workflow for one map: convert, map, save. |

**`R/functions_difference.R`**

| Function | Purpose |
|---|---|
| `kgc_transitions(t1, t2, file_name, title, subtitle, key)` | Compares two classification maps cell by cell and records each class change (for example `Af → Am`). Saves a transition map (`.png`, `.tif`) and two tables: `_codes.csv` and `_counts.csv`. Use `key = all_key` for 3-letter classes or `key = major_key` for major classes. |

### Class codes

The 30 Köppen-Geiger classes come from `macroBiome::vegClsNumCodes`:

| Code | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Class | Af | Am | Aw | BWh | BWk | BSh | BSk | Csa | Csb | Csc | Cwa | Cwb | Cwc | Cfa | Cfb |

| Code | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25 | 26 | 27 | 28 | 29 | 30 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Class | Cfc | Dsa | Dsb | Dsc | Dsd | Dwa | Dwb | Dwc | Dwd | Dfa | Dfb | Dfc | Dfd | ET | EF |

The major classes are 1 = A (tropical), 2 = B (dry), 3 = C (temperate), 4 = D (continental),
5 = E (polar). The map legends show only the classes that actually occur in each map.

## R packages used

| Package | What it's used for |
|---|---|
| **terra** | Reading, shifting, masking, reclassifying and writing rasters. |
| **macroBiome** | `cliKoppenGrid()`, which assigns a Köppen-Geiger class to every cell; `vegClsNumCodes` for the class names. |
| **tmap** (v4) | Classification and transition maps, and saving them as PNG (`tmap_save`). |
| **sf** | Reading the island, climate division and elevation band shapefiles. |
| **exactextractr** | Area of each class within each island, climate division or elevation band. |
| **tidyverse** (dplyr, tidyr, ggplot2) | Data handling for the statistics and tables; Figure 3 plot. |
| **openxlsx**, **readxl** | Writing and reading the Excel files of area statistics. |

## How to run

### 1. Install R and the packages

Any R installation works. 

```r
install.packages(c("terra", "tmap", "macroBiome", "sf", "exactextractr",
                   "tidyverse", "openxlsx", "readxl"))
```

To use [pixi](https://pixi.sh) (for example, under WSL/Linux):

```bash
pixi add r-base r-terra r-tmap r-devtools r-tidyverse r-sf r-exactextractr r-openxlsx r-readxl
# macroBiome is not on conda-forge, so install it from CRAN:
pixi run Rscript -e 'install.packages("macroBiome", repos="https://cloud.r-project.org")'
```

`macroBiome` depends on `devtools`, which is why `r-devtools` is installed from conda-forge
first. Building it from CRAN often fails on Linux.

To use plain R or RStudio instead, run:



### 2. Create the output folders (one time)

Git does not store empty folders, so create them before the first run:

```bash
mkdir -p KoppenGeigerClassifications/results/classifications/{all,major}
mkdir -p KoppenGeigerClassifications/results/difference_maps/{all,major}
```

### 3. Run the main pipeline

All paths are relative to the **repository root** (`HIClimClass/`). Run the steps in order;
each one reads the results of the step before.

- **RStudio:** open `hawaii_climate_classification.Rproj`, then source the scripts in order.
- **VS Code or the R console:**

  ```r
  setwd("path/to/HIClimClass")
  source("KoppenGeigerClassifications/R/01_classify.R")
  source("KoppenGeigerClassifications/R/02_convert.R")
  source("KoppenGeigerClassifications/R/03_difference.R")
  ```

- **Terminal (with pixi):**

  ```bash
  cd path/to/HIClimClass
  pixi run --manifest-path path/to/pixi.toml Rscript KoppenGeigerClassifications/R/01_classify.R
  pixi run --manifest-path path/to/pixi.toml Rscript KoppenGeigerClassifications/R/02_convert.R
  pixi run --manifest-path path/to/pixi.toml Rscript KoppenGeigerClassifications/R/03_difference.R
  ```

| Step | Output |
|---|---|
| `01_classify.R` | `results/classifications/all/<scenario>_kgc.tif` / `.png` for all 10 scenarios |
| `02_convert.R` | `results/classifications/major/<scenario>_major.tif` / `.png` |
| `03_difference.R` | Transition maps and `_codes.csv` / `_counts.csv` tables in `results/difference_maps/all/` and `results/difference_maps/major/` |

### 4. Statistics, Table 1 and Figure 3

Run `calc_area_stats_contemporary.R` and `calc_area_stats_future.R` first, then
`T1_assembly.R` (which reads the contemporary statistics) and `figure3_assembly.R`.

These scripts currently use file paths from a different folder layout (`scripts/macroBiome.R`,
`HI_KGC layers/…`, `contemporary_climatology/…`, `results/…`). To run them inside this
repository, change those paths to the repository layout. The functions are now in
`KoppenGeigerClassifications/R/functions_classify.R`, and the GIS layers need to be downloaded
from OneDrive.

| Script | Output |
|---|---|
| `calc_area_stats_contemporary.R` | `kg_island_stats_contemporary.xlsx`, `kg_climdiv_stats_contemporary.xlsx` |
| `calc_area_stats_future.R` | `future_kgc/kg_statewide_stats_future.xlsx` |
| `T1_assembly.R` | `t1_PARTIAL.csv` (Table 1) |
| `figure3_assembly.R` | `fig3_PARTIAL.png` (Figure 3) |

## Notes and limitations

- **Memory.** `01_classify.R` runs 10 classifications in one R session, which uses a lot of
  memory, and R may be stopped with "Killed". On WSL, raise the limit in
  `%USERPROFILE%\.wslconfig` (for example `memory=12GB`) and run `wsl --shutdown`. Or run the
  remaining `run_kgc(...)` calls in a fresh R session after sourcing `functions_classify.R`.
- **"path does not exist".** The `results/` subfolders are missing. Create them (see How to
  run, step 2).
- **`Rplots.pdf`.** When the scripts are run with `Rscript`, the maps they print are also
  written to `Rplots.pdf`. This file can be deleted.
- **Results are generated.** Rerunning the scripts overwrites the files in `results/`. Don't
  commit regenerated results unless you mean to share them.

## Reproducibility check

- 2026-10-23: Full classification workflow rerun successfully on WSL Ubuntu with pixi
  (R 4.5.3). All 10 maps reproduced. The end-of-century runs were done in a separate session
  because of the memory limit.

## License

GPL-3.0. See `LICENSE`.