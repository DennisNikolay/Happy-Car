﻿--PLZ die mit 00 beginnen sind definitiv ungültig.
INSERT INTO Personen VALUES 
	(0, 'Peter', 'Müller', '66740', 'Hauptstr.1', 'Saarlouis', 'Peter.Müller@web.de', 0683100000),
	(1, 'Hans Adolf', 'Bibelroy', '11111', 'Einsstr. 11', 'Einsstadt', 'Hans_Adolf@somepage.com', 11111111111),
	(2, 'Sandra', 'Schmidt', '12487', 'Abram-Joffe-Straße 3', 'Berlin', 'S.Schmidt@joadkhgfa89.to', 017200011100),
	(3, 'Hermann', 'Buchmann', '01222', 'Straße 42', 'Stadt', 'buchmann@verwaltung.de', 028409374),
	(4, 'Gus', 'Thomer', '73733', 'Einkaufsstr. 55', 'Schopstadt', 'Gus@thomer.de', 065115635),
	(5, 'Petra', 'Müller', '66740', 'Hauptstr. 1', 'Saarlouis', 'Petra.Müller@web.de', 0683100000),
	(6, 'Hildegard', 'Bibelroy', '11111', 'Einsstr.11', 'Einsstadt', 'HildegardB@somepage.com', 11111111111),
	(7, 'Yildiz', 'Tilbe', '12487', 'Hauptstr. 200', 'Berlin', 'YildizTilbe@ghioapi.de', 017200011100),
	(8, 'Hermann', 'Buchmannklon', '01222', 'Straße 43', 'Stadt', 'buchmannklon@verwaltung.de', 028409275),
	(9, 'Alexandra', 'Dünsch', '73732', 'Einkaufsstr. 155', 'Klossstadt', 'Alexandra.dünsch@gmx.net', 049846433),
	(10, 'Fred', 'Fred', '41564', 'Whasstr. 12', 'Whasstart', 'Fred.Fred@fred.com', 01984354102),
	(11, 'Friedolin', 'Fred', '41564', 'Whasstr. 12', 'Whasstart', 'Friedolin.Fred@fred.com', 01984354000),
	(12, 'Freda', 'Fred', '41564', 'Whasstr.12', 'Whasstart', 'Freda.Fred@fred.com', 01984354111),
	(13, 'Peter', 'Ludolf', '56307', 'Mittelstr. 2', 'Dernbach', 'PeterLudolf@web.de', 026891259),
	(14, 'Uwe', 'Ludolf', '56307', 'Mittelstr. 2', 'Dernbach', 'PeterLudolf@web.de', 026891259),
	(15, 'Manfred', 'Ludolf', '56307', 'Mittelstr. 2', 'Dernbach', 'PeterLudolf@web.de', 026891259),
	(16, 'Peter', 'Schreiner', '54441', 'Kabuffstraße 8', 'Kanara', 'peter@gmx.de', 06581787878),
	(17, 'Günther', 'Knopfler', '54341', 'Kirschenweg 1', 'Betonia', 'günther69@gmx.de', 065173458568),
	(18, 'Luise', 'McKidney', '88076', 'Sackgässchen 1', 'Dorflo', 'luise@home.de', 0171443322);


INSERT INTO Werke VALUES
	(0, 'Hauptwerk'),
	(1, 'Werk Zwickau'),
	(2, 'Heinemann Werk'),
	(3, 'Gutes Werken am See'),
	(4, 'Outsourcing Elements'),
	(5, 'Güllen Werke GmbH');


INSERT INTO Teilelager VALUES
	(0), (1), (2), (3), (4), (5);


INSERT INTO Mitarbeiter VALUES
	(0, '2011-11-11', 2000.00),
	(2, '2012-12-12',1800.00),
	(3, '1999-01-01', 1200.00),
	(5, '1999-02-02', 3400.40),
	(7, '2012-12-13',1600.00),
	(8, '2003-04-04', 800.21),
	(10, '2013-10-10', 1650.00),
	(11, '2013-10-10', 1650.00),
	(12, '2013-10-10', 1650.00),
	(13, '2010-10-10', 8000.00),
	(14, '2010-10-10', 8000.00),
	(15, '2010-10-10', 8000.00),
	(16, '2005-12-10', 2500.00),
	(17, '2005-12-20', 2300.00),
	(18, '2003-08-12', 2100.00);


