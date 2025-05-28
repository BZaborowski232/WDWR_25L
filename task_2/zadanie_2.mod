# --- parametry ---
param liczba_scenariuszy := 50;

set GENERATORY;
set GODZINY_DOBY = 0..23, circular;
set SCENARIUSZE = 1..liczba_scenariuszy;

param wymagania_mocy{GODZINY_DOBY};
param dostepna_ilosc_gen{GENERATORY}, integer;
param minimalne_obciazenie{GENERATORY};
param maksymalne_obciazenie{GENERATORY};
param koszt_stalej_pracy{GENERATORY};
param koszt_dodatkowy_mw{SCENARIUSZE, GENERATORY};
param koszt_startu{GENERATORY};
param dopuszczalny_wzrost_zapotrzebowania;
param lambda;
param prawdopodobienstwo{SCENARIUSZE};

#  przypisuje każdemu scenariuszowi równe prawdopodobieństwo ponieważ brak jest informacji o ich prawdopodobieństwie
#  (zakładamy, że wszystkie scenariusze są równie prawdopodobne)
let {s in SCENARIUSZE} prawdopodobienstwo[s] := 1 / liczba_scenariuszy;


# --- zmienne ---
var ilosc_pracujacych{godzina in GODZINY_DOBY, gen in GENERATORY} >= 0, integer;    # ile generatorów typu pracuje o danej godzinie
var czy_uzyty{godzina in GODZINY_DOBY, gen in GENERATORY} binary;                   # binarka, czy generator typu jest użyty w danej godzinie (czyli pracuje lub jest uruchomiony)
var moc_wytwarzana{godzina in GODZINY_DOBY, gen in GENERATORY} >= 0;                # łączna moc od generatorów typu w godzinie
var liczba_uruchomien{godzina in GODZINY_DOBY, gen in GENERATORY} >= 0, integer;    # ile generatorów zostało uruchomionych w danej godzinie
var liczba_wylaczen{godzina in GODZINY_DOBY, gen in GENERATORY} >= 0, integer;      # ile generatorów zostało wyłączonych w danej godzinie


# --- ograniczenia ---

# Powiązanie ilosc_pracujacych i czy_uzyty - górna granica
s.t. DefinicjaUzyciaGeneratora {godzina in GODZINY_DOBY, gen in GENERATORY}:
    ilosc_pracujacych[godzina, gen] <= dostepna_ilosc_gen[gen] * czy_uzyty[godzina, gen];

# Powiązanie ilosc_pracujacych i czy_uzyty - dolna granica (jeśli czy_uzyty=1 to ilosc_pracujacych >= 1)
s.t. SpojnoscUzyciaGeneratora {godzina in GODZINY_DOBY, gen in GENERATORY}:
    ilosc_pracujacych[godzina, gen] >= czy_uzyty[godzina, gen];

# Gdy używam T1, to co najmniej T2 lub T3 musi być również użyty
s.t. UzycieT1ImplikujeT2lubT3 {godzina in GODZINY_DOBY}:
    czy_uzyty[godzina, "T2"] + czy_uzyty[godzina, "T3"] >= czy_uzyty[godzina, "T1"];

# Minimalna moc od pracujących generatorów
s.t. minimalna_moc{godzina in GODZINY_DOBY, gen in GENERATORY}:
    moc_wytwarzana[godzina, gen] >= ilosc_pracujacych[godzina, gen] * minimalne_obciazenie[gen];

# Suma mocy musi pokryć zapotrzebowanie
s.t. pokrycie_zapotrzebowania{godzina in GODZINY_DOBY}:
    sum {gen in GENERATORY} moc_wytwarzana[godzina, gen] = wymagania_mocy[godzina];

# Rezerwa mocy - maksymalna moc wszystkich pracujących generatorów
s.t. rezerwa_mocy{godzina in GODZINY_DOBY}:
    sum {gen in GENERATORY} ilosc_pracujacych[godzina, gen] * maksymalne_obciazenie[gen]
    >= (1 + dopuszczalny_wzrost_zapotrzebowania) * wymagania_mocy[godzina];

# Górna granica mocy wytwarzanej przez każdy generator
s.t. gorna_granica_mocy {godzina in GODZINY_DOBY, gen in GENERATORY}:
    moc_wytwarzana[godzina, gen] <= ilosc_pracujacych[godzina, gen] * maksymalne_obciazenie[gen];


# Limit dostępnych generatorów
s.t. limit_pracujacych{godzina in GODZINY_DOBY, gen in GENERATORY}:
    ilosc_pracujacych[godzina, gen] <= dostepna_ilosc_gen[gen];

# Zmiana stanu generatorów (różnica pracujących = uruchomienia - wyłączenia)
s.t. zmiana_stanu{godzina in GODZINY_DOBY, gen in GENERATORY}:
    ilosc_pracujacych[godzina, gen] = ilosc_pracujacych[prev(godzina), gen]
        + liczba_uruchomien[godzina, gen] - liczba_wylaczen[godzina, gen];

# --- Zadanie 2 ---

# Koszt dla każdego scenariusza
var koszt{s in SCENARIUSZE} =
    sum {godzina in GODZINY_DOBY, gen in GENERATORY} (
        liczba_uruchomien[godzina, gen] * koszt_startu[gen]
        + ilosc_pracujacych[godzina, gen] * koszt_stalej_pracy[gen]
        + (moc_wytwarzana[godzina, gen] - ilosc_pracujacych[godzina, gen] * minimalne_obciazenie[gen]) 
          * koszt_dodatkowy_mw[s, gen]
    );

# Średni koszt
var sredni_koszt = sum {s in SCENARIUSZE} koszt[s] * prawdopodobienstwo[s];

# Ryzyko jako średnia różnica Giniego
var ryzyko_GINI = 0.5 * sum {s1 in SCENARIUSZE, s2 in SCENARIUSZE} 
    abs(koszt[s1] - koszt[s2]) * prawdopodobienstwo[s1] * prawdopodobienstwo[s2];

# Wspólna funkcja celu (skalarna): minimalizacja S
var S;

s.t. s1: S >= sredni_koszt;
s.t. s2: S >= lambda * ryzyko_GINI;

# Funkcja celu: minimalizacja S z lekko zaburzoną wagą na oba składniki
minimize goal: S + 0.000001 * (sredni_koszt + ryzyko_GINI);