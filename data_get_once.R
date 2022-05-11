library(ggplot2)
library(dplyr)
library(readr)

# GHO homicide estimates indicator
# https://ghoapi.azureedge.net/api/VIOLENCE_HOMICIDENUM
homicides  <-  
  read_csv("data/original/gho_VIOLENCE_HOMICIDENUM.csv") %>% 
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
  read_csv("data/original/gho_country_codes.csv") %>% 
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
  read_delim("data/original/UNSD_m49.csv",delim=";",
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
  read_csv("data/original/WPP2019_TotalPopulationBySex.csv") %>%
  filter(Variant == "Medium") %>% 
  rename(m49 = LocID,
         year = Time,
         MLE = PopMale,
         FMLE = PopFemale,
         BTSX = PopTotal) %>% 
  tidyr::pivot_longer(cols=c("MLE","FMLE","BTSX"),names_to = "sex",values_to="pop") %>% 
  select(m49,year,sex,pop)
  
# UN GDP per capita, PPP at current international $
# https://data.un.org/Data.aspx?q=gdp&d=WDI&f=Indicator_Code:NY.GDP.PCAP.PP.CD&c=2,4,5&s=Country_Name:asc,Year:desc&v=1
gdp <- 
  read_csv("data/original/UNdata_Export_GDP_PerCap.csv") %>% 
  select(`Country or Area Code`,
         Year,
         Value) %>% 
  rename(iso3 = `Country or Area Code`,
         year = Year,
         gdp_ppp = Value) %>% 
  mutate(sex = "BTSX") %>% 
  select(iso3, year, sex, gdp_ppp)

data_country_s <- homicides %>% 
  left_join(population) %>% 
  left_join(gdp) %>% 
  mutate(rate = round(100*cases/pop,2)) %>% 
  select(iso3, m49, country, region, year, sex, cases, pop, rate, gdp_ppp)

saveRDS(data_country_s,"data/data_country_s.rds")

rm(countries,m49iso3,population,gdp,homicides)