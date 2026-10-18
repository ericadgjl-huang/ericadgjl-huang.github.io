# =============================================================
# Assignment 6 · Part 2a — mtcars: what goes with fuel economy?
# Layout: sidebar (bslib::page_sidebar)
# Inputs: x variable, colour grouping, horsepower range, trend line
# Outputs: scatter plot, text summary, table — all from one reactive()
# =============================================================

library(shiny)
library(bslib)
library(ggplot2)
source("eric_theme.R")

# ---- Data ----------------------------------------------------
cars <- mtcars
cars$car <- rownames(mtcars)
cars$cyl_f <- factor(cars$cyl, labels = c("4 cylinders", "6 cylinders", "8 cylinders"))
cars$am_f  <- factor(cars$am,  labels = c("Automatic", "Manual"))

# x-axis choices: column = c(menu label, axis label with units)
x_vars <- list(
  wt   = c("Weight",            "Weight (1,000 lbs)"),
  hp   = c("Horsepower",        "Gross horsepower (hp)"),
  disp = c("Engine size",       "Engine displacement (cubic inches)"),
  qsec = c("Quarter-mile time", "Quarter-mile time (seconds)"),
  drat = c("Rear axle ratio",   "Rear axle ratio (ratio)")
)
x_choices <- setNames(names(x_vars), sapply(x_vars, `[`, 1))

source_note <- "Source: Motor Trend road tests of 1973–74 models, via R's mtcars dataset"

# ---- UI ------------------------------------------------------
ui <- page_sidebar(
  title = "What goes with fuel economy? 32 cars from 1973–74",
  theme = eric_bs_theme(),
  fillable = FALSE,   # let cards keep their natural height

  sidebar = sidebar(
    width = 280,
    selectInput("xvar", "Compare fuel economy with:", choices = x_choices,
                selected = "wt"),
    radioButtons("colour_by", "Colour points by:",
                 choices = c("Cylinders" = "cyl_f",
                             "Transmission" = "am_f",
                             "No grouping" = "none")),
    sliderInput("hp_range", "Keep cars with horsepower between:",
                min = 50, max = 340, value = c(50, 340), step = 10,
                post = " hp"),
    checkboxInput("show_fit", "Show linear trend line", value = TRUE)
  ),

  card(
    card_header("Fuel economy against the selected variable"),
    plotOutput("scatter", height = "420px"),
    textOutput("summary")
  ),
  card(
    card_header("Cars in the current selection"),
    card_body(fillable = FALSE, DT::DTOutput("car_table"))
  )
)

# ---- Server --------------------------------------------------
server <- function(input, output, session) {

  eric_thematic()

  # One reactive() feeds all three outputs: the plot, the summary and the table
  selected_cars <- reactive({
    d <- cars[cars$hp >= input$hp_range[1] & cars$hp <= input$hp_range[2], ]
    validate(need(nrow(d) >= 3,
                  "Fewer than 3 cars in this horsepower range. Widen the slider."))
    d
  })

  x_label <- reactive(x_vars[[input$xvar]][2])
  x_name  <- reactive(tolower(x_vars[[input$xvar]][1]))

  output$scatter <- renderPlot({
    d <- selected_cars()
    d$x <- d[[input$xvar]]

    p <- ggplot(d, aes(x = x, y = mpg))

    if (input$show_fit) {
      p <- p + geom_smooth(method = "lm", formula = y ~ x, se = TRUE,
                           colour = eric_col$ink2, fill = eric_col$grid,
                           linewidth = 0.7)
    }

    if (input$colour_by == "none") {
      p <- p + geom_point(shape = 21, size = 3.2, stroke = 0.3,
                          fill = eric_col$accent, colour = eric_col$ink2)
    } else {
      p <- p +
        geom_point(aes(fill = .data[[input$colour_by]]),
                   shape = 21, size = 3.2, stroke = 0.3, colour = eric_col$ink2) +
        scale_fill_manual(values = eric_cat, name = NULL)
    }

    p +
      labs(title    = paste0("Fuel economy vs ", x_name()),
           subtitle = paste0("Each point is one car model (", nrow(d), " of 32 shown)"),
           x = x_label(),
           y = "Fuel economy (miles per US gallon)",
           caption = source_note) +
      theme_mine(grid = "xy")
  }, res = 96)

  output$summary <- renderText({
    d <- selected_cars()
    r <- cor(d[[input$xvar]], d$mpg)
    direction <- if (r < 0) "lower" else "higher"
    sprintf("%d of 32 cars are shown. Correlation between %s and fuel economy: r = %.2f, so cars with a larger %s tend to have %s fuel economy.",
            nrow(d), x_name(), r, x_name(), direction)
  })

  output$car_table <- DT::renderDT({
    d <- selected_cars()
    out <- data.frame(
      Car          = d$car,
      MPG          = d$mpg,
      Selected     = d[[input$xvar]],
      Cylinders    = d$cyl,
      Transmission = as.character(d$am_f),
      Horsepower   = d$hp
    )
    names(out)[3] <- x_label()
    out <- out[order(-out$MPG), ]
    DT::datatable(out, rownames = FALSE, fillContainer = FALSE,
                  options = list(pageLength = 8, dom = "ftip"))
  })
}

shinyApp(ui, server)
