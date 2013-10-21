Wykład 2
========

Wprowadzenie
------------

Jak pewnie Państwo zdążyli się zorientować tabele, które prezentuje, są
jakoś powiązane z moją działalnością naukową.

Tabela z zeszłych zajęć jest raczej wynikiem zapytania, niż
źródłem danych, w schemacie, który opracowałem dane są przechowywane w
tabeli, w której w wierszu przechowujemy:

* datę pomiaru
* wartość pomiaru
* źródło danych
* rodzaj parametru

Taki układ danych (a rozważałem kilka innych) ma takie przewagi:

* Dodanie nowego parametru czy źródła danych nie zmienia schematu
  bazy danych
* Operacje dokonywane na całym zbiorze danych są szybkie
* Zadania takie, jak normalizacja - są proste

Pierwszym przybliżeniem tego schematu
może być taka tabela.

.. figure:: /wyklad2/data/data-point-initial.*

    Schemat tabeli

W tabeli tej przechowywane są:

* datę pomiaru
* wartość pomiaru
* **nazwa** źródła pomiaru
* **nazwa** rodzaju parametru


.. _w2-pk:

Pojęcie klucza głównego
-----------------------

Klucz główny jest to ograniczenie, które jednoznacznie identyfikuje
dany wiersz w danej tabeli.

Wiemy, że w danej chwili czasowej dane źródło danych powinno nam zwrócić
co najwyżej jeden pomiar danego rodzaju.

Inaczej w naszej bazie danych, nie może być więcej, niż jeden wiersz
przechowujący poziom pyłu PM_10 na stacji Warszawa
komunikacyjna w danej chwili.

Zauważmy też, że te trzy informacje jednoznacznie identyfikują dany
wiersz, więc możemy określić, że dany wiersz będzie stanowić klucz główny.

Wady naszego schematu
---------------------

Taki schemat ma kilka istotnych wad:

* By wybrać listę wszystkich parametrów musiałbym wykonać zapytanie
  na całej tabeli, (która może być dowolnie duża)
* Tabela nie jest efektywna jeśli chodzi o rozmiar danych, ponieważ
  np. stacje pomiarowe mają długie nazwy (dokładny wpływ na rozmiar
  tabeli jest trudny do obliczenia, bo różne silniki baz danych
  mogą stosować różne optymalizacje)
* By zmienić nazwę stacji muszę dokonać UPDATE na każdym
  wierszu w tabeli (itd).
* Nie mogę przechować w bazie danych informacji o parametrze, o ile
  nie mam żadnych danych zebranych o tym parametrze.


W zasadzie całą krytykę tego schematu można zawrzeć w takim zdaniu:
schemat jest zdenormalizowany (więcej o tym na następnych zajęciach).

Normalizacja przykładu
----------------------

By znormalizować schemat, musimy dodać dodatkowe tabele, które przechowują
odpowiednio informacje o rodzajach punktów pomiarowych oraz
źródłach danych.


Schemat ten może wyglądać tak:

.. figure:: /wyklad2/data/data-point-final.*

    Układ naszej bazy danych


Poszczególne wiersze tabeli ``DATA_POINT`` w kolumnie
data_source zawierają wartości typu ``int``
odnoszące się do wartości w kolumnie ``pk`` tabeli
``DATA_SOURCE``.

Tworzenie tabel i ograniczeń będzie tematem zajęć w przyszłym tygodniu,
teraz zajmiemy się wybieraniem danych z tego typu danych.

Relacja jeden-do-wielu
^^^^^^^^^^^^^^^^^^^^^^

Formalnie wiersze w tabeli ``DATA_POINT`` mają relację
wiele-do-jednego (many-to-one), tj.
wiele wierszy z tabeli ``DATA_POINT`` będzie się odnosić
do jednego wierszy ``DATA_SOURCE`` i ``POINT_TYPE``.

Naturalne i syntetyczne klucze główne
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Opisane są na następnym wykładzie: :ref:`_w3-naturalne-syntetyczne-pk`.

Wybieranie danych ze schematu z relacjami
-----------------------------------------

W wyrażeniu ``SELECT`` w wielu miejscach możemy jako wyrażenie
umieścić podzapytanie. Przykładowo, w mojej bazie dane są przechowywane
w znormalizowanej postaci. By wygenerować z nich
zdenormalizowaną tabelę musiałem wykonać takie zapytanie:

