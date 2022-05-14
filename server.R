shinyServer(function(input, output, session) {

  uniform_plot <- function(p,ns = 1) {
    p + 
    theme_minimal() +
    theme(plot.title = element_text(hjust = 1), 
          legend.position = ifelse(ns <= 15, "bottom", "none"))
  }
  
  # initialize select inputs
  r <- reactiveValues(
    group = sym("region"),
    df = data_region_s
  )

  # update reactive values upon region selected
  observeEvent(c(input$s_region,input$s_country), {
    if (is.null(input$s_region)) {
      r$group <- sym("region")
      r$df <- data_region_s
    } else {
      r$group <- sym("country")
      r$df <- data_country_s %>% filter(country %in% input$s_country) 
    }
  })
    
  # update country select upon region selected
  observe({
    ranked <- data_country %>% 
      filter(year == MAX_YR, region %in% input$s_region) %>% 
      mutate(rank = rank(rate)) %>% 
      arrange(desc(rank)) %>% 
      .$country
    ifelse(input$ck_all, slctd <- ranked, slctd <- ranked[1:8])
    updateSelectInput(session,"s_country",
                      choices = ranked,
                      selected = slctd)
  })
  
  # update region select upon button click
  observeEvent(input$b_clear, {
    updateSelectInput(session, "s_region", selected = character(0))
  })
  
  output$plot_latest <- renderPlot({
    p <- r$df %>% 
      filter(sex == "BTSX", year == MAX_YR) %>% 
      ggplot(aes(reorder(.data[[r$group]], rate), rate)) +
      geom_bar(stat = "identity", fill = COLOR_BLUE, alpha = 2/3) +
      coord_flip() +
      labs(x = NULL, y = LBL_RATE,
           title = MAX_YR)
    uniform_plot(p)
  })
  
  output$plot_historical <- renderPlot({
    p <- r$df %>% 
      filter(sex == "BTSX") %>% 
      ggplot(aes(year, rate)) +
      geom_line(aes(color = reorder(.data[[r$group]], desc(rate)))) +
      labs(x = NULL, y = LBL_RATE, color = NULL,
           title = paste(MIN_YR, "to", MAX_YR))
    nvars <- n_distinct(r$df[[r$group]])
    uniform_plot(p,nvars)
  })
  
  output$plot_sex <- renderPlot({
    p <- r$df %>% 
      filter(year == MAX_YR) %>% 
      ggplot(aes(reorder(.data[[r$group]], desc(rate)), rate)) +
      geom_point(aes(color = sex), size = 4, alpha = 2/3) +
      guides(x = guide_axis(angle = 25)) +
      scale_color_discrete(labels = c("BTSX" = "Both sexes", 
                                      "FMLE" = "Female",
                                      "MLE" = "Male")) +
      labs(x = NULL, y = LBL_RATE, color = NULL,
           title = MAX_YR) 
    uniform_plot(p)
  })
  
  output$plot_gdp <- renderPlot({
    p <- r$df %>% 
      filter(sex == "BTSX", year == input$s_year, !is.na(gdp_ppp)) %>% 
      ggplot(aes(gdp_ppp, rate)) +
      geom_point(aes(color = .data[[r$group]], size = pop), alpha = 2/3) +
      guides(size = "none") +
      scale_x_continuous(limits = c(250,142e3)) +
      scale_y_continuous(limits = c(0,100)) +
      scale_size_continuous(range = c(1,15)) +
      labs(x = LBL_GDP, y = LBL_RATE, color = NULL,
           title = input$s_year)
    nvars <- n_distinct(r$df[[r$group]])
    uniform_plot(p,nvars)
  })
  
  output$plot_density <- renderPlot({
    p <- data_country %>% 
      ggplot(aes(rate, colour = region, fill = region)) + 
      geom_density(alpha = 1/4) +
      labs(x = LBL_RATE, color = NULL, fill = NULL,
           title = paste(MIN_YR,"to",MAX_YR)) 
    uniform_plot(p)
  })
  
  output$plot_violin <- renderPlot({
    p <- data_country %>% 
      ggplot(aes(rate, region)) + 
      geom_violin(alpha = 1/3, fill = COLOR_BLUE, color = COLOR_BLUE) +
      labs(x = LBL_RATE, y = NULL,
           title = paste(MIN_YR,"to",MAX_YR)) 
    uniform_plot(p)
  })
  
  output$map_choropleth <- renderLeaflet({
    rates <- data_country %>% 
      filter(year == MAX_YR) %>% 
      group_by(iso3) %>% 
      select(iso3,rate)
    
    world_sf <- left_join(world_sf, rates, by = c("GID_0" = "iso3"))
    
    bins <- c(0,5,10,20,40,100)
    pal <- colorBin("Oranges", domain = world_sf$rate, bins = bins)
    labels <- 
      sprintf("<strong>%s</strong><br/>rate %g", world_sf$NAME_0, world_sf$rate) %>% 
      lapply(htmltools::HTML)
    
    leaflet(world_sf) %>% 
      setView(-20, 10, zoom = 2) %>% 
      addPolygons(
        fillColor = ~pal(rate),
        weight = .5,
        opacity = 1,
        color = "white",
        fillOpacity = 0.7,
        highlightOptions = highlightOptions(
          color = "#666",
          fillOpacity = 0.7,
          bringToFront = TRUE),
        label = labels,
        labelOptions = labelOptions(
          style = list(padding = "3px 8px"),
          direction = "auto")) %>% 
      addLegend("bottomleft", 
                pal = pal, 
                values = ~rate,
                title = paste0(MAX_YR, "<br/>", LBL_RATE),
                na.label = "No data",
                opacity = 1)
  })
})