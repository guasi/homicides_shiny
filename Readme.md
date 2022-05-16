Welcome to my first Shiny app! I built it to learn the basics in R. 

This site uses World Health Organization [data on homicide estimates](https://ghoapi.azureedge.net/api/VIOLENCE_HOMICIDENUM) worldwide and United Nations [population](https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard)/CSV_FILES/WPP2019_TotalPopulationBySex.csv) and [GDP](https://data.un.org/Data.aspx?q=gdp&d=WDI&f=Indicator_Code:NY.GDP.PCAP.PP.CD&c=2,4,5&s=Country_Name:asc,Year:desc&v=1) data.

The `leaflet` choropleths world maps use [GADM](https://gadm.org/) rsd polygon files obtained with the `geodata` package, transformed into a `SpatVector` with `terra` and into a spatial data frame with `sf`. 

View at [ilagos.shinyapps.io/homicides_shiny/](https://ilagos.shinyapps.io/homicides_shiny/)
