library(shiny)
library(ggplot2)
library(corrplot)

shinyUI(fluidPage(
  titlePanel("House Price Analysis Dashboard"),
  
  mainPanel(
    tabsetPanel(
      tabPanel("Overview",
               h3("Project Summary"),
               p("This dashboard analyzes housing prices using various property features such as square footage, number of bedrooms/bathrooms, year built, renovations, and city. It includes visualizations, regression analysis, and prediction tools to explore factors influencing price."),
               plotOutput("boxPlotBedrooms"),
               plotOutput("avgPriceCity")
      ),
      
      tabPanel("Scatter Plots",
               plotOutput("scatterLiving"),
               plotOutput("scatterLot")
      ),
      tabPanel("Condition & Correlation",
               plotOutput("conditionPlot"),
               plotOutput("corrPlot")
      ),
      tabPanel("Regression",
               plotOutput("livingReg"),
               verbatimTextOutput("modelSummary")
      ),
      tabPanel("Diagnostics",
               plotOutput("residPlot"),
               plotOutput("histPlot")
      ),
      tabPanel("Prediction",
               sidebarLayout(
                 sidebarPanel(
                   selectInput("city", "City:", choices = NULL),
                   numericInput("sqft_living", "Sqft Living:", value = 2000, min = 100, max = 10000),
                   numericInput("floors", "Floors:", value = 1),
                   numericInput("bedrooms", "Bedrooms:", value = 3, min = 1, max = 10),
                   numericInput("bathrooms", "Bathrooms:", value = 2, min = 1, max = 10),
                   numericInput("sqft_lot", "Sqft Lot:", value = 5000),
                   numericInput("yr_built", "Year Built:", value = 1990, min = 1900, max = 2025),
                   numericInput("condition", "Condition (1-5):", value = 3, min = 1, max = 5),
                   numericInput("sqft_above", "Sqft Above:", value = 1500),
                   actionButton("predictButton", "Predict Price")
                 ),
                 mainPanel(
                   h4("Predicted Price:"),
                   verbatimTextOutput("predicted_price")
                 )
               )
      )
    )
  )
))