.. code-block:: sql

    SELECT
        date,
        (SELECT name from "POINT_TYPE" WHERE id = point_type) AS point_type_name,
        (SELECT name from "DATA_SOURCE" WHERE id = data_source) AS data_source_name,
        value
    FROM "DATA_POINT_DAILY";

W porównaniu z zapytaniami z poprzednich zajęć mamy następujące nowe
informacje:

* Jedną z głównych niezgodności bazy danych postgresql ze
  standardem SQL jest to, że interpretuje ona wszystkie nazwy, które nie
  są zawarte w podwójnych cudzysłowach, tj: " jako nazwy
  małymi literami, więc podane dwa wyrażenia są tożsame:

    .. code-block:: sql

        SELECT * FROM DATA_POINT;
        SELECT * FROM data_point;


* By wymusić pisownie nazwy tabeli z wielkich liter, należy umieścić ją
  w podwójnym cudzysłowie.

   Warto dodać też, że przykładowo taka: "dasda sad as 1Q@#!@#$!$"
   nazwa tabeli też jest poprawna.
* Zamiast wartości dwóch kolumn mamy wykonane podzapytania, które
  wybierają nazwy rodzaju punktu i źródła danych.
* Proszę zauważyć że podzapytanie "widzi" kolumny wybrane
  w ramach bieżącego wiersza, przykładowo kolumna ``point_type``
  należąca do tabeli ``"DATA_POINT_DAILY"`` jest widoczna
  w podzapytaniu wybierającego nazwę typu punktu.

Techniczne detale podzapytań przy wybieraniu danych
----------------------------------------------------


Podzapytania muszą być zamknięte w nawiasie
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Wynikiem takiego zapytania:

.. code-block:: sql

    SELECT
        date,
        SELECT name from "POINT_TYPE" WHERE id = point_type AS point_type_name,
        (SELECT name from "DATA_SOURCE" WHERE id = data_source) AS data_source_name,
        value
    FROM "DATA_POINT_DAILY";


jest::


   -- Executing query:
    (...)
    ERROR:  syntax error at or near "SELECT"
    LINE 3:  SELECT name from "POINT_TYPE" WHERE id = point_type AS poin...


Podzapytania takie muszą zwrócić dokładnie jeden rząd
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Co powinien zrobić postgres, jeśli podzapytanie zwróciłoby dwie
nazwy dla stacji?

Takie zapytanie:

.. code-block:: sql

    SELECT
        date,
        (SELECT name from "POINT_TYPE" WHERE id = point_type OR id = 4) AS point_type_name,
        (SELECT name from "DATA_SOURCE" WHERE id = data_source) AS data_source_name,
        value
     FROM "DATA_POINT_DAILY";


zwróci błąd::

    ERROR: more than one row returned by a subquery used as an expression
    SQL state: 21000



Jeśli podzapytanie nie zwróci żadnych wyników postgresql w zbiorze wynikowym umieści wartość ``NULL``.

Takie zapytanie

.. code-block:: sql

    SELECT
        date,
        (SELECT name from "POINT_TYPE" WHERE id = point_type AND id = 4) AS point_type_name,
        (SELECT name from "DATA_SOURCE" WHERE id = data_source) AS data_source_name,
    value
    FROM "DATA_POINT_DAILY";

dla wszystkich typów punktów pomiarowych poza tymi o ``id`` równym ``4``,
będzie w drugiej kolumnie zawierało ``NULL``

Podzapytanie musi zwracać jedną kolumnę
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Podzapytanie musi zwrócić dokładnie jedną kolumnę, nie mniej nie więcej.
Liczba wyników zwracanych przez to zapytanie musi wynosić jeden.
Liczbą tą nie jest dwa, ani zero. `Pięć zupełnie odpada
<http://en.wikipedia.org/w/index.php?title=Rabbit_of_Caerbannog&oldid=574553650#Holy_Hand_Grenade_of_Antioch>`_.

Znów: gdyby podzapytanie miało zwrócić kilka kolumn nie Postgres
nie wiedziałby co z tym zrobić.

Podzapytania w klauzuli `WHERE`
--------------------------------

