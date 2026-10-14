# =============================================================
# eric_style.R — Eric Huang 的個人繪圖風格（EPPS 6356）
# 風格：B「現代乾淨」版面 + 暖色系
#   sans 字型、焦橙主色、淡暖灰水平格線、無外框
# 用法：在每份作業開頭 source("eric_style.R")
#   Base graphics：op <- my_par(); ...畫圖...; par(op)
#   ggplot2      ：ggplot(...) + ... + theme_mine()
# =============================================================

# ---- 1. 顏色 ------------------------------------------------
eric_col <- list(
  accent = "#C8551E",  # 主色：焦橙（單一系列的長條、直方圖、點都用它）
  tint   = "#ECC4B0",  # 主色的淡色版（不透明）：「背景」組別用，讓主色的組別跳出來
  ink    = "#2B2622",  # 標題、軸標籤（暖黑）
  ink2   = "#5E5650",  # 次要文字：刻度標籤、圖例文字
  muted  = "#8C837C",  # 資料來源註記
  grid   = "#ECE6E0",  # 格線（淡暖灰）
  base   = "#CFC6BE",  # 基準線／座標軸線
  bg     = "#FFFFFF"   # 背景
)

# 類別色：需要區分多組時（例如圓餅圖）才用，依序取用、不要跳著用。
# 已驗證：亮度、彩度、色盲（紅綠）可分辨度、一般視覺可分辨度都通過。
# 注意：第 3 色（金黃）對白底對比較低，用它時請加上文字標籤。
# 圓餅圖最多用 6 色；超過的類別合併成 "Other" 並用 eric_col$base 的灰色。
eric_cat <- c("#C8551E", "#00897B", "#C68F00", "#3A6FB0",
              "#D45F86", "#5E8A1A", "#7B4FB0", "#A8432B")

eric_src <- "Source: Happy Planet Index 2024 (hpi2024.csv)"

# ---- 2. Base graphics --------------------------------------
# 設定整體外觀，回傳舊設定；畫完用 par(op) 還原。
my_par <- function(...) {
  par(family    = "sans",
      bg        = eric_col$bg,
      fg        = eric_col$base,      # 軸線、刻度
      col       = eric_col$ink,
      col.main  = eric_col$ink,  font.main = 2, cex.main = 1.15,
      col.lab   = eric_col$ink,  cex.lab   = 0.95,
      col.axis  = eric_col$ink2, cex.axis  = 0.85,
      las = 1,                        # 刻度標籤一律水平
      mgp = c(2.6, 0.55, 0),          # 軸標籤、刻度標籤、軸線的位置
      tcl = -0.25,                    # 短刻度，朝外
      bty = "n",                      # 不畫外框
      lwd = 1.5, pch = 19,
      mar = c(5.5, 4.5, 3.5, 1.5),    # 下方多留一行給資料來源
      ...)
}

# 在目前的 plot region 畫淡灰色格線（先畫格線、再疊資料）
# side = 2 畫水平線（對應 y 軸刻度），side = 1 畫垂直線（對應 x 軸刻度）
grid_mine <- function(side = 2) {
  if (side == 2) abline(h = axTicks(2), col = eric_col$grid, lwd = 1)
  else           abline(v = axTicks(1), col = eric_col$grid, lwd = 1)
}

# 標題靠左對齊，而且對齊「整張圖」的左緣（不是 plot region 的左緣），
# 這樣左邊有長標籤的圖（例如橫式長條圖）標題也不會被擠到中間，
# 也和 ggplot2 的 plot.title.position = "plot" 一致。
title_mine <- function(main, sub = NULL) {
  x0 <- grconvertX(0.02, from = "nfc", to = "user")   # 圖形區左緣往內 2%
  mtext(main, side = 3, at = x0, adj = 0, line = if (is.null(sub)) 1.2 else 1.9,
        font = 2, cex = 1.15, col = eric_col$ink)
  if (!is.null(sub)) mtext(sub, side = 3, at = x0, adj = 0, line = 0.7,
                           cex = 0.85, col = eric_col$ink2)
}

# 資料來源註記：同樣對齊整張圖的左緣
source_mine <- function(text = eric_src, line = 4.2) {
  x0 <- grconvertX(0.02, from = "nfc", to = "user")
  mtext(text, side = 1, line = line, at = x0, adj = 0, cex = 0.72, col = eric_col$muted)
}

# ---- 3. ggplot2 --------------------------------------------
# 建在 theme_minimal() 上，對齊 Part 1 的字型、顏色、格線。
theme_mine <- function(base_size = 11, base_family = "sans") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      text             = ggplot2::element_text(colour = eric_col$ink),
      plot.title       = ggplot2::element_text(face = "bold", size = ggplot2::rel(1.15),
                                               hjust = 0, margin = ggplot2::margin(b = 6)),
      plot.title.position = "plot",
      plot.subtitle    = ggplot2::element_text(colour = eric_col$ink2, hjust = 0),
      plot.caption     = ggplot2::element_text(colour = eric_col$muted, size = ggplot2::rel(0.75),
                                               hjust = 0),
      plot.caption.position = "plot",
      axis.title       = ggplot2::element_text(size = ggplot2::rel(0.95)),
      axis.text        = ggplot2::element_text(colour = eric_col$ink2, size = ggplot2::rel(0.85)),
      axis.ticks       = ggplot2::element_line(colour = eric_col$base, linewidth = 0.4),
      axis.ticks.length = ggplot2::unit(2.5, "pt"),
      axis.line.x      = ggplot2::element_line(colour = eric_col$base, linewidth = 0.4),
      panel.grid.major.y = ggplot2::element_line(colour = eric_col$grid, linewidth = 0.5),
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      legend.position  = "top",
      legend.justification = "left",
      legend.title     = ggplot2::element_text(size = ggplot2::rel(0.85), colour = eric_col$ink2),
      legend.text      = ggplot2::element_text(size = ggplot2::rel(0.85), colour = eric_col$ink2),
      plot.background  = ggplot2::element_rect(fill = eric_col$bg, colour = NA),
      plot.margin      = ggplot2::margin(10, 14, 8, 10)
    )
}
# 橫向長條圖時，把格線換成垂直方向：
#   + theme_mine() + theme(panel.grid.major.y = element_blank(),
#                          panel.grid.major.x = element_line(colour = eric_col$grid))
