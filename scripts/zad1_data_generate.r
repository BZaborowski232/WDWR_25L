#skrypt generuje oczekiwane wartości kosztu dodatkowego megawata (MW) dla trzech różnych technologii (T1, T2, T3) na podstawie obciętego rozkładu t-Studenta. # nolint

# Parametry rozkładu t-Studenta, granice obcięcia — ograniczają rozkład do przedziału ⟨1, 5⟩.
alpha <- 1
beta <- 5


v <- 5						#stopnie swobody dla rozkładu t-Studenta.
mu <- c(2.5, 1.5, 3.5)		#średnie kosztów dla trzech technologii.
variance <- c(1, 25, 9)		#wariancje kosztów dla trzech technologii.

stddev <- sqrt(variance)	#Liczymy odchylenie standardowe jako pierwiastek z wariancji.

# Obliczamy parametry rozkładu t-Studenta dla obcięcia (przeskalowane).
a <- (alpha - mu) / stddev	
b <- (beta - mu) / stddev

#Liczymy wartość oczekiwaną (średnią) z rozkładu t-Studenta obciętego do przedziału ⟨1, 5⟩.
#Chcemy uzyskać realistyczne, oczyszczone wartości kosztów MW dla każdej technologii.
expected <- mu + stddev * gamma((v - 1) / 2) * ((v + a^2)^(-(v - 1) / 2) - (v + b^2)^(-(v - 1) / 2)) * v^(v / 2) / 2 / (pt(b, v) - pt(a, v)) / gamma(v / 2) / gamma(1 / 2)

sink("../task_1/zadanie_1.dat") #przekierowuje cały output do pliku zadanie_1.dat 
cat("param koszt_dodatkowy_mw := T1 ", expected[1], " T2 ", expected[2], " T3 ", expected[3], ";\n", sep = "")	#zapisuje parametry w formacie AMPL
