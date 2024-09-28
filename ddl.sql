
IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'LekarzKardiolog')
CREATE DATABASE LekarzKardiolog;
GO
USE LekarzKardiolog;
GO

DROP TABLE IF EXISTS placowka.dokumenty;
DROP TABLE IF EXISTS placowka.opinie;
DROP TABLE IF EXISTS placowka.wizyty;
DROP TABLE IF EXISTS placowka.rezerwacje;
DROP TABLE IF EXISTS placowka.pacjenci;
DROP TABLE IF EXISTS placowka.lekarze;
DROP PROCEDURE IF EXISTS placowka.DodajDokument;
DROP PROCEDURE IF EXISTS placowka.WyszukajOpinie;
DROP INDEX IF EXISTS IX_rezerwacje_data_wizyty ON placowka.rezerwacje;
DROP SCHEMA IF EXISTS placowka;

DROP PROCEDURE IF EXISTS recepcja.ZarejestrujPacjenta;
DROP PROCEDURE IF EXISTS recepcja.RezerwujWizyte;
DROP VIEW IF EXISTS recepcja.pacjenci;
DROP PROCEDURE IF EXISTS recepcja.PrzypiszInnegoLekarzaDoWizyty;
DROP PROCEDURE IF EXISTS recepcja.ZaktualizujDanePacjenta;
DROP PROCEDURE IF EXISTS recepcja.ZaktualizujDateWizyty;
DROP PROCEDURE IF EXISTS recepcja.ZaktualizujDateRezerwacji;
DROP PROCEDURE IF EXISTS recepcja.AnulujRezerwacje;
DROP SCHEMA IF EXISTS recepcja;

DROP PROCEDURE IF EXISTS lekarz.DodajAlergiePacjentowi;
DROP PROCEDURE IF EXISTS lekarz.UsunAlergiePacjentowi;
DROP PROCEDURE IF EXISTS lekarz.DodajDodatkoweInformacjeDoWizyty;
DROP PROCEDURE IF EXISTS lekarz.DodajZaleceniaDoWizyty;
DROP TABLE IF EXISTS lekarz.idLekarzaDoNazwyUzytkownika;
DROP VIEW IF EXISTS lekarz.MojeRezerwacje;
DROP VIEW IF EXISTS lekarz.MojeWizyty;
DROP PROCEDURE IF EXISTS lekarz.UsunWyleczonaAlergiePacjentowi;
DROP PROCEDURE IF EXISTS lekarz.ZarejestrujNowaAlergiePacjentowi;
DROP PROCEDURE IF EXISTS lekarz.ZakonczWizyte;
DROP SCHEMA IF EXISTS lekarz;
GO


CREATE SCHEMA placowka;
GO

CREATE TABLE placowka.pacjenci (
	id INT PRIMARY KEY IDENTITY(1,1),
	pesel NVARCHAR(12) UNIQUE NOT NULL,
	imie NVARCHAR(255) NOT NULL,
	nazwisko NVARCHAR(255) NOT NULL,
	data_urodzenia DATE NOT NULL,
	adres NVARCHAR(255) NOT NULL,
	numer_telefonu NVARCHAR(32) NOT NULL,
	email NVARCHAR(255) NOT NULL,
	alergie NVARCHAR(MAX),
);


CREATE TABLE placowka.lekarze (
	id INT PRIMARY KEY IDENTITY(1,1),
	imie NVARCHAR(255) NOT NULL,
	nazwisko NVARCHAR(255) NOT NULL,
	adres NVARCHAR(255) NOT NULL,
	numer_telefonu NVARCHAR(32),
	email NVARCHAR(255) NOT NULL
);

CREATE TABLE placowka.dokumenty (
	id INT PRIMARY KEY IDENTITY(1,1),
	id_pacjenta INT REFERENCES placowka.pacjenci(id),
	tresc VARBINARY(MAX), -- binarne dane
);

CREATE TABLE placowka.rezerwacje (
	id INT PRIMARY KEY IDENTITY(1,1),
	id_pacjenta INT REFERENCES placowka.pacjenci(id),
	id_lekarza INT REFERENCES placowka.lekarze(id),
	data_wizyty DATETIME NOT NULL CHECK(data_wizyty > GETDATE()),
	powod_wizyty NVARCHAR(MAX) NOT NULL,
	aktualny_status INT CHECK(aktualny_status IN (0,1,2))
	-- status 0 -- ZAPLANOWANE
	-- status 1 -- ANULOWANE
	-- status 2 -- ZAKONCZONE
);

