library(shiny)
library(ggplot2)
library(dplyr)
library(leaflet)

# Data -----------------------------------------------------
homicides  <-  readRDS("data/homicides.rds")
hom_btsx_gdp <- readRDS("data/hom_btsx_gdp.rds")

# GADM map
# geodata::world(resolution = 5, level=0, path="data")
world_sf <- readRDS("data/gadm36_adm0_r5_pk.rds") %>% 
  terra::vect() %>% 
  sf::st_as_sf() %>% 
  sf::st_transform(crs = "+proj=longlat +datum=WGS84")

# Global --------------------------------------------------
MAX_YR <- max(homicides$year)
MIN_YR <- min(homicides$year)

# Colors --------------------------------------------------
COLOR_BLUE <- "#428bca"
