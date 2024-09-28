INSERT INTO placowka.pacjenci (pesel, imie, nazwisko, data_urodzenia, adres, numer_telefonu, email, alergie)
VALUES 
('12345678901', 'Adam', 'Nowak', '1990-05-21', 'Warszawa, ul. Polna 3', '123456789', 'adam.nowak@example.com', '{"alergie":[]}'),
('23456789012', 'Ewa', 'Kowalska', '1985-09-12', 'Warszawa, ul. Szkolna 10', '987654321', 'ewa.kowalska@example.com', '{"alergie":[]}'),
('34567890123', 'Karol', 'Wiśniewski', '1978-02-15', 'Warszawa, ul. Leśna 2', '654321987', 'karol.wisniewski@example.com', '{"alergie":[]}'),
('45678901234', 'Jan', 'Kowalski', '1995-07-11', 'Warszawa, ul. Długa 5', '789654123', 'jan.kowalski@example.com', '{"alergie":[]}'),
('56789012345', 'Agnieszka', 'Majewska', '1982-11-30', 'Warszawa, ul. Krótka 7', '321789654', 'agnieszka.majewska@example.com', '{"alergie":[]}'),
('67890123456', 'Piotr', 'Zieliński', '1992-04-10', 'Warszawa, ul. Kwiatowa 4', '147258369', 'piotr.zielinski@example.com', '{"alergie":[]}'),
('78901234567', 'Anna', 'Lewandowska', '1987-06-25', 'Warszawa, ul. Miodowa 8', '963852741', 'anna.lewandowska@example.com', '{"alergie":[]}'),
('89012345678', 'Tomasz', 'Zalewski', '1983-01-15', 'Warszawa, ul. Ogrodowa 6', '321654987', 'tomasz.zalewski@example.com', '{"alergie":[]}'),
('90123456789', 'Maria', 'Nowakowska', '1976-03-29', 'Warszawa, ul. Zielona 11', '852963741', 'maria.nowakowska@example.com', '{"alergie":[]}'),
('01234567890', 'Michał', 'Sikorski', '1993-10-12', 'Szczecin, ul. Wrzosowa 12', '159753456', 'michal.sikorski@example.com', '{"alergie":[]}'),
('11234567890', 'Dorota', 'Piotrowska', '1989-07-19', 'Warszawa, ul. Jasna 9', '357951486', 'dorota.piotrowska@example.com', '{"alergie":[]}'),
('22345678901', 'Jakub', 'Dąbrowski', '1980-08-05', 'Toruń, ul. Stroma 13', '456123789', 'jakub.dabrowski@example.com', '{"alergie":[]}'),
('33456789012', 'Monika', 'Grabowska', '1996-12-28', 'Warszawa, ul. Słoneczna 15', '258963147', 'monika.grabowska@example.com', '{"alergie":[]}'),
('44567890123', 'Paweł', 'Chmielewski', '1991-11-16', 'Warszawa, ul. Prosta 14', '753159456', 'pawel.chmielewski@example.com', '{"alergie":[]}'),
('55678901234', 'Zofia', 'Kaczmarek', '1979-02-18', 'Warszawa, ul. Zielona 7', '951753456', 'zofia.kaczmarek@example.com', '{"alergie":[]}');






INSERT INTO placowka.lekarze (imie, nazwisko, adres, numer_telefonu, email)
VALUES 
('John', 'Jones', 'Warszawa, ul. Zielona 9', '123456789', 'johnjones@example.com');
INSERT INTO placowka.lekarze (imie, nazwisko, adres, numer_telefonu, email)
VALUES ('Sam', 'Brown', 'Warszawa, ul. Górna 15', '987654321', 'sambrown@example.com');
INSERT INTO placowka.lekarze (imie, nazwisko, adres, numer_telefonu, email)
VALUES ('James', 'Addams', 'Warszawa, ul. Morska 8', '654321987', 'jamesaddams@example.com');
INSERT INTO placowka.lekarze (imie, nazwisko, adres, numer_telefonu, email)
VALUES ('Sam', 'Higgins', 'Warszawa, ul. Leśna 10', '789654123', 'samhiggins@example.com');




INSERT INTO placowka.dokumenty (id_pacjenta, tresc)
VALUES 
(1, 0x526573756c7473), (2, 0x526573756c7473), (3, 0x526573756c7473), 
(4, 0x526573756c7473), (5, 0x526573756c7473), (6, 0x526573756c7473), 
(7, 0x526573756c7473), (8, 0x526573756c7473), (9, 0x526573756c7473), 
(10, 0x526573756c7473), (11, 0x526573756c7473), (12, 0x526573756c7473), 
(13, 0x526573756c7473), (14, 0x526573756c7473), (15, 0x526573756c7473);



INSERT INTO placowka.rezerwacje (id_pacjenta, id_lekarza, data_wizyty, powod_wizyty, aktualny_status)
VALUES 
(1, 1, '2024-12-10 10:00', 'Badanie kontrolne', 0),
(2, 2, '2024-12-11 11:00', 'Ból w klatce piersiowej', 0),
(3, 3, '2024-12-12 12:00', 'Kołatanie serca', 0),
(4, 1, '2024-12-13 09:30', 'Kontrola ciśnienia', 0),
(5, 1, '2024-12-14 10:15', 'Zawroty głowy', 0),
(6, 1, '2024-12-15 08:45', 'Zmęczenie', 0),
(7, 1, '2024-12-16 09:00', 'Profilaktyka', 0),
(8, 1, '2024-12-17 11:45', 'Arytmia', 0),
(9, 1, '2024-12-18 12:30', 'Częste skurcze', 0),
(10, 2, '2024-12-19 14:00', 'Rehabilitacja', 0),
(11, 3, '2024-12-20 15:00', 'Diagnostyka serca', 0),
(12, 3, '2024-12-21 16:30', 'Duszności', 0),
(13, 2, '2024-12-22 17:45', 'Zmiany w EKG', 0),
(14, 3, '2024-12-23 09:00', 'Nadciśnienie tętnicze', 0),
(15, 2, '2024-12-24 10:30', 'Bóle wieńcowe', 0);


INSERT INTO placowka.wizyty (id_pacjenta, id_rezerwacji)
VALUES 
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15);



INSERT INTO placowka.opinie (id_pacjenta, id_lekarza, ocena, komentarz)
VALUES 
(1, 1, 5, '{"comment": "Excellent care"}'),
(2, 2, 4, '{"comment": "Good but slow service"}'),
(3, 3, 5, '{"comment": "Very professional"}'),
(4, 1, 3, '{"comment": "Average service"}'),
(5, 1, 4, '{"comment": "Good but long wait"}'),
(6, 1, 5, '{"comment": "Good doctor"}'),
(7, 1, 4, '{"comment": "Good consultation"}'),
(8, 1, 5, '{"comment": "Great experience"}'),
(9, 2, 3, '{"comment": "Good service"}'),
(10, 2, 4, '{"comment": "Efficient treatment"}'),
(11, 2, 5, '{"comment": "Very caring"}'),
(12, 2, 4, '{"comment": "Good follow-up"}'),
(13, 2, 3, '{"comment": "Service could improve but its good"}'),
(14, 3, 5, '{"comment": "Highly recommended, good"}'),
(15, 4, 4, '{"comment": "Good doctor with care"}');