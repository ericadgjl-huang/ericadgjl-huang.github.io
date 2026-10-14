# =============================================================
# Assignment 5 · Part 1d：盒鬚圖（只用 base graphics）
# 問題：長條圖只看到各地區的平均；地區內部的差異有多大？
# =============================================================
source("scripts/assignment5/eric_style.R")
hpi <- read.csv("data/hpi2024.csv")

# ---- 1. 資料 ------------------------------------------------
d <- hpi[!is.na(hpi$hpi), ]

# 依中位數排序。橫式盒鬚圖從下往上畫，所以由小到大排，最高的會在最上面
med <- sort(tapply(d$hpi, d$continent, median))
d$region <- factor(d$continent, levels = names(med))
k      <- nlevels(d$region)
nn     <- table(d$region)
mn     <- tapply(d$hpi, d$region, mean)            # 各地區平均（菱形）
allmed <- median(d$hpi)                            # 所有國家的中位數（參考線）

# 每個地區的最高分國家
top <- do.call(rbind, lapply(split(d, d$region), function(x) x[which.max(x$hpi), ]))

# ---- 2. 畫圖 ------------------------------------------------
op <- my_par(mar = c(5.5, 13, 3.5, 1.5))           # 左邊留寬給完整地區名稱

# 空白座標 → 格線 → 參考線 → 盒子 → 點（畫家模型：後畫的在上面）
plot(NA, xlim = c(30, 74), ylim = c(0.4, k + 0.6), axes = FALSE, ann = FALSE, yaxs = "i")
grid_mine(1)
abline(v = allmed, lty = 2, col = eric_col$ink, lwd = 1.1)

boxplot(hpi ~ region, data = d, horizontal = TRUE, add = TRUE, axes = FALSE,
        col = eric_col$tint, border = eric_col$ink2, lwd = 1,
        medcol = eric_col$accent, medlwd = 3,      # 中位數：粗的深橘線
        whisklty = 1, staplewex = 0.3,
        outline = FALSE,                           # 離群值不另外畫，因為下面會畫出所有點
        boxwex = 0.6)

# low-level 註解 1：每個國家一個點（§3.4.6：第 i 個盒子在 y = i，加 jitter 避免重疊）
set.seed(6356)
points(d$hpi, jitter(as.integer(d$region), amount = 0.17),
       pch = 21, bg = adjustcolor(eric_col$accent, 0.75), col = "white", cex = 0.85, lwd = 0.5)

# low-level 註解 2：平均數菱形
points(mn, 1:k, pch = 23, bg = "white", col = eric_col$ink, cex = 1, lwd = 1.2)

# low-level 註解 3：每個地區最高分的國家
text(top$hpi + 0.7, as.integer(top$region), top$country,
     adj = c(0, 0.5), cex = 0.68, col = eric_col$ink2)

# 座標軸：只標到 70，右側留給國家名稱
axis(1, at = seq(30, 70, 10), lwd = 0)
axis(2, at = 1:k, labels = sprintf("%s (n=%d)", levels(d$region), as.integer(nn)),
     lwd = 0, cex.axis = 0.78)
mtext(sprintf("All-country median %.1f", allmed), side = 3, at = allmed,
      line = -0.2, cex = 0.7, col = eric_col$ink)

# 圖例：中位數線、平均數菱形；放在右下角的空白處，避開國家名稱
#（點＝一個國家已寫在副標題；盒子＝中間 50% 是盒鬚圖的標準讀法）
legend(x = 62, y = 3.2,
       legend = c("Median", "Mean"),
       lty = c(1, NA), lwd = c(3, NA), pch = c(NA, 23),
       col = c(eric_col$accent, eric_col$ink), pt.bg = c(NA, "white"),
       bty = "n", cex = 0.75, text.col = eric_col$ink2, seg.len = 1.5)

title(xlab = "HPI score")
title_mine("Wide spread within most regions",
           "HPI score by region, sorted by median; each dot is one country, top country labeled")
source_mine()

par(op)
