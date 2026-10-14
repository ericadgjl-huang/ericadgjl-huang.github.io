# =============================================================
# Assignment 5 · Part 1b：長條圖共用的資料整理（直式、橫式都 source 這個檔）
# =============================================================
source("scripts/assignment5/eric_style.R")
hpi <- read.csv("data/hpi2024.csv")

d   <- hpi[!is.na(hpi$hpi), ]                                   # 有 HPI 的國家
m   <- sort(tapply(d$hpi, d$continent, mean), decreasing = TRUE) # 各地區平均，由高到低
nn  <- table(d$continent)[names(m)]                             # 各地區國家數
avg <- mean(d$hpi)                                              # 所有國家的平均

# 高於平均用主色，低於平均用淡色
bar_cols <- ifelse(m > avg, eric_col$accent, eric_col$tint)
