Welcome to my first Shiny app! By building it I learned the basics in R. The following are some issues I encountered.

I learned I had to use `.data[[var]]` or `{{var}}` in `tidyverse` when supplying a variable through a character vector or function argument.

For `leaflet` choropleths world maps you need a data object that has the polygon information of each country. There are many ways to get this. I settled for getting an RSD file from GADM using the `geodata` package, reading it in `base` R, transforming it into a `SpatVector` with `terra`, and then into a spatial data frame with `sf` so that it could be joined with my data and interpreted by `leaflet`. You can skip storing and reading the RSD file and instead get the `SpatVector` object directly from GADM every time the application is instantiated. 

To narrow down the country list depending on the region selected, I ended up using `observe` to update the `selectInput` for country, instead of `renderUI` to create a whole new `uiOutput` object.