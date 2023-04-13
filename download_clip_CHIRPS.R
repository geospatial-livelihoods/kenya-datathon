# Download and clip CHIRPS
# Author: John Mutua

# R options
gc(reset = T); rm(list = ls())
library(pacman)
pacman::p_load(tidyverse,terra,lubridate,R.utils)

# Paths
root <- "/Users/s2255815/Library/CloudStorage/OneDrive-UniversityofEdinburgh/JOWorkshop"

datadir <- paste0(root, "/Data")
outdir <- paste0(root, "/Data/Climate/Chirps"); dir.create(outdir, F, T)

# Level 1 admin
shp <- gadm(country = "KEN", level=1, path = paste0(datadir, "/Boundaries"), version="latest") %>% sf::st_as_sf()

# Time frame
ini <- as.Date("2018-01-01")
end <- as.Date("2022-12-31")
dts <- seq(from = ini, to = end, by = "day"); rm(ini, end)

# Output directory
tempdir  <- "/Users/s2255815/Downloads/chirps_download"; dir.create(outdir,F,T)

# Main function
getChirps <- function(date = dts){
  # CHIRPS base URL
  #chrps <- 'https://data.chc.ucsb.edu/products/CHIRPS-2.0/global_daily/tifs/p05'
  chrps <- "https://data.chc.ucsb.edu/products/CHIRPS-2.0/africa_daily/tifs/p05"
  # Get day and year
  Day  <- date
  Year <- lubridate::year(Day)
  # Target file
  tfile <- paste0(chrps, "/",Year, "/chirps-v2.0.", gsub("-", ".",Day,fixed=T), ".tif.gz")
  # Destination file
  dfile <- paste0(tempdir, "/",basename(tfile))
  # Raster file
  rfile <- gsub(".gz", "", dfile,fixed = T)
  
  if(!file.exists(paste0(outdir, "/", basename(rfile)))){
    
    # Downloading
    if(!file.exists(dfile)){
      tryCatch(expr = {
        utils::download.file(url = tfile, destfile = dfile)
      },
      error = function(e){
        cat(paste0(basename(tfile), " failed.\n"))
      })
    }
    
    # Unzip and clip to area of interest
    dfile_clipped <- R.utils::gunzip(dfile, skip = TRUE) %>% 
      terra::rast(.) %>% 
      terra::crop(., shp) %>% 
      terra::mask(., shp)
    
    unlink(paste0(tempdir, "/", names(dfile_clipped), ".tif"))
    
    # Write raster
    terra::writeRaster(dfile_clipped, paste0(outdir, "/", names(dfile_clipped), ".tif"), overwrite=TRUE)
    
    return(cat(paste0("File ",basename(rfile), " processed correctly!!!\n")))
  } else {
    return(cat(paste0("File ",basename(rfile), " already exists!\n")))
  }
  
}

# Loop through the dates
#dts %>% purrr::map(.f = getChirps)
for(i in 1:length(dts)){
  getChirps(date=dts[i])
}