Postgresql udostępnia funkcje, które z pozwalają przekształcić podzapytanie
w wartość logiczną, `pełna lista tych funkcji
<http://www.postgresql.org/docs/9.2/static/functions-subquery.html>`_

Przykładowo chcemy wybrać wszystkie nazwy stacji, które zbierają pył
zawieszony PM10.

.. code-block:: sql

    SELECT name from "DATA_SOURCE" WHERE EXISTS (
        SELECT * FROM "DATA_POINT_DAILY" WHERE data_source = id AND point_type=4
    );

Uwaga: Parametr określający poziom pyłu zawieszonego
ma ``id`` równe 4.
Znaczenie zapytania: wybieramy nazwę ze wszystkich stacji,
z tabeli ``"DATA_SOURCE"``, które to stacje spełniają taki warunek,
że w tabeli ``"DATA_POINT_DAILY"`` istnieją wiersze zawierające
pomiary pyłu zawieszonego z danej stacji.


Wybieranie z wielu tabel
------------------------

Dokładnie takie same wyniki można uzyskać wybierając wynik z wielu
tabel na raz:

.. code-block:: sql

    SELECT
        dp.date,
        ds.name,
        pt.name,
        dp.value
    FROM "DATA_POINT_DAILY" AS dp, "POINT_TYPE" as pt, "DATA_SOURCE" as ds
    WHERE dp.point_type = pt.id AND dp.data_source = ds.id;

Nowe cechy w tym zapytaniu:

* Wiele tabel podanych w klauzuli ``FROM``, poszczególne
  tabele oddzielane są od siebie przecinkiem
* Klauzula ``AS`` przy nazwie tabeli powoduje, że możemy
  odnosić się do kolumn z tej tabeli za pomocą identyfikatora podanego
  po ``AS``.  Przykładowo w naszym zapytaniu ``ds.name`` oznacza
  kolumnę ``name`` z tabeli ``"DATA_SOURCE"``, a
  ``pt.name`` oznacza kolumnę ``name`` z tabeli
  ``"POINT TYPE"``.
  Operator JOIN

Operator ``JOIN``
-----------------

Takie same wyniki możemy osiągnąć za pomocą operatora JOIN.

.. code-block:: sql

    SELECT
        dp.date,
        ds.name,
        pt.name,
        dp.value
    FROM "DATA_POINT_DAILY" AS dp
    INNER JOIN "DATA_SOURCE" ds ON (ds.id = dp.data_source)
    INNER JOIN "POINT_TYPE" pt ON (pt.id = dp.point_type)

Nowe cechy w tym zapytaniu:


* Pojawia się operator ``INNER JOIN``, w podanym przykładzie
  ma on składnię:
  ``INNER JOIN TABLE [AS foo] ON boolean_expression``,
  gdzie ``boolean_expression`` to wyrażenie logiczne.


Oprócz ``ON`` możliwe są takie warianty::

    INNER JOIN TABLE USING (id)
    INNER JOIN TABLE NATURAL


Dokładne znaczenia są opisane w `podręczniku postgreSQL
<http://www.postgresql.org/docs/9.3/static/queries-table-expressions.html>`_.
Proszę się z nimi zapoznać!

Wybieranie wielu wierszy z jednej tabeli
----------------------------------------

Powiedzmy, że chcemy zbadać korelację prędkości wiatru z pochodną
poziomu pyłu zawieszonego ``PM10``.
W tym celu musimy opracować zapytanie zawierające prędkość wiatru i dobowy
przyrost pyłu zawieszonego PM10.
Jak to zrobić? Otóż nikt nie zabronił nam zrobić ``INNER JOIN`` tabeli
z samą sobą.

.. code-block:: sql

    SELECT corr(pm_jutro.value - pm.value, ws.value) FROM "DATA_POINT_DAILY" ws
        INNER JOIN  "DATA_POINT_DAILY" AS pm ON pm.date = ws.date AND ws.data_source = pm.data_source AND pm.point_type = 4
        INNER JOIN  "DATA_POINT_DAILY" AS pm_jutro ON pm_jutro.date = ws.date + 1 AND ws.data_source = pm_jutro.data_source AND pm_jutro.point_type = 4
    WHERE ws.point_type = (SELECT id FROM "POINT_TYPE" WHERE lower(name) = 'wind_speed') --