INSERT INTO Werksarbeiter VALUES
	(0, 0),
	(5, 1),
	(17, 2);


INSERT INTO LKW_Fahrer VALUES 
	(10, '2009-01-01'),
	(11, '2008-02-02'),
	(12, '2007-03-03'),
	(18, '2007-05-03');


INSERT INTO Verwaltungsangestellte VALUES
	(3),(8);

INSERT INTO LAGERARBEITER VALUES
	(13),(14),(15),(16);

INSERT INTO Teilelagerarbeiter VALUES
	(13, 2),(14,2);


INSERT INTO Autolagerarbeiter VALUES
	(15), (16);


INSERT INTO Großhändler VALUES
	(0, 'Expensive Cars','Geschäftstr. 3', '12345', 'Counttown', 5),
	(1, 'Cheap Cars', 'Randstraße 9', '12345', 'Counttown', 25),
	(2, 'Lensen und Partner GmbH', 'Hauptstraße 1', '66551', 'Saarhausen', 0),
	(3, 'Autos 4 Life', 'Tortenstraße 4', '66151', 'Goldsilbern', 5),
	(4, 'Kadetten und Twingos GmbH', 'Rue de Kartoffel 17', '44251', 'Köpfern', 0);


INSERT INTO Modelle VALUES
	(0, 19999, 'Prototyp'),
	(1, 11000, 'Billiger Prototyp'),
	(2, 12000.99, 'Happy Hippo Car - Der Verkaufsschlager'),
	(3, 13999, 'Twilight 500'),
	(4, 9999.99, 'Karre');


INSERT INTO Kunden VALUES
	(1,100),(4, 300), (6, 104), (9, 304);


INSERT INTO Privatkunden VALUES
	(4),(9);


INSERT INTO Kontaktpersonen VALUES
	(1, 0),
	(6, 1);


INSERT INTO Aufträge VALUES
	(0, 39998, '2015-06-06', 0, 2, '2014-08-09', 1, 3),
	(1, 22000, '2015-06-06', 1, 2, '2014-08-09', 4, 8),
	(2, 23999.98, '2015-06-06', 2, 2, '2014-08-09', 6, 3),
	(3, 39998, '2015-06-06', 0, 2, '2014-08-09', 9, 3);


INSERT INTO Werksaufträge VALUES
	(1, 0, 'WARTEND'),
	(5, 1, 'IN_BEARBEITUNG'),
	(4, 2, 'AUSGEFÜHRT');


INSERT INTO Autoteiltypen VALUES
	(0, 100, 'Flügeltür Rot'),
	(1, 100, 'Flügeltür Blau'),
	(2, 200, 'Flügeltür Grün'),
	(3, 100, 'Tür Blau'),
	(4, 100, 'Tür Rot'),
	(5, 100, 'Tür Grün'),
	(6, 50, 'Fenster Tönung Blau'),
	(7, 50, 'Fenster ohne Tönung'),
	(8, 500, 'Karosserie Blau'),
	(9, 600, 'Karosserie Grün'),
	(10, 600, 'Karosserie Gelb'),
	(11, 600, 'Karosserie Rot'),
	(12, 100, 'Reifen klein'),
	(13, 100, 'Reifen mittel'),
	(14, 100, 'Reifen groß'),
	(15, 2000, 'Motor schwach'),
	(16, 3000, 'Motor gut'),
	(17, 4000, 'Motor sportlich');


INSERT INTO Modellteile VALUES
	(0, 0), (0, 6), (0, 8), (0, 12), (0, 17),
	(1, 1), (1, 6), (1, 8), (1, 13), (1, 16),
	(2, 1), (2, 6), (2, 8), (2, 13), (2, 15),
	(3, 1), (3, 6), (3, 8), (3, 13), (3, 16),
	(4, 1), (4, 6), (4, 8), (4, 13), (4, 16);


INSERT INTO Autos VALUES
	(0, 0, 'LIEFERND', 0),
	(1, 1, 'LIEFERND', 0),
	(2, 0, 'LAGERND', 3),
	(3, 3, 'WARTEND', 5),
	(4, 2, 'ARCHIVIERT', 2);


