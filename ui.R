navbarPage("WHO Homicide Estimates",
  theme = shinytheme("cosmo"),
  tabPanel("Interactive Charts", # Interactive Charts tab ----
    fluidPage(
      sidebarLayout(
        sidebarPanel( ## Interactive Charts side -------
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
          )
        ),
        mainPanel( ## Interactive Charts main ---------  
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
                            sep = "", animate = T)))
          )
        )
        ## Interactive Charts end----
      )
    )
  ),
  tabPanel("Regional Charts", # Regional Charts tab ----
    fluidRow(
      column(6, plotOutput("plot_density")),
      column(6, plotOutput("plot_violin"))),
    includeMarkdown("includes/tab_regional_charts.md")
  ),
  tabPanel("World Map", # World Map tab ----
    leafletOutput("map_choropleth")
  ),
  tabPanel("About", # About tab ----
    includeMarkdown("includes/tab_about.md")
  ),
  tags$footer( # footer ----
    HTML("<hr/>
      <p>2022 Ingrid Lagos | Sources:
        <a href='https://apps.who.int/gho/data/node.imr.VIOLENCE_HOMICIDENUM'>WHO homicides estimates</a>,
        <a href='https://data.un.org/Data.aspx?q=gdp&d=WDI&f=Indicator_Code:NY.GDP.PCAP.PP.CD&c=2,4,5&s=Country_Name:asc,Year:desc&v=1'>UN GDP</a>,
        <a href='https://population.un.org/wpp/Download/Standard/Population/'>UN population prospects</a>
        | Code: <a href='https://github.com/guasi/homicides_shiny'>github</a>       
      </p>"
    )
  )
)