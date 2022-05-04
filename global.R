library(shiny)
library(tidyverse)

# GHO homicide estimates indicator
homicides <- read_csv("data/gho_VIOLENCE_HOMICIDENUM.csv")
homicides  <-  homicides %>% 
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
countries <- read_csv("data/gho_country_codes.csv")
countries <- countries %>% 
  select(ISO,
         DisplayString,
         WHO_REGION) %>% 
  rename(iso3 = ISO,
         country = DisplayString,
         region = WHO_REGION)

homicides <- homicides %>% 
  left_join(countries)

# UN m49 and iso3 codes
m49iso3 <- read_delim("data/UNSD_m49.csv",delim=";",
                        col_type = list(`M49 Code` = col_number()))
m49iso3 <- m49iso3 %>% 
  select(`ISO-alpha3 Code`,
         `M49 Code`) %>% 
  rename(iso3 = `ISO-alpha3 Code`,
         m49 = `M49 Code`)

homicides <- homicides %>% 
  left_join(m49iso3)

# UN population numbers
population <- read_csv("data/WPP2019_TotalPopulationBySex.csv")
population <- population %>%
  filter(Variant == "Medium") %>% 
  rename(m49 = LocID,
         year = Time,
         MLE = PopMale,
         FMLE = PopFemale,
         BTSX = PopTotal) %>% 
  pivot_longer(cols=c("MLE","FMLE","BTSX"),names_to = "sex",values_to="pop") %>% 
  select(m49,year,sex,pop)
  
# UN GDP at current prices in dollars
gdp <- read_csv("data/UNdata_Export_GDP.csv")
gdp <- gdp %>% 
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

rm(countries,m49iso3,population,gdp)