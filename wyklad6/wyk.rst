Wykład 6
========

Manipulowanie ciągami znaków
----------------------------

Operatorem konkatenacji jest symbol ||:

.. code-block:: sql

    SELECT 'Ala ma ' || 'kota. ' || 123

Generalnie głównym rodzajem tesktu jakim manipulujemy po stronie
bazy danych postgresql są zapytania. Poniższa funkcja przygtowuje
zapytanie które inna część systemu
wykona, zapytanie to ma wybierać użytkowników którzy nie są
adminami (układ z poprzednich zajęć!):

.. code-block:: sql

    -- Function: foo(character varying)
    -- DROP FUNCTION foo(character varying);
    CREATE OR REPLACE FUNCTION foo(param character varying)
    RETURNS character varying AS
    $BODY$SELECT $SELECT$ SELECT * FROM "USERS" where is_admin = False and name = '$SELECT$ || $1 || $$'$$ $BODY$
    LANGUAGE sql VOLATILE
    COST 100;

Funkcja ta ta jednak ma dziury. Zapytanie: ``select foo($$bar' OR true OR name = '$$)``
zwraca:

.. code-block:: sql

    SELECT * FROM "USERS" where is_admin = False and name = 'bar' OR true OR name = ''

Taka podatność nazwya się sql injection i jest możliwa gdy:

* Użytkownik ma możliwość wpisywania tekstu który trafi do tekstu zapytania sql
  (w naszym przykładzie tym tekstem jest nazwa użytkownika).
* Tekst ten nie jest poprawnie eskejpowany tj. istnieje możliwość by
  został on zinterpretowany jako polecenie SQL, a nie np. stała znakowa.

Funkcje ``quote_xxx``
*********************

By się zapezpieczyć musimy dokonać eskejpowania ciągu znaków danego przez
użytkownika, tak by stanowił on zawsze stałą znakową.
Postgresql pozwala na eskejpowanie dwóch rodzajów ciągów znaków:
identyfikatorów (``quote_ident``) oraz
stałych (``quote_literal``).

Problem eskejpowania stałych jest mniej istotny wewnątrz bazy danych,
ponieważ zakładamy że jeśli atakujący dostał się do bazy danych, w
dziewięciu przypadkach na dziesięć i tak mamy duży problem.


Funkcja format
**************
Bardziej zaawansowaną funkcją jest funkcja ``format``
pozwala ona na wklejenie fragmentów tekstu do szablonu.

Rozważmy:

.. code-block:: sql

    SELECT format('Hello %s, %1$s', 'World') -- Hello World, World

Szablonem jest ciąg znaków: ``'Hello %s, %1$s'``, wewnątrz tego szablonu
umieszczmy znaczniki które będą wymienione na podane paramety.  W naszym
przykładzie takimi znaczyniami są ``%s`` jak i ``%1$s``.

``%s``
    oznacza "wstaw kolejny paramert wywołania jako
    ciąg znaków",
``%1$s``
    "wstaw tutaj wartość pierwszego parametru funkcji"

Więcej o funkcji format w `podręczniku postgresql
<http://www.postgresql.org/docs/9.1/static/functions-string.html>`_.


Wykonywanie ciągów znaków
-------------------------

Sklejanie ciągów znaków widocznych dla użytkownika, jest bardzo
rzadko przydatne. W praktyce jednak często skleja się ciągi znaków
tworząc zapytania które np. tworzą tabele.
Wykonywanie takich zapytań jest
`opisane w podręczniku (proszę przejrzeć!)
<http://www.postgresql.org/docs/9.2/static/plpgsql-statements.html#PLPGSQL-STATEMENTS-EXECUTING-DYN>`_

Sprawdzenie czy dane zapytanie się powiodło
-------------------------------------------

Na zeszłych zajęciach w zadaniu stworzenia procedury pozwalającej
zmianę hasła dla użytkownika należało większość z Państwa miało taką
logikę:

