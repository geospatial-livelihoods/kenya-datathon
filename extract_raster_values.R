# Extract raster statistics by admin unit
# Author: John Mutua

gc(reset = T); rm(list = ls()) 
if (!require("pacman")) install.packages("pacman")
pacman::p_load(geodata, terra, sf, ggplot2, tidyr, dplyr, raster, stringr, readxl, viridis)

# Paths
root <- "/Users/s2255815/Library/CloudStorage/OneDrive-UniversityofEdinburgh/JOWorkshop"
datadir <- paste0(root, "/Data")
outdir <- paste0(root, "/Outputs"); dir.create(outdir, F, T)

# Level 1 admin
shp <- gadm(country = "KEN", level=1, path = paste0(datadir, "/Boundaries"), version="latest") %>% sf::st_as_sf()

# Load rasters
raster_files <- list.files(paste0(datadir), pattern = ".tif$", full.names = TRUE, recursive = TRUE) 

# Loop through rasters
raster_file_stats <- lapply(X = raster_files, FUN = function(raster_file){
  
  # Extract raster name
  ras_extract_name <- sapply(strsplit(raster_file, "/\\s*"), tail, 1)
  
  ras <- terra::rast(raster_file)
  
  # Extract data
  ras_extract <- ras %>% terra::extract(., shp, fun = mean, na.rm = TRUE) %>% rename_with(.cols = 2, ~paste0(ras_extract_name))
  
  return(ras_extract)
   
})

# Combine list of dataframes
raster_extract <- raster_file_stats %>% reduce(full_join, by = "ID")

# Merge the extracted data to the polygons
shp <- shp %>% 
  mutate(ID := seq_len(nrow(.))) %>% 
  left_join(., raster_extract, by = "ID")

# Write extract as shapefile
sf::write_sf(shp, paste0(outdir, "/level2_extract.shp"), overwrite=TRUE)