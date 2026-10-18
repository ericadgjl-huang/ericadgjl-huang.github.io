# =============================================================
# Assignment 6 · Part 4 — Happy Planet Explorer (my own data)
# Data: Happy Planet Index 2026 data file, 154 countries, 2006–2025
#
# Inputs (none is a drop-down): year slider, region checkboxes,
#   x-axis radio buttons, and a click on the scatter plot
# Linked outputs: year_data() feeds the scatter plot, the summary line,
#   the rankings table and the CSV download, so they always agree
# Mastering Shiny ch. 6–7 features: bslib theme, tabs (page_navbar),
#   interactive plot (click), download button
# =============================================================

library(shiny)
library(bslib)
library(ggplot2)
source("eric_theme.R")

# ---- Data ----------------------------------------------------
# hpi_panel.csv is made from HPI.xlsx by prep_data.R (relative path only)
hpi <- read.csv("hpi_panel.csv")

regions <- c("Latin America", "N America & Oceania", "Western Europe",
             "Middle East & N. Africa", "Africa", "South Asia",
             "Eastern Europe & Central Asia", "East Asia")
region_cols <- setNames(eric_cat, regions)

# x-axis choices: column = c(button label, axis label with units)
x_vars <- list(
  life_exp  = c("Life expectancy",      "Life expectancy at birth (years)"),
  life_sat  = c("Life satisfaction",    "Life satisfaction (0–10 ladder)"),
  footprint = c("Ecological footprint", "Ecological footprint (global hectares per person)"),
  gdp_pc    = c("GDP per capita",       "GDP per capita (PPP, constant 2021 $, log scale)")
)
x_choices <- setNames(names(x_vars), sapply(x_vars, `[`, 1))

y_label     <- "Happy Planet Index score (0–100)"
source_note <- "Source: Abdallah & Barberà Mas (2026), Happy Planet Index 2026 data file\n(happyplanetindex.org)"

# ---- UI ------------------------------------------------------
ui <- page_navbar(
  title = "Happy Planet Explorer",
  theme = eric_bs_theme(),
  fillable = FALSE,

  sidebar = sidebar(
    width = 290,
    sliderInput("year", "Year:", min = 2006, max = 2025, value = 2025,
                step = 1, sep = "",
                animate = animationOptions(interval = 900)),
    radioButtons("xvar", "Compare HPI with:", choices = x_choices,
                 selected = "life_exp"),
    checkboxGroupInput("regions", "Regions:", choices = regions,
                       selected = regions),
    p(class = "small text-muted",
      "Point size shows population. Click a point to see that country's trend.")
  ),

  nav_panel(
    "Explore",
    card(
      plotOutput("scatter", height = "460px", click = "scatter_click"),
      textOutput("summary")
    ),
    card(
      plotOutput("trend", height = "320px")
    )
  ),

  nav_panel(
    "Rankings",
    card(
      card_header(
        class = "d-flex justify-content-between align-items-center",
        textOutput("table_title", inline = TRUE),
        downloadButton("download", "Download CSV", class = "btn-sm btn-primary")
      ),
      card_body(fillable = FALSE, DT::DTOutput("rank_table"))
    )
  ),

  nav_panel(
    "About",
    card(
      card_header("About this app"),
      h5("What it shows"),
      p("The Happy Planet Index (HPI) asks how well each country turns its",
        "ecological resources into long and happy lives. Roughly, it multiplies",
        "life satisfaction by life expectancy and divides by the ecological",
        "footprint, so a high score means good lives at a low environmental cost.",
        "This app lets you compare the HPI with each of its parts, and with",
        "income, for any year from 2006 to 2025, and follow a single country over time."),
      h5("Data"),
      tags$ul(
        tags$li("Source: Abdallah, S. & Barberà Mas, E. (2026). ",
                tags$em("The Happy Planet Index 2026 Data File."),
                " Accessed from ",
                tags$a(href = "https://happyplanetindex.org", "happyplanetindex.org"), "."),
        tags$li("Coverage: 154 countries with an HPI score, 2006–2025 (2,666 country-years)."),
        tags$li("Life expectancy (years): UNDP. Life satisfaction (0–10): Gallup World Poll,",
                "via the World Happiness Report 2026. Ecological footprint (global hectares",
                "per person): York University Ecological Footprint Initiative.",
                "Population: UN Population Division. GDP per capita (PPP, constant 2021 $): World Bank."),
        tags$li("GDP per capita for 2025 repeats the 2024 value, as in the HPI file.",
                "Country-years without GDP data are left out of the GDP view only.")
      ),
      h5("Date"),
      p("Data file published 2026; app built in October 2026 for EPPS 6356",
        "Data Visualization (Fall 2026), University of Texas at Dallas, by Eric Huang.")
    )
  )
)