.. code-block:: sql

    IF (SELECT ... FROM "USERS" WHERE user_name = user_name_param AND is_admin= FALSE) THEN
        UPDATE .....
    ELSE
        RAISE EXCEPTION
    ENDIF

Takie coś działałom jednak powodowało dwukrotne przeszukanie tablicy,
raz by stwierdzić czy użytkownik jest administratorem, i raz by zmienić mu hasło.

Można to uprościć:

.. code-block:: sql

    UPDATE "USERS" WHERE user_name = user_name_param and is_admin = false;
    IF NOT FOUND THEN
        RAISE EXCEPTION ...
    ENDIF

``FOUND`` jest magiczną zmienną która jest prawdziwa jeśli
ostatnie polecenie się powiodło. Dokładne wyjaśnienie tej
zmiennej w `podręczniku
<http://www.postgresql.org/docs/9.2/static/plpgsql-statements.html#PLPGSQL-STATEMENTS-DIAGNOSTICS>`_

Transakcje
----------

Transakcje są metodą na deterministyczny dostęp do bazy danych
przez wielu równoległych klientów.


By rozpocząć transakcję należy wpisać słowo kluczowe
``BEGIN``, by ją zamknąć i zapisać zmiany ``COMMIT``
a by je odrzucić ``ROLLBACK``.

.. _wyk6-tran-example:

Przykład transakcji
*******************

Wstępne polecenia:

.. code-block:: sql

    CREATE TABLE foo (
    foo integer,
    bar integer
    );
    INSERT INTO foo (foo, bar) VALUES (1, 2);
    INSERT INTO foo (foo, bar) VALUES (2, 3);
    INSERT INTO foo (foo, bar) VALUES (3, 4);
    INSERT INTO foo (foo, bar) VALUES (1, 2);
    INSERT INTO foo (foo, bar) VALUES (2, 3);
    INSERT INTO foo (foo, bar) VALUES (3, 4);

Proszę teraz otworzyć dwie konsole psql w pierwszej wpisać:

.. code-block:: sql

    BEGIN; -- rozpoczynamy tansakcje
    DROP TABLE foo;

a w drugiej:

.. code-block:: sql

    BEGIN
    SELECT * FROM foo;

Okazuje się że zapytanie nie możę się wykonać. Bo druga transakcja
nie 'wie' jeszcze czy pierwsza usunie tabelę, czy ją zostawi.
Jeśli w pierwszej konsoli wpiszemy ROLLBACK okaże się że
druga transakcja zwróci wyniki, a jeśli COMMIT zwróci błąd
(tabela nie istnieje).

Natomiast jeśli wpiszemy takie polecenie zobaczymy że transakcja widzi
swoje zmiany:

.. code-block:: sql

    foo=# BEGIN; -- rozpoczynamy tansakcje
    BEGIN
    foo=# DROP TABLE foo;
    DROP TABLE
    foo=# select * from foo;
    ERROR:  relation "foo" does not exist
    LINE 1: select * from foo;

Transakcje a procedura
----------------------

Procedury zawsze wykonywane są wewnątrz transakcji która
zainincjowała wywołanie procedury, jeśli nie ma tam transakcji,
to procedura będzie wykonana w nowej transakcji.

Jeśli procedura A wywołuje procedurę B to oznacza że B będzie
wykonane dokładnie w tej samej transakcji co A
(co może być nie dobre).

Poziomy izolacji transakcji
---------------------------

Poziom izolacji transakcji definuje jak bardzo transakcje są od siebie
odizolowane. Najwyższym poziomem izolacji jest ``SERIAL``,
który znaczy że silnik baz danych zapewnia że transakcje wykonują się
tak jak by były wykonywane jedna po drugiej (nie oznacza to że
nie mogą być wykonywane równolegle: oznacza to z wewnątrz transakcji
działania innych traksakcji są niewidoczne).
Proszę doczytać:
http://www.postgresql.org/docs/9.2/static/transaction-iso.html
.

W wersji minimum proszę przeczytać wszystko przed paragrafem
13.2.1.

