Zajęcia II
==========

Informacje ogólne
-----------------

Plik z tabelą do zajęć: :download:`data/zaj2.sql`.

Zrzut zawartości tabel:

* Tabela ``POINT_TYPE``: :download:`data/data_source.html`
* Tabela ``DATA_SOURCE``: :download:`data/denormalized_table.html``

.. figure:: /wyklad2/data/data-point-final.*

    Układ naszej bazy danych (była omawiana :doc:`na wykładzie <wyk2>`)

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

Dla każdej stacji zbierającej $PM_{10}$,
dla każdego miesiąca proszę wybrać ilość dni dla których średni poziom był
większy niż $50 \frac{\mu g}{m^3}$.

Challenge
---------

Zadanie polega na wykonaniu zapytania zwracającego dane z poprzednich zajęć.

.. note::

    Zadaniem challenge jest:

    * Danie lepszym studentom czegoś w rodzaju wyzwania
    * Spowodowanie że nikt nie wyjdzie za szybko

    Zatem zasady challenge są takie: po skończeniu zadań można wyjść
    maksymalnie 45 minut przed czasem. By wyjść wcześniej trzeba wykonać
    challenge.

    Challenge jest sprawdzadny ręcznie.