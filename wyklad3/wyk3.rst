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
        Uwaga! Znaczy to, że użytkownik przypisany jest do klastra, a nie
        do bazy danych! Uniemożliwia to, np. posiadanie dwóch użytkowników
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

By odnieść się do tabeli w innym schemacie, należy nazwę tabeli
poprzedzić nazwą schematu, tj. by wybrać dane z tabeli FOO
w schemacie foo, należy wykonać polecenie:

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

By zmienić domyślny schemat, należy wykonać polecenie:

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

Powoduje skasowanie z tabeli ``FOO`` wszystkich wierszy, dla których
podane ``wyrażenie_logiczne`` będzie prawdziwe. Drugi przykład usunie
wszystkie wiersze, dla których wartość w kolumnie ``"bar"`` będzie
większa niż wartość w kolumnie ``"foo"``.

TRUNCATE
^^^^^^^^

Polecenie to usuwa wszystkie wiersze z tabeli, jest szybsze niż `DELETE`.


UPDATE
^^^^^^

Przykładowo:

.. code-block::

    UPDATE FOO set "foo"="baz"-1, "bar"="baz" WHERE "foo" < "bar"

Tworzenie tabel
^^^^^^^^^^^^^^^



.. note::

    Polecam tworzyć tabele za pomocą interfejsu administracyjnego
    ``pgadmin3``. Jest szybciej niż przez konsolę.

Definicja tabeli w postgresql składa się z:

* Listy kolumn
* Ograniczeń
* Indeksów
* triggerów (o nich potem)
* Zasad (o tym nie powiemy)
* Uprawnień (o nich potem)
* i innych rzeczy

Do tworzenia tabel służy klauzula:

.. code-block::

    CREATE TABLE "FOO"
    (
        [lista kolumn, indeksów, ograniczeń i triggerów , może być pusta]

    );

Typy kolumn
^^^^^^^^^^^

``character varying``
    Ciąg znaków o zmiennej długości. Uwaga: większość baz danych wymaga
    podania maksymalnej ilości znaków w takim typie, postgres natomiast
    `tego nie wymaga <http://www.postgresql.org/docs/9.2/static/datatype-character.html>`_.

``TEXT``
    Praktycznie odpowiednik ``character varying``.

``smallint, integer, and bigint``
    Liczby całkowite różnych rozmiarów

``real, double precision``
     Liczba zmiennoprzecinkowa o ustalonej dokładności 64bity. Dokładność
     tych liczb jest taka jak systemu operacyjnego.

