# =============================================================
# Assignment 5 · Part 2e：散布圖／泡泡圖（ggplot2 版）
# 對應 Part 1：part1_e_scatter.R
# =============================================================
library(ggplot2)
source("scripts/assignment5/eric_style.R")
hpi <- read.csv("data/hpi2024.csv")

f <- hpi[complete.cases(hpi$footprint, hpi$life_sat), ]
f$group <- ifelse(f$continent == "Latin America", "Latin America", "Other regions")
f <- f[order(-f$pop), ]                                  # 大泡泡先畫
lw <- as.data.frame(lowess(f$footprint, f$life_sat, f = 0.6))
biocap <- 1.6

# 箭頭標註：文字位置 (tx, ty)、對齊方式 hj，箭頭從 (sx, sy) 指向該國的圓
lab <- data.frame(country = c("Costa Rica", "Finland", "Luxembourg", "Philippines"),
                  tx = c(3.4, 5.25, 9.6, 0.75), ty = c(7.85, 7.95, 7.75, 6.75),
                  hj = c(0.5, 1, 0.5, 0.5),
                  sx = c(3.15, 5.35, 9.75, 0.95), sy = c(7.72, 7.93, 7.6, 6.6))
lab$px <- f$footprint[match(lab$country, f$country)]
lab$py <- f$life_sat[match(lab$country, f$country)]
lab$ex <- lab$sx + (lab$px - lab$sx) * 0.85; lab$ey <- lab$sy + (lab$py - lab$sy) * 0.85

p_scatter <- ggplot(f, aes(x = footprint, y = life_sat)) +
  geom_vline(xintercept = biocap, linetype = "dashed", colour = eric_col$ink, linewidth = 0.4) +
  annotate("text", x = biocap + 0.1, y = 2.85, label = "Earth's biocapacity\nabout 1.6 gha per person",
           hjust = 0, vjust = 0, size = 2.6, colour = eric_col$ink, lineheight = 0.9) +
  geom_point(aes(size = pop, fill = group), shape = 21, colour = "white", stroke = 0.3) +
  scale_size_area(max_size = 16, guide = "none") +          # 面積 ∝ 人口
  scale_fill_manual(values = c("Latin America" = adjustcolor(eric_col$accent, 0.85),
                               "Other regions" = adjustcolor(eric_col$base, 0.7)),
                    name = "Bubble size = population") +
  guides(fill = guide_legend(override.aes = list(size = 3.5))) +
  geom_path(data = lw, aes(x = x, y = y), colour = eric_col$ink, linewidth = 0.6) +
  geom_segment(data = lab, aes(x = sx, y = sy, xend = ex, yend = ey), inherit.aes = FALSE,
               colour = eric_col$ink, linewidth = 0.35, arrow = arrow(length = unit(0.05, "in"))) +
  geom_text(data = lab, aes(x = tx, y = ty, label = country, hjust = hj), inherit.aes = FALSE,
            size = 2.85, colour = eric_col$ink) +
  scale_x_continuous(limits = c(0, 12), breaks = seq(0, 12, 2), expand = c(0, 0)) +
  scale_y_continuous(limits = c(2.8, 8), breaks = 3:8) +
  labs(title = "Latin America: high satisfaction, modest footprint",
       subtitle = sprintf("%d countries; curve = lowess smooth", nrow(f)),
       x = "Ecological footprint (global hectares per person)", y = "Life satisfaction (0-10)",
       caption = paste0(eric_src, "; biocapacity: Global Footprint Network (2016)")) +
  theme_mine() +
  theme(legend.position = "bottom", legend.justification = "right")

p_scatter
