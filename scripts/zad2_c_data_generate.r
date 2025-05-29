#Idk czy bede z tego korzystac - ale zostawiam, zeby bylo w razie generowania wiecej scenarios do zadania 2c 


library(mvtnorm)

set.seed(0)

alpha <- 1
beta <- 5
v <- 5
mu <- c(2.5, 1.5, 3.5)
sigma <- matrix(c(1, -2, -1, -2, 25, -8, -1, -8, 9), ncol = 3, nrow = 3)
count <- 100

sink("../task_2/zadanie_2c.dat")
cat("param liczba_scenariuszy := ", count, ";\n\n", sep = "")
cat("param koszt_dodatkowy_mw: T1 T2 T3 :=\n")

scenario <- 1
while (scenario <= count) {
    sample <- mu + rmvt(1, sigma = sigma, df = v)
    if (min(sample) < alpha || max(sample) > beta) next
    cat("\t", scenario, " ", sample[1], " ", sample[2], " ", sample[3], "\n", sep = "")
    scenario <- scenario + 1
}

cat(";")