INSERT INTO LKWs VALUES
	(0, '2010-01-10'),
	(1, '2011-02-01'),
	(2, '2010-02-01'),
	(3, '2011-04-01'),
	(4, '2014-02-01');


INSERT INTO liefert VALUES
	(0, 0, 0, 10, 0, '2014-01-10'),
	(1, 1, 1, 11, 1, '2014-02-10');


INSERT INTO Hersteller VALUES
	(0, 'Teilezurichter - Profis und Azubis'),
	(1, 'Katalysatoren 4 Life'),
	(2, 'Teile gegen Bares'),
	(3, 'Items, Gadgets and more');


INSERT INTO produzieren VALUES
	(0, 0, 50.50),
	(1, 1, 50.50),
	(2, 0, 60.0),
	(3, 0, 60.0),
	(4, 0, 50.50),
	(5, 1, 50.50),
	(6, 2, 60.0),
	(7, 3, 60.0),
	(8, 3, 50.50),
	(9, 1, 50.50),
	(10, 0, 60.0),
	(11, 2, 60.0),
	(12, 0, 50.50),
	(13, 1, 50.50),
	(14, 0, 60.0),
	(15, 2, 60.0),
	(16, 0, 60.0),
	(17, 0, 60.0);


INSERT INTO bestellt VALUES
	(0, 0, 0, '2014-01-12'),
	(1, 1, 1, '2014-01-13'),
	(0, 2, 2, '2014-01-14'),
	(0, 1, 3, '2014-01-15'),
	(0, 2, 4, '2014-01-12'),
	(1, 1, 5, '2014-01-12');


INSERT INTO Autoteile VALUES
	(0, 0, 0, '2013-01-12', 'RESERVIERT'),
	(1, 1, 1, '2013-01-12', 'VERFÜGBAR'),
	(2, 2, 0, '2013-01-12', 'RESERVIERT'),
	(3, 3, 2, '2013-01-12', 'VERFÜGBAR'),
	(4, 4, 0, '2013-01-12', 'VERFÜGBAR'),
	(5, 5, 0, '2013-01-12', 'VERFÜGBAR'),
	(6, 6, 0, '2013-01-12', 'RESERVIERT'),
	(7, 7, 0, '2013-01-12', 'RESERVIERT'),
	(8, 8, 2, '2013-01-12', 'RESERVIERT'),
	(9, 9, 0, '2013-01-12', 'VERFÜGBAR'),
	(10, 10, 0, '2013-01-12', 'VERFÜGBAR'),
	(11, 11, 4, '2013-01-12', 'VERFÜGBAR'),
	(12, 12, 4, '2013-01-12', 'VERFÜGBAR'),
	(13, 13, 0, '2013-01-12', 'RESERVIERT'),
	(14, 14, 5, '2013-01-12', 'RESERVIERT'),
	(15, 15, 5, '2013-01-12', 'RESERVIERT'),
	(16, 16, 0, '2013-01-12', 'RESERVIERT'),
	(17, 17, 1, '2013-01-12', 'RESERVIERT');

	
INSERT INTO Motoren VALUES
	(15, 80, 7000, 5, 'Diesel'),
	(16, 120, 8000, 8, 'Diesel'),
	(17, 240, 10000, 12, 'Super');


INSERT INTO Karosserien VALUES
	(8, 'Blau', 'Blech', 80, 150, 200),
	(9, 'Grün', 'Carbon', 80, 150, 200),
	(10, 'Gelb', 'Blech', 80, 150, 200),
	(11, 'Rot', 'Zink', 80, 150, 200);


INSERT INTO Türen VALUES
	(0, 'Rot', 'Flügeltür'),
	(1, 'Blau', 'Flügeltür'),
	(2, 'Grün', 'Flügeltür'),
	(3, 'Blau', 'normal'),
	(4, 'Rot', 'normal'),
	(5, 'Grün', 'normal');


INSERT INTO Fenster VALUES
	(6, 'Blau', 'Sicherheitsglas'),
	(7, 'klar', 'Saphirglas');


INSERT INTO Reifen VALUES
	(12, 'Blau', 17, 'Chrom'),
	(13, 'Grün', 18, 'Stahl'),
	(14, 'Schwarz', 20, 'Aluminium');