Locki
-----

W dowolnej chwili dowolna transakcja może powiedzieć: "Ta tabela
należy do mnie, nikt nie może do niej zapisywać, z niej czytać, ... itp."
Poziomów locków jest dużo (
http://www.postgresql.org/docs/9.1/static/explicit-locking.html
).

Co ważne niektóre operacje automatycznie zakładają locki na tabele
(to jakie locki są zakładane przez opracje zależy od ustawionego
poziomu izloacji transakcji).

Zachowanie z przykładu :ref:`wyk6-trans-example` (druga transakcja
czekała na pierwszą, wynikało z tego że polecenie ``DROP TABLE``
zakłada locka na tabelę).

Transakcje a zakleszczenie (deadlock)
-------------------------------------

Wyobraźmy sobie taki problem: Mamy stół przy którym siedzi N
biednych filozofów, którzy jedzą spagetti. By jeść spagetti
trzeba mieć dwa widelce. Biedni filozofowie mają po jednym
widelcu.

Procedura jest taka:

* W dowolnej chwili filozof podnosi swój widelec.
* Jeśli sąsiad po jego lewej stronie nie je zabiera mu widelec
* Zaczyna jeść
* Odkłada oba widelce

Pytanie brzmu: "Czy filozofowie umrą z głodu". Odpowiedź brzmi:
"zupełnie nie wiadomo".

Jeśli w danej chwili każdy z filozofów będzie wykonywać krok nr. 1,
to żaden nigdy nie będzie mógł wykonać kroku numer 2. W zależności
od parametróe problkemu takie zdarzenie jadnak może nigdy nie zajść.

Polecam:
http://pl.wikipedia.org/wiki/Problem_ucztuj%C4%85cych_filozof%C3%B3w
.

Ale co to ma do baz danych? Otóż w bazie danych takie zakleszczenia
też mogą się zdarzyć.

.. code-block:: sql

    CREATE TABLE foo (
    foo integer,
    bar integer
    );
    CREATE TABLE bar (
    foo integer,
    bar integer
    );

Proszę otworzyć dwie konsole w pierwszej wpisać:

.. code-block:: sql

    BEGIN;
    DROP TABLE foo;

w drugiej:

.. code-block:: sql

    BEGIN;
    DROP TABLE bar;
    SELECT * FROM foo;

w pierwszej:

.. code-block:: sql

    SELECT * FROM bar;

W tej sytuacji select z tabeli bar (wykonywany w transakcji 1)
będzie czekał na to czy tranzakcja
usuwająca tą tabelę (w transakcji 2) się skomituje (czy nastąpi rollback),
ale transakcja ta czeka na to czy ty transakcja 1 się skomituje.

Wynikiem tej sytuacji było:

.. code-block:: sql

    foo=# select * from foo;
    ERROR:  deadlock detected
    LINE 1: select * from foo;
    ^
    DETAIL:  Process 25568 waits for AccessShareLock on relation 260507 of database 235641; blocked by process 25449.
    Process 25449 waits for AccessShareLock on relation 301119 of database 235641; blocked by process 25568.
    HINT:  See server log for query details.

Postgresql nie dopuszcza do deadlocków poprzez ubijaie transakcji które blokują bazę danych.

Zgłaszanie błędów
-----------------

Do zgłoszenia informacji do użytkownika służy polecenie ``RAISE``:

.. code-block:: sql

    RAISE LEVEL "FORMAT", parameters

``Level`` określa poziom błędu, gdy poziomem tym jest ``EXCEPTIOM``
zgłoszenie błędu przerywa transakcję. W innym przypadku powoduje
zapisanie błędu do pliku lub konsoli osoby uruchamiającej zapytanie.
Domyślnie zapisywane są informacje na poziomie ``NOTICE`` lub wyższe.

Można to zmienić wykonując:

.. code-block:: sql

    SET client_min_messages = DEBUG1; -- wyświetla błędy użytkownikowi
    SET log_min_messages = DEBUG1; -- zapisuje do pliku logów.

