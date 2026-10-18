# Assignment 6 · Part 1b(ii) — custom fonts with bslib + thematic
# Based on the class sample app 04_mpg, restyled with my course chart style
# (clean-modern layout, warm burnt-orange accent; see eric_style.R in Assignment 5)

library(shiny)
library(datasets)
library(bslib)

# ---- My colours (same values as eric_style.R) ----------------------------
eric_col <- list(
  accent = "#C8551E",  # burnt orange
  ink    = "#2B2622",  # warm black: titles, labels
  ink2   = "#5E5650",  # secondary text
  muted  = "#8C837C",  # source note
  grid   = "#ECE6E0",  # light warm grey gridlines
  bg     = "#FFFFFF"
)

mpgData <- mtcars
mpgData$am <- factor(mpgData$am, labels = c("Automatic", "Manual"))

# Axis labels for each choice of grouping variable
x_labels <- c(cyl  = "Number of cylinders",
              am   = "Transmission type",
              gear = "Number of forward gears")

ui <- fluidPage(

  # ---- bslib theme: fonts + colours --------------------------------------
  # font_google() downloads Inter the first time and serves it with the app,
  # so every visitor sees the same typeface.
  theme = bs_theme(
    version      = 5,
    bg           = eric_col$bg,
    fg           = eric_col$ink,
    primary      = eric_col$accent,
    base_font    = font_google("Inter", wght = c(400, 600, 700)),
    heading_font = font_google("Inter", wght = c(400, 600, 700)),
    "headings-font-weight" = 700
  ),
  # ------------------------------------------------------------------------

  titlePanel("Miles Per Gallon (bslib fonts)"),

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

  # ---- Make the plots follow the app theme -------------------------------
  # font = "auto" is needed: by default thematic changes the plot colours
  # but leaves the plot font alone.
  thematic::thematic_shiny(
    bg = eric_col$bg, fg = eric_col$ink, accent = eric_col$accent,
    font = "auto"
  )
  # ------------------------------------------------------------------------

  formulaText <- reactive({
    paste("mpg ~", input$variable)
  })

  output$caption <- renderText({
    formulaText()
  })

  output$mpgPlot <- renderPlot({
    f <- as.formula(formulaText())

    # Layout only (colours and font come from thematic)
    op <- par(las = 1, mgp = c(2.6, 0.55, 0), tcl = -0.25,
              mar = c(5.5, 4.5, 3.5, 1.5))
    on.exit(par(op))

    # 1) invisible pass to set up the axes, 2) gridlines, 3) the boxes on top
    boxplot(f, data = mpgData, outline = input$outliers,
            col = NA, border = NA, outpch = NA,
            axes = FALSE, frame = FALSE, xlab = "", ylab = "")
    abline(h = axTicks(2), col = eric_col$grid, lwd = 1)
    boxplot(f, data = mpgData, outline = input$outliers, add = TRUE,
            col = eric_col$accent, border = eric_col$ink2,
            medcol = "white", medlwd = 2.5,
            whisklty = 1, staplewex = 0.4, pch = 19, outcol = eric_col$ink2,
            axes = TRUE, frame = FALSE)
    # boxplot(add = TRUE) does not draw axis labels, so add them here
    title(xlab = x_labels[[input$variable]],
          ylab = "Fuel economy (miles per US gallon)",
          col.lab = eric_col$ink)

    # Left-aligned title and source note, as in my Assignment 5 charts
    x0 <- grconvertX(0.02, from = "nfc", to = "user")
    mtext("Fuel economy by car characteristic, 1973–74 models",
          side = 3, at = x0, adj = 0, line = 1.4, font = 2, cex = 1.1,
          col = eric_col$ink)
    mtext("Source: Motor Trend (1974), via the mtcars dataset in R",
          side = 1, at = x0, adj = 0, line = 4.2, cex = 0.72,
          col = eric_col$muted)
  }, res = 96)
}

shinyApp(ui, server)