CREATE TABLE placowka.wizyty (
	id INT PRIMARY KEY IDENTITY(1,1),
	id_pacjenta INT REFERENCES placowka.pacjenci(id),
	id_rezerwacji INT REFERENCES placowka.rezerwacje(id),
	zalecenia_lekarza NVARCHAR(MAX) DEFAULT '{"zalecenia":[]}', -- JSON
	dodatkowe_informacje NVARCHAR(MAX) DEFAULT '{"info":[]}'-- JSON
);

CREATE TABLE placowka.opinie (
	id INT IDENTITY(1,1),
	id_pacjenta INT REFERENCES placowka.pacjenci(id),
	id_lekarza INT REFERENCES placowka.lekarze(id),
	ocena INT CHECK (ocena BETWEEN 1 AND 5),
	komentarz NVARCHAR(MAX), -- JSON
	CONSTRAINT PK_opinie PRIMARY KEY (id),
);
GO 

-- tworzenie indeksow full-text / wierszowych

CREATE INDEX IX_rezerwacje_data_wizyty ON placowka.rezerwacje(data_wizyty);
GO

IF NOT EXISTS(SELECT 1 FROM sys.fulltext_catalogs WHERE name = 'KomentarzKatalog') 
CREATE FULLTEXT CATALOG KomentarzKatalog AS DEFAULT;
GO

CREATE FULLTEXT INDEX ON placowka.opinie(komentarz)
KEY INDEX PK_opinie ON KomentarzKatalog;
GO

-- tworzenie procedur uzywanych przez wiecej niz 1 uzytkownika

-- procedura wyszukujaca opinie uzywajaca indeksu pelnotekstowego
CREATE PROCEDURE placowka.WyszukajOpinie
	@fraza NVARCHAR(255)
AS
BEGIN
	SELECT * FROM placowka.opinie
	WHERE CONTAINS(komentarz, @fraza);
END;
GO

-- procedura do dodawania roznych dokumentow odnoszace sie do pacjenta
CREATE PROCEDURE placowka.DodajDokument
	@pesel NVARCHAR(12),
	@dokument VARBINARY(MAX)
AS
BEGIN
	DECLARE @id_pacjenta INT;
	SELECT @id_pacjenta = id FROM placowka.pacjenci WHERE pesel = @pesel
	
	IF @id_pacjenta IS NULL
	BEGIN
		RAISERROR('Pacjent o podanym peselu nie istnieje',16,1);
		RETURN;
	END
	
	INSERT INTO placowka.dokumenty (id_pacjenta, tresc)
	VALUES(@id_pacjenta, @dokument);
END;
GO



-- nadawanie uprawnien dla okreslonych uzytkownikow do 
-- poszczegolnych tabel, procedur, schematow
-- oraz tworzenie widokow / procedur
-- charakterystycznych dla okreslonego usera


-- kierownik

--stworzenie loginu sql servera
IF NOT EXISTS(SELECT * FROM sys.server_principals WHERE name = 'kierownik')
CREATE login [kierownik]
WITH PASSWORD=N'12343'
MUST_CHANGE,
DEFAULT_DATABASE=LekarzKardiolog,
CHECK_EXPIRATION=ON;

-- stworzenie usera bazy
IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'kierownik')
CREATE USER kierownik for login kierownik

-- ustawienie default schema na placowke
ALTER USER kierownik WITH default_schema=placowka;

-- nadanie uprawnien read do wszystkich tabel w schemacie placowka
GRANT SELECT ON SCHEMA::placowka TO kierownik;
-- nadanie uprawnien do procedury read
GRANT EXECUTE ON OBJECT::placowka.WyszukajOpinie TO kierownik;
GO



-- specjalista ds. mediow spolecznosciowych

IF NOT EXISTS(SELECT * FROM sys.server_principals WHERE name = 'socialMedia')
CREATE login [socialMedia]
WITH PASSWORD=N'12343'
MUST_CHANGE,
DEFAULT_DATABASE=LekarzKardiolog,
CHECK_EXPIRATION=ON;

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'socialMedia')
CREATE USER socialMedia for login socialMedia

GRANT SELECT ON placowka.opinie to socialMedia;
GRANT EXECUTE ON OBJECT::placowka.WyszukajOpinie to socialMedia;
GO




-- recepcja

