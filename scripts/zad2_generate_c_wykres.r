costs_0 <- read.csv("../task_2/koszty_dla_0.csv", sep = "\t")$cost
costs_2400 <- read.csv("../task_2/koszty_dla_2400.csv", sep = "\t")$cost
costs_17000 <- read.csv("../task_2/koszty_dla_17000.csv", sep = "\t")$cost

costs_all <- c(costs_0, costs_2400, costs_17000)
xs <- seq(min(costs_all), max(costs_all), by = 1)

filename <- "../Obrazy/Wykres_dystrybuant.png"  
png(filename, width = 200, height = 200, units = "mm", res = 300)

# Ciemne tło
par(bg = "black", col.axis = "white", col.lab = "white", col.main = "white")

# Wykres
plot(xs, ecdf(costs_0)(xs), type = "l", xlab = "Koszt [zł]", ylab = "Prawdopodobieństwo",
     col = "deepskyblue", lwd = 3, main = "Dystrybuanty kosztów")

lines(xs, ecdf(costs_2400)(xs), col = "chartreuse2", lwd = 3)
lines(xs, ecdf(costs_17000)(xs), col = "orange", lwd = 3)

legend("topleft",
       legend = c("A, λ = 0", "B, λ = 2400", "C, λ = 17000"),
       col = c("deepskyblue", "chartreuse2", "orange"),
       lty = 1, lwd = 3, text.col = "white", bg = "black", box.col = "white")

dev.off()