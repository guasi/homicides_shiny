library(shiny)
library(ggplot2)
library(dplyr)
library(readr)
library(leaflet)

# GHO homicide estimates indicator
# https://ghoapi.azureedge.net/api/VIOLENCE_HOMICIDENUM
homicides  <-  
  read_csv("data/gho_VIOLENCE_HOMICIDENUM.csv") %>% 
  filter(SpatialDimType == "COUNTRY") %>% 
  select(SpatialDim,
         TimeDim,
         Dim1,
         NumericValue) %>% 
  rename(iso3 = SpatialDim,
         year = TimeDim,
         sex = Dim1,
         cases = NumericValue)

# GHO country regions
# https://apps.who.int/gho/data/node.metadata.COUNTRY
countries <- 
  read_csv("data/gho_country_codes.csv") %>% 
  select(ISO,
         DisplayString,
         WHO_REGION) %>% 
  rename(iso3 = ISO,
         country = DisplayString,
         region = WHO_REGION)

homicides <- homicides %>% 
  left_join(countries)

# UN m49 and iso3 
# https://unstats.un.org/unsd/methodology/m49/overview/
m49iso3 <- 
  read_delim("data/UNSD_m49.csv",delim=";",
              col_type = list(`M49 Code` = col_number())) %>% 
  select(`ISO-alpha3 Code`,
         `M49 Code`) %>% 
  rename(iso3 = `ISO-alpha3 Code`,
         m49 = `M49 Code`)

homicides <- homicides %>% 
  left_join(m49iso3)

# UN population numbers
# https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/CSV_FILES/WPP2019_TotalPopulationBySex.csv
population <- 
  read_csv("data/WPP2019_TotalPopulationBySex.csv") %>%
  filter(Variant == "Medium") %>% 
  rename(m49 = LocID,
         year = Time,
         MLE = PopMale,
         FMLE = PopFemale,
         BTSX = PopTotal) %>% 
  tidyr::pivot_longer(cols=c("MLE","FMLE","BTSX"),names_to = "sex",values_to="pop") %>% 
  select(m49,year,sex,pop)
  
# UN GDP at current prices in dollars
# https://data.un.org/Data.aspx?d=SNAAMA&f=grID:101;currID:USD;pcFlag:1;crID%3&c=2,3,5,6&s=_crEngNameOrderBy:asc,yr:desc&v=1
gdp <- 
  read_csv("data/UNdata_Export_GDP.csv") %>% 
  select(`Country or Area Code`,
         Year,
         Value) %>% 
  rename(m49 = `Country or Area Code`,
         year = Year,
         gross = Value) %>%
  mutate(m49 = replace(m49, m49 == 835, 834)) %>% #Map Tanzania Mainland 835 to Tanzania 834
  select(m49, year, gross)

homicides <- homicides %>% 
  left_join(population)

#filter population and homicides by both sexes and add GDP
hom_btsx_gdp <- homicides %>% 
  filter(sex == "BTSX") %>% 
  left_join(gdp)

max_yr <- max(homicides$year)
min_yr <- min(homicides$year)

# GADM map
# geodata::world(resolution = 5, level=0, path="data")
world_sf <- 
  readRDS("data/gadm36_adm0_r5_pk.rds") %>% 
  terra::vect() %>% 
  sf::st_as_sf() %>% 
  sf::st_transform(crs = "+proj=longlat +datum=WGS84")
  
rm(countries,m49iso3,population,gdp)