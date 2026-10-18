# =============================================================
# Assignment 6 · Part 2c — uspop: two centuries of US population growth
# Layout: inputs in a bar across the top, then summary boxes and cards
#         (no sidebar, no tabs)
# Inputs: year range, axis scale, chart type
# Outputs: chart, three summary boxes, table — all from one reactive()
# =============================================================

library(shiny)
library(bslib)
library(ggplot2)
source("eric_theme.R")

# ---- Data ----------------------------------------------------
# uspop is a time series (ts), not a data frame: convert it first
uspop_df <- data.frame(year       = as.numeric(time(uspop)),
                       population = as.numeric(uspop))   # millions
uspop_df$growth <- c(NA, diff(uspop_df$population) /
                       head(uspop_df$population, -1) * 100)  # % per decade

source_note <- "Source: US Census Bureau decennial censuses, via R's uspop dataset"

fmt_millions <- function(x) paste0(formatC(x, format = "f", digits = 1), " million")

# ---- UI ------------------------------------------------------
ui <- page_fluid(
  theme = eric_bs_theme(),
  h2("Two centuries of US population growth, 1790–1970", class = "mt-3"),
  p(class = "text-muted",
    "Population counted at each ten-year census. Choose the years and the view below."),

  # Inputs in one row across the top
  card(
    layout_columns(
      col_widths = c(6, 3, 3),
      sliderInput("years", "Census years:",
                  min = 1790, max = 1970, value = c(1790, 1970),
                  step = 10, sep = "", width = "100%"),
      radioButtons("view", "Show:",
                   choices = c("Total population" = "pop",
                               "Growth per decade" = "growth")),
      radioButtons("scale", "Population axis:",
                   choices = c("Linear" = "linear",
                               "Logarithmic" = "log"))
    )
  ),

  # Three summary boxes
  layout_columns(
    col_widths = c(4, 4, 4),
    value_box(title = textOutput("start_label", inline = TRUE),
              value = textOutput("start_pop", inline = TRUE)),
    value_box(title = textOutput("end_label", inline = TRUE),
              value = textOutput("end_pop", inline = TRUE)),
    value_box(title = "Growth over the period",
              value = textOutput("multiple", inline = TRUE))
  ),

  # Chart and table side by side
  layout_columns(
    col_widths = c(8, 4),
    card(plotOutput("chart", height = "430px")),
    card(card_header("Census counts"), tableOutput("pop_table"))
  )
)

# ---- Server --------------------------------------------------
server <- function(input, output, session) {

  eric_thematic()

  # One reactive() with the selected years; every output reads from it
  selected <- reactive({
    validate(need(input$years[2] > input$years[1],
                  "Choose a range of at least two census years."))
    uspop_df[uspop_df$year >= input$years[1] & uspop_df$year <= input$years[2], ]
  })

  # Summary boxes
  output$start_label <- renderText(paste("Population in", input$years[1]))
  output$end_label   <- renderText(paste("Population in", input$years[2]))
  output$start_pop   <- renderText(fmt_millions(head(selected()$population, 1)))
  output$end_pop     <- renderText(fmt_millions(tail(selected()$population, 1)))
  output$multiple    <- renderText({
    d <- selected()
    sprintf("%.1f times larger", tail(d$population, 1) / head(d$population, 1))
  })

  output$chart <- renderPlot({
    d <- selected()
    yrs <- sprintf("%d–%d", min(d$year), max(d$year))

    if (input$view == "pop") {
      p <- ggplot(d, aes(x = year, y = population)) +
        geom_line(colour = eric_col$accent, linewidth = 1.1) +
        geom_point(colour = eric_col$accent, size = 2.2) +
        labs(title    = sprintf("US population, %s", yrs),
             subtitle = if (input$scale == "log")
               "Logarithmic axis: a straight line means a steady growth rate"
             else "Linear axis",
             y = "Population (millions)")
      if (input$scale == "log") {
        p <- p + scale_y_log10(breaks = c(2, 5, 10, 20, 50, 100, 200))
      }
    } else {
      d <- d[!is.na(d$growth), ]   # 1790 has no previous census
      validate(need(nrow(d) > 0, "Choose a wider range to see growth rates."))
      p <- ggplot(d, aes(x = year, y = growth)) +
        geom_col(fill = eric_col$accent, width = 7) +
        labs(title    = sprintf("Population growth per decade, %s", yrs),
             subtitle = "Change since the previous census (the axis setting applies to total population only)",
             y = "Growth since previous census (%)")
    }

    p +
      scale_x_continuous(breaks = seq(1790, 1970, by = 20)) +
      labs(x = "Census year", caption = source_note) +
      theme_mine(grid = "y")
  }, res = 96)

  output$pop_table <- renderTable({
    d <- selected()
    data.frame(
      Year = as.integer(d$year),
      `Population (millions)` = d$population,
      `Growth (%)` = ifelse(is.na(d$growth), "–",
                            formatC(d$growth, format = "f", digits = 1)),
      check.names = FALSE
    )
  }, digits = 1, striped = TRUE, spacing = "s", width = "100%")
}

shinyApp(ui, server)
