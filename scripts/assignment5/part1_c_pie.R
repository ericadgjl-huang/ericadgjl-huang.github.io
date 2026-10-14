# =============================================================
# Assignment 5 · Part 1c：圓餅圖（只用 base graphics）
# 問題：全球人口分布在哪些地區？
# 工作目錄：網站專案根目錄（打開 epps6356-website-eric.Rproj）
# =============================================================
source("scripts/assignment5/eric_style.R")
hpi <- read.csv("data/hpi2024.csv")

# ---- 1. 整理資料：各地區人口加總（pop 單位是千人）-----------
pop_region <- sort(tapply(hpi$pop, hpi$continent, sum, na.rm = TRUE),
                   decreasing = TRUE)

# 8 個地區太多片；保留前 6 大，最小的 2 個併成 Other（放最後、用灰色）
keep   <- 6
slices <- c(pop_region[1:keep], Other = sum(pop_region[-(1:keep)]))
share  <- 100 * slices / sum(slices)
cols   <- c(eric_cat[1:keep], eric_col$base)

# ---- 2. 畫圖 ------------------------------------------------
op <- my_par(mar = c(5.5, 1, 4.5, 13))     # 右邊留空間給圖例

pie(slices,
    labels     = sprintf("%.0f%%", share), # 片上標百分比
    col        = cols,
    border     = "white",                  # 片與片之間留白
    clockwise  = TRUE, init.angle = 90,    # 從 12 點鐘方向、順時針，由大到小
    radius     = 0.95,
    cex        = 0.9, col.lab = eric_col$ink)

title_mine("Where the world's people live",
           "Share of total population across 153 countries, by region")

# low-level 註解 1：圖例（顏色有意義，所以必須有圖例）
legend(x = par("usr")[2] + 0.05, y = 0.75,
       legend = sprintf("%s  (%.0f%%)", names(slices), share),
       fill = cols, border = NA, bty = "n",
       cex = 0.85, text.col = eric_col$ink2, xpd = NA, y.intersp = 1.3)

# low-level 註解 2：說明 Other 包含哪些地區＋資料來源
source_mine("Other = N America & Oceania + Eastern Europe & Central Asia", line = 2.8)
source_mine()

par(op)
