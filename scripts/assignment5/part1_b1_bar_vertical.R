# =============================================================
# Assignment 5 · Part 1b-i：直式長條圖（只用 base graphics）
# 問題：哪個地區的平均 HPI 最高？哪些地區高於整體平均？
# =============================================================
source("scripts/assignment5/part1_b_bar_data.R")

# 直式的 x 軸空間有限，地區名稱必須斷行＋縮寫
short <- c("Latin America" = "Latin\nAmerica", "Western Europe" = "Western\nEurope",
           "South Asia" = "South\nAsia", "Eastern Europe & Central Asia" = "E. Europe &\nC. Asia",
           "East Asia" = "East\nAsia", "N America & Oceania" = "N. America\n& Oceania",
           "Middle East & N. Africa" = "Middle East\n& N. Africa", "Africa" = "Africa")

op  <- my_par(mar = c(6.5, 4.5, 3.5, 1.5))     # 下方多留空間給兩行標籤
mid <- barplot(m, plot = FALSE)                # 先取得每根長條的 x 位置（§3.4.6）

# 空白座標 → 格線 → 平均線 → 長條（平均線畫在長條後面，不會穿過數字）
plot(NA, xlim = c(min(mid) - 0.6, max(mid) + 0.6), ylim = c(0, 64),
     axes = FALSE, ann = FALSE, xaxs = "i", yaxs = "i")
grid_mine(2)
abline(h = avg, lty = 2, col = eric_col$ink, lwd = 1.1)
barplot(m, col = bar_cols, border = NA, add = TRUE, axes = FALSE,
        names.arg = rep("", length(m)))
axis(2, lwd = 0)

# 地區名稱（用 mtext 才能控制兩行標籤的位置）
mtext(short[names(m)], side = 1, at = mid, line = 1.6, cex = 0.68,
      col = eric_col$ink2, padj = 0.5)

# low-level 註解：數值寫在長條頂端內側；參考線說明
text(mid, m - 1.2, sprintf("%.1f", m), adj = c(0.5, 1), cex = 0.75, font = 2,
     col = ifelse(m > avg, "white", eric_col$ink))
text(max(mid) + 0.55, avg + 1, sprintf("All-country average %.1f", avg),
     adj = c(1, 0), cex = 0.7, col = eric_col$ink)

title(ylab = "Mean HPI score")
title_mine("Latin America leads in average HPI",
           "Mean HPI score by region; darker bars are above the all-country average")
source_mine(line = 5.2)

par(op)
