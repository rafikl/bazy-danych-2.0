Zajęcia 4
=========

Na dzisiejszych zadaniach będziemy pracować nad
migracją schematu z poprzednich zajęć.

Algorytm wykonywania sprawdzania **każdego zadania** jest następujący:

* Tworzona jest nowa baza danych.
* Wprowadzany jest modelowy schemat danych z
  :doc:`poprzednich zajęć </wyklad3/zaj3>`.
* Wprowadzane są losowane testowe dane.
* Państwa migracja jest wprowadzana
* Wykonuje testy

Potencjalne problemy
--------------------

.. warning::::

  Proszę sprawdzać kod migracji na **swojej bazie danych**
  w jeśli kod ten zgłosi wyjątek, migracja się nie powiedzie,
  co pociągnie za sobą błędy w testach, które mogą niewiele
  mówić o przyczynie problemów.

.. note::

    Dobrą metodą na skasowanie danych z bazy danych jest
    wykonanie polecenia:

    .. code-block:: sql

        DROP SCHEMA public CASCADE;
        CREATE SCHEMA public;

Zbiór zadań nr 1 --- migracja bazy danych do schematu SINGLE-TABLE
------------------------------------------------------------------


Ilość zadań w tym zbiorze: 5 (numery 100, 101, 102, 103, 104)

W tym zestawie zadań będziemy migrować bazę danych do schematu w którym
dane o studentach i pracownikach będą w jednej tabeli

Etap 1.1 (nieoceniane) zadania przygotowawcze
puste.

Etap 1.2 (nieoceniane)  stworzenie tabeli osoba
-----------------------------------------------

Proszę stworzyć tabelę osoba, która ma takie kolumny:

* ``id`` serial  klucz główny
* ``type`` character varying czy w danym wierszu mamy
  przechowywanego studenta czy pracownika.
* ``name`` character varying NOT NULL
* ``surname`` character varying NOT NULL
* ``status`` character varying
* ``message`` character varying
* ``tel_no`` character varying
* ``gender`` integer

Proszę zauważyć że nie możemy wymagać by message nie było
nullem (jak to było na zeszłych zajęciach), bo w danym wierszu
może być przechowywany pracownik, który message z założenia nie ma!

Etap 1.3 stworzenie tabeli osoba --- constrainty
------------------------------------------------

Proszę dodać takie więzy do tabeli ``OSOBA``

* Poprawna płeć (jak tydzień temu)
* ``type`` jest kluczem obcym to tabeli`` TAG``
  która zawiera dwa nowe klucze: ``type:prac`` i
  ``type:stud``. Jeśli dany rekord ma ``type:prac``
  to jest pracownikiem, a jeśli  type:stud studentem.
* ``status`` i ``message`` nie są nulem kiedy dany rekord jest studentem
  ``tel_no`` nie jest nullem kiedy dany rekord jest pracownikiem
  Status jest kluczem obcym do tabeli tag.

W tabeli TAG nie ma kluczy: ``type:prac`` i
``type:stud``, proszę je dodać.

Etap 1.4 (nieoceniane) zadania przygotowawcze
---------------------------------------------

Proszę usunąć wszystkie więzy które spowodują że migracja się
nie powiedzie (potem je odtworzymy).

Etap 1.5 (oceniane) migracja danych do tabeli osoba
---------------------------------------------------

Skopiowanie danych do nowej tabeli powinno być proste, zasadniczym
problemem jednak jest to że wartości ``id`` w tabelach
``PRACOWNIK`` i ``STUDENT`` powtarzają się.
Powoduje to konieczność przepisania odniesień w tabeli
``PRACA_DYPLOMOWA``.

By to zrobić musimy tymczasowo w tabeli ``OSOBA`` przechować
stare ``id`` danej osoby z tabeli ``PRACOWNIK``
lub ``STUDENT``, a  nastepnie przepisać dane.

