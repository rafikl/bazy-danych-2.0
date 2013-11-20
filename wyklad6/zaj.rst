Zajęcia 6: Materializowane widoki
=================================

Wprowadzenie
------------

Mamy (znaną) bazę danych z puktami pomiarowymi, teraz dodamy do niej takie
ficzery:

* Możliwość versjonowania danych pomiarowych
* Automatyczne uśrednianie danych pomiarowych w czasie

Startowy schemat bazy danych:

.. figure:: data/data-point-initial.*

    Startowy schemat bazy danych


Oceny
-----

Wykonanie zadania 1: ocena 4.0.

Wykonanie zadaniń 1 i 2: ocena 5.0.

Wykonanie zadań i Challenge: ocena 5.0 + chwała.

Dane do zadań
-------------

.. note::

    Takie errory przy imporcie nie są groźne::

        psql:foo.sql:10288370: ERROR:  function point_type_insert() does not exist
        psql:foo.sql:10288379: ERROR:  function point_type_insert_metadata() does not exist
        psql:foo.sql:10288388: ERROR:  function data_source_insert() does not exist

* w formacie (``*tar.lzma``) :download:`data/zaj6.sql.tar.lzma` (27mb)
* w formacie (``*zip``) :download:`data/zaj6.sql.zip` (44mb)

Automatyczne przechowywanie danych historycznych
================================================

Pomysł jest taki, że trzymamy w bazie danych nie tylko bierzącą wartość
rzędu, ale również jego poprzednie wartości.

Wbrew pozorom nie jest to bardzo wydumany ficzer, takie rzeczy relatywnie często
robi się w biznesie (i to rzeczywiście często jest zadanie bazy danych).

Przykładowo wielki telekom ma gargantuniczny system trzymając wszystkie
umowy i cenniki wraz ze starymi wersjami. Można wydrukować "Umowę Pomelo Mix w
wersji 161".

Implementacja tego wymogu jest relatywnie prosta, przynajmniej na poziomie
koncepcyjnym.

Powiedzmy że mamy taką tabelę:

.. code-block:: sql

    CREATE TABLE FOO(
        foo integer primary key,
        foobar timestamp primary key,
        bar double,
        baz character varying,
    )

Pierwsza opcja
--------------

Dodajemy teraz nowy element klucza głównego:

.. code-block:: sql

    CREATE TABLE FOO(
        foo integer,
        foobar timestamp,
        version integer, --<-- to tu
        bar double,
        baz character varying,
    )


zakładamy że pierwszy rząd z danymi `foo` i `foobar` będzie dostawać `version`
równe zero, a każdy kolejny:

.. code-block:: sql

    SELECT MAX(version) + 1 FROM FOO where foo = 'foo' AND foobar = ...;

albo będziemy po prostu generować te wartości z jakiejś sekwencji, to zależy
czy chcemy mieć ciągłe kontinuum wersji dla danego wiersza.

Druga opcja
--------------

.. code-block:: sql

    CREATE TABLE FOO(
        foo integer,
        foobar timestamp,
        insert_date timestamp default now(), --<-- to tu
        bar double,
        baz character varying,
    )

Wybieranie najnowszej wersji
----------------------------

W obu przypadkach najnowszą wersję wybieramy za pomocą zapytania:

.. code-block:: sql

    SELECT * FROM FOO WHERE foo = ... AND foobar = ... AND insert_date = (SELECT MAX(insert_date) FROM  FOO WHERE foo = ... AND foobar = ...);

Uwaga
-----

Podana metoda przechowywania danych historycznych jest jedną z wielu i
to jaką metodę zastosujemy zależy od potrzeb.

Czasem równie dobrze jest przechowywanie w taki sposób:
http://stackoverflow.com/a/3874750.

Indeksy
=======

Indeksy są metodą na przyśpieszenie niektórych zapytań
kosztem zwiększenia rozmiaru bazy danych oraz spowolnienia insertów.

W praktyce indeks (indeksy) pozwalją na przyśpieszenie zapytania

.. code-block:: sql

    SELECT MAX(insert_date) FROM  FOO WHERE foo = ... AND foobar = ...

tylko gdy indeksy są dodane do kolmn `foo`, `bar`.


Deffered constraints
====================

Więzy w bazie danych mogą być albo sprawdzane natychmiast (po każdej operacji),
albo pod koniec transakcji. Druga opcja może być szybsza, ale czasem może też
być wolniejsza.

W naszym przypadku sugeruję by wszystkie więzy definiować jako DEFFERRABLE INITIALLY DEFERRED,
a duże kopiowania danych proszę wykonywać w transakcji.



Zadanie 1: Włączenie danych historycznych
=========================================

Docelowy schemat:

.. figure:: data/data-point-target.svg

    Docelowy schemat bazy danych


Zadanie 1.1 Utworzenie tabelki `DATA_POINT_HISTORY`
---------------------------------------------------

Tworzymy tą tabelę.

Zachowania tej tabeli:

* Nie można na tej tabeli robić `DELETE`
* Nie można na tej tabeli robić `UPDATE`
* Są klucze obce do tabel `POINT_TYPE` i `DATA_SOURCE`

Tak na prawdę nie powinno się również móc na tej tabeli robić `INSERT`
(przynajmniej dla wszystkich użytkowników), ale daruje to Państwu.

