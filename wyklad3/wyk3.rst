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

.. code-block:: sql

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
--------------------

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

.. code-block:: sql

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

.. code-block:: sql

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

``serial``

    Więcej w rozdziale :ref:`w3-generowanie-pk`.


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

.. code-block:: sql

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

.. code-block:: sql

    CREATE TABLE "PROMOTOR_LINK"
    (
       student_id integer,
       pracownik_id integer,
        PRIMARY KEY (student_id, pracownik_id)
    );

Wiersz będzie jednoznacznie identyfikowany przez trzy kolumny:
studenta, pracownika oraz rodzaj pracy, którą student napisał a
promotor wypromował.

.. w3-naturalne-syntetyczne-pk:

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
******************************************

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


Przykład: numer ``PESEL`` jako klucz główny w tabeli
*****************************************************

Wszyscy wiedzą, że pesel ma takie charakterystyki:

* Numer pesel jest unikalny
* Numer pesel zawiera datę urodzenia
* Numer pesel posiada sumę kontrolną
* Numer pesel jest niezmienny (raz nadany nie zmieni się nigdy)
* Każdy ma pesel
* Numer pesel będzie obowiązywać zawsze.

w praktyce:

Numer pesel był przez lata nadawany *ręcznie* tj. pani w urzędzie
nadawała go i ręcznie liczyła sumę kontrolną, zdarzają się więc
osoby, które mają taki sam numer pesel (rzadko, bo rzadko, ale są).

Numer pesel zawiera datę urodzenia, jednak zdarzają się dni, w których
"urodziło się" ponad 10 000 osób, wtedy osobom przypisuje się numery
pesel z następnych dni.

Numer pesel posiada sumę kontrolną, ale czasem jest ona błędnie wyliczona
(znów: pesele były przyznawane *ręcznie*).

Można zmienić sobie numer ``PESEL`` (`Ustawa o ewidencji ludości i
dowodach osobistych <http://isap.sejm.gov.pl/DetailsServlet?id=WDU19740140085>`_)

Niektóre osoby przebywające w Polsce nie posiadają numeru pesel
(np. obcokrajowcy).

.. _w3-generowanie-pk:

Generowanie kluczy głównych
***************************

Wartości sztucznych kluczy głównych muszą być generowane przez
bazę danych.

Najprostszą metodą generowania kluczy głównych jest użycie typu
``SERIAL`` do kolumny oznaczającej klucz główny:


.. code-block:: sql

    CREATE TABLE "STUDENT_2"
    (
        id serial NOT NULL,
        CONSTRAINT "STUDENT_2_pkey" PRIMARY KEY (id )
    )

Teraz kolejnym wstawianym wierszom kolumny ``id`` będą
przypisywane kolejne liczby naturalne.

Takie podejście może mieć pewne wady: podczas
wstawiania wiersza musimy nie tylko umieścić dane w bazie danych,
ale również odebrać nadaną wartość klucza głównego. Co może być
niewydajne przy wstawianiu miliona wierszy do bazy danych.

By odebrać od bazy danych wartość nadanego ``id`` możemy
użyć klauzuli (jest ona rozszerzeniem SQL i działa
tylko w postgresql):

.. code-block:: sql

    INSERT INTO "STUDENT_2"(id) VALUES (DEFAULT)
    RETURNING id;


Sekewencje
**********

Bardziej wydajną metodą generowania kluczy głównych są sekwencje.
Sekwencja czymś co zwraca kolejne liczby naturalne i jest skonstruowana
tak, że bez względu na sposób dostępu sekwencja nigdy nie zwróci
tej samej liczby wielokrotnie.

By stworzyć sekwencję należy wykonać polecenie:

.. code-block:: sql

    CREATE SEQUENCE FOOBAR;

Do pobrania następnej liczby z sekwencji służy funkcja
nextval.

By stworzyć klucz główny generowany z sekwencji można wykonać:

.. code-block:: sql

    CREATE TABLE products (
        product_no integer DEFAULT nextval('products_product_no_seq')
    );

Sekwencje mają tą przewagę nad kolumnami ``serial``, że możliwe jest zarezerwowanie wielu
przyszłych wartości kluczy głównych na raz.

Klucze obce
^^^^^^^^^^^


By jedna tabela odnosiła się do innej musimy dodać kolejne
ograniczenie, tzw. klucz obcy.

Powiedzmy, że tabele student i pracownik z poprzedniego przykładu
mają taką definicję:

