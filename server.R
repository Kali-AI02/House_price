library(shiny)
library(dplyr)
library(ggplot2)
library(corrplot)

server <- function(input, output, session) {
  
  clean_data <- read.csv("C:/Users/user/Documents/new_project/traffic/data.csv") %>%
    filter(!is.na(price) & price > 0)
  
  model <- lm(log(price) ~ log(sqft_living) + bedrooms + bathrooms + sqft_lot +
                yr_built + condition + sqft_above + floors + city,
              data = clean_data)
  
  observe({
    updateSelectInput(session, "city", choices = unique(clean_data$city))
  })
  
  output$boxPlotBedrooms <- renderPlot({
    boxplot(price ~ bedrooms, data = clean_data,
            main = "Price by Bedrooms", xlab = "Bedrooms", ylab = "Price",
            col = "lightgreen")
  })
  
  output$avgPriceCity <- renderPlot({
    clean_data %>%
      group_by(city) %>%
      summarise(avg_price = mean(price)) %>%
      top_n(10, avg_price) %>%
      ggplot(aes(x = reorder(city, avg_price), y = avg_price)) +
      geom_col(fill = "#69b3a2") +
      coord_flip() +
      labs(title = "Top 10 Cities by Avg Price", x = "City", y = "Avg Price ($)") +
      theme_minimal()
  })
  
  output$scatterLiving <- renderPlot({
    plot(clean_data$sqft_living, clean_data$price,
         main = "Price vs Sqft Living", xlab = "Sqft Living", ylab = "Price",
         pch = 19, col = "darkblue")
    abline(lm(price ~ sqft_living, data = clean_data), col = "red", lwd = 2)
  })
  
  output$scatterLot <- renderPlot({
    plot(clean_data$sqft_lot, clean_data$price,
         main = "Price vs Sqft Lot", xlab = "Sqft Lot", ylab = "Price",
         pch = 19, col = "green")
    abline(lm(price ~ sqft_lot, data = clean_data), col = "red", lwd = 2)
  })
  
  output$conditionPlot <- renderPlot({
    ggplot(clean_data, aes(x = factor(condition), y = price)) +
      geom_boxplot(fill = "lightcoral") +
      labs(title = "Price by Condition", x = "Condition", y = "Price") +
      theme_minimal()
  })
  
  output$corrPlot <- renderPlot({
    numeric_data <- select_if(clean_data, is.numeric)
    corr_matrix <- cor(numeric_data, use = "complete.obs")
    corrplot(corr_matrix, method = "color", type = "upper", tl.cex = 0.8)
  })
  
  output$livingReg <- renderPlot({
    ggplot(clean_data, aes(x = sqft_living, y = price)) +
      geom_point() +
      geom_smooth(method = "lm", formula = y ~ x, se = FALSE) +
      xlim(0, 9000) + ylim(0, 5000000) +
      labs(title = "Price vs Sqft Living with Regression Line")
  })
  
  output$modelSummary <- renderPrint({
    summary(model)
  })
  
  output$residPlot <- renderPlot({
    plot(fitted(model), resid(model),
         main = "Residuals vs Fitted", xlab = "Fitted Values", ylab = "Residuals",
         pch = 19, col = "blue")
    abline(h = 0, lty = 2, col = "red")
  })
  
  output$histPlot <- renderPlot({
    hist(resid(model), breaks = 10,
         main = "Histogram of Residuals", xlab = "Residuals",
         col = "lightblue", border = "black")
  })
  
  # Respond to the action button click
  observeEvent(input$predictButton, {
    req(input$city)  # Ensure city is selected
    
    new_data <- data.frame(
      sqft_living = input$sqft_living,
      bedrooms = input$bedrooms,
      bathrooms = input$bathrooms,
      sqft_lot = input$sqft_lot,
      yr_built = input$yr_built,
      condition = input$condition,
      sqft_above = input$sqft_above,
      floors = input$floors,
      city = input$city
    )
    
    pred_log <- predict(model, newdata = new_data)
    pred_price <- exp(pred_log)  # Convert log price back to actual price
    
    output$predicted_price <- renderText({
      paste("Predicted Price: $", format(round(pred_price, 2), big.mark = ","))
    })
  })
}
