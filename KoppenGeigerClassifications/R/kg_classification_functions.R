#classify one cell's climate as a Koppen-Geiger climate zone 
# kg_inputs: 24 layer Spatraster from stack_prcp_temp of precipitation (mm) Jan-Dec, 
    #then temperature (C) Jan-Dec, created by stack_prcp_temp
# Returns the numeric KG class code, or NA if any month is missing
# Note: ClimClass only uses Tm; Tn and Tx are filled with mean temperature as placeholders
classify_kg_cell <- function(kg_inputs) {
  if (any(is.na(kg_inputs))) return(NA)
  df <- data.frame(month = 1:12,
                   P = kg_inputs[1:12], 
                   Tn = kg_inputs[13:24], 
                   Tx = kg_inputs[13:24], 
                   Tm = kg_inputs[13:24])
  ClimClass::koeppen_geiger(df, A_B_C_special_sub.classes = TRUE, clim.resume_verbose = FALSE, class.nr = TRUE)$class
}


#classifies all cells in a raster as a Koppen-Geiger climate zone 
#returns raster with all cells classified
# kg_inputs: numeric vector of length 24 - precipitation (mm) Jan-Dec, 
    #then temperature (C) Jan-Dec, created by stack_prcp_temp
#filename: optional path to save the results
#plot: if TRUE, shows quick map of the classes
classify_kg <- function(kg_inputs, filename = "", plot = TRUE) {
  kg <- terra::app(kg_inputs, classify_kg_cell,
                   filename = filename, overwrite = TRUE)
  names(kg) <- "kg_class"
  if (plot) plot(kg)
  kg
}