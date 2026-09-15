setwd("D:/BDA Project")
library(shiny)
library(tidyverse)
library(randomForest)
library(DT)
library(bslib)

car_data2 <- read.csv("Car_sales_v2.csv")

# ---- Load the pre-trained model ----
rf_model_price <- readRDS("rf_model_price.rds")
car_model_v2 <- readRDS("car_model_v2.rds")

make_choices <- levels(car_model_v2$Car.Make)
fuel_choices <- levels(car_model_v2$Fuel.Type)
color_choices <- levels(car_model_v2$Color)
transmission_choices <- levels(car_model_v2$Transmission)
condition_choices <- levels(car_model_v2$Condition)
accident_choices <- levels(car_model_v2$Accident)

ui <- fluidPage(
  theme = bs_theme(bootswatch = "flatly"),
  titlePanel("Car Price Analysis Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Global Filters"),
      selectInput("filter_make", "Car Make:",
                  choices = c("All", sort(unique(car_data2$Car.Make))),
                  selected = "All"),
      selectInput("filter_condition", "Condition:",
                  choices = c("All", sort(unique(car_data2$Condition))),
                  selected = "All"),
      sliderInput("filter_price_range", "Price Range:",
                  min = floor(min(car_data2$Price)),
                  max = ceiling(max(car_data2$Price)),
                  value = c(floor(min(car_data2$Price)), ceiling(max(car_data2$Price)))),
      hr(),
      textOutput("filtered_count")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Data Explorer",
                 br(),
                 DTOutput("data_table")
        ),
        
        tabPanel("Visualizations",
                 br(),
                 selectInput("plot_type", "Choose a plot:",
                             choices = c("Mileage vs Price (Scatter)" = "scatter",
                                         "Price Distribution (Histogram)" = "histogram",
                                         "Price Outliers (Boxplot)" = "boxplot")),
                 plotOutput("selected_plot")
        ),
        
        tabPanel("Brand Analysis",
                 br(),
                 plotOutput("brand_plot", height = "600px")
        ),
        
        tabPanel("Predict Price",
                 br(),
                 fluidRow(
                   column(4,
                          wellPanel(
                            h4("Car Identity"),
                            selectInput("pred_make", "Car Make:", choices = make_choices),
                            sliderInput("pred_year", "Year:", min = 2010, max = 2023, value = 2020),
                            sliderInput("pred_mileage", "Mileage:", min = 5000, max = 150000, value = 50000)
                          )
                   ),
                   column(4,
                          wellPanel(
                            h4("Specs"),
                            selectInput("pred_fuel", "Fuel Type:", choices = fuel_choices),
                            selectInput("pred_color", "Color:", choices = color_choices),
                            selectInput("pred_transmission", "Transmission:", choices = transmission_choices)
                          )
                   ),
                   column(4,
                          wellPanel(
                            h4("Condition"),
                            selectInput("pred_condition", "Condition:", choices = condition_choices),
                            selectInput("pred_accident", "Accident History:", choices = accident_choices)
                          )
                   )
                 ),
                 hr(),
                 fluidRow(
                   column(12, align = "center",
                          h3("Predicted Price:"),
                          div(style = "font-size: 28px; font-weight: bold; color: #2c3e50;",
                              verbatimTextOutput("prediction_output"))
                   )
                 )
        )
      )
    )
  )
)

server <- function(input, output) {
  
  filtered_data <- reactive({
    data <- car_data2
    
    if (input$filter_make != "All") {
      data <- data %>% filter(Car.Make == input$filter_make)
    }
    
    if (input$filter_condition != "All") {
      data <- data %>% filter(Condition == input$filter_condition)
    }
    
    data <- data %>%
      filter(Price >= input$filter_price_range[1] & Price <= input$filter_price_range[2])
    
    data
  })
  
  output$filtered_count <- renderText({
    paste("Showing", nrow(filtered_data()), "of", nrow(car_data2), "cars")
  })
  
  output$data_table <- renderDT({
    datatable(filtered_data(), options = list(pageLength = 10, scrollX = TRUE))
  })
  
  output$selected_plot <- renderPlot({
    data <- filtered_data()
    if (nrow(data) == 0) return(NULL)
    
    if (input$plot_type == "scatter") {
      ggplot(data, aes(x = Mileage, y = Price, color = Condition)) +
        geom_point(size = 2, alpha = 0.5) +
        labs(title = "Mileage vs Price", x = "Mileage", y = "Price") +
        theme_minimal()
      
    } else if (input$plot_type == "histogram") {
      ggplot(data, aes(x = Price)) +
        geom_histogram(aes(y = after_stat(density)), fill = "skyblue", color = "black", bins = 40) +
        geom_density(alpha = 0.7, fill = "orange") +
        labs(title = "Price Distribution", x = "Price", y = "Density")
      
    } else if (input$plot_type == "boxplot") {
      ggplot(data, aes(x = Price)) +
        geom_boxplot(fill = "skyblue") +
        labs(title = "Price Outliers", x = "Price")
    }
  })
  
  output$brand_plot <- renderPlot({
    car_data2 %>%
      group_by(Car.Make) %>%
      summarise(avg_price = mean(Price)) %>%
      arrange(desc(avg_price)) %>%
      ggplot(aes(x = reorder(Car.Make, avg_price), y = avg_price)) +
      geom_col(fill = "steelblue") +
      coord_flip() +
      labs(title = "Average Price by Car Make", x = "Car Make", y = "Average Price") +
      theme_minimal()
  })
  
  output$prediction_output <- renderPrint({
    new_observation <- data.frame(
      Car.Make = factor(input$pred_make, levels = make_choices),
      Year = input$pred_year,
      Mileage = input$pred_mileage,
      Fuel.Type = factor(input$pred_fuel, levels = fuel_choices),
      Color = factor(input$pred_color, levels = color_choices),
      Transmission = factor(input$pred_transmission, levels = transmission_choices),
      Condition = factor(input$pred_condition, levels = condition_choices),
      Accident = factor(input$pred_accident, levels = accident_choices)
    )
    
    prediction <- predict(rf_model_price, newdata = new_observation)
    cat("$", format(round(prediction, 2), big.mark = ","), sep = "")
  })
  
}

shinyApp(ui = ui, server = server)