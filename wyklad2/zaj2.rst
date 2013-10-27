Zajęcia 2
=========

Informacje ogólne
-----------------

Plik z tabelą do zajęć: :download:`data/zaj2.sql`.

Zrzut zawartości tabel:

* Tabela ``POINT_TYPE``: :download:`data/point_type.html`
* Tabela ``DATA_SOURCE``: :download:`data/data_source.html`

.. figure:: /wyklad2/data/data-point-final.*

    Układ naszej bazy danych (była omawiana :doc:`na wykładzie <wyk2>`)

.. note::

    **UWAGI**: w programie oceniającym tabele ``POINT_TYPE`` oraz ``DATA_SOURCE``
    będą takie same jak macie w pobranym pliku.

    Zawartość tabeli ``DATA_POINT_DAILY`` może się różnić.

    **UWAGA** Zapisywanie zapytań może być dobrym pomysłem, mogą się przydać.

Zadanie 0; Import bazy danych
-----------------------------

.. code-block:: bash

    jbzdak@debian:~$ psql -f /usr/local/bazy_danych/script/zaj2.sql

Zadanie 1: Podzapytania
------------------------

Proszę opracować zapytanie, którego wynikiem będzie nazwa stacji na,
której osiągnięto maksymalny poziom ``SO 2``.

Zapytanie musi używać subselectów!

Jako wynik pracy proszę wysłać zapytanie.

Zadanie 2: select from many tables
----------------------------------

Proszę wybrać zestaw danych zawierający dwie kolumny w pierwszej
znajduje się nazwa stacji a w drugiej nazwa parametru. Nazwa stacji
i parametru znajdują się w jednym rzędzie wyniku zapytania tylko
jeśli dany parametr jest rejestrowany przez daną stację (czyli istnieje
przynajmniej jeden wiersz w tabeli ``DATA_POINT`` zawierający wiersz z
odnoszący się do tej stacji i punktu pomiarowego).

Dodatkowo proszę nie używać słowa ``JOIN`` w zapytaniu, nie można również
użyć słowa ``DISTINCT``.

Proponuję wykorzystanie funkcji ``EXISTS``, która przyjmuje
result set (czyli wynik podzapytania) i zwraca ``true`` jeśli wynik ten
ma jeden lub więcej wierszy.

Wyniki proszę posortować po nazwie źródła danych oraz nazwie punktu
pomiarowego

Jako wynik pracy proszę wysłać zapytanie.

Zadanie 3: Wyrażenia w zapytaniach
----------------------------------

Proszę stworzyć zapytanie, które spełnia następujące warunki:

* Wybiera trzy kolumny ``date``, ``wind_x`` oraz ``wind_y``.
* Kolumny te zawierają składową x i y wiatru, które należy wyznaczyć
  wiedząc, że wiatr w tabeli podany jest w układzie współrzędnych
  radialnym a my transformujemy go do kartezjańskiego.
* Wyniki sortowane są po id źródła danych oraz dacie

Zapytanie musi korzystać z operatora JOIN

W zapytaniu tym wymagane jest ustalenie następujących nazw kolumn:
``date``, ``wind_x``, ``wind_y``.

Jako wynik pracy proszę wysłać zapytanie.

Zadanie 4: Wyrażenia w zapytaniach
----------------------------------

Proszę stworzyć jak w zadaniu trzecim.

Zapytanie nie może korzystać z operatora ``JOIN`` i subselectów

Jako wynik pracy proszę wysłać zapytanie.

Zadanie 5: SELECT FROM SUBQUERY
-------------------------------

Proszę wybrać dla każdej stacji ilość rejestrowanych na niej
parametrów. Zakładamy, że parametr A jest rejestrowany na stacji B, jeśli jest
przynajmniej jeden pomiar A ze stacji B.

W pierwszej kolumnie prosze wybrać ID data source, w drugiej ilość parametrów

Wynik proszę posortować po data_source

Jako wynik pracy proszę wysłać zapytanie.

Zadanie 6: Relacje jeden-do-wielu
---------------------------------

Proszę wybrać nazwy stacji, na których przekroczono dopuszczalny
poziom PM_10 (czyli 50 mug/m^3) ponad 40 razy w roku 2004.

Zbiór wynikowy powinien zawierać takie kolumny: nazwę stacji, ilość
dni, w których przekroczono dopuszczalny poziom

Wyniki proszę posortować po nazwie źródła danych.

Kolumny powinny mieć nazwy: ``data_source_name``, ``days``.

Nazwę źródła danych proszę wybrać za pomocą subselecta

W wersji na 5.0 ilość subselectów jest ograniczona do 1.

Zadanie 7: Relacje jeden-do-wielu
----------------------------------

Jak powyżej tylko należy użyć operatora JOIN

Zadanie 8
---------

Proszę wybrać zestaw danych jak w zadaniu 2, z tym że zamiast wybierać
nazwy źródła i parametru wybieramy ich ``id``, tak samo
sortujemy po ``id``.

Proszę użyć słowa ``distinct``.

Zadanie 9: SELECT FROM SUBSELECT
--------------------------------

.. note::

    W regulacjach norm zanieczyszczeń powietrza przyjmuje się dwa kryteria
    dobrej jakości powietrza: niski średni roczny poziom zanieczyszczeń,
    oraz ilość dni w danym roku w których średnia dzienna jest
    wyższa od pewnego progu.

    W UE dla pyłu zawieszonego dopuszcza się w maksymalnie 50 dni dla których
    średni poziom $PM_{10}$ jest wyższy niż $50 \frac {\mu g}{m^3}

Skonstruować zapytanie spełniające następującą specyfikację:

* Zapytanie zwraca jeden wiersz dla każdej stacji dokonującej pomiarów poziomu
  pyłu zawierszonego $PM_{10}$.
* W pierwszej kolumnie proszę zwrócić ilość lat w których było ponad 50 dni
  z poziomem $PM_{10}$ wyższym niż $50 \frac {\mu g}{m^3}
* W drugiej kolumnie proszę podać nazwę stacji.
* Wyniki proszę sortować po nazwie stacji



Challenge 1
-----------

Jak zadanie 9, ale między pierwszą a drugą kolumną należy wstawić ilość lat
dla których w ogóle dostępne są dane dla danej stacji.

.. note::

    Zadaniem challenge jest:

    * Danie lepszym studentom czegoś w rodzaju wyzwania
    * Spowodowanie że nikt nie wyjdzie za szybko

    Zatem zasady challenge są takie: po skończeniu zadań można wyjść
    maksymalnie 45 minut przed czasem. By wyjść wcześniej trzeba wykonać
    challenge.

    Challenge jest sprawdzadny ręcznie.


Challenge 2
-----------

Zadanie polega na wykonaniu zapytania zwracającego dane z poprzednich zajęć.
