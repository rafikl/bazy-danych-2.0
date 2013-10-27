Zajęcia III
===========

Opis zadania
------------

Zadanie polega na wykonaniu schematu bazy danych zawierającego: tabele, relacje
i ograniczenia.

W każdym zadaniu wysyłanie na serwer wykonany schemat bazy danych.

Procedura działania programu sprawdzającego wygląda tak:

* Na czystej bazie danych wdrażam podany przez Was schemat.
* Nastpępnie przeprowadzam serię testów, które mogą sprawdzać takie rzeczy jak:

 * Próba umieszczenia poprawnych danych w bazie danych (i np. sprawdzenia czy
   dane są dostępne po ich umieszczeniu).
 * Próba wprowadzenia niepoprawnych danych (baza powinna zgłosić błąd)

.. figure:: data/db-schema.*

    Schemat bazy do utworzenia


Zadanie 1: tabela ``TAG``
----------------------------
Tabela ``TAG`` ma dwie kolumny: ``key`` oraz ``label`` Kolumna ``key`` jest kluczem głównym.

W podanej tabeli proszę umieścić takie wiersze (tj. dodać wyrażenie INSERT w skrypcie).

=====================   ===================
  key                     label
=====================   ===================
status:student          Student
status:doktorant        Doktorant
status:absolwent        Absolwent
praca:inz               Praca Inżynierska
praca:mgr               Praca Magisterska
praca:dr                Praca Doktorska
=====================   ===================

Zadanie 2: Podstawowy schemat tabeli student
---------------------------------------------

Proszę utworzyć podstawowy schemat tabeli student, czyli:

* Nazwa tabeli ``STUDENT``
* ``id`` które ma wartość ustalaną automatycznie i jest kluczem głównym
* ``name``, ``surname``, ``message``, ``status`` kolumny typu character varying.
* ``gender`` kolumna typu integer

Zadanie 3: Dodanie constraintów do tabeli student
-------------------------------------------------

* ``name``, ``surname``, ``message`` nie może być nullem
* ``gender`` ma wartość ``0`` lub ``1``
* ``status`` jest kluczem obcym to tabeli ``TAG``

Zadanie 4: Tabela pracownik, podstawowy schemat
-----------------------------------------------

Proszę utworzyć podstawowy schemat tabeli ``PRACOWNIK``, czyli:

* Nazwa tabeli ``PRACOWNIK``
* ``id`` które ma wartość ustalaną automatycznie i jest kluczem głównym
* ``name``, ``surname``, ``tel_no`` kolumny typu character varying.
* ``gender`` kolumna typu integer

Zadanie 5: Tabela pracownik, dodatkowe ograniczenia
----------------------------------------------------
Proszę dodać ograniczenia do tabeli pracownik:

* ``name``, ``surname``, ``tel_no`` nie może być nullem
* gender ma wartość 0 lub 1
* tel_no jest ładnie sformatowanym numerem na Wydział
  Fizyki: tj. 22 234-xx-xx gdzie x to liczba od 0 do 9. Polecam
  klauzulę `SIMILAR TO <http://www.postgresql.org/docs/9.0/static/functions-matching.html>`_
  , ale podejrzemwam że można ten sam efekt osiągnąć za pomocą
  kilku ograniczeń

Zadanie 6: Tabela praca dyplomowa
---------------------------------

Tabela ta ma złożony klucz główny, możemy tak zrobić, bowiem pracę
dyplomową jednoznacznie identyfikuje id studenta oraz
jej typ typ. jeden student może napisać jedną pracę
inżynierską.

Podstawowe dane tabeli:

* ``student_id`` Klucz obcy do tabeli student, element klucza głównego
* ``type`` Klucz obcy to tabeli tag, element klucza głównego
* ``promotor_id`` klucz obcy to tabeli pracownik
* tytuł ciąg znaków nie pusty

Zadanie 7
---------
Dodanie warunków kaskadowania do tabeli ``PRACA_DYPLOMOWA``,
W momencie usunięcia studenta usuwane są wszystkie prace dyplomowe
W momencie usunięcia pracownika prace dyplomowe, które promował
przestają mieć przypisanego promotora.

Zadanie 8
----------

Tak skonfigurować klucze obce do tabeli ``TAG``, by
usunięcie wierszy z tej tabeli było niemożliwe, jeśli
do wspomnianych wierszy odnoszą się inne tabele.

Zadanie 9
---------
To zadanie uruchamia wszystkie poprzednie testy, nie trzeba
nic do niego dopisywać.
