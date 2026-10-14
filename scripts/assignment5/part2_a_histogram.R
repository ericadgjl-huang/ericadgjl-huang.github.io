# =============================================================
# Assignment 5 · Part 2a：直方圖（ggplot2 版）
# 對應 Part 1：part1_a_histogram.R
# =============================================================
library(ggplot2)
source("scripts/assignment5/eric_style.R")
hpi <- read.csv("data/hpi2024.csv")

d   <- hpi[!is.na(hpi$hpi), ]
n   <- nrow(d); mu <- mean(d$hpi); md <- median(d$hpi)
top <- d[which.max(d$hpi), ]
cut <- 60; bw <- 2.5
n_cut <- sum(d$hpi >= cut)

p_hist <- ggplot(d, aes(x = hpi)) +
  # 長條：用 after_stat(x)（每組的中心）判斷是否 >= 60，決定深淺
  geom_histogram(aes(fill = after_stat(x >= cut)), breaks = seq(30, 70, bw),
                 colour = "white", linewidth = 0.4) +
  scale_fill_manual(values = c(`FALSE` = eric_col$tint, `TRUE` = eric_col$accent),
                    guide = "none") +
  # 密度曲線：after_stat(count) × 組距，換算成「國家數」
  geom_density(aes(y = after_stat(count) * bw,
                   linetype = "Smoothed distribution (density)"),
               colour = eric_col$ink, linewidth = 0.6) +
  # rug：每個國家一條小刻度
  geom_rug(aes(linetype = "Each tick = one country"), sides = "b",
           colour = adjustcolor(eric_col$ink, 0.55), length = unit(0.03, "npc")) +
  scale_linetype_manual(name = NULL, values = c("solid", "solid"),
                        guide = guide_legend(override.aes = list(colour = c(adjustcolor(eric_col$ink, .55), eric_col$ink),
                                                                 linewidth = c(.3, .6)))) +
  # 平均數、中位數：線重疊，標籤分放兩側
  geom_vline(xintercept = md, linetype = "dotted", colour = eric_col$ink, linewidth = 0.5) +
  geom_vline(xintercept = mu, linetype = "dashed", colour = eric_col$ink, linewidth = 0.4) +
  annotate("text", x = md - 0.4, y = 23.3, label = sprintf("Median %.1f", md),
           hjust = 1, size = 2.9, colour = eric_col$ink) +
  annotate("text", x = mu + 0.4, y = 23.3, label = sprintf("Mean %.1f", mu),
           hjust = 0, size = 2.9, colour = eric_col$ink) +
  # 60+ 說明與最高分國家
  annotate("text", x = 66.6, y = 11.2, label = sprintf("Only %d countries\nscore %d+", n_cut, cut),
           vjust = 0, size = 2.9, fontface = "bold", colour = eric_col$accent, lineheight = 0.9) +
  annotate("text", x = 66.6, y = 6.8, label = sprintf("%s %.1f\n(highest)", top$country, top$hpi),
           vjust = 0, size = 2.85, colour = eric_col$ink, lineheight = 0.9) +
  annotate("segment", x = 66.6, xend = top$hpi, y = 6.4, yend = 1.5, colour = eric_col$ink,
           linewidth = 0.35, arrow = arrow(length = unit(0.05, "in"), type = "open")) +
  scale_x_continuous(breaks = seq(30, 70, 5), limits = c(28.5, 71.5), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, 24), expand = expansion(mult = c(0, 0.02))) +
  labs(title = sprintf("Few countries reach an HPI of %d", cut),
       subtitle = sprintf("%d countries; %d+ highlighted; mean and median nearly equal (roughly symmetric)", n, cut),
       x = "Happy Planet Index score (0-100)", y = "Number of countries", caption = eric_src) +
  theme_mine()

p_hist