IF NOT EXISTS(SELECT * FROM sys.server_principals WHERE name = 'recepcja')
CREATE login [recepcja]
WITH PASSWORD=N'12343'
MUST_CHANGE,
DEFAULT_DATABASE=LekarzKardiolog,
CHECK_EXPIRATION=ON;

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'recepcja')
CREATE USER recepcja for login recepcja
GO


CREATE SCHEMA recepcja;
GO

ALTER USER recepcja WITH default_schema=recepcja;
GO

GRANT SELECT ON placowka.rezerwacje TO recepcja;
GRANT EXECUTE ON SCHEMA::recepcja TO recepcja;
GRANT EXECUTE ON OBJECT::placowka.DodajDokument TO recepcja;
GRANT SELECT ON placowka.lekarze TO recepcja;
GO

-- tworzenie widoku w celu enkapsulacji dokumentacji medycznej (alergii pacjenta)
CREATE VIEW recepcja.pacjenci
AS
SELECT id, imie, nazwisko, data_urodzenia, adres, numer_telefonu, email 
FROM placowka.pacjenci
GO

-- procedura do rejestracji pacjenta w placowce
-- alergie dodaje lekarz (dane wrazliwe)
CREATE PROCEDURE recepcja.ZarejestrujPacjenta
	@imie NVARCHAR(255),
	@pesel NVARCHAR(12),
	@nazwisko NVARCHAR(255),
	@data_urodzenia DATE,
	@adres NVARCHAR(255),
	@numer_telefonu NVARCHAR(32),
	@email NVARCHAR(255)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM placowka.pacjenci WHERE pesel = @pesel)
	BEGIN
		RAISERROR('Pacjent juz istnieje',16,1);
		RETURN;
	END
	INSERT INTO placowka.pacjenci (pesel,imie,nazwisko,data_urodzenia, adres, numer_telefonu, email)
	VALUES (@pesel,@imie, @nazwisko, @data_urodzenia, @adres, @numer_telefonu, @email);
END;
GO

-- procedura do aktualizacji danych pacjenta w placowce
-- daty urodzenia nie da sie zmienic, a alergi nie dodaje
-- recepcjonista bo to dane wrazliwe
CREATE PROCEDURE recepcja.ZaktualizujDanePacjenta
	@imie NVARCHAR(255),
	@pesel NVARCHAR(12),
	@nazwisko NVARCHAR(255),
	@adres NVARCHAR(255),
	@numer_telefonu NVARCHAR(32),
	@email NVARCHAR(255)
AS
BEGIN
	IF NOT EXISTS (SELECT 1 FROM placowka.pacjenci WHERE pesel = @pesel)
	BEGIN
		RAISERROR('Pacjent nie istnieje',16,1);
		RETURN;
	END
	UPDATE placowka.pacjenci
	SET 
	imie = @imie, 
	nazwisko = @nazwisko, 
	adres = @adres, 
	numer_telefonu = @numer_telefonu, 
	email = @email
	WHERE pesel = @pesel;
END;
GO


-- procedura do rezerwacji wizyty pacjenta w placowce,
-- jesli lekarz o tej dacie ma juz umowione wizyte, rezerwacja sie nie powiedzie
-- jesli pacjent o podanym peselu nie istnieje, rezerwacja sie nie powiedzie
-- jesli pacjent ma juz zarezerwowana wizyte, rezerwacja sie nie powiedzie
CREATE PROCEDURE recepcja.RezerwujWizyte
	@pesel_pacjenta NVARCHAR(12),
	@id_lekarza INT,
	@data_wizyty DATETIME,
	@powod_wizyty NVARCHAR(MAX)
AS
BEGIN
	IF EXISTS (SELECT 1 FROM placowka.rezerwacje 
	WHERE id_lekarza = @id_lekarza 
	AND data_wizyty = @data_wizyty
	AND aktualny_status = 0)
	BEGIN
		RAISERROR('Lekarz nie jest dostepny w tym czasie',16,1);
		RETURN;
	END

	DECLARE @pesel NVARCHAR(12);
	DECLARE @id_pacjenta INT;
	SELECT @pesel = pesel, @id_pacjenta = id FROM placowka.pacjenci
	WHERE pesel = @pesel_pacjenta;

	IF @pesel IS NULL
	BEGIN
		RAISERROR('Pacjent nie istnieje',16,1);
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM placowka.rezerwacje 
	WHERE id = @id_pacjenta
	AND data_wizyty = @data_wizyty
	AND aktualny_status = 0)
	BEGIN
		RAISERROR('Pacjent ma juz zarezerwowana wizyte w tym czasie',16,1);
		RETURN;
	END

	INSERT INTO placowka.rezerwacje (id_pacjenta, id_lekarza, data_wizyty, powod_wizyty, aktualny_status)
	VALUES (@id_pacjenta, @id_lekarza, @data_wizyty, @powod_wizyty, 0);