By przenieść dane z tabeli ``PRACOWNIK`` i ``STUDENT``
należy:

* Dodać do tabeli ``OSOBA`` dwie kolumny student_id
  oraz pracownik_id.
* Umieścić dane z tabel ``PRACOWNIK`` i
  ``STUDENT`` w tabeli OSOBA, kolumne
  ``id`` z tabeli PRACOWNIK umieszczamy
  w kolumnie ``pracownik_id``.
* W tabeli ``PRACA_DYPLOMOWA`` odświerzyć zawartość
  kolumn ``promotor_id`` oraz ``student_id``
  tak by prace odnosiły się do wierszy w tabeli ``OSOBA``.
* Umieścić z powrotem ograniczenia w tabeli
  ``PRACA_DYPLOMOWA`` oraz ``OSOBA``
* Usunąć tabele ``PRACOWNIK`` oraz
  ``STUDENT``
* Usunąć z tabeli ``OSOBA`` kolumnty ``student_id``,
  ``pracownik_id``

Zadania
^^^^^^^

* Poprawnie przeprowadzone kopiowanie do tabeli osoba oceniane jest
  jako zadanie 101.
* Poprawne przepisanie danych w tabeli ``PRACA_DYPLOMOWA``
  oceniane jest jako zadanie 102
* Wyczyszczenie schematu (usunięcie tabel ``PRACOWNIK`` oraz
  ``STUDENT``) oraz niepotrzebnych kolumn z tabeli ``OSOBA``
  oceniane jest jako zadanie 103
* Cała migracja oceniana jest jako zadanie 104

Zbiór zdań II --- migracja do schematu z postgresowym dziedziczeniem tabel
--------------------------------------------------------------------------

Ilość zadań w tym zbiorze: 4 (numery 100, 101, 102, 103)

Przemigrujmy teraz ten sam schemat do innej postaci,
takiej korzystającej z dziedziczenia Postgresql.
W tym układzie mamy trzy tabele: ``OSOBA``.
``PRACOWNIK`` oraz ``STUDENT`` przy czym
``PRACOWNIK`` oraz ``STUDENT`` dziedziczą
po osobie.

Etap 2.1 (nieoceniane)
----------------------
Proszę usunąć wszystkie więzy z całego schematu. Proszę
zmienić nazwy tabel ``PRACOWNIK`` oraz ``STUDENT``
na ``PRACOWNIK_OLD`` oraz ``STUDENT_OLD``.

Etap 2.2
--------
Stworzenie schematu tabel ``OSOBA``.
``PRACOWNIK`` oraz ``STUDENT``.

Tabela ``OSOBA`` zawiera:

* ``id`` serial  klucz główny
* ``name`` character varying NOT NULL
* ``surname`` character varying NOT NULL

Tabela ``STUDENT`` zawiera:

* ``status`` character varying
* ``message`` character varying

Tabela ``PRACOWNIK`` zawiera:

* ``tel_no`` character varying

Zadanie 2.3 Migracja danych
---------------------------

Tutaj podobnie: należy przepisać klucze główne w tabeli
``PRACA_DYPLOMOWA``.

Zadania:
^^^^^^^^
* Poprawnie przeprowadzone kopiowanie do tabeli osoba oceniane jest
  jako zadanie 201.
* Poprawne przepisanie danych w tabeli PRACA_DYPLOMOWA
  oceniane jest jako zadanie 202
* Wyczyszczenie schematu (usunięcie tabel ``PRACOWNIK_OLD`` oraz
  ``STUDENT_OLD``) oraz niepotrzebnych kolumn ze wszystkich tabel
  oceniana jest jako zdanie 203


Proszę zainstalować ograniczenia z poprzednich zajęć na tych tabelach
Podane zadanie jest oceniane jako zadanie 200

Challenge
---------

Migracja danych do schematu na rysunku:

.. figure:: data/db-schema-rel.*

    Migracja danych do schematu