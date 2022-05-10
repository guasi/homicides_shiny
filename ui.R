shinyUI(fluidPage(

  titlePanel("WHO Homicide Estimates"),

  sidebarLayout(
    sidebarPanel(
      conditionalPanel(condition = "input.tabs != 'Overall' & input.tabs != 'Map'",
        selectInput("s_region","Region",
                    choices = unique(homicides$region),
                    selected = NULL,
                    multiple = T),
        selectInput("s_country","Country",
                    choices = NULL,
                    selected = NULL,
                    multiple = T),
        p("When region is selected, countries with highest homicide rates in region automatically display. You can add/remove countries to display."),
        actionButton("b_clear","clear filters", class = "btn-warning btn-sm pull-right"),
        actionButton("b_all", "all countries", class = "btn-primary btn-sm")
      ),
      conditionalPanel(condition = "input.tabs == 'Overall' | input.tabs == 'Map'",
        p("Homicide rates seem to be lowering in all regions except in the Americas, where rates have stayed the same for the last twenty years. A handfull of countries in the world have extremely high rates.")
      )
    ),
    
    mainPanel(
      tabsetPanel(id = "tabs",
        tabPanel("Latest Year",plotOutput("plot_latest")),
        tabPanel("Historical",plotOutput("plot_historical")),
        tabPanel("By Sex",plotOutput("plot_sex")),
        tabPanel("GDP",
                 plotOutput("plot_gdp"),
                 hr(),
                 div(class = "center-block", style="width:300px", 
                     sliderInput("s_year","Year",
                             min = min(homicides$year),
                             max = max(homicides$year),
                             value = 2000,
                             sep = "",
                             animate = T))),
        tabPanel("Overall",plotOutput("plot_overall")),
        tabPanel("Map",leafletOutput("map_choropleth"))
      ),
      HTML("<hr><small>Sources:
        <a href='https://apps.who.int/gho/data/node.imr.VIOLENCE_HOMICIDENUM'>WHO estimates of number of homicides</a>,
        <a href='https://data.un.org/Data.aspx?q=gdp&d=WDI&f=Indicator_Code:NY.GDP.PCAP.PP.CD&c=2,4,5&s=Country_Name:asc,Year:desc&v=1'>UN GDP</a>,
        <a href='https://population.un.org/wpp/Download/Standard/Population/'>UN world population prospects</a>
          </small>"
      )
    )
  )
))
