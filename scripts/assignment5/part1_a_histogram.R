# =============================================================
# Assignment 5 · Part 1a：直方圖（只用 base graphics）
# 問題：各國的 HPI 分數怎麼分布？有多少國家達到 60 分？
# 工作目錄：網站專案根目錄（打開 epps6356-website-eric.Rproj）
# =============================================================
source("scripts/assignment5/eric_style.R")
hpi <- read.csv("data/hpi2024.csv")

# ---- 1. 資料 ------------------------------------------------
x  <- hpi$hpi[!is.na(hpi$hpi)]          # 有 HPI 分數的國家
n  <- length(x)
mu <- mean(x)
md <- median(x)
top <- hpi[which.max(hpi$hpi), ]         # 最高分的國家（Costa Rica）
cut <- 60                                # 要強調的門檻
n_cut <- sum(x >= cut)

h <- hist(x, breaks = seq(30, 70, 2.5), plot = FALSE)   # 每 2.5 分一組

# 60 分以上的組用主色，其他用同色系的淡色
bar_cols <- ifelse(h$mids >= cut, eric_col$accent, eric_col$tint)

# ---- 2. 畫圖 ------------------------------------------------
op <- my_par()

# 先建立空白座標，畫格線，再把長條疊上去（畫家模型）
plot(h, col = NA, border = NA, main = "", axes = FALSE, ylim = c(0, 24),
     xlab = "Happy Planet Index score (0-100)", ylab = "Number of countries")
grid_mine(2)
plot(h, col = bar_cols, border = "white", add = TRUE)

# low-level 註解 1：密度曲線（換算成「國家數」的尺度，才能和長條疊在同一張圖）
dens <- density(x)
lines(dens$x, dens$y * n * 2.5, col = eric_col$ink, lwd = 1.6)   # 2.5 = 組距

# low-level 註解 2：rug——底部每一條小刻度代表一個國家
rug(x, ticksize = 0.03, col = adjustcolor(eric_col$ink, 0.55), lwd = 0.8)

# low-level 註解 3：平均數、中位數
# 兩者只差 0.1，線一定會重疊；所以把標籤分放線的兩側，用箭頭方向區分
abline(v = md, lty = 3, lwd = 1.3, col = eric_col$ink)
abline(v = mu, lty = 2, lwd = 1.1, col = eric_col$ink)
text(md - 0.4, 23.3, sprintf("Median %.1f", md), adj = c(1, 0.5), cex = 0.74, col = eric_col$ink)
text(mu + 0.4, 23.3, sprintf("Mean %.1f", mu),   adj = c(0, 0.5), cex = 0.74, col = eric_col$ink)

# low-level 註解 4：60+ 的說明與最高分國家，放在右側空白處，箭頭指向 Costa Rica
text(66.6, 11.2, sprintf("Only %d countries\nscore %d+", n_cut, cut),
     adj = c(0.5, 0), cex = 0.75, col = eric_col$accent, font = 2)
text(66.6, 6.8, sprintf("%s %.1f\n(highest)", top$country, top$hpi),
     adj = c(0.5, 0), cex = 0.74, col = eric_col$ink)
arrows(66.6, 6.4, top$hpi, 1.5, length = 0.06, col = eric_col$ink, lwd = 1)

# 座標軸
axis(1, at = seq(30, 70, 5), col = eric_col$base)
axis(2, lwd = 0)

# 圖例：密度曲線和 rug 需要說明；平均數／中位數已直接標在線旁
legend("topright", inset = c(0.01, 0.06),
       legend = c("Smoothed distribution (density)", "Each tick = one country"),
       lty = c(1, 1), lwd = c(1.6, 0.8),
       col = c(eric_col$ink, adjustcolor(eric_col$ink, 0.55)),
       bty = "n", cex = 0.74, text.col = eric_col$ink2, seg.len = 1.6)

title_mine(sprintf("Few countries reach an HPI of %d", cut),
           sprintf("%d countries; %d+ highlighted; mean and median nearly equal (roughly symmetric)", n, cut))
source_mine()

par(op)
