Wykład 5
========

Na wejściówkę
-------------

Wejściówka będzie raczej praktyczna. Proszę być w stanie napisać
prostą procedurę pgSQL, prosty trigger, czy wiedzieć co się
dzieje jak trigger zwraca ``NULL``.

Język plPGSQL
-------------

Język plPLGSQL jest rozwiniętym językiem proceduralnym działającym
po stronie serwera psql.

Nie jest to jedyny język w jakim można pisać procedury składowane bazy danych
postgresql, procedury można pisać w:

* `Pythonie <http://www.postgresql.org/docs/9.3/static/plpython.html>`_
* Javaskrypcie (od wersji 9.3), dostępny jako rozszerzenie
* Perlu (jako rozszerzenie)
* Jako dowolny skrypt powłoki (tego nie polecam...)
* SQL (zwykły SQL bez rozszerzeń ``pl/pgSQL``)

Stałe znakowe
-------------
W postgresql stałe znakowe definiowane są za pomocą pojedyńczych
cudzysłowów ``'foo'``.

Możliwa jest też inna postać stałych znakowych:
``$tag$treść$tag$``, gdzie ``$tag$`` może
zawierać wewnątrz dowolny ciąg znaków (w szczególności może to być:
``$$``)

Takie stałe znakowe łatwo jest zagnieżdżać.

.. note::

    Notacja ta jest bardzo ważna, ponieważ większość kodu pl/pgSQL jest umieszczana
    na serwerze jako ciągi znaków.



Struktura plpgsql
------------------

Blok kodu plpgsql ma następującą strukturę
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sql

    [ DECLARE
    declarations ]
    BEGIN
    statements
    END;

Część zaczynająca się od ``DECLARE`` zawiera deklaracje zmiennych.
między ``BEGIN`` a ``END`` mamy jakieś wyrażenia.


Blok ``DECLARE``
^^^^^^^^^^^^^^^^

Block declare zawiera nazwy i typy wszystkich zmiennych dostępnych w
procedurze.

Składnia jest taka jak przy tworzeniu tabel, czyli:

.. code-block:: sql

    DECLARE
        nazwa typ;
    BEGIN
        ...
    END;

Typy dostępne w bloku declare
*****************************

Dostępne są wszystkie typy które mogą być użyte w ``CREATE TABLE`` a nawet więcej.

By wskazać na typ będący wierszem tabeli ``"FOO"`` możemy napisać: ``"FOO"%ROWTYPE``,
by wskazać na wiersz będący wierszem dowolnej tabeli należy użyć typu ``record``.

Podstawowe konstrukcje języka
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. note::

    Uwaga większość tego rozdziału jest pobrana z
    `podręcznika postgresa <http://www.postgresql.org/docs/9.3/static/plpgsql-control-structures.html>`_

Wyrażenie warunkowe IF
^^^^^^^^^^^^^^^^^^^^^^

Przykładowo:

.. code-block:: sql

    IF v_user_id <> 0 THEN
        UPDATE users SET email = v_email WHERE user_id = v_user_id;
    END IF;


Składnia podstawowej wersji:

.. code-block:: sql

    IF boolean-expression THEN
        statements
    END IF;


``IF`` można zagnieżdżać:

.. code-block:: sql

    IF demo_row.sex = 'm' THEN
        pretty_sex := 'man';
    ELSE
        IF demo_row.sex = 'f' THEN
            pretty_sex := 'woman';
        END IF;
    END IF;

Pętla WHILE
^^^^^^^^^^^

.. code-block:: sql

    WHILE NOT done LOOP
        -- some computations here
    END LOOP;

Pętla ``FOR``
^^^^^^^^^^^^^
Pętla for pozwala na iterowanie po wynikach zapytań, przykładowo


.. code-block:: sql

    FOR nazwa IN zapytanie LOOP

    END LOOP;


Przykładowo tak można rozwiązać problem migracji danych na poprzednie
zajęcia:

.. code-block:: sql

    DECLARE
        r record;
        new_id integer;
    BEGIN
        FOR r in SELECT * FROM "PRACOWNIK" LOOP
            INSERT INTO "OSOBA"(name, surname, gender, tel_no) VALUES (r.name, r.surname, r.gender, r.tel_no) RETURNING id INTO new_id;
            UPDATE "PRACA_DYPLOMOWA" SET promotor_id = new_id WHERE promotor_id = r.id;
        END LOOP;
    END;

