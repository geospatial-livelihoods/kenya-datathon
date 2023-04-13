# Livestock tropical livestock units
# Author: John Mutua
# TLU = Cattle * 0.7 + Sheep * 0.1 + Goat * 0.1 + Chicken * 0.01 + Pig * 0.2 + Horse * 0.8

gc(reset = T); rm(list = ls())
library(pacman)
pacman::p_load(raster,tidyverse,readxl,sf,sp, terra)

# Paths
root <- "/Users/s2255815/Library/CloudStorage/OneDrive-UniversityofEdinburgh/JOWorkshop"
datadir <- paste0(root, "/Data")
outdir <- paste0(root, "/Outputs"); dir.create(outdir, F, T)

grep2 <- Vectorize(FUN = grep, vectorize.args = "pattern", SIMPLIFY = TRUE)

livestock_density_files <- list.files(paste0(datadir, "/Socioeconomic/Livestock_density"), pattern = "*_2010_Da.tif$", full.names = TRUE, recursive = T) %>%
  grep2(pattern = c("cattle","sheep","goats","chicken","pig","horse"), x = ., value = T) %>%
  terra::rast()

livestock_tlu <- terra::app(x = livestock_density_files, fun = function(x){
  x <- as.numeric(x)
  x[which(is.na(x))] <- 0
  y <- 0.7*x[1] + 0.1*x[2] + 0.1*x[3] + 0.01*x[4] + 0.2*x[5] + 0.8*x[6]
  y <- ifelse(y == 0, NA, y)
  return(y)
})

terra::writeRaster(livestock_tlu, paste0(datadir, "/Socioeconomic/Livestock_density/Livestock_tlu.tif"), overwrite=TRUE)