**Kopiowanie danych**

By wydajnie skopiować dane między `DATA_POINT_OLD` oraz `DATA_POINT_HISTORY`
można tymczasowo usunąć wsztstkie constrainty na tej tabeli (potem je odtworzyć)

**Wydajność**

Proszę zbadać czas wykonania zapytania:

.. code-block:: sql

    INSERT INTO "DATA_POINT_HISTORY"(...) SELECT ... FROM "DATA_POINT_OLD" LIMIT 1000;

Czas wykonywania tych zapytań proszę zapisać na kartce.

Zadanie 1.2 Utworzenie widoku `VIEW_DATA_POINT_CURRENT`
-------------------------------------------------------

Jest to widok który zawsze zawiera tylko najaktualniejsze wersje danych
pomiarowych z tabeli: `DATA_POINT_HISTORY`.

**Wydajność**

Następnie proszę wykonać zapytania:

.. code-block:: sql

    SELECT * FROM "VIEW_DATA_POINT_CURRENT":

    SELECT * FROM "VIEW_DATA_POINT_CURRENT" WHERE POINT_TYPE = 4 AND DATA_SOURCE = 1:

Czas wykonywania tych zapytań proszę zapisać na kartce.

**Uwaga**

Możecie Państwo użyć klauzuli `DISTINCT ON`.

Zadanie 1.3 Utworzenie tabeli `DATA_POINT_CURRENT`
--------------------------------------------------

Oznaczyłem ją jako `WIDOK`, ale tak na prawdę będzie to materializowany widok,
czyli tak na prawdę tabela z mnóstwem triggerów.

Zachowania tej tabeli:

* Zawsze zawiera najnowszą wersję rekordu
* INSERT oraz UPDATE powodują dodanie kolejnej wersji historycznej dla tabeli
  `DATA_POINT_HISTORY`.
* DELETE wstawia NULL kolejną wersję z wartością `NULL` do `DATA_POINT_HISTORY`
* Są klucze obce do tabel `POINT_TYPE` i `DATA_SOURCE`

**Wydajność 1**

Proszę wyczyścić tabelę: `DATA_POINT_HISTORY` a następnie wstawić do niej dane
ponownie za pomocą `DATA_POINT_CURRENT`.

Następnie proszę wykonać zapytania:

.. code-block:: sql

    SELECT * FROM "DATA_POINT_CURRENT":

    SELECT * FROM "DATA_POINT_CURRENT" WHERE POINT_TYPE = 4 AND DATA_SOURCE = 1:

Czas wykonywania tych zapytań proszę zapisać na kartce.


Zadanie 1.4 Wydajność
---------------------

Jaki wpływ na wydajność wybierania danych miało wprowadzenie materializowanego
widoku?

Jami miało wpływ na wydajność umieszczania danych wprowadzenie go?


Zadanie 2: Uśrednianie danych
=============================

Mamy już tabelę zawierającą dane historyczne oraz tabelę zawierającą dane
bierzące, teraz dodatkowy kawałek informacji: Tak na prawdę nie wiemy z
jaką częstotliwością zbierane są dane w tabelach: `DATA_POINT_HISTORY` oraz
`DATA_POINT_CURRENT`, tj, różne źródła danych mogą zbierać dane z
różną rozdzielczością czasową.

Takie dane nie nadają się do żadnej obróbki, wymagane jest zatem sprowadzenie
ich do stałej częstotliwości, jedną z takich częstotliwości jest
uśrednianie dzienne.


Zadanie 2.1 Utworzenie widoku `DATA_POINT_DAILY_VIEW`
-----------------------------------------------------

Widok wybierający dane w uśrendnieniu dziennym.

Zadanie 2.2 Utworzenie tabelki `DATA_POINT_DAILY`
-------------------------------------------------

Oznaczyłem ją jako `WIDOK`, ale tak na prawdę będzie to materializowany widok.

Zachowania tej tabeli:

* Wyniki zawsze zawierają dane uśrednione dziennie, tj. wiersz ze źródła 4
  i typu punktu 3 z datą '12-12-2012' zawiera wartość średnią dla tego dnia
  dla wspomnianego punktu i stacji.
* Nie można na tej tabeli robić `DELETE`
* Nie można na tej tabeli robić `UPDATE`


Zadanie 2.4 Wydajność
---------------------

Jak w zadaniu 1.


Challenge
=========

Do tej pory wiersze w tabeli  `DATA_POINT_HISTORY` odnosiły się do tabeli
`DATA_SOURCE`. Kiedy zmienimy źródło danych pośrednio zmienimy również
znaczenie danych w tabeli `DATA_SOURCE`.

Proszę zmienić schemat tak by wprowadzić dane historyczne również do tabeli
`DATA_SOURCE`, wprowadzając `DATA_SOURCE_HISTORY`, wiersze w tabeli
`DATA_POINT_HISTORY` mają klucz obcy do się do tabeli `DATA_SOURCE`, a
wiersze w tabeli `DATA_POINT` mają odniesienie do tabeli `DATA_SOURCE`.

.. note::

    Tak, w tym wypadku dodanie historycznego klucza obcego nie ma wielkiego
    sensu, ale czasem się przydaje!