END;
GO

-- procedura do rezerwacji wizyty pacjenta w placowce,
CREATE PROCEDURE recepcja.ZaktualizujDateRezerwacji
	@pesel_pacjenta NVARCHAR(12),
	@data_wizyty DATETIME,
	@nowa_data_wizyty DATETIME
AS
BEGIN
	DECLARE @id_pacjenta INT;

	SELECT @id_pacjenta = id FROM placowka.pacjenci
	WHERE pesel = @pesel_pacjenta;

	IF @id_pacjenta IS NULL
	BEGIN
		RAISERROR('Pacjent nie istnieje',16,1);
		RETURN;
	END

	IF EXISTS(SELECT 1 FROM placowka.rezerwacje 
	WHERE data_wizyty = @nowa_data_wizyty
	AND id_pacjenta = @id_pacjenta
	AND aktualny_status = 0)
	BEGIN
		RAISERROR('Pacjent ma juz zarezerwowana wizyte w dacie na ktora chce przelozyc',16,1);
		RETURN;
	END
		
	DECLARE @id_lekarza INT;

	SELECT @id_lekarza = id_lekarza FROM placowka.rezerwacje 
	WHERE data_wizyty = @data_wizyty
	AND id_pacjenta = @id_pacjenta;

	IF @id_lekarza IS NULL
	BEGIN
		RAISERROR('Nie ma wizyty ktora chcemy zaktualizowac',16,1);
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM placowka.rezerwacje
	WHERE data_wizyty = @nowa_data_wizyty
	AND id_lekarza = @id_lekarza
	AND aktualny_status = 0)
	BEGIN
		RAISERROR('Nie mozna przelozyc wizyty na ta date poniewaz lekarz jest juz wtedy zajety)',16,1);
		RETURN;
	END

	UPDATE placowka.rezerwacje 
	SET data_wizyty = @nowa_data_wizyty 
	WHERE data_wizyty = @data_wizyty
	AND id_pacjenta = @id_pacjenta;
END;
GO

-- procedura do rezerwacji wizyty pacjenta w placowce,
CREATE PROCEDURE recepcja.PrzypiszInnegoLekarzaDoWizyty
	@pesel_pacjenta NVARCHAR(12),
	@id_nowego_lekarza INT,
	@data_wizyty DATETIME
AS
BEGIN
	DECLARE @id_pacjenta INT;

	SELECT @id_pacjenta = id FROM placowka.pacjenci
	WHERE pesel = @pesel_pacjenta;

	IF @id_pacjenta IS NULL
	BEGIN
		RAISERROR('Pacjent nie istnieje',16,1);
		RETURN;
	END
		
	IF NOT EXISTS (SELECT 1 FROM placowka.rezerwacje 
	WHERE data_wizyty = @data_wizyty
	AND id_pacjenta = @id_pacjenta
	AND aktualny_status = 0)
	BEGIN
		RAISERROR('Pacjent nie ma wizyty ktora chcemy zaktualizowac',16,1);
		RETURN;
	END

	IF EXISTS (SELECT 1 FROM placowka.rezerwacje
	WHERE data_wizyty = @data_wizyty
	AND id_lekarza = @id_nowego_lekarza
	AND aktualny_status = 0)
	BEGIN 
		RAISERROR('Nie mozna zmienic lekarza poniewaz nie jest on wtedy dostepny',16,1);
		RETURN;
	END

	UPDATE placowka.rezerwacje
	SET id_lekarza = @id_nowego_lekarza
	WHERE id_pacjenta = @id_pacjenta
	AND data_wizyty = @data_wizyty;
END;
GO

CREATE PROCEDURE recepcja.AnulujRezerwacje
	@pesel_pacjenta NVARCHAR(12),
	@data_wizyty DATETIME
