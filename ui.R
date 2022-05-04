shinyUI(fluidPage(

  titlePanel("WHO Homicide Estimates"),

  sidebarLayout(
    sidebarPanel(
      selectInput("s_region","Region",
                  choices = unique(homicides$region),
                  selected = NULL,
                  multiple = T),
      selectInput("s_country","Country",
                  choices = NULL,
                  selected = NULL,
                  multiple = T),
      p("When region is selected, countries with highest homicide rates in region automatically display. You can add/remove countries to display."),
      
      conditionalPanel(condition = "input.tabs == 'GDP'",
                      sliderInput("s_year","Year",
                                  min = min(homicides$year),
                                  max = max(homicides$year),
                                  value = 2000,
                                  sep = "",
                                  animate = T)),
      actionButton("b_clear","clear filters")
    ),
    
    mainPanel(
      tabsetPanel(id = "tabs",
        tabPanel("Latest",plotOutput("plot_latest")),
        tabPanel("Historical",plotOutput("plot_historical")),
        tabPanel("Sex",plotOutput("plot_sex")),
        tabPanel("GDP",plotOutput("plot_gdp"))
      ),
      HTML("<hr><small>Sources:
        <a href='https://apps.who.int/gho/data/node.imr.VIOLENCE_HOMICIDENUM'>WHO estimates of number of homicides</a>,
        <a href='http://data.un.org/Data.aspx?d=SNAAMA&f=grID:101;currID:USD;pcFlag:0;itID:9&c=2,3,5,6&s=_crEngNameOrderBy:asc,yr:desc&v=1'>UN GDP</a>,
        <a href='https://population.un.org/wpp/Download/Standard/Population/'>UN world population prospects</a>
          </small>"
      )
    )
  )
))