Struktura ``DO``
^^^^^^^^^^^^^^^^

Mamy już jakieś podstawy jęzka ``pl/pgSQL``, ale jeszcze nie wieamy jak
polecenia PSQL rzeczywiście wykonać ---
zarówno psql oraz pgadmin III oczekują kodu ``SQL``.

Pierwszą metodą wykonania kodu plPGSQL jest komenda DO, jej struktura jest taka:

.. code-block:: sql

   DO stała_znakowa;


Gdzie ``stała_znakowa`` to ciąg znaków zawierający kod ``pl/pgSQL``.

Przykładowo:

.. code-block:: sql

    DO $$
    DECLARE
        r record;
        new_id integer;
    BEGIN
        FOR r in SELECT * FROM "PRACOWNIK" LOOP
            INSERT INTO "OSOBA"(name, surname, gender, tel_no) VALUES (r.name, r.surname, r.gender, r.tel_no) RETURNING id INTO new_id;
            UPDATE "PRACA_DYPLOMOWA" SET promotor_id = new_id WHERE promotor_id = r.id;
        END LOOP;
    END;
    $$

Uprawnienia w psql
------------------
Często aplikacje korzystające z bazy danych mają bardzo wysokie
uprawnienia w bazie danych,
czasem jednak warto ograniczyć uprawnienia danego użytkownika do
wykonywania konkretnych operacji.

Poziomy uprawnień w postgresie:

``SUPERUSER``
    superuser moze wszystko.

    .. code-block:: sql

        CREATE USER name SUPERUSER;

``OWNER``

    właściciel bazy danych, może robić wszystko w bazie danych

    .. code-block:: sql

        CREATE DATABSE foo OWNER bar;

    Każdy inny obiekt w bazie danych również ma przypisanego
    właściciela.

``POZOSTALI``

    mają uprawnienia do tego do czego je otrzymali.

    By nadać komuś uprawnienia należy wykonać polecenie ``GRANT`` opisane
    `w podręczniku <http://www.postgresql.org/docs/8.1/static/sql-grant.html>`_.

    Ja (jak zwykle) raczej radzę używać pgAdmina, który
    pozwala to wyklikać.

Zmiana ownera w psql
--------------------

Zmiana ``OWNER-a`` może być problematyczna. Użytkownik P może X przypisać
właściciela O tylko wtedy gdy:

* Użytkownik O mógłby stworzyć obiekt X

 * Jeśli obiektem X jest tabela czy widok to O musi mieć uprawnienia do
   tworzenia obiektów w danym schemacie.
 * Jeśli obiektem X jest baza danych, O musi mieć uprawnienie do tworzenia
   baz danych

* Użytkownik P będzie mógł dalej modyfikować X (nawet po zmianie właściciela).


Role w psql
-----------


Oprócz użytkowników mamy w postgresie również role.
Rola zestaw uprawnień który możemy nadać użytkownikom.

.. code-block:: sql

    CREATE ROLE administrator;
    CREATe USER jbzdak;
    GRANT administrator TO jbzdak;

Najbardziej polecanym rozwiązaniem jest nadawanie uprawnień dla ról i przypisywanie
ich użytkoownikom.

Funkcje jako dodatkowa kontrola uprawnień
-----------------------------------------

Uprawnienia nadane przez ``GRANT`` czasem nie są wystarczająco
dokładne. Możemy zabronić danemu użytkownikowi edytowania danej tabeli.
ale nie możemy powiedzieć: "możesz edytować jeśli prawdziwy jest warunek
foo".

Powiedzmy że chcemy zaimplementować następującą funkcjonalność:

* Mamy tabele użytkowników, którzy dzielą się na dwie kategorie:
  użytkwonik i administrator.
* Użytkownicy ci nie mają nic wspólnego z bazą danych, są to
  użytkownicy jakiegoś systemu który korzysta z bazy danych.
* Na poziomie bazy danych chcemy ograniczyć dostęp użytkownika
  bazodanowego w taki sposób by mógł on edytować dane zwykłych
  użytkowników a nie mogł dotknąć administratorów.

