# Changing Climate Zones in Hawaii
## Köppen-Geiger Climate Classification of Hawaiʻi

Project for **Applied Climatology**. The code classifies every grid cell in Hawaiʻi into a
**Köppen-Geiger climate zone**, using statewide maps of mean monthly rainfall and mean monthly
air temperature, and then maps the result.
 
## What the code does
 
The Köppen-Geiger system groups climates by their yearly cycle of temperature and precipitation.
Examples are tropical rainforest (Af), monsoon (Am), and arid steppe (BSh). This project applies
the system pixel by pixel across the Hawaiian Islands:
 
1. **Load the data.** Twelve monthly rainfall rasters and twelve monthly temperature rasters are
   each stacked into a 12-layer raster. Layers are named `P_Jan … P_Dec` for rainfall and
   `T_Jan … T_Dec` for temperature.
2. **Combine.** The two stacks are joined into a 24-layer raster: rainfall (layers 1–12),
   then temperature (layers 13–24).
3. **Classify.** For each cell, the 24 values are passed to `ClimClass::koeppen_geiger()`,
   which returns a numeric Köppen-Geiger class code. Cells with any missing month, such as
   ocean cells, become `NA`.
4. **Map.** The classified raster is plotted.
## Data
 
Statewide mean monthly climatology rasters (GeoTIFF, WGS84 / EPSG:4326, about 250 m grid):
 
| Variable | Units | File name pattern |
|---|---|---|
| Rainfall | mm | `contemporary_climatology_rainfall_mean_monthly_statewide_<month>.tif` |
| Mean air temperature | °C | `contemporary_climatology_mean_air_temperature_mean_monthly_statewide_<month>.tif` |
 
The data appear to come from the Hawaiʻi Climate Data Portal (HCDP).
 
The data are stored zipped in `KoppenGeigerClassifications/data/Dataset1/`. Unzip them before
running the code (see **How to run**).
 
## Repository structure
 
```
KoppenGeigerClassifications/
├── R/
│   ├── kg_prep_functions.R            # loading and stacking the monthly rasters
│   ├── kg_classification_functions.R  # Köppen-Geiger classification
│   └── kg_mapping_functions.R         # mapping
├── analysis/
│   ├── analysis.R                     # main workflow (run this)
│   └── original.R                     # first version with hard-coded Windows paths (kept for reference)
└── data/
    └── Dataset1/
        ├── rainfall.zip
        └── temperature.zip
```
 
## Functions
 
| Function | File | Purpose |
|---|---|---|
| `month_labels(month_format)` | `kg_prep_functions.R` | Returns the 12 month names in a chosen format (`"lower"` → `january`, `"abb"` → `Jan`, `"num2"` → `01`, and others). |
| `load_source(data_dir, pattern, month_format, prefix)` | `kg_prep_functions.R` | Reads 12 monthly GeoTIFFs from `data_dir` into one 12-layer `SpatRaster`, with layers named `<prefix>_Jan … <prefix>_Dec`. |
| `stack_prcp_temp(prcp, temp)` | `kg_prep_functions.R` | Checks that both inputs have 12 correctly named layers, then stacks rainfall followed by temperature. |
| `classify_kg_cell(kg_inputs)` | `kg_classification_functions.R` | Classifies one cell from its 24 values using `ClimClass::koeppen_geiger()`. Returns `NA` if any value is missing. |
| `classify_kg(kg_inputs, filename, plot)` | `kg_classification_functions.R` | Applies `classify_kg_cell` to every cell with `terra::app()`. It can also save the result to a file and show a quick plot. |
| `map_kg_zones(kg)` | `kg_mapping_functions.R` | Plots the classified raster. |
 
## R packages used
 
| Package | What it's used for |
|---|---|
| **terra** | Reading GeoTIFFs (`rast`), stacking layers (`c`), counting layers (`nlyr`), applying the classification cell by cell (`app`), and plotting. |
| **ClimClass** | `koeppen_geiger()`, which assigns the Köppen-Geiger class from monthly precipitation and temperature. |
| **tmap** | Thematic map making. It is loaded for the mapping step; the current plots use `terra::plot`. |
 
Packages that are useful for development, but not required by the analysis:
 
- **languageserver** gives autocomplete in VS Code.
- **httpgd** shows plots inside VS Code.
- **IRkernel** lets you run R in Jupyter.
## How to run
 
### 1. Set up the environment (one time)
 
This setup uses [pixi](https://pixi.sh) under WSL/Linux:
 
```bash
pixi add r-base r-terra r-tmap r-languageserver r-httpgd
# ClimClass is not on conda-forge, so install it from CRAN:
pixi run Rscript -e 'install.packages("ClimClass", repos="https://cloud.r-project.org")'
```
 
### 2. Unzip the data (one time)
 
From `KoppenGeigerClassifications/`, in R:
 
```r
unzip("data/Dataset1/rainfall.zip",    exdir = "data/Dataset1/rainfall",    junkpaths = TRUE)
unzip("data/Dataset1/temperature.zip", exdir = "data/Dataset1/temperature", junkpaths = TRUE)
```
 
### 3. Run the analysis
 
```r
proj_dir <- "path/to/HIClimClass/KoppenGeigerClassifications"
setwd(file.path(proj_dir, "data/Dataset1"))   # load_source() looks for "rainfall/" and "temperature/" here
 
library(terra); library(tmap); library(ClimClass)
 
source(file.path(proj_dir, "R/kg_prep_functions.R"))
source(file.path(proj_dir, "R/kg_classification_functions.R"))
source(file.path(proj_dir, "R/kg_mapping_functions.R"))
source(file.path(proj_dir, "analysis/analysis.R"))
```
 
The result is stored in the object `kg`, which is a single-layer raster of Köppen-Geiger class
codes. To save it:
 
```r
writeRaster(kg, "kg_hawaii.tif", overwrite = TRUE)
```
 
Classification runs once per land cell, so it can take several minutes.
 
## Notes and limitations
 
- **Temperature input.** `ClimClass::koeppen_geiger()` expects minimum (`Tn`), maximum (`Tx`),
  and mean (`Tm`) temperature, but the Köppen-Geiger calculation only uses the mean. The code
  passes mean temperature into all three columns as placeholders.
- **Output codes.** The output contains numeric class codes, not letters such as "Af".
  Converting the codes to Köppen letters and adding a colored legend is a planned improvement
  to the mapping step.
- **Variable name `kg`.** `analysis.R` creates an object called `kg`. Don't use `kg` for
  anything else, such as a folder path, in the same R session.
- **`analysis.R` doesn't load packages itself.** Load `terra`, `tmap`, and `ClimClass` first,
  or `plot()` will fail.
## License
 
GPL-3.0. See `LICENSE`.