Cechy zapytania:


* Warunek ``WHERE`` zapewnia nam, że dane z tabeli głównej należą
  zawierają prędkość wiatru.
* Warunki ``INNER JOIN`` w obu przypadkach zapewniają nam,
  że wybieramy pył zawieszony rejestrowany na tej samej stacji, na której
  wybieramy prędkość wiatru.
* Dodatkowo dla ``pm_jutro`` wymagamy, by wiersz pochodził z
  następnego dnia.
* Funkcja ``corr`` wyznacza korelację.


Podzapytanie czy JOIN
---------------------

Z punktu widzenia wydajności nie ma znaczenia, której konstrukcji:
subselect, wybór z wielu tabel czy ``JOIN`` skorzystamy.

Subselecty mają zdecydowanie mniejsze możliwości, tj. wszystkie zestawy
danych, które można opisać za pomocą subselectów da się przepisać na
``JOIN``y, ale nie wszystkie ``JOINY`` można przepisać na subselecty.

Wybór konkretnego wyrażenia jest zatem kwestią czytelności kodu.


Relacja wiele-do-wielu
----------------------

Relacja wiele do wielu to relacja, w której wiele wierszy tabeli A jest
powiązanych każdy z wieloma różnymi wierszami tabeli B.

Przykładowo tabela student zawiera studentów, którzy mają zainteresowania,
oczywiście wielu studentów może mieć takie same zainteresowania.

Na poziomie bazy danych relacja taka wymaga utworzenia tabeli
pośredniczącej:

.. figure:: /wyklad2/data/mant-to-many.*

    Schemat

Przykładowo: jeśli w tabeli student są studenci o ``id`` 1, 2 i 3, oraz
zainteresowania o id 100, 101 oraz 102. To wiersz w tabeli
``STUDENT_ZAINTERESOWANIE`` o wartości kolumny ``student_id`` równej 2
oraz ``zainteresowanie_id`` równej 102 oznacza, że student o id 2 ma zainteresowanie
numer 102. Kolejne zainteresowania dla studenta 2 są reprezentowane
przez kolejne wiersze z tej tabeli.


``LEFT``, ``RIGHT``, ``INNER``, ``CROSS JOIN``
----------------------------------------------

By wybrać każdego studenta i jego zainteresowania należałoby napisać:

.. code-block:: sql

    SELECT student_id, zainteresowanie_id FROM STUDENT as stud
    JOIN STUDENT_ZAINTERESOWANIE ON student_id = stud.pk


Takie zapytanie wybierze nam studentów i ich zainteresowania, jednak
jeśli jakiś student nie ma zainteresowań, będzie nieobecny w wyniku tego zapytania.

By stworzyć zapytanie, które zwróci również tych studentów, którzy nie mają
zainteresowań należy użyć:

.. code-block:: sql

    SELECT stud.pl, zainteresowanie_id FROM STUDENT as stud
    LEFT JOIN STUDENT_ZAINTERESOWANIE ON student_id = stud.pk


Dodanie słowa ``LEFT`` do ``JOIN`` spowoduje, że
po wykonaniu samego JOINA silnik bazy danych do wyniku zapytania
doda wszystkie wiersze obecne w tabeli student, które nie zostały wybrane,
oraz dla tych wierszy przypisze kolumnom z tabeli ``STUDENT_ZAINTERESOWANIE``
wartość ``NULL``.

Gdybyśmy chcieli wybrać tylko studentów mających zainteresowanie i
zainteresowania nie wybrane przez studentów należałoby napisać: ``RIGHT JOIN``.

Gdybyśmy chcieli wybrać zarówno studentów bez zainteresowań, jak i zainteresowania bez studentów
musielibyśmy dodać ``CROSS JOIN``

INNER JOIN jest synonimem dla JOIN, oraz
OUTER LEFT JOIN jest synonimem dla LEFT JOIN itp.

Więcej o outer joinach `w podręczniku postgresql <http://www.postgresql.org/docs/9.2/static/tutorial-join.html>`_

Klauzula `DISTINCT`
-------------------

Klauzula distinct pozwala wybrać tylko unikalne zestawy danych,
przykładowo takie zapytanie wybiera wszystkie zestawy parametrów
dla każdej stacji:

