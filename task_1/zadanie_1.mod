#Plik z modelem do zadania 1

# --- parametry ---
set GENERATORY;
set GODZINY_DOBY = 0..23, circular;
param wymagania_mocy{GODZINY_DOBY};
param dostepna_ilosc_gen{GENERATORY}, integer;
param minimalne_obciazenie{GENERATORY};
param maksymalne_obciazenie{GENERATORY};
param prog_przeciazenia;  # np. 0.9
param koszt_stalej_pracy{GENERATORY};
param koszt_dodatkowej_mocy_mw{GENERATORY};
param koszt_startu{GENERATORY};
param koszt_pracy_przeciazenie;
param dopuszczalny_wzrost_zapotrzebowania;


# --- zmienne ---
var ilosc_pracujacych{GODZINY_DOBY, GENERATORY} >= 0, integer; 		# ile generatorów typu pracuje o danej godzinie
var ilosc_przeciazen{GODZINY_DOBY, GENERATORY} >= 0, integer; 		# ile jest przeciążonych
var moc_wytwarzana{GODZINY_DOBY, GENERATORY} >= 0; 					# łączna moc od generatorów typu w godzinie
var liczba_uruchomien{GODZINY_DOBY, GENERATORY} >= 0, integer; 		# ile generatorów zostało uruchomionych w danej godzinie
var liczba_wylaczen{GODZINY_DOBY, GENERATORY} >= 0, integer; 		# ile generatorów zostało wyłączonych w danej godzinie



# --- ograniczenia ---

# moc nie może być mniejsza niż minimalne obciążenie
subject to minimalna_moc{godzina in GODZINY_DOBY, gen in GENERATORY}:
    moc_wytwarzana[godzina, gen] >= ilosc_pracujacych[godzina, gen] * minimalne_obciazenie[gen];

# moc nie może przekroczyć limitu:
# - 90% max obc. jeśli nie jest przeciążony
# - 100% max obciazenie jeśli jest przeciążony
subject to maksymalna_moc{godzina in GODZINY_DOBY, gen in GENERATORY}:
    moc_wytwarzana[godzina, gen] <=
        (ilosc_pracujacych[godzina, gen] - ilosc_przeciazen[godzina, gen]) * (prog_przeciazenia * maksymalne_obciazenie[gen])
        + ilosc_przeciazen[godzina, gen] * maksymalne_obciazenie[gen];

# suma mocy generatorów musi pokryć zapotrzebowanie
subject to pokrycie_zapotrzebowania{godzina in GODZINY_DOBY}:
    sum {gen in GENERATORY} moc_wytwarzana[godzina, gen] = wymagania_mocy[godzina];

# pracujące generatory muszą mieć moc co najmniej 110% zapotrzebowania
subject to rezerwa_mocy{godzina in GODZINY_DOBY}:
    sum {gen in GENERATORY} ilosc_pracujacych[godzina, gen] * maksymalne_obciazenie[gen] >= (1 + dopuszczalny_wzrost_zapotrzebowania) * wymagania_mocy[godzina];

# ograniczenia na ilość dostępnych generatorów
subject to limit_pracujacych{godzina in GODZINY_DOBY, gen in GENERATORY}:
    ilosc_pracujacych[godzina, gen] <= dostepna_ilosc_gen[gen];

subject to limit_przeciazen{godzina in GODZINY_DOBY, gen in GENERATORY}:
    ilosc_przeciazen[godzina, gen] <= ilosc_pracujacych[godzina, gen];

# zmiana liczby pracujących jest różnicą stanu z poprzedniej godziny plus uruchomienia minus wyłączenia
subject to zmiana_stanu{godzina in GODZINY_DOBY, gen in GENERATORY}:
    ilosc_pracujacych[godzina, gen] = ilosc_pracujacych[prev(godzina), gen] + liczba_uruchomien[godzina, gen] - liczba_wylaczen[godzina, gen];

# --- funkcja celu ---
minimize calkowity_koszt:
    sum{godzina in GODZINY_DOBY, gen in GENERATORY} (
        liczba_uruchomien[godzina, gen] * koszt_startu[gen]
        + ilosc_pracujacych[godzina, gen] * koszt_stalej_pracy[gen]
        + (moc_wytwarzana[godzina, gen] - ilosc_pracujacych[godzina, gen] * minimalne_obciazenie[gen]) * koszt_dodatkowej_mocy_mw[gen]
        + ilosc_przeciazen[godzina, gen] * koszt_pracy_przeciazenie
);
