# Wczytanie danych
df <- read.csv("../task_2/zadanie_2ab_wyniki.csv", sep = "\t")

# Nazwa pliku wyjściowego
filename <- "zadanie_2ab_wykres.png"

# Ustawienia pliku PNG
png(filename, width = 200, height = 200, units = "mm", res = 300)

# Podstawowy wykres: ryzyko (x) vs koszt (y)
plot(df$ryzyko_GINI, df$koszt, pch = 20,
     xlab = "Ryzyko Giniego [zł]",
     ylab = "Średni koszt [zł]",
     main = "")

# Zaznaczanie punktu o minimalnym koszcie
min_cost <- df[which.min(df$koszt), ]
points(min_cost$ryzyko_GINI, min_cost$koszt, pch = 0, col = "red", cex = 1.5)
text(min_cost$ryzyko_GINI, min_cost$koszt, pos = 2,
     labels = paste("Min koszt\n(", round(min_cost$ryzyko_GINI), ", ", round(min_cost$koszt), 
                    ")\nλ=", min_cost$lambda, sep=""),
     col = "red", cex = 0.8)

# Zaznaczanie punktu o minimalnym ryzyku
min_risk <- df[which.min(df$ryzyko_GINI), ]
points(min_risk$ryzyko_GINI, min_risk$koszt, pch = 2, col = "blue", cex = 1.5)
text(min_risk$ryzyko_GINI, min_risk$koszt, pos = 4,
     labels = paste("Min ryzyko\n(", round(min_risk$ryzyko_GINI), ", ", round(min_risk$koszt),
                    ")\nλ=", min_risk$lambda, sep=""),
     col = "blue", cex = 0.8)

# Przykładowo lambda od ktorej jest wieksza zmiana tendencji
wybrane_lambda <- c(2400)

for (l in wybrane_lambda) {
  punkty <- df[df$lambda == l, ]
  if(nrow(punkty) > 0){
    points(punkty$ryzyko_GINI, punkty$koszt, pch = 0, col = "#02dd02", cex = 1.3)
    text(punkty$ryzyko_GINI, punkty$koszt, pos = 3, labels = paste0("λ=", l), col = "#02dd02", cex = 0.7)
  }
}

# Dodanie legendy
legend("topright", legend = c("Punkty danych", "Min koszt", "Min ryzyko", "Wybrane λ \n przy zmianie \ntendencji"),
       pch = c(20, 0, 2, 15),
       col = c("black", "red", "blue", "#02dd02"),
       pt.cex = c(1, 1.5, 1.5, 1.3),
       bty = "n", # bez obramowania legendy
       cex = 0.9)

# Zamknięcie pliku PNG
dev.off()

shell.exec(filename)
