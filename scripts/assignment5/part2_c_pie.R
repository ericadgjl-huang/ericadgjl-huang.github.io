# =============================================================
# Assignment 5 · Part 2c：圓餅圖（ggplot2 版）
# ggplot2 沒有圓餅圖函數：做法是「一根堆疊長條」+ coord_polar() 轉成極座標
# 對應 Part 1：part1_c_pie.R
# =============================================================
library(ggplot2)
source("scripts/assignment5/eric_style.R")
hpi <- read.csv("data/hpi2024.csv")

pop_region <- sort(tapply(hpi$pop, hpi$continent, sum, na.rm = TRUE), decreasing = TRUE)
keep   <- 6
slices <- c(pop_region[1:keep], Other = sum(pop_region[-(1:keep)]))

pie <- data.frame(region = names(slices), pop = as.numeric(slices))
pie$share  <- 100 * pie$pop / sum(pie$pop)
pie$legend <- sprintf("%s  (%.0f%%)", pie$region, pie$share)
pie$legend <- factor(pie$legend, levels = pie$legend)     # 固定順序：由大到小，Other 最後
cols <- setNames(c(eric_cat[1:keep], eric_col$base), levels(pie$legend))

# 百分比標籤的位置：每片中間的角度（從 12 點鐘順時針累加）
pie$mid <- cumsum(pie$pop) - pie$pop / 2

p_pie <- ggplot(pie, aes(x = 1, y = pop, fill = legend)) +
  # reverse = TRUE：第一個類別放在堆疊最底部，轉成圓之後就從 12 點鐘開始
  geom_col(width = 1, colour = "white", linewidth = 0.7, position = position_stack(reverse = TRUE)) +
  geom_text(aes(x = 1.62, y = mid, label = sprintf("%.0f%%", share)),
            size = 3.1, colour = eric_col$ink) +
  coord_polar(theta = "y", start = 0, direction = 1) +     # 從 12 點鐘、順時針
  scale_fill_manual(values = cols, name = NULL) +
  scale_x_continuous(limits = c(0.5, 1.7)) +
  labs(title = "Where the world's people live",
       subtitle = "Share of total population across 153 countries, by region",
       caption = paste0("Other = N America & Oceania + Eastern Europe & Central Asia\n", eric_src)) +
  theme_mine() +
  theme(axis.text = element_blank(), axis.title = element_blank(),
        axis.ticks = element_blank(), axis.line.x = element_blank(),
        panel.grid.major.y = element_blank(),
        legend.position = "right", legend.justification = "center",
        legend.key.size = unit(0.45, "cm"))

p_pie
