# =============================================================
# Assignment 5 · Part 1e：散布圖／泡泡圖（只用 base graphics）
# 問題：生活滿意度一定要靠很大的生態足跡嗎？拉丁美洲落在哪裡？
# =============================================================
source("scripts/assignment5/eric_style.R")
hpi <- read.csv("data/hpi2024.csv")

# ---- 1. 資料 ------------------------------------------------
f  <- hpi[complete.cases(hpi$footprint, hpi$life_sat), ]
la <- f$continent == "Latin America"                    # 要強調的地區
sz <- sqrt(f$pop / max(f$pop)) * 6 + 0.4                # 泡泡大小：面積 ∝ 人口（取平方根）
o  <- order(-f$pop)                                     # 大泡泡先畫，小泡泡才不會被蓋住
lw <- lowess(f$footprint, f$life_sat, f = 0.6)          # 平滑趨勢線
biocap <- 1.6   # 地球承載力（Global Footprint Network, 2016 年：1.6 gha/人）

# 箭頭標註：文字放在 (tx, ty)，箭頭從文字的邊緣出發，指向該國的圓
# 箭頭只畫到剩下距離的 85%，不蓋住圓本身
point_to <- function(country, tx, ty, shrink = 0.85) {
  i  <- match(country, f$country)
  px <- f$footprint[i]; py <- f$life_sat[i]
  text(tx, ty, country, cex = 0.72, col = eric_col$ink)
  # 算出文字框邊緣：沿著「文字 → 圓」的方向，走到碰到文字框為止
  hw <- strwidth(country, cex = 0.72) / 2 + 0.08
  hh <- strheight(country, cex = 0.72) / 2 + 0.06
  dx <- px - tx; dy <- py - ty
  t  <- min(hw / abs(dx), hh / abs(dy))
  sx <- tx + t * dx; sy <- ty + t * dy
  arrows(sx, sy, sx + (px - sx) * shrink, sy + (py - sy) * shrink,
         length = 0.05, col = eric_col$ink, lwd = 0.9)
}

# ---- 2. 畫圖 ------------------------------------------------
op <- my_par()
plot(f$footprint, f$life_sat, type = "n", axes = FALSE,
     xlim = c(0, 12), ylim = c(2.8, 8), xaxs = "i",
     xlab = "Ecological footprint (global hectares per person)",
     ylab = "Life satisfaction (0-10)")
grid_mine(2)

# 參考線：地球承載力
abline(v = biocap, lty = 2, col = eric_col$ink, lwd = 1.1)
text(biocap + 0.1, 2.85, "Earth's biocapacity\nabout 1.6 gha per person",
     adj = c(0, 0), cex = 0.66, col = eric_col$ink)

# 泡泡：拉丁美洲用主色，其他地區用灰色
points(f$footprint[o], f$life_sat[o], pch = 21, cex = sz[o], lwd = 0.6, col = "white",
       bg = ifelse(la[o], adjustcolor(eric_col$accent, 0.85), adjustcolor(eric_col$base, 0.7)))

# 平滑趨勢線
lines(lw, col = eric_col$ink, lwd = 1.4)

# low-level 註解：箭頭指向四個代表性國家
point_to("Costa Rica",  3.4,  7.85)
point_to("Finland",     5.0,  7.95)
point_to("Luxembourg",  9.6,  7.75)
point_to("Philippines", 0.75, 6.75)

axis(1, at = seq(0, 12, 2), col = eric_col$base)
axis(2, lwd = 0)

# 圖例：顏色＝地區、大小＝人口
legend("bottomright", c("Latin America", "Other regions"), pch = 21, pt.cex = 1.4,
       pt.bg = c(eric_col$accent, eric_col$base), col = "white",
       bty = "n", cex = 0.74, text.col = eric_col$ink2,
       title = "Bubble size = population", title.col = eric_col$ink2)

title_mine("Latin America: high satisfaction, modest footprint",
           sprintf("%d countries; curve = lowess smooth", nrow(f)))
source_mine(paste0(eric_src, "; biocapacity: Global Footprint Network (2016)"))

par(op)
