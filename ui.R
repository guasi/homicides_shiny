navbarPage("WHO Homicide Estimates",
  theme = shinythemes::shinytheme("cosmo"),
  tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "style.css")),
  collapsible = TRUE,
  tabPanel("Interactive Charts", # Interactive Charts tab ----
    fluidPage(
      sidebarLayout(
        sidebarPanel( ## Interactive Charts side -------
          conditionalPanel(condition = "input.tabs != 'Regional' & input.tabs != 'Map'",
            selectInput("s_region", "Region",
                        choices = REGIONS,
                        selected = NULL,
                        multiple = T,
                        selectize = F),
            selectInput("s_country", "Country",
                        choices = NULL,
                        selected = NULL,
                        multiple = T,
                        selectize = F),
            checkboxInput("ck_all", "Select all countries", value = F),
            actionButton("b_clear", "clear filters", class = "btn-warning btn-sm")
          )
        ),
        mainPanel( ## Interactive Charts main ---------  
          tabsetPanel(id = "tabs",
            tabPanel("Historical", plotOutput("plot_historical")),
            tabPanel("Latest Year", plotOutput("plot_latest")),
            tabPanel("By Sex", plotOutput("plot_sex")),
            tabPanel("GDP", plotOutput("plot_gdp"),
              hr(),
              div(class = "center-block", style="width:300px", 
                sliderInput("s_year", "Year",
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
  tabPanel("Regional Charts",
    fluidRow(
      column(6, plotOutput("plot_density")),
      column(6, plotOutput("plot_violin"))),
    includeMarkdown("includes/tab_regional_charts.md")
  ),
  tabPanel("World Map", leafletOutput("map_choropleth"), class = "loading-spinner"),
  tabPanel("About", includeMarkdown("includes/tab_about.md")),
  tags$footer(includeHTML("includes/footer.html"))
)