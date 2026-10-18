# =============================================================
# Assignment 6 · Part 2b — USArrests: which states had the most arrests?
# Layout: navigation bar with tabs (bslib::page_navbar)
# Inputs: crime type, number of states, sort order
# Outputs: ranked bar chart, scatter plot, summary text, table —
#          all from one reactive()
# =============================================================

library(shiny)
library(bslib)
library(ggplot2)
library(ggrepel)   # labels that do not overlap
source("eric_theme.R")

# ---- Data ----------------------------------------------------
arrests <- USArrests
arrests$State <- rownames(USArrests)

crime_labels <- c(Murder  = "Murder",
                  Assault = "Assault",
                  Rape    = "Rape")

source_note <- paste0("Source: World Almanac and Book of Facts 1975 (arrests); ",
                      "Statistical Abstract of the United States 1975\n",
                      "(urban population); via R's USArrests dataset")

# ---- UI ------------------------------------------------------
ui <- page_navbar(
  title = "US arrests by state, 1973",
  theme = eric_bs_theme(),
  fillable = FALSE,   # let cards keep their natural height

  # The sidebar is shared by all tabs, so every tab uses the same selection
  sidebar = sidebar(
    width = 270,
    radioButtons("crime", "Type of arrest:", choices = crime_labels),
    sliderInput("top_n", "Number of states to highlight:",
                min = 5, max = 50, value = 10, step = 1),
    radioButtons("order", "Show states with:",
                 choices = c("The highest rates" = "high",
                             "The lowest rates"  = "low")),
    hr(),
    p(class = "small text-muted",
      "Rates are arrests per 100,000 residents. The same states are",
      "highlighted on every tab.")
  ),

  nav_panel(
    "Ranking",
    card(
      plotOutput("bar_chart", height = "auto"),
      textOutput("summary")
    )
  ),
  nav_panel(
    "Arrests vs urban population",
    card(
      plotOutput("scatter", height = "480px"),
      textOutput("scatter_note")
    )
  ),
  nav_panel(
    "Data",
    card(card_body(fillable = FALSE, DT::DTOutput("state_table")))
  )
)

# ---- Server --------------------------------------------------
server <- function(input, output, session) {

  eric_thematic()

  # One reactive() with the ranking; every output reads from it
  ranked <- reactive({
    d <- arrests
    d$Rate <- d[[input$crime]]
    d <- d[order(d$Rate, decreasing = (input$order == "high")), ]
    d$Rank <- seq_len(nrow(d))
    d$Highlighted <- d$Rank <= input$top_n
    d
  })

  crime_name <- reactive(crime_labels[[input$crime]])
  which_end  <- reactive(if (input$order == "high") "highest" else "lowest")

  output$bar_chart <- renderPlot({
    d <- ranked()
    d <- d[d$Highlighted, ]
    # Highest rate at the top of the chart when sorting high-to-low
    d$State <- factor(d$State, levels = rev(d$State))

    ggplot(d, aes(x = Rate, y = State)) +
      geom_col(fill = eric_col$accent, width = 0.7) +
      geom_text(aes(label = formatC(Rate, format = "f",
                                    digits = if (input$crime == "Assault") 0 else 1)),
                hjust = -0.2, size = 3.3, colour = eric_col$ink2) +
      scale_x_continuous(expand = expansion(mult = c(0, 0.12))) +
      labs(title    = if (nrow(d) == 50)
                        sprintf("All 50 states ranked by %s arrest rate", tolower(crime_name()))
                      else sprintf("The %d states with the %s %s arrest rates",
                                   nrow(d), which_end(), tolower(crime_name())),
           subtitle = "Arrests per 100,000 residents, 1973",
           x = sprintf("%s arrests (per 100,000 residents)", crime_name()),
           y = NULL,
           caption = source_note) +
      theme_mine(grid = "x") +
      theme(axis.line.x = element_blank(),
            axis.ticks.y = element_blank(),
            axis.text.y = element_text(colour = eric_col$ink))
  },
  # Taller chart when more states are shown
  height = function() 150 + 22 * input$top_n,
  res = 96)

  output$summary <- renderText({
    d <- ranked()
    sprintf("Average %s arrest rate: %.1f per 100,000 across all 50 states, and %.1f across the %d states shown.",
            tolower(crime_name()), mean(d$Rate),
            mean(d$Rate[d$Highlighted]), sum(d$Highlighted))
  })

  output$scatter <- renderPlot({
    d <- ranked()
    hl <- d[d$Highlighted, ]

    ggplot(d, aes(x = UrbanPop, y = Rate)) +
      geom_point(data = d[!d$Highlighted, ], colour = eric_col$tint, size = 2.6) +
      geom_point(data = hl, colour = eric_col$accent, size = 2.8) +
      geom_text_repel(data = hl, aes(label = State), size = 3,
                      colour = eric_col$ink2, min.segment.length = 0.2,
                      segment.colour = eric_col$base, seed = 1) +
      labs(title    = sprintf("%s arrests and urbanisation", crime_name()),
           subtitle = sprintf("Orange: the %d states with the %s rates", nrow(hl), which_end()),
           x = "Urban population (% of state residents)",
           y = sprintf("%s arrests (per 100,000 residents)", crime_name()),
           caption = source_note) +
      theme_mine(grid = "xy")
  }, res = 96)

  output$scatter_note <- renderText({
    d <- ranked()
    sprintf("Correlation between urban population and %s arrests across the 50 states: r = %.2f.",
            tolower(crime_name()), cor(d$UrbanPop, d$Rate))
  })

  output$state_table <- DT::renderDT({
    d <- ranked()
    out <- data.frame(
      Rank  = d$Rank,
      State = d$State,
      Rate  = d$Rate,
      Murder = d$Murder, Assault = d$Assault, Rape = d$Rape,
      `Urban population (%)` = d$UrbanPop,
      check.names = FALSE
    )
    names(out)[3] <- sprintf("%s rate (selected)", crime_name())
    DT::datatable(out, rownames = FALSE, fillContainer = FALSE,
                  options = list(pageLength = 15, dom = "ftip")) |>
      DT::formatStyle("Rank", target = "row",
                      fontWeight = DT::styleInterval(input$top_n, c("600", "400")))
  })
}

shinyApp(ui, server)
