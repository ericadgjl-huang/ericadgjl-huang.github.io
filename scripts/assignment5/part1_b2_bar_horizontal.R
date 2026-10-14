# =============================================================
# Assignment 5 · Part 1b-ii：橫式長條圖（只用 base graphics）
# 同一份資料；橫式可以放完整地區名稱和國家數，由上往下讀
# =============================================================
source("scripts/assignment5/part1_b_bar_data.R")

# barplot(horiz = TRUE) 從下往上畫，所以反轉順序，讓最高的在最上面
mr <- rev(m); cr <- rev(bar_cols); nr <- rev(nn)

op  <- my_par(mar = c(5.5, 13, 3.5, 2))        # 左邊留寬給完整名稱
mid <- barplot(mr, horiz = TRUE, plot = FALSE)

plot(NA, ylim = c(min(mid) - 0.6, max(mid) + 0.6), xlim = c(0, 64),
     axes = FALSE, ann = FALSE, xaxs = "i", yaxs = "i")
grid_mine(1)                                   # 橫式改用垂直格線
abline(v = avg, lty = 2, col = eric_col$ink, lwd = 1.1)
barplot(mr, horiz = TRUE, col = cr, border = NA, add = TRUE, axes = FALSE,
        names.arg = sprintf("%s (n=%d)", names(mr), as.integer(nr)),
        cex.names = 0.78, col.axis = eric_col$ink2)
axis(1, lwd = 0)

# low-level 註解：數值寫在長條尾端內側；參考線標籤放在上方邊界
text(mr - 0.8, mid, sprintf("%.1f", mr), adj = c(1, 0.5), cex = 0.72, font = 2,
     col = ifelse(mr > avg, "white", eric_col$ink))
mtext(sprintf("Average %.1f", avg), side = 3, at = avg, line = -0.2,
      cex = 0.7, col = eric_col$ink)

title(xlab = "Mean HPI score")
title_mine("Latin America leads in average HPI",
           "Mean HPI score by region; darker bars are above average (n = number of countries)")
source_mine()

par(op)
