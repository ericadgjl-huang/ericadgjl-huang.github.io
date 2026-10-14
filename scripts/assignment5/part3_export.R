# =============================================================
# Assignment 5 · Part 3：輸出格式比較
# 圖：散布圖／泡泡圖（Part 1e 的 base 版 + Part 2e 的 ggplot2 版）
# 尺寸：6.5 × 4 吋；點陣格式 300 dpi
# 執行後會產生 part3_output/ 資料夾（12 個檔案）和 part3_sizes.csv
# =============================================================
library(ggplot2)

out <- "files/assignment5/part3_output"
dir.create(out, recursive = TRUE, showWarnings = FALSE)   # recursive：連上層資料夾一起建立
W <- 6.5; H <- 4; DPI <- 300

# ---- 1. Base graphics：用 device 函數，每個都要 dev.off() 關閉 ----
draw_base <- function() source("scripts/assignment5/part1_e_scatter.R")

pdf (file.path(out, "scatter_base.pdf"),  width = W, height = H)
draw_base(); dev.off()

svg (file.path(out, "scatter_base.svg"),  width = W, height = H)
draw_base(); dev.off()

png (file.path(out, "scatter_base.png"),  width = W, height = H, units = "in", res = DPI)
draw_base(); dev.off()

jpeg(file.path(out, "scatter_base.jpg"),  width = W, height = H, units = "in", res = DPI)   # quality 預設 75
draw_base(); dev.off()

tiff(file.path(out, "scatter_base.tiff"), width = W, height = H, units = "in", res = DPI)   # compression 預設 "none"
draw_base(); dev.off()

bmp (file.path(out, "scatter_base.bmp"),  width = W, height = H, units = "in", res = DPI)
draw_base(); dev.off()

# ---- 2. ggplot2：用 ggsave() ----
source("scripts/assignment5/part2_e_scatter.R")          # 建立 p_scatter
for (ext in c("pdf", "svg", "png", "jpg", "tiff", "bmp")) {
  ggsave(file.path(out, paste0("scatter_ggplot.", ext)), p_scatter,
         width = W, height = H, units = "in", dpi = DPI,
         device = if (ext == "svg") grDevices::svg else NULL)  # svg 用內建裝置，不需要 svglite 套件
}

# ---- 3. 比較表 ----------------------------------------------
fmt <- data.frame(
  format       = c("pdf", "svg", "png", "jpg", "tiff", "bmp"),
  type         = c("Vector", "Vector", "Raster", "Raster", "Raster", "Raster"),
  compression  = c("Lossless", "Lossless", "Lossless", "Lossy", "Lossless", "Lossless"),
  transparency = c("Yes", "Yes", "Yes", "No", "Yes", "No")
)
fmt$base_KB   <- round(file.size(file.path(out, paste0("scatter_base.",   fmt$format))) / 1024, 1)
fmt$ggplot_KB <- round(file.size(file.path(out, paste0("scatter_ggplot.", fmt$format))) / 1024, 1)
print(fmt)
write.csv(fmt, "files/assignment5/part3_sizes.csv", row.names = FALSE)
