library(shiny)
library(ggplot2)
library(dplyr)
library(leaflet)

# Data -----------------------------------------------------
data_country_s  <-  readRDS("data/data_country_s.rds")
data_country <- data_country_s %>% filter(sex == "BTSX")
data_region_s <- data_country_s %>% 
  group_by(region, year, sex) %>% 
  summarise(pop = sum(pop), 
            rate = round(100*sum(cases)/pop,2), 
            gdp_ppp = median(gdp_ppp, na.rm = T), .groups = "drop")


# GADM Maps ------------------------------------------------
# geodata::world(resolution = 5, level=0, path="data")
world_sf <- readRDS("data/gadm36_adm0_r5_pk.rds") %>% 
  terra::vect() %>% 
  sf::st_as_sf() %>% 
  sf::st_transform(crs = "+proj=longlat +datum=WGS84")

# Global ---------------------------------------------------
MAX_YR <- max(data_country_s$year)
MIN_YR <- min(data_country_s$year)
REGIONS <- unique(data_country_s$region)

# Colors ---------------------------------------------------
COLOR_BLUE <- "#428bca"