Obsługa błędów
--------------

.. code-block:: sql

    BEGIN
        statements
    EXCEPTION
        WHEN condition [ OR condition ... ] THEN
            handler_statements
        [ WHEN condition [ OR condition ... ] THEN
            handler_statements
        ... ]
    END;

Co jest ważne, to to że w Psql nie ma typów wyjątków, tak
jak w Javie czy ``C++``. Różne rodzaje sytuacji wyjątkowych rozpoznaje się
za pomocą kodów błędów lub ich nazw. Na przykład:

.. code-block:: sql

    WHEN division_by_zero THEN ...
    WHEN SQLSTATE '22012' THEN ...


Pełna lista kodów błędów:
http://www.postgresql.org/docs/9.1/static/errcodes-appendix.html
Dodatkowe info:
http://www.postgresql.org/docs/9.1/static/plpgsql-control-structures.html#PLPGSQL-ERROR-TRAPPING

Przy wysyłaniu błędów też możemy specyfikować stan:

.. code-block:: sql

    RAISE division_by_zero; --- bez podania wiadomości
    RAISE SQLSTATE '22012'; --- określenie numerycznego błędu
    RAISE unique_violation USING MESSAGE = 'Duplicate user ID: ' || user_id; ---z podaniem tekstu i stanu błędu

Widoki
------

Wróćmy przez chwilę do pomysłu normalizacji schematu. Na :ref:`zajecia3`
dokonywaliśmy normalizacji schematu, poprzez wprowadzenie
dziedziczenia na tabelach.

.. figure:: /wyklad3/data/db-schema.*


Powiedzmy że chcemy udostępnić tabelę która udostępnia wszystkie dane
sytudenta, jednak nie łamać wymogów normalizacji (dane są w jednym miejscu).

Prawidłowym rozwiązaniem będzie wprowadzenie widoku, który wybiera
dane z tabel ``OSOBA`` i ``STUDENT``.

Materializowane widoki
----------------------

Czasem zapytanie które realizuje dany widok trwa nie kilka sekund,
a kilka godzin. W takim wypadku tworzymy tzw. materializowany widok,
czyli tabelę która pełni rolę widoku, tj. przechowuje wyniki
pewnego zapytania, ale dane te są fizycznie na dysku.

Materializowane widoki łamią wymaganie normalizacji danych, ale
czasem są koniecznością.

Dodatkowo do materializowanych widoków raczej nie powinno robić się
insertów czy updejtów.

Moment odświerzania materializowanego widoku zależy od wymagań
aplikacji. Możliwe jest takie opracowanie triggerów by materializowany
widok był zawsze aktualny. Jednak. jeśli rozmawiamy o aplikacji księgowej, która w
materializowanym widoku trzyma jakieś raporty finansowe, to może starczy
odświerzać wyniki o godzinie 3.00, a może starczy raz na miesiąc.

Język postgresql ma bardzo prostą implementację materializowanych widoków,
dostępną od `aktualnej wersji 9.3
<http://www.postgresql.org/docs/9.3/static/rules-materializedviews.html>`_

Tabele historyczne
------------------

Powiedzmy że w tabeli ``ZAKUPY`` przechowujemy dane o
zakupach (czymkolwiek one by nie były). Tabela ta zawiera klucz główny w
kolumnie id.

Może pojawić się potrzeba przechowywania nie tylko bierzącego stanu
danego zakupu, ale również historii stanu dla każdego z zakupów.
Tworzymy zatem tabelę ZAKUPY_HISTORIA która ma złożony
klucz główny jednym z elementów tego klucza jest klucz obcy to tabeli
``ZAKUPY``, drugim numer wersji danego wiersza.
Strona ta stosuje pliki cookies generowane przez system gogole analytics.
Można sobie je wyłączyć do jej prawidłowego działania.

Przejrzenie materiałów na zajęcia.
----------------------------------

Dobrym pomysłem byłoby zapoznanie się z materiałami na ćwiczenia.

