Wykład 3: Zarządzanie schematem danych
=======================================

Schemat a baza danych
----------------------

Uwaga tutaj Postgres działa zdecydowanie inaczej niż ``MySQL``.

Podstawowe pojęcia:

``Database cluster``
    Jedna instancja Postgresa zawierająca wielu użytkowników
    oraz wiele baz danych. Uwaga --- w tym terminie nie chodzi o klaster
    składający się z wielu komputerów, słowo klaster dotyczy wielu
    odseparowanych baz danych.

    .. note::
        Uwaga! Znaczy to że użytkownik przypisany jest do klastra, a nie
        do bazy danych! Uniemożliwia to np. posiadanie dwóch użytkowników
        o tej samej nazwie w różnych bazach danych (logujących się np.
        innymi hasłami).

``Database``
    Jedna baza danych. Bazy danych są odseparowane od siebie, tj. na przykład
    nie można wykonać polecenia, które wybiera dane z tabel w dwóch
    bazach danych.

    .. note::
        Znaczy wszystko można, tylko jest to dość skomplikowane,
        postgres zawiera rozszerzenie dblink, które pozwala na dostęp do innych
        baz danych czy klastrów baz danych, jednak rozszerzenie to łączy się
        do zdalnej bazy danych po za pośrednictwem połączenia TCP/IP,
        jak każdy inny zewnętrzny klient.

``Schemat bazy danych``
    Zbiór tabel, procedur itp. Schematy w jednej bazie danych mogą się
    ze sobą komunikować.

Używanie wielu schematów
------------------------

By odnieść się do tabeli w innym schemacie należy nazwę tabeli
poprzedzić nazwą schematu, tj. by wybrać dane z tabeli FOO
w schemacie foo należy wykonać polecenie:

.. code-block:: sql

    SELECT * FROM foo.FOO;

Ustawianie domyślnego schematu
------------------------------

W każdej bazie danych postgresa jest schemat ``public``, który
jest wykorzystywany jako domyślny schemat, tak więc po napisaniu:

.. code-block:: sql

    SELECT * FROM foo;

Wykonywane jest tak na prawdę:

.. code-block:: sql

    SELECT * FROM public.foo;

By zmienić domyślny schemat należy wykonać polecenie:

.. code-block::

    SET search_path TO foo, bar, baz

Działa to trochę jak zmienna PATH w UNIXie, tj. jeśli po wykonaniu polecenia
podanego wyżej przy próbie odniesienia się do tabeli FOO,
użyta zostanie tabela foo.FOO, a jeśli ta nie istnieje,
zostanie użyte bar.Foo itp.

Polecenie SET działa dla bieżącego połączenia (np. dla konkretnej
sesji ``psql`` bądź danego okna ``pgAdminIII``), można
ustawić też search_path dla użytkownika, schematu bazy danych,
cz yw pliku konfiguracyjnym polecenia psql.

Więcej informacji na `stackoverflow <http://stackoverflow.com/questions/2875610/>`_.

Polecenie ``INSERT``
====================

Polecenie insert jest prostsze niż ``SELECT``:

.. code-block:: sql

    INSERT INTO {{tabela}}({{lista kolumn}}) VALUES ({{lista wartości}}, [({{lista wartości}})...]

Na przykład:

.. code-block:: sql

    INSERT INTO foo("foo", "bar") VALUES (1,2), (2,3), (3,4);

polecenie to oznacza: Chcę wstawić wiersze do tabeli "foo", podam teraz
listę wartości w kolumnach "foo" i "bar", wartości w pierwszym wstawianym
wierszu to 1 i 2, w drugim 2 i 3, w trzecim 3 i 4.

Listę kolumn można pominąć, wtedy wstawiane wstawiamy wartości do
wszystkich kolumn (w tej kolejności, w której zostały one zdefiniowane w
tabeli).

.. warning::

    Nie polecam tego rozwiązania.

Możliwe jest też wstawienie do wiersza wartości domyślnej danej kolumny
za pomocą słowa kluczowego DEFAULT

.. code-block:: sql

    INSERT INTO "STUDENT_2"(id) VALUES (DEFAULT);

Inne operacje na wierszach
--------------------------


DELETE
^^^^^^

.. code-block:: sql

    DELETE FROM FOO WHERE wyrażenie_logiczne;

    DELETE FROM FOO WHERE "foo" < "bar"

Powoduje skasowanie z tabeli ``FOO`` wszystkich wierszy dla których
podane ``wyrażenie_logiczne`` będzie prawdziwe. Drugi przykład usunie
wszystkie wiersze dla których wartość w kolumnie ``"bar"`` będzie
większa niż wartość w kolumnie ``"foo"``.


UPDATE
^^^^^^

Przykładowo:

.. code-block::

    UPDATE FOO set "foo"="baz"-1, "bar"="baz" WHERE "foo" < "bar"

Typy kolumn
===========

``character varying``
    Ciąg znaków o zmiennej długości. Uwaga: większość baz danych wymaga
    podania maksymalnej ilości znaków w takim typie, postgres natomiast
    `tego nie wymaga <http://www.postgresql.org/docs/9.2/static/datatype-character.html>`_.

``TEXT``
    Praktycznie odpowiednik ``character varying``.

``smallint, integer, and bigint``
    Liczby całkowite różnych rozmiarów

``numeric``
    Liczba zmiennoprzecinkowa o ustalonej dokładności. W telegraficznym
    skrócie: *zwykłe* liczby zmiennoprzecinkowe mają pewne niedokładności,
    a pewne cechy ich zachowania nie są do końca określone (zależą od
    infrastruktury procesora).

    Dokładne
    wyjaśnienie na "
    na wiki</a> i w
    <a href="http://www.postgresql.org/docs/9.2/static/datatype-numeric.html#DATATYPE-NUMERIC-DECIMAL">podręczniku</a>





