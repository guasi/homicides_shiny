shinyUI(fluidPage(

  titlePanel("WHO Homicide Estimates"),

  sidebarLayout(
    sidebarPanel(
      conditionalPanel(condition = "input.tabs != 'Regional' & input.tabs != 'Map'",
        selectInput("s_region","Region",
                    choices = REGIONS,
                    selected = NULL,
                    multiple = T,
                    selectize = F),
        selectInput("s_country","Country",
                    choices = NULL,
                    selected = NULL,
                    multiple = T,
                    selectize = F),
        checkboxInput("ck_all", "Select all countries", value = F),
        actionButton("b_clear","clear filters", class = "btn-warning btn-sm")
      ),
      conditionalPanel(condition = "input.tabs == 'Regional' | input.tabs == 'Map'",
        p("The historical chart shows homicide rates seem to be declining in all regions except in the Americas, where rates have stayed the same for the last twenty years."),
        p("The density charts differentiate the distribution by region, which can also be seen on the map.")
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
                             min = MIN_YR,
                             max = MAX_YR,
                             value = MIN_YR,
                             sep = "",
                             animate = T))),
        tabPanel("Regional",
                 plotOutput("plot_density"),
                 plotOutput("plot_violin")),
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