.. code-block:: sql

    SELECT DISTINCT data_source, point_type FROM "DATA_POINT_DAILY" ORDER BY data_source, point_type;


Dla zainteresowanych: w PostgreSQL dostępna jest klauzula
`DISTINCT ON`, która pozwala wybrać wiersze unikalne
względem pewnego podzbioru wszystkich kolumn, `więcej w dokumentacji:
<http://www.postgresql.org/docs/9.0/static/sql-select.html#SQL-DISTINCT>`_

SELECT FROM SUBQUERY
--------------------

Wynik zapytania jest tabelą, prawda?

Zatem może da się na wyniku zapytania wykonać inne zapytanie.

Da się!

Powiedzmy, że chcemy rozwiązać bardziej rozbudowaną wersję zadania 12 z
poprzednich zajęć, tj: chcemy wybrać
ilość miesięcy, w których średni poziom był powyżej pewnej wartości,
dla każdej stacji pomiarowej.

Najpierw stwórzmy zapytanie zwracające po prostu średnie miesięczne
poziomy pyłu zawieszonego PM_10 i ograniczmy zapytanie
dla miesięcy z poziomem powyżej 50 migrogramów na m^3.

.. code-block:: sql

    SELECT date_trunc('month', date), data_source, AVG(value) FROM "DATA_POINT_DAILY"
        WHERE point_type = 4 AND value is not NULL
        GROUP BY data_source, date_trunc('month', date)
        HAVING AVG(value)> 50
        ORDER BY date_trunc('month', date)


Teraz potraktujmy to jako tabelę wejściową do innego zapytania:

.. code-block:: sql

    SELECT data_source, COUNT(*) FROM poprzednie zapytanie
    GROUP BY data_source
    ORDER BY data_source


Tylko czym jest "poprzednie zapytanie"? Otóż jest po prostu
treścią zapytania.


.. code-block:: sql

    SELECT data_source, COUNT(*)
    FROM (
        SELECT date_trunc('month', date), data_source, AVG(value) FROM "DATA_POINT_DAILY"
        WHERE point_type = 4 AND value is not NULL
        GROUP BY data_source, date_trunc('month', date)
        HAVING AVG(value)> 50
        ORDER BY date_trunc('month', date)
    ) as baz
    GROUP BY data_source
    ORDER BY data_source


Proszę zauważyć, że podzapytanie jest zamknięte w nawiasach, oraz nadano
mu alias za pomocą klauzuli as. Zarówno nawiasy jaki i
nadanie aliasu jest wymagane!


Window Functions --- nieobowiązkowe
-----------------------------------

Zasadniczo SQL zakłada, że poszczególne wiersze w zapytaniu są od siebie
niezależne.

Window Functions pozwalają na wykorzystanie w zapytaniu wielu wierszy
jakoś powiązanych z bieżąco przetwarzanym wierszem.

Przykładowo chcemy wybrać to, na ile wartość w danym wierszu różni się
od średniej dla danej stacji i danego parametru:


.. code-block:: sql

    SELECT value - AVG(value) OVER (PARTITION BY(data_source, point_type)), data_source, point_type
    FROM "DATA_POINT_DAILY"
    WHERE value is not NULL
    ORDER BY data_source, point_type


Po pierwsze widzimy funkcję agregującą, a w zapytaniu nie ma klauzuli
GROUP BY.

Po funkcji AVG pojawia się nowe słowo kluczowe OVER,
które mówi po jakim zbiorze wartości jest wyznaczana średnia,
następnie za pomocą PARTITION BY podajemy, że średnia wyznaczana
jest z wierszy o takiej samej wartości kolumny data_source,
oraz point_type.

Jako bonus window functions pozwalają np. wybrać numer wiersza, np:

.. code-block:: sql

    SELECT data_source, COUNT(*) as count, row_number() OVER (ORDER BY COUNT(*) DESC)
    FROM (
        SELECT date_trunc('month', date), data_source, AVG(value) FROM "DATA_POINT_DAILY"
        WHERE point_type = 4 AND value is not NULL
        GROUP BY data_source, date_trunc('month', date)
        HAVING AVG(value)> 50
        ORDER BY date_trunc('month', date)
    ) as baz
    GROUP BY data_source
    ORDER BY data_source


