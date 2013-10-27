Wykład 4
========


Migrowanie schematu
-------------------

Złośliwi twierdzą, że gdyby mosty były budowane przez informatyków,
przeciętny most rozpadałby się po trzech dniach od postawienia.
Informatycy twierdzą natomiast, że gdyby przeciętny most był projektowany
jak informatyczny projekt, to okazałoby się, że ów most w pierwszej
koncepcyjnej wersji byłby `mostem powietrznym <http://pl.wikipedia.org/w/index.php?title=Operacja_Vittles&oldid=36450042>`_.

Ewolucja systemów informatycznych jest koniecznością, więc prędzej czy
później pojawia się konieczność ewoluowania schematu bazy danych.

Wraz z ewolucją schematu pojawia się konieczność migracji
danych między nowym a starym schematem.

Dobrą praktyką jest przechowywanie skryptów do migracji danych oraz
posiadania migracji wstecznych.

Przykładowo deweloper opracowuje migrację schematu danych z wersji X do Y na swoim
komputerze, następnie jest ona testowana na systemie testowym, by
wreszcie trafić na produkcję.

Pojawia się zatem konieczność oprogramowania takich rzeczy jak:

* Przechowywania w schemacie danych jego wersji --- różne środowiska w jednym
  projekcie mogą posiadać różne wersjie bazy danych (np. migracje
* Opracowanie narzędzia do migracji danych.

Typowe wymagania dla narzędzia do migracji
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

* Narzędzie to przechowuje dane o aktualnej wersji bazy danych
* Narzędzie to umożliwia tworzenie porządku w migracjach, to jest określać
  która wersja jest starsza od której, oraz np. zmigrować daną bazę danych
  do najnowszej wersji

Opcjonalnie:

* Generowanie kodu migrującego bazę danych między schematami

Jakie własności w relacyjnych bazach danych ułatwiają nam migrowanie danych
---------------------------------------------------------------------------

Posiadanie schematu
^^^^^^^^^^^^^^^^^^^

Bazy danych ułatwiają migracje danych z powodu posiadania możliwości
budowania ograniczeń w schemacie, tj. by pisać migracje danych nie
musimy posiadać dostępu do danych: w zasadzie starczy znajomość schematu
bazy danych. Jest to ważne, ponieważ często, w praktyce, programiści nie
mają dostępu do produkcyjnej danych (na przykład w banku).

By zmigrować dane nie muszę znać samych danych --- starczy znajomość
ich schematu.

Transakcyjność
^^^^^^^^^^^^^^

Drugą cechą, która ułatwia migrowanie baz danych, jest ich
transakcyjność. Intuicyjnie transakcja jest metodą na wykonywanie
wielu poleceń, tak jakby były jednym atomowym poleceniem z
punktu widzenia reszty bazy danych. Transakcje są atomowe, w tym sensie,
że wykonują się poprawnie, albo nie wykonują się w ogóle. Co między innymi znaczy, że
albo wszystkie więzy w bazie są spełnione pod koniec transakcji, albo
transakcja jest wycofywana.


Inaczej mówiąc transakcja jest metodą przenoszenia bazy danych z
jednego, dobrze zdefiniowanego, stanu do innego
dobrze zdefiniowanego stanu.

W praktyce oznacza to, że migracja bazy ze stanu X do Y,spowoduje, że
po jej wykonaniu baza będzie w stanie Y (wersja optymistyczna) lub X
(wersja pesymistyczna, kiedy migracja się nie powiedzie). Nie możliwe jest
np. to by baza po migracji nie nadawała się do użytku,

Techniki dziedziczenia w bazie danych
-------------------------------------

Powiedzmy że mamy dwie tabele, które przechowują podobne dane, na przykład
tabele pracownik i student z poprzedmich zajęć. Chcielibyśmy jakoś
wyrazić to podobieństwo. W językach obiektowych takie podobieństwo
wyrażamy za pomocą dziedziczenia, podobne określenie stosuje się w
bazach danych.

Dwie oddzielne tabele
^^^^^^^^^^^^^^^^^^^^^

Trzymamy dane w dwóch oddzielnych tabelach.
W bazie danych nie ma relacji, jest to przykład z poprzednich zajęć.

Cechy tego rozwiązania:

* Najprostsze rozwiązanie
* Nie ma joinów
* Nie da się wyrazić tego że ktoś jest zarówno studentem jak i
  pracownikiem
* Można wybrać dane wszystkich osób (zarówno studentów jak i pracowników),
  jednak jest to nie wygodne (operator `UNION <http://www.postgresql.org/docs/9.2/static/sql-select.html#SQL-UNION>`_)

Dziedziczenie tabel
^^^^^^^^^^^^^^^^^^^

Mamy trzy tabele: ``osoba``, ``pracownik``, ``student``.

.. figure:: data/db-schema-rel.*

    Dziedziczenie w bazie danych

Tabela ``osoba`` trzyma dane wspólne dla tabel ``pracownik`` i ``student``. Klucz
główny tabel ``pracownik`` i ``student`` jest jednocześnie kluczem obcym do
tabeli ``osoba``.

Cechy schematu:

* Żeby wybrać dane o studencie i pracowniku należy dokonać JOINA.
* Łatwo wybrać dane wszsytkich osób, jest to naturalne.
* Można wyrazić że ktoś jest i pracownikiem i studentem.

Pojedyńcza tabela
^^^^^^^^^^^^^^^^^

Mamy jedą tabelę, która zawiera dane zarówno studenów, jak i pracowników,
zawiera ona kolumny obu tych tabel. Zawiera też dodatkową kolumnę która
zawiera informacje czy dany wiersz reprezentuje studenta czy pracownika.
Dane dotyczące pracownika w wierszu reprezentującym studenta mają
wartość NULL.

.. figure:: data/db-schema-single-table.*

    Dziedziczenie przez zastosowanie jednej tabeli

Cechy rozwiązania:

* Nie ma joinów
* Może być problem z osobą która jest i studentem i pracownikiem.
* Nie możemy dawać constraintów NON NULL na kolumnach
  należących dla pracownika i studenta (można to emulować innymi constraintami).
* Są problemy z unikalnymi ograniczeniami dotyczącymi oddzielnie
  studentów i pracowników.
* Tworzenie kluczy obcych do pracowników i studentów może być trudne.

Dziedziczenie POSTGRESQL
^^^^^^^^^^^^^^^^^^^^^^^^


.. figure:: data/db-schema-inherits.*

    Dziedziczenie postgresql

Postgresql umożliwia `dziedziczenie tabel <http://www.postgresql.org/docs/9.2/static/ddl-inherit.html>`_.

Rozważmy taki przykład:

.. code-block:: sql

    -- Uwaga! te tabelki są podobne to tych które będziecie Pańwtwo robić na zajęciach.
    -- ale nie są takie same!
    CREATE TABLE OSOBA(
        id serial,
        name character varying,
        surname character varying,
        primary key id
    );

    CREATE TABLE STUDENT(
        message character varying
    ) INHERITS (OSOBA);

Oznacza on że:


* Tabela student ma kolumny ``id``, ``name`` i ``surname``.
* Tabela student nie dziedziczy więzów (primary key)
* Po insercie do tabeli ``student``, dane też pojawią się w tabeli
  ``osoba``.

Cechy tego rozwiązania

* Może być problem z osobą która jest i studentem i pracownikiem.
* Są problemy z unikalnymi constraintami.
* Tabela po której dziedziczą inne tabele nie wspiera wszystkich
  operacji SQL.

Przydatne cechy dialektu SQL postgres
-------------------------------------

INSERT from SELECT
^^^^^^^^^^^^^^^^^^

Do kopiowania danych między tabelami służy polecenie INSERT,
które zamiast listy wartości może przyjąć zapytanie.

.. code-block:: sql

    INSERT INTO OSOBA(name, surname) (SELECT name, surname FROM OSOBA_OLD);

INSERT, UPDATE, DELETE RETURNING
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Nie tylko zapytania ``SELECT`` pozwalają na zwracanie zbiorów danych,
do zapytań ``INSERT``, ``UPDATE``, ``DELETE`` można dołączyć klauzulę
``RETURNING`` która spowoduje że zapytanie to zwróci zmodyfikowane rekordy.

Przykładowo takie zapytanie spowoduje zwrócenie automatycznie nadanych id.

.. code-block:: sql

    INSERT INTO OSOBA(name, surname) (SELECT name, surname FROM OSOBA_OLD) RETURNING id;

.. note::

    Klauzula returning jest rozszerzeniem postgresql i może jej nie być w
    wielu serwerach (w wielu poważniejszych jest obecna!)

UPDATE FROM
^^^^^^^^^^^

W postgresql możliwe jest wykonywanie instrukcji:

.. code-block:: sql

    UPDATE "FOO" SET foo = bar.foobar FROM "BAR" bar, "BAZ" baz WHERE foo = baz.baz

klauzula ``FROM`` pozwala podać wiele nazw tabel, podanie kilku
tabel spowoduje że najpierw zostanie wykonany kartezjański produkt tabel
z których wybieramy, następnie zostanie dokonany update.

Common table expression
^^^^^^^^^^^^^^^^^^^^^^^
Common Table Expressions to mechanzim pozwalający dołączyć do jednego
zapytania wynik innego zapytania:

.. code-block:: sql

    WITH ids AS (
        INSERT INTO OSOBA(name, surname) (SELECT name, surname FROM OSOBA_OLD) RETURNING id;
    ) INSERT INTO STUDENT ( tutaj mamy dostępną magiczną tabelę ids, zawierającą nadane id);