.. code-block:: sql

    CREATE TABLE "STUDENT"
    (
      id integer NOT NULL,
      CONSTRAINT "STUDENT_pkey" PRIMARY KEY (id ),
      name character varying
    );

    CREATE TABLE "PRACOWNIK"
    (
      id integer NOT NULL,
      CONSTRAINT "PRACOWNIK_pkey" PRIMARY KEY (id ),
      name character varying
    )


W takim wypadku do tabeli ``"PROMOTOR_LINK"`` musimy dodać takie
ograniczenia:

.. code-block:: sql

    ALTER TABLE "PROMOTOR_LINK"
      ADD CONSTRAINT "PROMOTOR_LINK_student_id_fkey" FOREIGN KEY (student_id)
          REFERENCES "STUDENT" (id);
    ALTER TABLE "PROMOTOR_LINK"
      ADD CONSTRAINT "PROMOTOR_LINK_promotor_id_fkey" FOREIGN KEY (pracownik_id)
          REFERENCES "PROMOTOR" (id);


Składnia tego wyrażenia jest taka:

.. code-block:: sql
    
    ADD CONSTRAINT [[NAZWA]] FOREINGN KEY ([[lista kolumn w lokalnej tabeli]])
    REFERENCES [[nazwa zdalnej tabeli]] ([[lista kolumn w zdalnej tabeli]];

Klucze obce gwarantują, że jeśli w danym wierszu w kolumnie
``student_id`` jest wartość ``4``, to rzeczywiście istnieje
wiersz w tabeli ``STUDENT`` którego ``id`` wynosi ``4``.

Klucze obce pozwalają bezpiecznie pisać polecenia ``SELECT`` z klauzulą ``JOIN``, 
przy zapytaniu: 

.. code-block:: sql

    SELECT student.name, promotor.name FROM "PROMOTOR_LINK" AS pl 
        JOIN "STUDENT" student ON (student.id = pl.student_id)
        JOIN "PROMOTOR" promotor ON (promotor.id = pl.promotor_id)

wiemy że dla student o ``id`` równym ``student_id`` będzie zawsze istnieć:
gwarantuje to ``FOREIGN KEY``.


Złożone klucze obce
^^^^^^^^^^^^^^^^^^^

Jeśli tabela, do której się odnosimy ma złożony klucz główny to
klucze obce do tej tabeli muszą być złożone.
Powiedzmy, że mamy tabelę praca, która odwzorowuje pracę dyplomową,
wartość w tej tabeli jest jednoznacznie identyfikowana przez dwie
kolumny: rozdaj pracy i id studenta:

.. code-block:: sql

    CREATE TABLE "Praca"
    (
      student_id integer NOT NULL,
      type integer NOT NULL,
      CONSTRAINT "Praca_pkey" PRIMARY KEY (student_id , type )
    )

By dodać odniesienie to do pracy do tabeli ``PROMOTOR_LINK``
musielibyśmy dodać kolumnę ``praca_type`` oraz
złożony klucz obcy:

.. code-block:: sql

    ALTER TABLE "PROMOTOR_LINK" ADD COLUMN praca_type integer;
    ALTER TABLE "PROMOTOR_LINK" ALTER COLUMN praca_type SET NOT NULL;
    ALTER TABLE "PROMOTOR_LINK" ADD CONSTRAINT "PROMOTOR_LINK_student_id_fkey1" FOREIGN KEY (student_id, praca_type)
      REFERENCES "Praca" (student_id, type)

Cascade
^^^^^^^^

Silnik bazy danych nie pozwoli na wstawienie rzędu danych do tabeli
`PROMOTOR_LINK`, jeśli w tym rzędzie będzie odniesienie
do nieistniejącego studenta. Jednak co się stanie jeśli już po
utworzeniu wiersza w tabeli `PROMOTOR_LINK` usuniemy
studenta, do którego dany wiersz się odnosi?

Ponieważ serwer wymusza prawdziwość ograniczeń zawsze,
pod koniec transakcji (czym są transakcje powiemy później)
baza danych zgłosi wyjątek, że ograniczenie jest niespełnione i zmiany
zostaną wycofane.

W dalszej cześci zakładamy że usuwamy rząd z tabeli ``STUDENT`` do którego donosi
się jakiś wiersz z tabeli: `PROMOTOR_LINK`.

Ponieważ takie zachowanie może nie być pożądane, może zostać
skonfigurowane, za pomocą dodatkowych klauzul, które
zarządzają propagacją (z ang. cascade) zmian:

.. code-block:: sql

    CONSTRAINT "PROMOTOR_LINK_student_id_fkey1" FOREIGN KEY (student_id, praca_type)
    REFERENCES "Praca" (student_id, type)
    ON UPDATE NO ACTION ON DELETE NO ACTION

Dokładniej rozszyfrujmy linijkę:

.. code-block:: sql

    ON UPDATE NO ACTION ON DELETE NO ACTION.

Linia ta pozwala wybrać akcję do wykonania przez serwer, gdy
zdalny wiersz (w naszym przykładzie zdalny rząd to wiersz z tabeli ``STUDENT``
do którego odnosi się jakaś ``PRACA_LINK``), danych jest usuwany (``ON DELETE``) bądź
zmieniany (``ON UPDATE``).

Akcje do wybrania są takie:

``NO ACTION``
    spowoduje nie wykonanie żadnej akcji,
    co może spowodować wyrzucenie wyjątku podczas zamykania transakcji
    (nie spowoduje go jeśli potem usuniemy również wiersz ze wszystkuch tabel
    posiadających klucz obcy do tego wiersza).
``RESTRICT``
    spowoduje wyrzucenie wyjątku od razu!
``SET NULL``
    spowoduje ustawienie wartości NULL w
    kolumnach odnoszących się do kasowanego lub zmienianego wiersza.
``SET DEFAULT``
    spowoduje ustawienie domyślnej wartości
    w kolumnach odnoszących się do kasowanego lub zmienianego wiersza
``CASCADE``
    jeśli zdalny wiersz jest kasowany spowoduje
    skasowanie wierszy, które się do niego odnoszą, jeśli jest
    zmieniany spowoduje zmianę wartości w tej tabeli by ciągle
    odnosiły się do tego samego wiersza.


Ograniczenie NOT NULL
^^^^^^^^^^^^^^^^^^^^^

Domyślnie kolumny zawsze mogą przyjmować wartość pustą (``NULL``)
Dodanie ograniczenia NOT NULL umożliwia wymuszenie by wartości w danej
kolumnie były różne od ``null``.

Ograniczenie UNIQUE
^^^^^^^^^^^^^^^^^^^

Ograniczenie to powoduje że dana wartość w danej kolumnie w danej tabeli może
pojawić się tylko raz.

Powedzmy że chcemy wymagać by nasi użytkownicy mieli unikalne adresy e-mail:

.. code-block:: sql

    CREATE TABLE "FOO"
    (
        pk integer,
        email character varying,
        CONSTRAINT "FOO_unique" UNIQUE (email)
    )

.. note::

    Klucze unikalne powodują podobne problemy co naturalne klucze główne:
    czasem po prostu może się okazać, że coś powinno być unikalne,
    takie nie jest.

Ograniczenie CHECK
^^^^^^^^^^^^^^^^^^

Ograniczenie check pozwala na sprawdzenie wyniku dowolnej operacji logicznej
wykonywanej na danym wierszu (operacja ta nie może wykonywać
zapytań ani odnosić się do innych rzędów tabeli).

Przykładowo by sprawdzić czy email jest poprawny należy dodać takie graniczenie:

.. code-block:: sql

    CREATE TABLE "FOO"
    (
        pk integer,
        email character varying,
        CONSTRAINT "FOO_email_check" CHECK (email LIKE '%@%.%')
    )

Teraz takie zapytanie się powiedzie:

.. code-block:: sql

    INSERT INTO "FOO"(email) VALUES('bzdak@poczta.if.pw.edu.pl');

a takie nie:

.. code-block:: sql

    INSERT INTO "FOO"(email) VALUES('bar');

.. note::

    Generalnie sprawdzanie poprawnoście adresu ``e-mail`` za pomocą `wyrażenia
    regularnego <http://pl.wikipedia.org/w/index.php?title=Wyra%C5%BCenie_regularne&oldid=36664770>`_
    (jeśli nie znacie wyrażeń regularnych, bardzo polecam poznanie ich!)
    w bazie danych nie jest najlepszym pomysłem, ponieważ:

    * Większość specjalistów powie że baza danych nie jest odpowiednią warstwą
      aplikacji do wykonania tego sprawdzenia.
    * Najlepszą metodą sprawdzenia poprawności adresu e-mail jest wysłanie
      na ten adres wiadomości.
    * Zgodnie ze specyfikacją `RFC 5322
      <http://tools.ietf.org/html/rfc5322#section-3.4.1>`_ adres email może
      zawierać dużo bardzo dużo dziwnych rzeczy, na przykład taki adres
      *jest poprawny*: ``"Abc\@def"@iana.org``.
