# =============================================================
# Assignment 5 · Part 2d：盒鬚圖（ggplot2 版）
# 對應 Part 1：part1_d_boxplot.R
# =============================================================
library(ggplot2)
source("scripts/assignment5/eric_style.R")
hpi <- read.csv("data/hpi2024.csv")

d   <- hpi[!is.na(hpi$hpi), ]
med <- sort(tapply(d$hpi, d$continent, median))           # 由小到大：y 軸由下往上，最高在上
nn  <- table(d$continent)[names(med)]
labs_n <- setNames(sprintf("%s (n=%d)", names(med), as.integer(nn)), names(med))
d$region <- factor(d$continent, levels = names(med))
allmed <- median(d$hpi)

# 每個地區的摘要：中位數、平均數、最高分國家
s <- do.call(rbind, lapply(split(d, d$region), function(x) {
  t <- x[which.max(x$hpi), ]
  data.frame(region = x$region[1], med = median(x$hpi), mean = mean(x$hpi),
             top = t$country, top_hpi = t$hpi)
}))
s$y <- as.integer(s$region)
k <- nlevels(d$region)

p_box <- ggplot(d, aes(x = hpi, y = region)) +
  geom_vline(xintercept = allmed, linetype = "dashed", colour = eric_col$ink, linewidth = 0.4) +
  geom_boxplot(fill = eric_col$tint, colour = eric_col$ink2, width = 0.6,
               outlier.shape = NA, linewidth = 0.4) +
  # 中位數線另外用主色重畫（geom_boxplot 的中位數線和外框同色）
  geom_segment(data = s, aes(x = med, xend = med, y = y - 0.3, yend = y + 0.3),
               inherit.aes = FALSE, colour = eric_col$accent, linewidth = 1.3) +
  geom_point(position = position_jitter(width = 0, height = 0.17, seed = 6356),
             shape = 21, fill = adjustcolor(eric_col$accent, 0.75), colour = "white",
             size = 2, stroke = 0.3) +
  geom_point(data = s, aes(x = mean, y = y), inherit.aes = FALSE,
             shape = 23, fill = "white", colour = eric_col$ink, size = 2.6, stroke = 0.7) +
  geom_text(data = s, aes(x = top_hpi + 0.7, y = y, label = top), inherit.aes = FALSE,
            hjust = 0, size = 2.65, colour = eric_col$ink2) +
  annotate("text", x = allmed, y = k + 0.62, label = sprintf("All-country median %.1f", allmed),
           vjust = 0, size = 2.7, colour = eric_col$ink) +
  # 圖例：手動畫在右下角空白處
  annotate("segment", x = 62, xend = 63.3, y = 2.9, yend = 2.9, colour = eric_col$accent, linewidth = 1.3) +
  annotate("text", x = 63.8, y = 2.9, label = "Median", hjust = 0, size = 2.8, colour = eric_col$ink2) +
  annotate("point", x = 62.65, y = 2.4, shape = 23, fill = "white", colour = eric_col$ink, size = 2.6, stroke = 0.7) +
  annotate("text", x = 63.8, y = 2.4, label = "Mean", hjust = 0, size = 2.8, colour = eric_col$ink2) +
  scale_y_discrete(labels = labs_n, expand = expansion(add = c(0.6, 1.1))) +
  scale_x_continuous(limits = c(30, 74), breaks = seq(30, 70, 10), expand = c(0, 0)) +
  coord_cartesian(clip = "off") +
  labs(title = "Wide spread within most regions",
       subtitle = "HPI score by region, sorted by median; each dot is one country, top country labeled",
       x = "HPI score", y = NULL, caption = eric_src) +
  theme_mine() +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(colour = eric_col$grid, linewidth = 0.5),
        axis.line.x = element_blank(), axis.ticks.y = element_blank(),
        axis.text.y = element_text(size = rel(0.9)))

p_box
