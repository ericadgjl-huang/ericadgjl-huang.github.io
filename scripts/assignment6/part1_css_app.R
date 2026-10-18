# Assignment 6 · Part 1b(i) — custom fonts with CSS
# Based on the class sample app 04_mpg

library(shiny)
library(datasets)

mpgData <- mtcars
mpgData$am <- factor(mpgData$am, labels = c("Automatic", "Manual"))

ui <- fluidPage(

  # ---- NEW: CSS style block --------------------------------------------
  # Each rule lists several fonts and ends with a generic family,
  # in case a visitor's computer does not have the first choice.
  tags$head(tags$style(HTML("
    body {
      background-color: white;
      color: black;
      font-family: 'Segoe UI', 'Helvetica Neue', Arial, sans-serif;
    }
    h1, h2, h3 {
      font-family: Georgia, 'Times New Roman', serif;
    }
    .shiny-input-container {
      color: #000000;
    }
  "))),
  # ------------------------------------------------------------------------

  titlePanel("Miles Per Gallon (CSS fonts)"),

  sidebarLayout(
    sidebarPanel(
      selectInput("variable", "Variable:",
                  c("Cylinders" = "cyl",
                    "Transmission" = "am",
                    "Gears" = "gear")),
      checkboxInput("outliers", "Show outliers", TRUE)
    ),
    mainPanel(
      h3(textOutput("caption")),
      plotOutput("mpgPlot")
    )
  )
)

server <- function(input, output) {

  formulaText <- reactive({
    paste("mpg ~", input$variable)
  })

  output$caption <- renderText({
    formulaText()
  })

  output$mpgPlot <- renderPlot({
    boxplot(as.formula(formulaText()),
            data = mpgData,
            outline = input$outliers,
            col = "#75AADB", pch = 19)
  })
}

shinyApp(ui, server)