``numeric``
    Liczba stałoprzecinkowa.

    W telegraficznym
    skrócie: *zwykłe* liczby zmiennoprzecinkowe mają pewne niedokładności,
    a pewne cechy ich zachowania nie są do końca określone (zależą od
    infrastruktury procesora).

    Przykładowo dla liczb zmiennoprzecinkowych (``floating point`` możliwe jest takie działanie:

    .. code-block:: python

        >>> 0.2 + 0.1
        0.30000000000000004

    (wynika to z problemów zaokrągleń). Liczby stałoprzecinkowe mają dobrze
    zdefiniowane zasady zaokrąglania, co jest przydatne w bazach danych będących
    backendem np. do systemów księgowych.

    Dokładne
    wyjaśnienie na `na wikipedii <en.wikipedia.org/w/index.php?title=Fixed-point_arithmetic&oldid=568726823>`_
    oraz `w podręczniku postgresql <http://www.postgresql.org/docs/9.2/static/datatype-numeric.html#DATATYPE-NUMERIC-DECIMAL>`_.

``date``

    Dzień, miesiąc i rok.

    `Umieszczanie dat <http://www.postgresql.org/docs/9.1/static/functions-datetime.html>`_:

     .. code-block:: sql

        date '2001-09-28'

``time``

    Czas (minuta i godzina) z dokładnością do milisekundy

``timestamp``

    Data i godzina (dokładność do milisekundy)

``timestamp with timezone``

    Data i godzina (dokładność do milisekundy), z określeniem strefy czasowej.


Definiowanie kolumn
^^^^^^^^^^^^^^^^^^^

Definicja kolumny w najprostszej postaci jest taka:

.. code-block:: sql

    nazwa_kolumny typ;

Na przykład:

.. code-block:: sql

    CREATE TABLE "FOO"
    (
        pk integer
    );

.. code-block:: sql

    ALTER TABLE "FOO" ADD COLUMN pk integer;

Dodawanie kolumn
****************

.. code-block:: sql

    ALTER TABLE "FOO" ADD COLUMN ....;
    ALTER TABLE "FOO" DROP COLUMN nazwa;
    ALTER TABLE "FOO" RENAME COLUMN nazwa1 TO nazwa2;

Usuwanie tabel
**************

.. code-block:: sql

    DROP TABLE "FOO":


Domyślne wartości
*****************

Do każdej kolumny możemy dodać domyślną wartość, tj. wartość która
będzie przypisana do kolumny, jeśli w poleceniu ``INSERT``
dana kolumna nie będzie określona.

Klauzula default może określać wartość domyślną jako stałą, lub np.
wynik wywołania funkcji.

Klauzula default nie umożliwia odnoszenia się do pozostałych kolumn
w danym wierszu (taka funkcjonalność możliwa jest do osiągnięcia
za pomocą triggera).

.. code-block:: sql

    CREATE TABLE products (
        product_no integer DEFAULT nextval('products_product_no_seq'), -- default jako funkcja
        name text,
        price numeric DEFAULT 9.99 -- stałe default
    );

Indeksy
^^^^^^^

Indeksy są techniką pozwalającą na przyśpieszanie wykonywania zapytań,
bez indeksów każde zapytanie musi odczytać całą tabelę, tj.
takie zapytanie:

.. code-block::

    SELECT name FROM student WHERE id = 5;

Będzie odczytywać wiersze z tabeli jeden po drugim, aż trafi na
indeks o id równym pięć wtedy go zwróci.

Indeks jest miejscem, w którym ``id`` są posortowane,
a wraz z nim przechowywana jest informacja gdzie znajduje się
rząd o danym ``id``.

W takim wypadku baza danych musi przeszukać indeks (co średnio
zajmuje jej średnio $log_2(n)$ ($n$ -- ilość wierszy w tabeli)
odczytów, a potem odczytuje z dysku dobry wiersz.

Wady indeksów:
**************

Zwiększają rozmiar bazy danych, często rozmiar indeksów do tabeli
jest większy, niż rozmiar tabeli.

Zwalniają dodawanie wierszy (bo dodając wiersz baza musi odświeżyć
wszystkie indeksy!)

W niektórych wypadkach nie powodują przyśpieszenia odczytów (o tym później).

Triggery
^^^^^^^^

Są to małe kawałki SQL uruchamiane przed lub po takich operacjach jak
wstawienie, zmiana czy usunięcie wiersza.

Ograniczenia
------------

O tym jak działają kluce główne pisałem na poprzednim
wykładzie: :ref:`w2-pk`.

Klucze główne
^^^^^^^^^^^^^

Klucze główne składające się z pojedynczej kolumny nazywamy prostymi.

Składnia ich tworzenia jest taka:

.. code-block:: sql

    CREATE TABLE "BAR"
    (
        pk integer primary key
    );

Możliwa jest też druga składnia:

.. code-block:: sql

    CREATE TABLE "BAZ"
    (
        pk integer,
        primary key (pk)
    );

Drugi sposób określania kluczy głównych jest o tyle wygodny, że
wydziela definicję danych od definicji więzów.

Złożone klucze główne
*********************

Złożone klucze główne to klucze, na które składa się wiele kolumn.
Przykładowo mamy tabelę, która obrazuje relację studenta i promotora
tabela ta będzie miała taką definicję:


.. _w3-naturalne-syntetyczne-pk:

Naturalne i syntetyczne (sztuczne) klucze główne
************************************************

Naturalny klucz główny (*z ang.* natural key), to klucz główny, na
który składają się kolumny już istniejące w bazie danych mające
znaczenie w *świecie rzeczywistym*. W naszej bazie tabela ``DATA_POINT``
ma klucz naturalny.

Klucz syntetyczny (*z ang.* surrogate key), to klucz,,którego wartości
mają znaczenie tylko wewnątrz bazy danych. W naszej bazie tabele
``DATA_SOURCE`` oraz ``POINT_TYPE`` mają klucze syntetyczne, są to
kolejne liczby naturalne przypisane do danego wiersza.

Klucze naturalne kontra klucze syntetyczne
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Według wielu administratorów w zasadzie zawsze należy dodawać
do tabeli klucz syntetyczny. Ma on takie zalety:

* Jego wartość nigdy się nie zmienia (zmianę wartości w klucza naturalnego
  może wymusić zmiana w świecie)
* Nie zależy od zachowania świata zewnętrznego.
* Klucze sztuczne są mniejsze, generalnie są intem.
* Joiny po kluczach sztucznych mogą być szybsze (Sztuczne klucze główne
  są mniejsze)

Wady kluczy syntetycznych:

* Powoduje dodanie nowej kolumny i nowego indeksu do tabeli
* Wartość sztucznego klucza nie zależy od zawartości wiersza,
  co może utrudniać tworzenie rozproszonych baz danych.

Wady kluczy naturalnych

* Zmiana świata zewnętrznego może wymusić zmianę kluczy naturalnych
  w naszej bazie danych.
* Może się okazać, że klucze, które są teoretycznie unikalne,
  wcale takie nie są.



