# Reproduce from the website root: Rscript scripts/class5-overfitting.R
# Base R only. Independent noisy samples from the same quadratic process.
set.seed(6356)
train <- data.frame(x = seq(-1, 1, length.out = 35))
train$y <- 1 + 2 * train$x - 3 * train$x^2 + rnorm(nrow(train), sd = 0.6)
test <- data.frame(x = runif(4000, -1, 1))
test$y <- 1 + 2 * test$x - 3 * test$x^2 + rnorm(nrow(test), sd = 0.6)
degrees <- 1:12
errors <- t(vapply(degrees, function(d) {
  fit <- lm(y ~ poly(x, degree = d), data = train)
  c(training = sqrt(mean(residuals(fit)^2)),
    test = sqrt(mean((test$y - predict(fit, newdata = test))^2)))
}, numeric(2)))
dir.create("images", showWarnings = FALSE)
png("images/class5-overfitting.png", width = 1500, height = 850, res = 180)
par(mar = c(4.4, 4.5, 3.7, 1), las = 1, family = "sans")
matplot(degrees, errors, type = "b", pch = c(16, 17), lty = c(1, 2),
        col = c("#0072B2", "#D55E00"), lwd = 2, xaxt = "n",
        xlab = "Polynomial degree", ylab = "RMSE",
        ylim = c(0, max(errors) * 1.15),
        main = "Better training fit can mean worse predictions")
axis(1, at = degrees)
legend("topleft", legend = c("Training (n = 35)", "Independent test (n = 4,000)"),
       col = c("#0072B2", "#D55E00"), pch = c(16, 17), lty = c(1, 2),
       lwd = 2, bty = "n", cex = 0.9)
mtext("Simulated quadratic signal + noise | Fixed seed: 6356", side = 3,
      line = 0.3, cex = 0.8, col = "#555555")
invisible(dev.off())
print(data.frame(degree = degrees, errors), row.names = FALSE)
# This test set illustrates generalization; do not use it for model selection
# and then claim the selected model's test error is an unbiased final estimate.
