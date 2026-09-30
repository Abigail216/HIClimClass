
month_labels <- function(month_format) {
  switch(month_format,
         lower     = tolower(month.name),     # january
         title     = month.name,              # January
         abb_lower = tolower(month.abb),      # jan
         abb       = month.abb,               # Jan
         num2      = sprintf("%02d", 1:12),   # 01
         num       = as.character(1:12),      # 1
         stop("Unknown month_format: ", month_format)
  )
}


load_source <- function(data_dir, pattern, month_format) {
  files <- file.path(data_dir, sprintf(pattern, month_labels(month_format)))
  r <- rast(files)
  names(r) <- month.abb
  r
}

stack_prcp_temp <- function(prcp, temp) {
  c(prcp, temp)
}

classify_kg <- function(stack_prcp_temp) {
  if (any(is.na(stack_prcp_temp))) return(NA)
  df <- data.frame(month = 1:12,
                   P = stack_prcp_temp[1:12], 
                   Tn = stack_prcp_temp[13:24], 
                   Tx = stack_prcp_temp[13:24], 
                   Tm = stack_prcp_temp[13:24])
  koeppen_geiger(df, A_B_C_special_sub.classes = TRUE, clim.resume_verbose = TRUE, class.nr = TRUE)$class
}


map_kg zones <- function(g, title, legend_title, palette) {
  tm_shape(classify_kg)
}
