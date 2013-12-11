
Zajęcia 5
=========


Zadanie 1 stworzenie tabeli
---------------------------

Stworzenie tabeli ``USERS``, która będzie przechowywać dane, ma ona takie kolumny:

* ``username character varying NOT NULL PRIMARY KEY`` nazwa użytkownika
* ``password character varying NOT NULL`` hasło użytkownika Uprawnienia w tabeli
* ``is_admin int NOT NULL DEFAULT 0`` czy użytkownik jest adminem. Proszę dodać checka is_admin IN (0, 1).

Uprawnienia w bazie danych
--------------------------

W bazie danych będą dwie role: ``admin`` i ``user``.

* ``admin`` jest właścicielem (``OWNER``) tabeli ``USERS``
* ``user`` który nie ma do niej dostępu

Użytkownik ``A`` może przypisać roli ``B`` własność tabeli ``T`` jeśli:

* Rola ``B`` może tworzyć tabele w schemacie w którym znajduje się ``T``
* Użytkownik ``A`` jest elementem roli ``B``

Zadanie 2, Widok LIST_USERS
---------------------------

O widokach nie było na wykładzie, ale są one proste:
`http://www.postgresql.org/docs/9.2/static/sql-createview.html
<http://www.postgresql.org/docs/9.2/static/sql-createview.html>`_

Proszę stworzyć widok ``LIST_USERS`` dostępny dla użytkownika o roli ``user``
który będzie zwracał tylko nazwy użytkowników nie będących administratorami.

W tym widoku będzie jedna kolumna o nazwie ``username``.


Zadanie 3
---------

Teraz proszę stworzyć funkcję ``add_user(username, password)``
która będzie dostępna dla użytkownika ``user`` i która będzie
wstawiać do tabeli ``USERS`` użytkownia i hasło. Przy czym
będzie tworzyć użytkownika który nie jest administratorem.

.. note::

    **Challenge**: proszę zaimplementowć taką samą funkcjonalność
    za pomocą widoku USER_LIST

Zadanie 4
---------

Teraz proszę stworzyć funkcję ``change_user(username, password)``
która będzie dostępna dla użytkownika ``user`` i która
będzie zmieniać hasło użytkownikowi o nazwie ``username``.
Jeśli username jest admiem funkcja powinna zgłaszać błąd.

O zgłaszaniu błędów `w podręczniku
<http://www.postgresql.org/docs/9.3/static/plpgsql-errors-and-messages.html>`_


.. note::

    **Challenge** proszę zaimplementowć taką samą funkcjonalność
    za pomocą widoku USER_LIST

Zadanie 5
---------

Teraz proszę stworzyć funkcję ``del_user(usernamed)``
która będzie dostępna dla użytkownika ``use``r i która
będzie kasować użytkownika o nazwie ``username``.
Jeśli username jest admiem funkcja powinna zgłaszać błąd.

.. note::

    **Challenge** proszę zaimplementowć taką samą funkcjonalność
    za pomocą widoku USER_LIST


Zadanie 6
---------

Proszę stworzyć na tabeli ``USERS`` trigger który dokonuje
automatycznego hashowania hasła. Działa ona w sposób następujący:

* Losuje stały ciąg znaków zwany solą
* Wykonuje funkcje skrótu na haśle
* Zapisuje wynik funkcji skrótu zamiast hasła.

.. code-block:: sql

  CREATE EXTENSION pgcrypto; -- Wykonujemy raz;
  SELECT gen_salt('bf'); --- losuje sól
  SELECT crypt( 'password123', gen_salt('bf')); -- losuje sól i hashuje hasło
  SELECT crypt('bar',  '$2a$06$R5QGfy9Jml2bH7pGH2T88.Gy9TTciacG0z77i6ACZHliuciW4g4sy') =  '$2a$06$R5QGfy9Jml2bH7pGH2T88.Gy9TTciacG0z77i6ACZHliuciW4g4sy';
  --- SPrawdza poprawność hasła.

O co chodzi z hashowaniem haseł
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Staramy się nie przechowywać danych dostępowych do systemu (czy jest to aplikacja
WWW czy jest to system operacyjny) w formie jawnej. Tj. nie przechowujemy
samej informacji dostępowej, a coś co umożliwia nam sprawdzenie czy użytkownik
podał poprawne dane dostępowe.

Dzięki temu włamywacz po uzyskaniu naszej bazy danych nie może zalogować
się do systemu (w bazie danych nie ma informacji dostępowych)

W przypadku haseł jedną z metod jest hashowanie haseł, funkcja hashująca
to funkcja mająca takie cechy:

* Jest jednostronna, tj. mając jej argument łatwo wygenerować wynik, ale mając
  jej wynik trudno wygenerować jej argument.
* Jest deterministyczna tj. dla tego samego wejścia daje takie same wyjście.

Jeśli przechowujemy wynik działania funkcji skrótu na haśle możemy łatwo sprawdzić
czy użytkownich przechował poprawne hasło.

Sól to po prostu losowy jawny ciąg znaków dodawany do hasła przed wykonaniem
funkcji skrótu.

Zadanie 7
---------

Proszę stworzyć funkcję która sprawdza hasła ``check_password(user, password)``,
gdzie ``password`` jest podane tekstem jawnym. Funkcja ta zwraca `true` jeśli
hasło zgadza się z zahashowanym hasłem.
