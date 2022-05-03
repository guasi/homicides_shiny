shinyServer(function(input, output, session) {
  
  latest_yr <- max(homicides$year)
  r <- reactiveValues()
  
  observe({
    ifelse(input$tabs == "Sex", data <- homicides, data <- hom_btsx_gdp)
    if (is.null(input$s_region)) {
      r$group <- "region"
      r$df <- data
    } else {
      r$group <- "country"
      r$df <- data %>% filter(country %in% input$s_country)
    }
  })
  
  observeEvent(input$b_clear, {
    updateSelectInput(session,"s_region",selected = character(0))
  })
  
  output$ui_country <- renderUI({
    ranked <- hom_btsx_gdp %>% 
      filter(region %in% input$s_region) %>% 
      group_by(country) %>% 
      summarise(rate = sum(cases)/sum(pop), .groups = "drop") %>% 
      mutate(rank = rank(rate)) %>% 
      arrange(desc(rank)) %>% 
      .$country
    
      selectInput("s_country","Country",
                  choices = ranked,
                  selected = ranked[1:8],
                  multiple = T)
  })
  
  output$plot_latest <- renderPlot({
    r$df %>% 
      filter(year == latest_yr) %>% 
      group_by(.data[[r$group]]) %>% 
      summarise(rate = 100*sum(cases)/sum(pop), .groups = "drop") %>% 
      ggplot(aes(reorder(.data[[r$group]],rate),rate)) +
      geom_bar(stat="identity", fill = "#7C7BB2") +
      coord_flip() +
      labs(y = "homicides per 100,000",
           x = NULL,
           title = latest_yr) +
      theme_minimal()
  })
  
  output$plot_historical <- renderPlot({
    r$df %>% 
      group_by(year,.data[[r$group]]) %>% 
      summarise(rate = 100*sum(cases)/sum(pop), .groups = "drop") %>% 
      ggplot(aes(year,rate)) +
      geom_line(aes(color = .data[[r$group]])) +
      labs(y = "homicides per 100,000") +
      theme_minimal() 
  })
  
  output$plot_sex <- renderPlot({
    r$df %>% 
      filter(year == latest_yr) %>% 
      group_by(.data[[r$group]],sex) %>% 
      summarise(rate = 100*sum(cases)/sum(pop), .groups = "drop") %>% 
      ggplot(aes(reorder(.data[[r$group]],desc(rate)),rate)) +
      geom_point(aes(color=sex), size = 4) +
      guides(x = guide_axis(angle = 45)) +
      scale_color_discrete(labels = c("BTSX" = "Both sexes", 
                                      "FMLE" = "Female",
                                      "MLE" = "Male")) +
      labs(y = "homicides per 100,000",
           x = NULL,
           title = latest_yr,
           color = NULL) +
      theme_minimal()
  })
  
  output$plot_gdp <- renderPlot({
    ifelse(is.null(input$s_region), lx <- c(0,3.4e4), lx <- c(0, 2e3))
    r$df %>% 
      filter(year == input$s_year) %>% 
      group_by(.data[[r$group]]) %>% 
      summarise(gross = sum(gross, na.rm = T)/1e9,
                pop = sum(pop),
                rate = 100*sum(cases)/pop, .groups = "drop")  %>% 
      ggplot(aes(gross,rate)) +
      geom_point(aes(color = .data[[r$group]], size = pop), alpha = 2/3) +
      guides(size = "none") +
      scale_x_continuous(limits = lx) +
      scale_y_continuous(limits = c(0,100)) +
      scale_size_continuous(range = c(1,15)) +
      labs(y = "homicides per 100,000",
           x = "GDP in billions") +
      theme_minimal()
  })

})
