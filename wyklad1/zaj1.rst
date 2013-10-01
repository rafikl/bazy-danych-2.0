Zajęcia 1
=========

Informacje ogólne
-----------------

Plik do pobrania bazy danych :download:`/wyklad1/data/zaj1.sql`

Komputery laboratoryjne są tak skonfigurowane że by uzyskać połączenie
z bazą danych należy po prostu napisać ``psql`` (bez hasła).

By uzyskać połączenie za pomocą programu ``pgAdminIII`` należy wpisać następujące
dane:

.. figure:: /wyklad1/data/new-reg.*

    Dane do ponfiguracji połączenia z ``pgAdminIII``

Jak działają skrypty sprawdzające
---------------------------------

Skrypty sprawdzające porównują wynik zapytania wprowadzonego przez Państwa,
oraz zapytania modelowego, proszę więc dołożyć szczególnej uwagi by
Państwa zapytania spełniały wszystkie wymogi opisane w zapytaniu
(np. sortowanie, nazwy kolumn).

Zadanie 1: Korzystanie z polecenia ``psql`` i przekierowanie wyników zapytań do plików.
---------------------------------------------------------------------------------------


By wykonać zapytanie w poleceniu ``psql`` należy po prostu wpisać jego treść
i wcisnąć klawisz enter (proszę pamiętać o tym że zapytania SQL należy
kończyć za pomocą średnika).

By wyniki zapisać do pliku (a nie wyświetlać na konsolę) należy wpisać
metakomendę: ``\o <<ścieżka do pliku>>``, polecenie to spowoduje że
wynik każdej następnej komendy będzie zapisany do podanego pliku.

By znów wyświetlać wyniki na ekran należy podać metakomendę ``\o``.

Polecenia
^^^^^^^^^

1. Proszę wykonać zapytanie ``SELECT pm_10 FROM zaj1 ORDER BY date;``
2. Proszę zapisać wynik zapytania do pliku
3. Proszę wysłać plik na serwer

Zadanie 2 Korzystanie z programu `pgAdminIII` i eksport wyników zapytań
------------------------------------------------------------------------

By wykonać zapytanie należy połączyć się z bazą danych, a następnie
wybrać edytor kodu SQL (położenie guzika na obrazku:
:download:`/wyklad1/data/pgadminIIISQL.png`).

Należy wykonać zapytanie pobierające poziomy zanieczyszczeń
:math:`PM_{10}` oraz :math:`SO_2` czyli:

.. code-block:: sql

    SELECT ... FROM zaj1 ORDER BY date;

.. note::

    Uwaga nazwa kolumny z :math:`SO_2` zawiera specjalne znaki,
    więc należy ją umieścić wewnątrz podwójnych cudzysłowiów,
    tj. ``"SO2;WATAR``.

By wyeksportować wyniki zapytania należy (po jego wykonaniu)
wykonać ``File -> Export``.


Polecenia
^^^^^^^^^

1. Proszę uruchomić program ``pgAdminIII``
2. Proszę wykonać zadane zapytanie
3. Proszę wyeksportować wyniki
4. Wygenerowany plik proszę wysłać na serwer

Zadanie 3: Wyrażenia w podzapytaniach
--------------------------------------

Proszę wykonać zapytanie które spełnia następujące warunki:

1. Wybiera dwie kolumny ``wind_x`` oraz ``wind_y``
2. Kolumny te zawierają składowe x i y wiatru (we współrzędnych
   kartezjańkskich) --- danych tych nie ma w bazie, baza zawiera
   dane we współrzędnych radialnych, które należy przeliczyć do
   współrzędnych kartezjańskich.
3. Wyniki są sortowane po dacie.

Treść zapytania SQL proszę wysłać na serwer.

Zadanie 4: Wyrażenia w klauzuli WHERE
-------------------------------------

Proszę stworzyć zapytanie, które będzie wybierało poziom pyłu
zawieszonego :math:`PM_{10}` w wierszach spełniających
następujące warunki:

1. Prędkość wiatru jest wyższa od 1
2. Poziom ozonu jest równy zeru, lub ozon nie był rejestrowany
   tego dnia (posiada wartość ``NULL``). Poziom ozonu zapisany jest w
   kolumnie ``ozon``

Wyniki sortowane są po dacie.

Treść zapytania SQL proszę wysłać na serwer.

Zadanie 5: ORDER BY desc
------------------------

Proszę opracować zapytanie wybierające poziom
:math:`PM_{10}` posortowany względem zawartości kolumny ``date``
od wartości najwyższej do najniższej.

Treść zapytania SQL proszę wysłać na serwer.

Zadanie 6: Wyznaczanie średniej
-------------------------------

Proszę opracować zapytanie wyznaczające średnią prędkość wiatru
z całego zestawu danych (zapytanie zwraca jeden wiersz, proszę nie używać klauzuli
``AS``).

Treść zapytania SQL proszę wysłać na serwer.

Zadanie 7: Wyznaczanie średniej 2
---------------------------------
Proszę opracować zapytanie wyznaczające średnią prędkość wiatru,
w marcu 2012 roku (zapytanie zwraca jeden wiersz, proszę nie używać klauzuli
``AS``).

Treść zapytania SQL proszę wysłać na serwer.

Zadanie 8: Wyznaczanie średniej 3
----------------------------------

Proszę wyznaczyć dowolną metodą śrendie prędkości wiartu w wierszach
w których poziom pyłu zawieszonego był niższy od 50 oraz w pozostałych
dniach.

Wyznaczone wartości proszę zaokrąglić w dół do 0.01, przykładowo
jeśli wg. Państwa wartości te wynoszą odpowiednio 5.1234 oraz 6.0991
należy w odpowiednie pola formularza wpisać 5.12 oraz 6.09.


Zadanie 9: Klauzula ``GROUP BY``
---------------------------------
Przekroszenie dopuszczalnego poziomu :math:`PM_{10}` zawarte
jest w kolumnie ``przekroczenie``. Proszę teraz opracować
zapytanie wybierające średnie prędkości wiaru dla wszystkich możliwych
wartości przekroczenia.

Zapytanie powinno zwracać dwie kolumny: średnią predkość, oraz
wartość kolumny przekroczenie dla której ją wyznaczono, wynik powinien
być posortowany po wartości `przekroczenie`.


Zadanie 10: GROUP BY 2
-----------------------

Proszę opracować zapytanie zwracające dwie kolumny: ``day`` oraz ``pm_10`` (kolumy
są w tej kolejności). W kolumnie ``day`` umieszczamy konkretną datę, a w kolumnie
``pm_10`` umieszczamy średni poziom :math:`PM_{10}` dla danego dnia.

Treść zapytania SQL proszę wysłać na serwer.

.. note::

    Uwaga: baza danych zawiera średnie godzinowe.

Zadanie 11: GROUP BY 3
----------------------

Proszę wybrać miesiąc z najwyżym średnim poziomem :math:`PM_{10}`.

Średni poziom z tego miesiąca (z dokładnością 0.01) proszę wysłać w
formularzu.

Zadanie 12: HAVING
------------------
Proszę wybrać ilość dni ze **średnim** poziomem :math:`PM_{10}` przekraczającym
dopuszczalny poziom wynoszący 50 (mikrogramów na metr sześcienny).

Wyznaczoną wartość proszę umieścić w formularzu.

Praca domowa
------------

Żartowałem! Nie ma pracy domowej :)