AS
BEGIN
	DECLARE @id_pacjenta INT;
	SELECT @id_pacjenta = id 
	FROM placowka.pacjenci 
	WHERE pesel = @pesel_pacjenta;

	IF @id_pacjenta IS NULL
	BEGIN
		RAISERROR('Pacjent o podanym peselu nie istnieje',16,1);
		RETURN;
	END

	DECLARE @id_lekarza INT;

	IF NOT EXISTS(SELECT 1
	FROM placowka.rezerwacje
	WHERE id_pacjenta = @id_pacjenta
	AND data_wizyty = @data_wizyty)
	BEGIN
		RAISERROR('Rezerwacja nie istnieje dla tego pacjenta w tej dacie',16,1);
		RETURN;
	END

	UPDATE placowka.rezerwacje
	SET aktualny_status = 1
	WHERE id_pacjenta = @id_pacjenta
	AND data_wizyty = @data_wizyty;
END
GO





-- lekarz

CREATE SCHEMA lekarz;
GO

-- loginy dla poszczegolnych lekarzy
IF NOT EXISTS(SELECT * FROM sys.server_principals WHERE name = 'lekarz_Jones')
CREATE login [lekarz_Jones]
WITH PASSWORD=N'12343'
MUST_CHANGE,
DEFAULT_DATABASE=LekarzKardiolog,
CHECK_EXPIRATION=ON;
 GO
 
IF NOT EXISTS(SELECT * FROM sys.server_principals WHERE name = 'lekarz_Addams')
CREATE login [lekarz_Addams]
WITH PASSWORD=N'12343'
MUST_CHANGE,
DEFAULT_DATABASE=LekarzKardiolog,
CHECK_EXPIRATION=ON;
 GO

IF NOT EXISTS(SELECT * FROM sys.server_principals WHERE name = 'lekarz_Higgins')
CREATE login [lekarz_Higgins]
WITH PASSWORD=N'12343'
MUST_CHANGE,
DEFAULT_DATABASE=LekarzKardiolog,
CHECK_EXPIRATION=ON;
 GO

IF NOT EXISTS(SELECT * FROM sys.server_principals WHERE name = 'lekarz_Brown')
CREATE login [lekarz_Brown]
WITH PASSWORD=N'12343'
MUST_CHANGE,
DEFAULT_DATABASE=LekarzKardiolog,
CHECK_EXPIRATION=ON;
 GO
 
--uzytkownicy dla lekarzy
IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'lekarz_Brown')
CREATE USER lekarz_Brown for login lekarz_Brown
GO

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'lekarz_Addams')
CREATE USER lekarz_Addams for login lekarz_Addams
GO

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'lekarz_Higgins')
CREATE USER lekarz_Higgins for login lekarz_Higgins
GO

IF NOT EXISTS(SELECT * FROM sys.database_principals WHERE name = 'lekarz_Jones')
CREATE USER lekarz_Jones for login lekarz_Jones
GO
 
ALTER USER lekarz_Brown WITH default_schema=lekarz;
ALTER USER lekarz_Jones WITH default_schema=lekarz;
ALTER USER lekarz_Addams WITH default_schema=lekarz;
ALTER USER lekarz_Higgins WITH default_schema=lekarz;
GO
 
GRANT EXEC ON OBJECT::placowka.DodajDokument TO lekarz_Brown, lekarz_Jones, lekarz_Addams, lekarz_Higgins;
GRANT SELECT, EXEC ON SCHEMA::lekarz TO lekarz_Brown, lekarz_Jones, lekarz_Addams, lekarz_Higgins;
GRANT SELECT ON OBJECT::placowka.lekarze TO lekarz_Brown, lekarz_Jones, lekarz_Addams, lekarz_Higgins;
GRANT SELECT ON OBJECT::placowka.pacjenci TO lekarz_Brown, lekarz_Jones, lekarz_Addams, lekarz_Higgins;
GO

-- tabela wspomagajaca wyciaganie rezerwacji dla lekarza ktory
-- chce te dane wyciagnac

CREATE TABLE lekarz.idLekarzaDoNazwyUzytkownika (
	id_lekarza INT PRIMARY KEY,
	nazwa_uzytkownika VARCHAR(255),
);
GO

CREATE PROCEDURE lekarz.ZakonczWizyte
	@id_rezerwacji INT
