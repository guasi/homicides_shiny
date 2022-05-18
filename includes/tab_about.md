## Purpose

Welcome to my first Shiny app! 

The single purpose of this app was to learn R, R markdown, and Shiny. It does not add value to the already useful interactive interface the World Health Organization offers in their [Violence Info - Homicide](https://apps.who.int/violence-info/homicide/) app or [SDG Target 16.1| Violence](https://www.who.int/data/gho/data/indicators/indicator-details/GHO/estimates-of-rates-of-homicides-per-100-000-population) visualization page.

It is an exercise in joining [WHO homicide estimates](https://ghoapi.azureedge.net/api/VIOLENCE_HOMICIDENUM), [UN population](https://population.un.org/wpp/Download/Files/1_Indicators%20(Standard\)/CSV_FILES/WPP2019_TotalPopulationBySex.csv) and [UN GDP](https://data.un.org/Data.aspx?q=gdp&d=WDI&f=Indicator_Code:NY.GDP.PCAP.PP.CD&c=2,4,5&s=Country_Name:asc,Year:desc&v=1) data. It's also an exercise in getting a lightweight world polygon geodata file with m49 or iso alpha3 country codes.

## Lessons

As a novice in R, I learned some quirks of the language, like having to use `.data[[var]]` or `{{var}}` in `tidyverse` when supplying a variable through a character vector or function argument.

I learned there are many ways to build contextual dropdown menus in Shiny. After trying out the different options, I chose to use `observeEvent` to update the `selectInput` for country, instead of `renderUI` to create a whole new `uiOutput` object.

For `leaflet` choropleths world maps you need a data object that has the polygon information of each country. There are many ways to get this. I settled for getting an RSD file from [GADM](https://gadm.org) using the `geodata` package, reading it in `base` R, transforming it into a `SpatVector` with `terra`, and then into a spatial data frame with `sf` so that it could be joined with my data and interpreted by `leaflet`.
