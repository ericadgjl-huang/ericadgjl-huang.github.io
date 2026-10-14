# =============================================================
# Assignment 5 · Part 2b-i：直式長條圖（ggplot2 版）
# 對應 Part 1：part1_b1_bar_vertical.R
# =============================================================
library(ggplot2)
source("scripts/assignment5/part1_b_bar_data.R")    # m, nn, avg, bar_cols

bars <- data.frame(region = factor(names(m), levels = names(m)),   # 由高到低
                   mean = as.numeric(m))
bars$above <- bars$mean > avg

short <- c("Latin America" = "Latin\nAmerica", "Western Europe" = "Western\nEurope",
           "South Asia" = "South\nAsia", "Eastern Europe & Central Asia" = "E. Europe &\nC. Asia",
           "East Asia" = "East\nAsia", "N America & Oceania" = "N. America\n& Oceania",
           "Middle East & N. Africa" = "Middle East\n& N. Africa", "Africa" = "Africa")

p_bar_v <- ggplot(bars, aes(x = region, y = mean)) +
  geom_hline(yintercept = avg, linetype = "dashed", colour = eric_col$ink, linewidth = 0.4) +  # 先畫，在長條後面
  geom_col(aes(fill = above), width = 0.82) +
  scale_fill_manual(values = c(`TRUE` = eric_col$accent, `FALSE` = eric_col$tint), guide = "none") +
  geom_text(aes(y = mean - 1.2, label = sprintf("%.1f", mean), colour = above),
            vjust = 1, size = 2.9, fontface = "bold") +
  scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = eric_col$ink), guide = "none") +
  annotate("text", x = 8.45, y = avg + 1, label = sprintf("All-country average %.1f", avg),
           hjust = 1, vjust = 0, size = 2.7, colour = eric_col$ink) +
  scale_x_discrete(labels = short) +
  scale_y_continuous(limits = c(0, 64), breaks = seq(0, 60, 10), expand = c(0, 0)) +
  labs(title = "Latin America leads in average HPI",
       subtitle = "Mean HPI score by region; darker bars are above the all-country average",
       x = NULL, y = "Mean HPI score", caption = eric_src) +
  theme_mine() +
  theme(axis.text.x = element_text(size = rel(0.75), lineheight = 0.9),
        axis.ticks.x = element_blank())

p_bar_v