AS
BEGIN
	IF NOT EXISTS(SELECT 1 FROM placowka.rezerwacje 
	WHERE id = @id_rezerwacji
	AND id_lekarza = (SELECT id_lekarza 
	FROM lekarz.idLekarzaDoNazwyUzytkownika
	WHERE nazwa_uzytkownika = USER_NAME()))
	BEGIN
		RAISERROR('Nie ma rezerwacji o podanym ID',16,1);
		RETURN;
	END

	UPDATE placowka.rezerwacje
	SET aktualny_status = 2
	WHERE id = @id_rezerwacji;
END
GO

CREATE PROCEDURE lekarz.ZarejestrujNowaAlergiePacjentowi
	@id_pacjenta INT,
	@nowa_alergia NVARCHAR(255)
AS
BEGIN
	DECLARE @alergie NVARCHAR(MAX);

	SELECT @alergie = alergie FROM placowka.pacjenci WHERE id = @id_pacjenta

	-- jesli nie ma takiej alergi, dodajemy ja.
	IF CHARINDEX(@nowa_alergia, @alergie) = 0
	BEGIN
		SET @alergie = JSON_MODIFY(@alergie, 'append $.alergie', @nowa_alergia);
		UPDATE placowka.pacjenci
		SET alergie = @alergie
		WHERE id = @id_pacjenta
	END
END;
GO

CREATE PROCEDURE lekarz.UsunWyleczonaAlergiePacjentowi
	@id_pacjenta INT,
	@alergia_do_usuniecia NVARCHAR(255)
AS
BEGIN
	DECLARE @alergie NVARCHAR(MAX);

	SELECT @alergie = JSON_VALUE(alergie,'$.alergie') 
	FROM placowka.pacjenci 
	WHERE id = @id_pacjenta
	AND JSON_VALUE(alergie, '$.alergie') != @alergia_do_usuniecia 

	IF @alergie IS NULL
	BEGIN
		SELECT @alergie = '{"alergie":[]}'
	END

	UPDATE placowka.pacjenci
	SET alergie = @alergie
	WHERE id = @id_pacjenta
END;
GO

CREATE PROCEDURE lekarz.DodajDodatkoweInformacjeDoWizyty
	@id_wizyty INT,
	@nowe_dodatkowe_informacje NVARCHAR(MAX)
AS
BEGIN
	DECLARE @aktualne_informacje NVARCHAR(MAX);

	SELECT @aktualne_informacje = dodatkowe_informacje 
	FROM placowka.wizyty WHERE id = @id_wizyty

	-- jesli nie ma takiej alergi, dodajemy ja.
	IF CHARINDEX(@aktualne_informacje, @nowe_dodatkowe_informacje) = 0
	BEGIN
		SET @aktualne_informacje = JSON_MODIFY(@aktualne_informacje, 'append $.info', @nowe_dodatkowe_informacje);
		UPDATE placowka.wizyty
		SET dodatkowe_informacje = @aktualne_informacje
		WHERE id = @id_wizyty
	END
END;
GO

CREATE PROCEDURE lekarz.DodajZaleceniaDoWizyty
	@id_wizyty INT,
	@nowe_zalecenia NVARCHAR(MAX)
AS
BEGIN
	UPDATE placowka.wizyty
	SET zalecenia_lekarza = JSON_MODIFY(zalecenia_lekarza, '$.zalecenia',@nowe_zalecenia)
	WHERE id = @id_wizyty
END;
GO

-- widok do wyciagania rezerwacji dla okreslonego lekarza
CREATE VIEW lekarz.MojeRezerwacje 
AS
SELECT * FROM placowka.rezerwacje
WHERE id_lekarza = (SELECT id_lekarza 
	FROM lekarz.idLekarzaDoNazwyUzytkownika
	WHERE nazwa_uzytkownika = USER_NAME())
GO
-- widok do wyciagania wizyt na podstawie rezerwacji
CREATE VIEW lekarz.MojeWizyty 
AS
SELECT * FROM placowka.wizyty
WHERE id_rezerwacji IN (SELECT id FROM lekarz.MojeRezerwacje)
GO

CREATE OR ALTER TRIGGER placowka.dodawanieLekarzaDoHelpera
ON placowka.lekarze
AFTER INSERT
AS
BEGIN
	DECLARE @id_lekarza INT;
	DECLARE @name NVARCHAR(255);
	SELECT @id_lekarza = inserted.id FROM inserted
	SELECT @name = inserted.nazwisko FROM inserted

	INSERT INTO lekarz.idLekarzaDoNazwyUzytkownika 
	(id_lekarza, nazwa_uzytkownika)
	VALUES (@id_lekarza, 'lekarz_'+@name);
END
GO
