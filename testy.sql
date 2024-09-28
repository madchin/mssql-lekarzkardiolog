USE LekarzKardiolog;

-- Dostep do wszystkich danych bez mozliwosci modyfikacji czegokolwiek
EXECUTE AS USER = 'kierownik';

-- wyszukiwanie opinii przy uzyciu indeksu pelnotekstowego
EXEC placowka.WyszukajOpinie @fraza='Good';

SELECT * FROM placowka.dokumenty;
SELECT * FROM placowka.lekarze;
SELECT * FROM placowka.opinie;
SELECT * FROM placowka.pacjenci;
SELECT * FROM placowka.rezerwacje;
SELECT * FROM placowka.wizyty;

-- nie mozliwe, brak uprawnien EXEC
EXEC recepcja.PrzypiszInnegoLekarzaDoWizyty 
@pesel_pacjenta = '123',
@id_nowego_lekarza = 2,
@data_wizyty = '2024-12-01 11:00:00'

-- nie mozliwe, brak uprawnien INSERT
INSERT INTO placowka.lekarze (imie, nazwisko, adres, numer_telefonu, email)
VALUES 
('John', 'Jones', 'Warszawa, ul. Zielona 9', '123456789', 'johnjones@example.com');

REVERT;

EXECUTE AS USER = 'socialMedia';
SELECT * FROM placowka.opinie;
EXEC placowka.WyszukajOpinie @fraza = 'Good';


-- nie mozliwe, brak uprawnien EXEC
EXEC recepcja.PrzypiszInnegoLekarzaDoWizyty 
@pesel_pacjenta = '123',
@id_nowego_lekarza = 2,
@data_wizyty = '2024-12-01 11:00:00'

-- nie mozliwe, brak uprawnien INSERT
INSERT INTO placowka.lekarze (imie, nazwisko, adres, numer_telefonu, email)
VALUES 
('John', 'Jones', 'Warszawa, ul. Zielona 9', '123456789', 'johnjones@example.com');

REVERT;


EXECUTE AS USER = 'recepcja';

SELECT USER_NAME(), SUSER_NAME();

EXEC ZarejestrujPacjenta
	@imie = 'Jan',
	@pesel = '123456789',
	@nazwisko = 'Kowalski',
	@data_urodzenia = '1980-10-10',
	@adres = 'Warszawa, ul. Kwiatowa 1',
	@numer_telefonu = '123456678',
	@email = 'jan.kowalski@example.com'

--aktualizowanie danych pacjenta na podstawie peselu
EXEC recepcja.ZaktualizujDanePacjenta
	@imie = 'Marcin',
	@pesel = '123456789',
	@nazwisko = 'Kowal',
	@adres = 'Warszawa, ul. Kwiat 1',
	@numer_telefonu = '123456789',
	@email = 'email@email.com';

EXEC recepcja.RezerwujWizyte
	@pesel_pacjenta = '123456789',
	@id_lekarza = 1,
	@data_wizyty = '2024-11-10 11:00:00',
	@powod_wizyty = '{"reason":"bol glowy"}';

EXEC recepcja.ZaktualizujDateRezerwacji
	@pesel_pacjenta = '123456789',
	@data_wizyty = '2024-11-10 11:00:00',
	@nowa_data_wizyty = '2024-12-10 11:00:00';

EXEC recepcja.PrzypiszInnegoLekarzaDoWizyty
	@pesel_pacjenta = '123456789',
	@data_wizyty = '2024-12-10 11:00:00',
	@id_nowego_lekarza = 2;

EXEC recepcja.AnulujRezerwacje
	@pesel_pacjenta = '123456789',
	@data_wizyty = '2024-12-10 11:00:00';

SELECT * FROM placowka.lekarze;

REVERT;

-- testy dla lekarza
EXECUTE AS USER = 'lekarz_Brown';

EXEC lekarz.ZakonczWizyte
	@id_rezerwacji = 10;

SELECT * FROM MojeRezerwacje;

REVERT;




EXECUTE AS USER = 'lekarz_Higgins';

SELECT * FROM placowka.pacjenci;

EXEC lekarz.ZarejestrujNowaAlergiePacjentowi
	@id_pacjenta = 1,
	@nowa_alergia = 'trawy';

	
EXEC lekarz.UsunWyleczonaAlergiePacjentowi
	@id_pacjenta = 1,
	@alergia_do_usuniecia = 'trawy';
	

SELECT * FROM MojeRezerwacje;

SELECT * FROM MojeWizyty;

REVERT;





EXECUTE AS USER = 'lekarz_Addams';
SELECT * FROM MojeRezerwacje;

EXEC lekarz.DodajDodatkoweInformacjeDoWizyty
	@id_wizyty = 3,
	@nowe_dodatkowe_informacje = 'wszystko ok';

EXEC lekarz.DodajZaleceniaDoWizyty
	@id_wizyty = 3,
	@nowe_zalecenia = 'zaleca sie wykonywanie cwiczen'

SELECT * FROM MojeWizyty;

REVERT;

SELECT * FROM placowka.wizyty;



EXECUTE AS USER = 'lekarz_Jones';
SELECT * FROM MojeRezerwacje;

SELECT * FROM MojeWizyty;

REVERT;

SELECT * FROM lekarz.idLekarzaDoNazwyUzytkownika;