# ---- Server --------------------------------------------------
server <- function(input, output, session) {

  eric_thematic()

  # Shared reactive: one year, selected regions. Feeds the scatter plot,
  # the summary, the rankings table and the download.
  year_data <- reactive({
    validate(need(length(input$regions) > 0, "Select at least one region."))
    d <- hpi[hpi$year == input$year & hpi$region %in% input$regions, ]
    d$region <- factor(d$region, levels = regions)
    d
  })

  # Data actually plotted (drops missing values of the chosen x variable)
  plot_data <- reactive({
    d <- year_data()
    d$x <- d[[input$xvar]]
    d[!is.na(d$x), ]
  })

  # Country picked by clicking the scatter plot
  selected_country <- reactiveVal("Costa Rica")
  observeEvent(input$scatter_click, {
    hit <- nearPoints(plot_data(), input$scatter_click,
                      xvar = "x", yvar = "hpi", threshold = 12, maxpoints = 1)
    if (nrow(hit) == 1) selected_country(hit$country)
  })

  x_label <- reactive(x_vars[[input$xvar]][2])
  x_name  <- reactive({
    n <- x_vars[[input$xvar]][1]
    if (input$xvar == "gdp_pc") n else tolower(n)
  })

  # ---- Explore tab ----
  output$scatter <- renderPlot({
    d   <- plot_data()
    sel <- d[d$country == selected_country(), ]

    p <- ggplot(d, aes(x = x, y = hpi)) +
      geom_point(aes(size = population, fill = region),
                 shape = 21, colour = "white", stroke = 0.3, alpha = 0.9) +
      # Ring around the clicked country (fixed size so small countries show too)
      geom_point(data = sel, shape = 21, size = 6, fill = NA,
                 colour = eric_col$ink, stroke = 1.2) +
      geom_text(data = sel, aes(label = country), vjust = -1.4,
                size = 3.6, fontface = "bold", colour = eric_col$ink) +
      scale_fill_manual(values = region_cols, name = NULL, drop = TRUE) +
      scale_size(range = c(1.5, 14), guide = "none") +
      scale_y_continuous(expand = expansion(mult = c(0.05, 0.12))) +
      guides(fill = guide_legend(override.aes = list(size = 3.5), ncol = 2)) +
      coord_cartesian(clip = "off") +   # country labels near the edge stay visible
      labs(title    = sprintf("Happy Planet Index vs %s, %d", x_name(), input$year),
           subtitle = sprintf("%d countries; point size shows population", nrow(d)),
           x = x_label(), y = y_label, caption = source_note) +
      theme_mine(grid = "xy")

    if (input$xvar == "gdp_pc") {
      p <- p + scale_x_log10(labels = function(v) paste0("$", format(v, big.mark = ",",
                                                                    scientific = FALSE, trim = TRUE)))
    }
    p
  }, res = 96)

  output$summary <- renderText({
    d <- plot_data()
    top <- d[which.max(d$hpi), ]
    sprintf("%d countries shown for %d. Highest HPI: %s (%.1f). Correlation between %s and HPI: r = %.2f.",
            nrow(d), input$year, top$country, top$hpi, x_name(),
            cor(if (input$xvar == "gdp_pc") log10(d$x) else d$x, d$hpi))
  })

  output$trend <- renderPlot({
    ctry <- selected_country()
    one  <- hpi[hpi$country == ctry, ]
    reg  <- one$region[1]
    reg_avg <- aggregate(hpi ~ year, data = hpi[hpi$region == reg, ], FUN = mean)

    ggplot() +
      geom_vline(xintercept = input$year, colour = eric_col$base, linetype = "dotted") +
      geom_line(data = reg_avg, aes(x = year, y = hpi),
                colour = eric_col$muted, linewidth = 0.8, linetype = "dashed") +
      geom_line(data = one, aes(x = year, y = hpi),
                colour = eric_col$accent, linewidth = 1.2) +
      geom_point(data = one, aes(x = year, y = hpi),
                 colour = eric_col$accent, size = 1.8) +
      annotate("text", x = max(reg_avg$year), y = tail(reg_avg$hpi, 1),
               label = paste(reg, "average"), hjust = 1, vjust = -0.8,
               size = 3.2, colour = eric_col$muted) +
      scale_x_continuous(breaks = seq(2006, 2025, by = 3), limits = c(2006, 2025)) +
      labs(title    = sprintf("%s: HPI score, 2006–2025", ctry),
           subtitle = sprintf("Dashed: %s average (unweighted). Dotted: %d.",
                              reg, input$year),
           x = "Year", y = "HPI score (0–100)", caption = source_note) +
      theme_mine(grid = "y")
  }, res = 96)

  # ---- Rankings tab ----
  rank_table <- reactive({
    d <- year_data()
    d <- d[order(-d$hpi), ]
    data.frame(
      Rank = seq_len(nrow(d)),
      Country = d$country,
      Region = as.character(d$region),
      `HPI score` = round(d$hpi, 1),
      `Life expectancy (years)` = round(d$life_exp, 1),
      `Life satisfaction (0-10)` = round(d$life_sat, 2),
      `Ecological footprint (gha/person)` = round(d$footprint, 2),
      `GDP per capita (PPP 2021 $)` = round(d$gdp_pc),
      check.names = FALSE
    )
  })

  output$table_title <- renderText(
    sprintf("HPI rankings, %d (%d countries)", input$year, nrow(rank_table()))
  )

  output$rank_table <- DT::renderDT({
    DT::datatable(rank_table(), rownames = FALSE, fillContainer = FALSE,
                  options = list(pageLength = 15, dom = "ftip"))
  })

  output$download <- downloadHandler(
    filename = function() sprintf("hpi_rankings_%d.csv", input$year),
    content  = function(file) write.csv(rank_table(), file, row.names = FALSE)
  )
}

shinyApp(ui, server)
