# Convert RWI CSV to raster format

gc(reset = T); rm(list = ls())
library(pacman)
pacman::p_load(geodata, dplyr, sf, terra)

# Paths
datadir <- "/Users/s2255815/Library/CloudStorage/OneDrive-UniversityofEdinburgh/JOWorkshop/Data"
outdir <- paste0(datadir, "/Wealth_Information/Chietal_RWI")

# Area of interest
shp <- gadm(country = "KEN", level=1, path = paste0(datadir, "/Boundaries"), version="latest") %>% sf::st_as_sf()

# Reference raster
ref_raster <- terra::rast(paste0(datadir, "/Wealth_Information/Gridded_HDI/hdi_raster_predictions/hdi_raster_predictions.tiff")) %>% 
  crop(., shp) %>% 
  mask(., shp)

# Relative wealth index
rwi <- readr::read_csv(paste0(datadir, "/Wealth_Information/Chietal_RWI/ken_relative_wealth_index.csv"))

# Convert dataframe to simple feature
rwi_pts <- st_as_sf(x = rwi,
                    coords = c("longitude", "latitude"),
                    crs = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

# RWI points to raster
rwi_raster <- terra::rasterize(rwi_pts, ref_raster, fun = mean, field = "rwi")

# Write output
terra::writeRaster(rwi_raster, paste0(outdir, "/ken_relative_wealth_index.tif"), overwrite = T)