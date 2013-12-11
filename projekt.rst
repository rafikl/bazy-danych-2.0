Projekt
=======

Historia
--------

Tworzymy aplikację billingową, która pozwala na tworzenie tabel z których łatwo
generować rachunki.

Aplikacja ta będzie bardzo uproszczoną wersją tego co robi się w polskich
telekomach.

.. note::

    W prawdziwym świecie takie rzeczy nie są realizowane po stronie bazy danych
    (w każdym razie *nie tylko* po jej stronie), bo to generalnie przerasta
    projekt w którym baza danych jest efektywna kosztowo.

    Jednak przy billingowaniu w telekoamch bazy danych są bardzo złożone.


Część projektowa
================

Część w której musicie Państwo przemyśleć jak zrobicie bazę danych.

Globalne uproszczenia
---------------------

* Używamy polskich numerów, numer ma postać: `123 456 789`
* Rozliczenia są minutowe
* Kwoty przechowujemu w groszach

Plany billingowe
----------------

Plany bilingowe przechowywane są w schemacie Waszego konceptu, muszą uwzględniać
takie parametry:

* Nazwa planu
* Koszt SMS i minuty rozmowy do różnych sieci (sieci rozpoznjamy po prefiksie
  numeru, więc starczy przypisywać konkretne kwoty do prefiksów).

  * W prostej wersji możemy uznać że prefiksy mają zawsze długość trzech liczb
  * W bardziej złożonej możemy powiedzieć że rozmowa do podsieci `123` kosztuje
    5gr za minutę a do podsieci `123 4` kosztuje 10.

* Fajnie (nie jest to wymóg) byłoby móc przypisywać do abonamentu
  nie tylko SMS i minut, ale też kilobajtów trasmisji, MMS, itp.
* Wysokość abonamentu, abonamenty działają tak:

  * Co miesiąc abonent płaci N złotych i może je wykorzystać na dowolne połączenia.
  * Jeśli wykorzystał więcej musi dopłacić. Jeśli mniej to pieniądze przepadają.

Rejestrowaie połączenia telefonicznego składa się z takich funkcji:

.. method:: `can_start_connection(from_number, to_number, element_id)`:

    Sprawdza połączenie typu ``element_id`` między numerami,
    ``from_number`` oraz ``to_number`` może być rozpoczęte.

    Zwraca ilość jednostek tego połączenia na którą stać użytownika.

    :param varchar from_number: Numer wysylający --- jest on w naszej sieci
    :param varchar to_number: Numer który odbiera połączenie.
    :param element_id: Informacja o typie połączenia (głosowe, SMS)...

.. method:: `register_connection(from_number, to_number, element_id, units, date)`:

    Zapisuje połączenie do bazy danych.

    :param varchar from_number: Numer wysylający --- jest on w naszej sieci
    :param varchar to_number: Numer który odbiera połączenie.
    :param element_id: Informacja o typie połączenia (głosowe, SMS)...
    :param integer units: Ilość jendostek
    :param timestamp date: Chwila zajśca zdarzenia


.. method:: `select_fee(plan_id, element_id, target_phone_no)`:

    Zwraca koszt jednostki połączenia.

    :param plan_id: Plan osoby dzwoniącej
    :param element_id:  Informacja o typie połączenia (głosowe, SMS)....
    :param varchar target_phone_no: Telefon docelowy

Billingi
--------

.. method:: get_billing(client_id, date)

    Funkcja generuje biling za miesiąc.

    :param varchar client_id: Numer klienta dla którego generujemy billing
    :param date date: Data dla której generujemy billing (bierzemy miesiąc
       w którym jest da data.

Metoda ta zwraca tabelę mającą takie wiersze:

* Chwila zajścia zdarzenia
* Typ zdarzenia (połączenie/SMS)
* Ilość jednostek zdarzenia (minuty/SMS)
* Jednostka w którj jest poprzednia kolumna (min/szt)
* Koszt zdarzenia
* Kwota rachuku która uzbierała się od początku miesiąca do tego dnia.

Warunki zaliczenia
------------------

W system wbudowane są plany bilingowe opisane poniżej.

Uda mi się wygenerować raporty dla rozmów które sam zarejestrowałem.


Plany billingowe
^^^^^^^^^^^^^^^^

W szczególności możliwe jest wygenerowanie takich planów billingowych,
*te plany powinny być od razu wbudowane w bazę danych*:

**Pomelo na kartę**

* 0 zł abonamentu
* 29gr/min
* 20gr/SMS
* 20gr/MMS
* 25gr/50kb danych
* 75 gr/min do sieci zaczynającej się od numerów: 444


**Pomelo Smart**

* 74.90zł abonamentu
* 10gr/min
* 10gr/SMS
* 10gr/MMS
* 10gr/50kb danych
* 75gr/min do sieci "Fast Forward"
* 75 gr/min do sieci zaczynającej się od numerów: 444
