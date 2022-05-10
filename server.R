shinyServer(function(input, output, session) {

  uniform_plot <- function(p,ns = 1) {
    p + 
    labs(y = "homicides per 100,000") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 1), 
          legend.position = ifelse(ns <= 15, "bottom", "none"))
  }
  
  # initialize selections
  r <- reactiveValues(
    group = sym("region"),
    df = hom_btsx_gdp
  )

  # update reactive values upon region and tab selected
  observe({
    ifelse(input$tabs == "By Sex", data <- homicides, data <- hom_btsx_gdp)
    if (is.null(input$s_region)) {
      r$group <- sym("region")
      r$df <- data
    } else {
      r$group <- sym("country")
      r$df <- data %>% filter(country %in% input$s_country)
    }
  })
  
  # update country select upon region selected
  observe({
    ranked <- hom_btsx_gdp %>% 
      filter(region %in% input$s_region) %>% 
      group_by(country) %>% 
      summarise(rate = sum(cases)/sum(pop), .groups = "drop") %>% 
      mutate(rank = rank(rate)) %>% 
      arrange(desc(rank)) %>% 
      .$country
    ifelse (input$ck_all, slctd <- ranked, slctd <- ranked[1:8])
    updateSelectInput(session,"s_country",
                      choices = ranked,
                      selected = slctd)
  })
  
  #update region select upon button click
  observeEvent(input$b_clear, {
    updateSelectInput(session, "s_region", selected = character(0))
  })
  
  output$plot_latest <- renderPlot({
    p <- r$df %>% 
      filter(year == MAX_YR) %>% 
      group_by(.data[[r$group]]) %>% 
      summarise(rate = 100*sum(cases)/sum(pop), .groups = "drop") %>% 
      ggplot(aes(reorder(.data[[r$group]], rate), rate)) +
      geom_bar(stat = "identity", fill = COLOR_BLUE, alpha = 2/3) +
      coord_flip() +
      labs(x = NULL,
           title = MAX_YR)
    uniform_plot(p)
  })
  
  output$plot_historical <- renderPlot({
    p <- r$df %>% 
      group_by(.data[[r$group]], year) %>% 
      summarise(rate = 100*sum(cases)/sum(pop), .groups = "drop") %>% 
      ggplot(aes(year, rate)) +
      geom_line(aes(color = reorder(.data[[r$group]], desc(rate)))) +
      labs(x = NULL,
           title = paste(MIN_YR, "to", MAX_YR),
           color = NULL)
    nvars <- n_distinct(r$df[[r$group]])
    uniform_plot(p,nvars)
  })
  
  output$plot_sex <- renderPlot({
    p <- r$df %>% 
      filter(year == MAX_YR) %>% 
      group_by(.data[[r$group]], sex) %>% 
      summarise(rate = 100*sum(cases)/sum(pop), .groups = "drop") %>% 
      ggplot(aes(reorder(.data[[r$group]], desc(rate)), rate)) +
      geom_point(aes(color = sex), size = 4, alpha = 2/3) +
      guides(x = guide_axis(angle = 25)) +
      scale_color_discrete(labels = c("BTSX" = "Both sexes", 
                                      "FMLE" = "Female",
                                      "MLE" = "Male")) +
      labs(x = NULL,
           title = MAX_YR,
           color = NULL) 
    uniform_plot(p)
  })
  
  output$plot_gdp <- renderPlot({
    p <- r$df %>% 
      filter(year == input$s_year, !is.na(gdp_ppp)) %>% 
      group_by(.data[[r$group]]) %>% 
      summarise(gdp_ppp = median(gdp_ppp, na.rm = T),
                pop = sum(pop),
                rate = 100*sum(cases)/pop, .groups = "drop")  %>% 
      ggplot(aes(gdp_ppp, rate)) +
      geom_point(aes(color = .data[[r$group]], size = pop), alpha = 2/3) +
      guides(size = "none") +
      scale_x_continuous(limits = c(250,142e3)) +
      scale_y_continuous(limits = c(0,100)) +
      scale_size_continuous(range = c(1,15)) +
      labs(x = "GDP per capita, PPP, in current international $",
           title = input$s_year,
           color = NULL)
    nvars <- n_distinct(r$df[[r$group]])
    uniform_plot(p,nvars)
  })
  
  output$plot_histogram <- renderPlot({
    hom_btsx_gdp %>% 
      filter(year == MAX_YR) %>% 
      group_by(country) %>% 
      summarise(rate = 100*sum(cases)/sum(pop), .groups = "drop") %>% 
      ggplot(aes(rate)) +
      geom_histogram(binwidth = 4, fill = COLOR_BLUE, alpha = 2/3) +
      labs(x = "homicides per 100,000",
           title = MAX_YR) +
      theme_minimal()
  }) 
  
  output$plot_overall <- renderPlot({
    p <- hom_btsx_gdp %>% 
      group_by(region, country, year) %>% 
      summarise(rate = 100*sum(cases)/sum(pop), .groups = "drop") %>% 
      ggplot(aes(year, rate)) +
      geom_line(aes(group = country), color = "gray") +
      geom_smooth(aes(color = reorder(region, desc(rate))), se = FALSE) +
      labs(title = paste(MIN_YR,"to",MAX_YR),
           color = NULL)
    uniform_plot(p)
  })
  
  output$map_choropleth <- renderLeaflet({
    
    rates <- hom_btsx_gdp %>% 
      filter(year == MAX_YR) %>% 
      group_by(iso3) %>% 
      summarise(rate = round(100*sum(cases)/sum(pop),2)) %>% 
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
                title = paste(MAX_YR, "homicides <br> per 100,000"),
                na.label = "No data",
                opacity = 1)
    
  })
  
})