Taki schemat dostępu nie jest możliwy do zaimplementowania za pomocą
poleceń grant. Można jednak go zaimplementować za pomocą funkcji
postgresql.

Funkcie postgresql zasadniczo mają uprawnienia użytkownika
który je wykonuje, jednak można je sonfigurować tak by wykonywały się
z uprawnieniami osoby która je zdefiniowała.

W takim wypadku użytkownik nie ma prawa modyfikować tabeli użytkownik, ma
natomiast prawo do wykonania procedury która pozwala na modyfikację
zwykłych użytkowników, ale nie zezwala na modyfikację administratorów.


Manipulacja użytkownikami (rolami)
----------------------------------

Role są zdefiniowane na poziomie klastra baz danych (danej instancji
``postgresql``). Użytkownik to rola, która może się logować.

.. code-block:: sql

    CREATE USER foo; -- Tworzenie użytkownika foo
    CREATE ROLE bar; -- Tworzenie roli bar
    GRANT bar to foo;  -- Nadanie foo uprawnień roli bar.

Uprawnienia logowania
^^^^^^^^^^^^^^^^^^^^^

Postgresql umożliwia dwie metody logowania do bazy danych, za pomocą
połączenia ``TCP/IP`` oraz za `pomocą gniazd linuksa
<http://en.wikipedia.org/wiki/Unix_file_types#Socket>`_ (u mnie gniazdo to jest w
``/var/run/postgresql/.s.PGSQL.5432``).

W pliku ``pg_hba.conf`` (u mnie jest on w
``/etc/postgresql/9.3/main/pg_hba.conf``), znajdują się opcje konfigurujące
metody audentykacji dla różnych użytkowników, baz i metod komunikacji.

Metody logowania są takie:

``reject``
    Powoduje odrzucenie prób logowania.
``trust``
    Powoduje że każda próba logowania się powiedzie (możemy określić
    na jakiego użytkownika się logujemy)
``peer``
    Działa dla logowania za pomocą plików gniazd, i powoduje że użytkownik
    systemu operacyjnego o nazwie XXX jest logowany na tego samego użytkownika
    w bazie danych.
``md5``
    Logowanie hasłem.
inne
    Są też inne metody.

Definiowanie funkcji SQL
------------------------

W zasadzie funkcje wykonywane na bazie danych wcale nie muszą być
fukcjami plpgsql, mogą zawierać zwykły kod SQL.

 Składania tworzenia funkcji:

.. code-block:: sql

    CREATE FUNCTION nazwa(lista parametrów) RETURNS zwracany typ
        'ciąg znaków definiujący ciało funkcji'
    LANGUAGE język
    ...;


Przykładowo:

.. code-block:: sql

    CREATE FUNCTION add(integer, integer) RETURNS integer
        AS 'select $1 + $2;'
        LANGUAGE SQL
        IMMUTABLE
        RETURNS NULL ON NULL INPUT;

Podana funkcja nie jest napisana w pl/pgSQL, ale w zwykłym sql. Takie
funkcje są zdecydowanie mniej potężne, ale trochę łatwiejsze do pisania.

Dodatkowo proszę zauważyć że parametry przekazywane są do ciała funkcji
za pomocą wyrażeń $1.

Proszę doczytać o ``IMMUTABLE``, ``STABLE``, ``VOLATILE`` `w podręczniku
<http://www.postgresql.org/docs/9.2/static/sql-createfunction.html>`_

Następny przykład:

.. code-block:: sql

    CREATE FUNCTION sales_tax(subtotal real) RETURNS real AS $$
    BEGIN
        RETURN subtotal * 0.06;
    END;
    $$ LANGUAGE plpgsql;

Funkcje trigger
---------------

Funkcje trigger to małe kawałki kodu które są wykonywane automatycznie
przy wykonywaniu operacji na tabelach. Na przykład trigger wykonywany
przed wstawieniem wiersza do tabeli.

Najpierw opiszę jak definujemy funkcje trigger, a potem jak przypina się
je do tabeli.

Funkcja trigger ma takie cechy:

* Nie przyjmuje argumentów
* Zwraca typ trigger
* Zwraca albo NULL albo obiekt o takiej strukturze jaką ma
  wiersz w danej tabeli

.. code-block:: sql

    CREATE FUNCTION emp_stamp() RETURNS trigger AS $body$
    BEGIN
        -- TREŚĆ TRIGGERA
    END;
    $body$ LANGUAGE plpgsql;


