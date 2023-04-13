# Bulk clipping rasters
# Author: John Mutua

gc(reset = T); rm(list = ls())
library(pacman)
pacman::p_load(raster,tidyverse,sf,terra,geodata)

# Paths
root <- "/Users/s2255815/Library/CloudStorage/OneDrive-UniversityofEdinburgh/JOWorkshop"

datadir <- paste0(root, "/Data")
outdir <- paste0(root, "/Outputs"); dir.create(outdir, F, T)

# Level 1 admin
shp <- gadm(country = "KEN", level=1, path = paste0(datadir, "/Boundaries"), version="latest") %>% sf::st_as_sf()

# Load all rasters
#rasterList <- list.files(paste0(root), pattern = ".tif$", full.names = TRUE, recursive = T) 
rasterList <- list.files(paste0(root), pattern = "2019.*\\.tif$", full.names = TRUE, recursive = T) 

for (ras in rasterList){
  
  # Extract name of raster for use in writing output
  rasterName <- sapply(strsplit(ras, "/\\s*"), tail, 1)
  
  if (!file.exists(paste0(outdir, "/", rasterName))){
    
    cat("Clipping : ", rasterName, "\n")
    
    ras_clipped <- ras %>% 
      terra::crop(., shp) %>% 
      terra::mask(., shp)
    
    # Write raster
    terra::writeRaster(ras_clipped, paste0(outdir, "/", rasterName), overwrite=TRUE)
    
  }
  
}
