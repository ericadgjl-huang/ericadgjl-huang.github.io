# =============================================================
# Assignment 5 · Part 2b-ii：橫式長條圖（ggplot2 版）
# 對應 Part 1：part1_b2_bar_horizontal.R
# =============================================================
library(ggplot2)
source("scripts/assignment5/part1_b_bar_data.R")    # m, nn, avg, bar_cols

bars <- data.frame(region = names(m), mean = as.numeric(m), n = as.integer(nn))
bars$label <- sprintf("%s (n=%d)", bars$region, bars$n)
bars$label <- factor(bars$label, levels = rev(bars$label))   # y 軸由下往上排，反轉才會最高在上
bars$above <- bars$mean > avg

p_bar_h <- ggplot(bars, aes(x = mean, y = label)) +
  geom_vline(xintercept = avg, linetype = "dashed", colour = eric_col$ink, linewidth = 0.4) +
  geom_col(aes(fill = above), width = 0.82) +
  scale_fill_manual(values = c(`TRUE` = eric_col$accent, `FALSE` = eric_col$tint), guide = "none") +
  geom_text(aes(x = mean - 0.8, label = sprintf("%.1f", mean), colour = above),
            hjust = 1, size = 2.8, fontface = "bold") +
  scale_colour_manual(values = c(`TRUE` = "white", `FALSE` = eric_col$ink), guide = "none") +
  annotate("text", x = avg, y = 8.6, label = sprintf("Average %.1f", avg),
           vjust = 0, size = 2.7, colour = eric_col$ink) +
  scale_x_continuous(limits = c(0, 64), breaks = seq(0, 60, 10), expand = c(0, 0)) +
  scale_y_discrete(expand = expansion(add = c(0.6, 1.1))) +   # 上方多留空間給「Average」標籤

  labs(title = "Latin America leads in average HPI",
       subtitle = "Mean HPI score by region; darker bars are above average (n = number of countries)",
       x = "Mean HPI score", y = NULL, caption = eric_src) +
  theme_mine() +
  theme(panel.grid.major.y = element_blank(),                       # 橫式：改用垂直格線
        panel.grid.major.x = element_line(colour = eric_col$grid, linewidth = 0.5),
        axis.line.x = element_blank(), axis.ticks.y = element_blank(),
        axis.text.y = element_text(size = rel(0.9)))

p_bar_h
