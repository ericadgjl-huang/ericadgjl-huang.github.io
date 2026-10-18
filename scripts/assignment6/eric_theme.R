# =============================================================
# eric_theme.R — my Shiny + ggplot2 style for EPPS 6356
# Same colours as eric_style.R (Assignment 5): clean-modern layout,
# burnt-orange accent, light warm-grey gridlines, no box.
# Each app folder keeps its own copy so the app can be deployed alone.
# =============================================================

eric_col <- list(
  accent = "#C8551E",  # burnt orange: single-series marks
  tint   = "#ECC4B0",  # light version of the accent: background groups
  ink    = "#2B2622",  # titles, axis titles
  ink2   = "#5E5650",  # tick labels, legend text
  muted  = "#8C837C",  # source notes
  grid   = "#ECE6E0",  # gridlines
  base   = "#CFC6BE",  # axis lines
  bg     = "#FFFFFF"
)

# Categorical colours: use in order. Colour 3 (gold) is low-contrast on white.
eric_cat <- c("#C8551E", "#00897B", "#C68F00", "#3A6FB0",
              "#D45F86", "#5E8A1A", "#7B4FB0", "#A8432B")

# ---- App theme (bslib) -----------------------------------------
eric_bs_theme <- function(...) {
  bslib::bs_theme(
    version      = 5,
    bg           = eric_col$bg,
    fg           = eric_col$ink,
    primary      = eric_col$accent,
    base_font    = bslib::font_google("Inter", wght = c(400, 600, 700)),
    heading_font = bslib::font_google("Inter", wght = c(400, 600, 700)),
    "headings-font-weight" = 700,
    ...
  )
}

# thematic needs ragg or showtext to draw Google fonts in plots. This block
# never runs; it only tells rsconnect to install them on shinyapps.io.
if (FALSE) {
  library(ragg)
  library(showtext)
}

# Plots follow the app theme (font = "auto" also passes Inter to the plots)
eric_thematic <- function() {
  thematic::thematic_shiny(bg = eric_col$bg, fg = eric_col$ink,
                           accent = eric_col$accent, font = "auto")
}

# ---- ggplot2 theme ---------------------------------------------
# Only theme() tweaks, no complete theme such as theme_minimal(), so the
# font that thematic sets is kept.
theme_mine <- function(grid = "y") {
  grid_line <- ggplot2::element_line(colour = eric_col$grid, linewidth = 0.5)
  ggplot2::theme(
    plot.background    = ggplot2::element_rect(fill = eric_col$bg, colour = NA),
    panel.background   = ggplot2::element_rect(fill = eric_col$bg, colour = NA),
    panel.border       = ggplot2::element_blank(),
    panel.grid.minor   = ggplot2::element_blank(),
    panel.grid.major.x = if (grepl("x", grid)) grid_line else ggplot2::element_blank(),
    panel.grid.major.y = if (grepl("y", grid)) grid_line else ggplot2::element_blank(),
    axis.line.x        = ggplot2::element_line(colour = eric_col$base, linewidth = 0.4),
    axis.ticks         = ggplot2::element_line(colour = eric_col$base, linewidth = 0.4),
    axis.ticks.length  = ggplot2::unit(2.5, "pt"),
    axis.text          = ggplot2::element_text(colour = eric_col$ink2, size = ggplot2::rel(0.9)),
    axis.title         = ggplot2::element_text(colour = eric_col$ink),
    plot.title         = ggplot2::element_text(colour = eric_col$ink, face = "bold",
                                               size = ggplot2::rel(1.2), hjust = 0,
                                               margin = ggplot2::margin(b = 4)),
    plot.subtitle      = ggplot2::element_text(colour = eric_col$ink2, hjust = 0,
                                               margin = ggplot2::margin(b = 8)),
    plot.caption       = ggplot2::element_text(colour = eric_col$muted, size = ggplot2::rel(0.75),
                                               hjust = 0, margin = ggplot2::margin(t = 10)),
    plot.title.position   = "plot",
    plot.caption.position = "plot",
    legend.position    = "top",
    legend.justification = "left",
    legend.key         = ggplot2::element_blank(),
    legend.background  = ggplot2::element_blank(),
    legend.title       = ggplot2::element_text(colour = eric_col$ink2, size = ggplot2::rel(0.9)),
    legend.text        = ggplot2::element_text(colour = eric_col$ink2, size = ggplot2::rel(0.9)),
    plot.margin        = ggplot2::margin(10, 16, 8, 10)
  )
}