Wewnątrz triggera zdefiniowane jest mnóstwo magicznych
zmiennych, ale dwie są ważne: ``NEW``, ``OLD``,
które reprezentują odpowiedni nową wartość w wiersza danej tabeli, oraz
starą wartość tego wiersza. By wybrać czy zmodyfikować wartość w
``NEW`` i ``OLD`` należy wykonać: ``NEW.nazwa_kolumny``.

Przykład triggera

.. code-block:: sql

    CREATE TABLE emp (
        empname           text NOT NULL,
        salary            integer
    );

    CREATE TABLE emp_audit(
        operation         char(1)   NOT NULL,
        stamp             timestamp NOT NULL,
        userid            text      NOT NULL,
        empname           text      NOT NULL,
        salary integer
    );

    CREATE OR REPLACE FUNCTION process_emp_audit() RETURNS TRIGGER AS $emp_audit$
        BEGIN
            --
            -- Create a row in emp_audit to reflect the operation performed on emp,
            -- make use of the special variable TG_OP to work out the operation.
            --
            IF (TG_OP = 'DELETE') THEN
                INSERT INTO emp_audit SELECT 'D', now(), user, OLD.*;
                RETURN OLD;
            ELSIF (TG_OP = 'UPDATE') THEN
                INSERT INTO emp_audit SELECT 'U', now(), user, NEW.*;
                RETURN NEW;
            ELSIF (TG_OP = 'INSERT') THEN
                INSERT INTO emp_audit SELECT 'I', now(), user, NEW.*;
                RETURN NEW;
            END IF;
            RETURN NULL; -- result is ignored since this is an AFTER trigger
        END;
    $emp_audit$ LANGUAGE plpgsql;



Przypinanie triggerów do zapytań
---------------------------------

Tak zdefiniowany trigger oczywiście nic nie robi --- by włączyć triggera należy
przypiąć go do jakiejś tabeli. Żeby było ciekawiej możemy przypiąć go na wiele
sposobów:

* Trigger wykonywany przy ``INSERT``, dla każdego wiersza
* Trigger wykonywany przy ``UPDATE``, dla każdego wiersza
* Trigger wykonywany przy ``DELETE``, dla każdego wiersza
* Trigger wykonywany przy ``INSERT``, raz na zapytanie (modyfikujące wiele wierszy)
* Trigger wykonywany przy ``UPDATE``, raz na zapytanie (modyfikujące wiele wierszy)
* Trigger wykonywany przy ``DELETE``, raz na zapytanie (modyfikujące wiele wierszy)
* Trigger wykonywany przy ``TRUNCATE``, raz na zapytanie

Dodatkowo: trigger może być wykonywany:

* Przed wykonaniem zapytania (np. przed wykonaniem inserta)
* Po wykonaniu zapytania
* **Zamiast wykonania zapytania** --- to jest szczególnie ważne i pozwala
  całkowicie nadpisać logikę działania tabeli.

BEFORE i AFTER a kod triggera
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Jeśli trigger jest zdefiniowany jako uruchamiany BEFORE,
to wartość którą zwraca kontroluje przebieg operacji na której jest
zdefiniowany. Jeśli zwróci NULL oznacza to że dana operacja
jest zatrzymywana (INSERT czy UPDATE nie dochodzi do skutku).
Jeśli zwróci cokolwiek innego, to co zwraca musi mieć taką strukturę
jak NEW i OLD i taka wartość zastępuje
wiersz zapisywany do tabeli w danej operacji.

Typowym rozwiązaniem jest modyfikacja (bądź nie) NEW i
zwrócenie go (zdecydowanie polecam `lekturę podręcznika
<http://www.postgresql.org/docs/9.2/static/plpgsql-trigger.html>`_.

Triggery AFTER powinny zwracać NULL.

Składnia przypinania triggerów do tabel
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. code-block:: sql

    CREATE TRIGGER emp_audit
    AFTER INSERT OR UPDATE OR DELETE ON emp
        FOR EACH ROW EXECUTE PROCEDURE process_emp_audit();



Pełna składnia `tak zgadliście: w podręczniku
<http://www.postgresql.org/docs/9.2/static/sql-createtrigger.html>`_

