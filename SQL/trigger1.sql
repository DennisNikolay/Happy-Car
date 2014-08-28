﻿--Werksid not Null trigger 
--checked :)
CREATE FUNCTION checkWerksid() RETURNS TRIGGER AS
	$$ BEGIN
		IF(NEW.wid IS NULL) THEN RAISE EXCEPTION 'Wid bei Insert NULL';
		END IF; 
		RETURN NEW;
	END; $$ LANGUAGE plpgsql;

	
CREATE TRIGGER validInsertWerksarbeiter BEFORE INSERT ON Werksarbeiter FOR EACH ROW EXECUTE PROCEDURE checkWerksid();

CREATE TRIGGER validInsertTeilelagerarbeiter BEFORE INSERT ON Teilelagerarbeiter FOR EACH ROW EXECUTE PROCEDURE checkWerksid();


--License at least three years trigger
--checked :)
--BEM: Genauigkeit auf Monat, Tage ignoriert.
CREATE FUNCTION checkLicenseDate() RETURNS TRIGGER AS
	$$ BEGIN
		IF(now() - NEW.führerscheindatum <= interval '3 years') THEN RAISE EXCEPTION 'Führerschein noch nicht lange genug';
		END IF;
		RETURN NEW;
	END; $$ LANGUAGE plpgsql;
CREATE TRIGGER validInsertLKWFahrer BEFORE INSERT ON lkw_fahrer FOR EACH ROW EXECUTE PROCEDURE checkLicenseDate();

--began to work in past trigger
--checked :)
CREATE FUNCTION checkBeginn() RETURNS TRIGGER AS
	$$ BEGIN
		IF(NEW.beschäftigungsbeginn > now()) THEN RAISE EXCEPTION 'Beschäftigungsbeginn in der Zukunft';
		END IF; 
		RETURN NEW;
	END; $$ LANGUAGE plpgsql;
CREATE TRIGGER validInsertMitarbeiter BEFORE INSERT ON mitarbeiter FOR EACH ROW EXECUTE PROCEDURE checkBeginn();



--New Delivery trigger
--checked :)
CREATE FUNCTION newDelivery() RETURNS TRIGGER AS
	$$ BEGIN
		UPDATE Autos SET Status='LIEFERND' WHERE kfz_id=NEW.kfz_id AND modell_id=NEW.modell_id;
		RETURN NEW;
	END;$$ LANGUAGE plpgsql;
	
CREATE TRIGGER setOnDelivery AFTER INSERT ON liefert FOR EACH ROW EXECUTE PROCEDURE newDelivery();



--Delivery finished trigger
--checked :)
CREATE FUNCTION finishedDelivery(integer, integer, integer, integer) RETURNS boolean AS
	$$ BEGIN
		UPDATE Autos SET Status='ARCHIVIERT' WHERE kfz_id=$1 AND modell_id=$2;
		UPDATE liefert SET Lieferdatum=CURRENT_DATE WHERE KFZ_ID=$1 AND MID=$3 AND AID=$4;
		UPDATE Aufträge SET Status='ARCHIVIERT' WHERE AID=$4;
		RETURN true;
	END; $$ LANGUAGE plpgsql;
CREATE RULE setOnDeliveryFinished AS ON DELETE TO liefert DO INSTEAD SELECT finishedDelivery(OLD.kfz_id, OLD.modell_id, OLD.MID, OLD.AID);

CREATE FUNCTION checkAvailableWork(integer) RETURNS boolean AS
	$$
	DECLARE 
	auftrag integer;
	countNeeded integer;
	available boolean;
	notmissing boolean;
	BEGIN
	IF(EXISTS (SELECT 1 FROM Werksaufträge WHERE WID=$1 AND Status='IN_BEARBEITUNG') )
		THEN RETURN false; 
	END IF;
	FOR auftrag IN SELECT AID FROM Werksaufträge WHERE WID=$1
	LOOP
		countNeeded := (SELECT Anzahl FROM Aufträge WHERE AID=auftrag);
		available:=(NOT EXISTS (SELECT 1 FROM 
			-- Wähle Autoteile, die diesem Auftrag zugeordnet sind
			((SELECT TeiletypID, count(*) FROM Autoteile WHERE lagert_in = $1 AND AID=auftrag GROUP BY TeiletypID) AS tmp1
			 RIGHT OUTER JOIN
			--Anzahl benötigter Teile um NEW.Anzahl Autos herzustellen
			(SELECT TeiletypID, (Anzahl * countNeeded) AS teileNeeded FROM ModellTeile WHERE Modell_ID=(SELECT Modell_ID FROM 				Aufträge WHERE AID = auftrag)) AS tmp2
			ON tmp1.TeiletypID=tmp2.TeiletypID)
			WHERE teileNeeded>count OR count IS NULL LIMIT 1));
		--Sind genügend Teile im Lager?
		IF (available) THEN
			IF(NOT EXISTS (SELECT * FROM Werksaufträge WHERE Status='IN_BEARBEITUNG' AND WID=$1)) THEN
				UPDATE Werksaufträge SET Status='IN_BEARBEITUNG' WHERE WID=$1 AND AID=auftrag;
				UPDATE Werksaufträge SET Herstellungsbeginn=CURRENT_DATE WHERE WID=$1 AND AID=auftrag;
				RETURN true;
			END IF;
		END IF;
		notmissing:=(NOT EXISTS (SELECT 1 FROM 
			-- Wähle Autoteile, die keinem Auftrag zugeordnet sind (AID ist NULL)
			((SELECT TeiletypID, count(*) FROM Autoteile WHERE lagert_in = $1 AND AID IS NULL GROUP BY TeiletypID) AS tmp1
			 RIGHT OUTER JOIN
			--Anzahl benötigter Teile um NEW.Anzahl Autos herzustellen
			(SELECT TeiletypID, (Anzahl * countNeeded) AS teileNeeded FROM ModellTeile WHERE Modell_ID=(SELECT Modell_ID FROM 				Aufträge WHERE AID =auftrag)) AS tmp2
			ON tmp1.TeiletypID=tmp2.TeiletypID)
			WHERE teileNeeded>count OR count IS NULL LIMIT 1));
		IF (notmissing) THEN
			IF(NOT EXISTS (SELECT * FROM Werksaufträge WHERE Status='IN_BEARBEITUNG' AND WID=$1)) THEN
				UPDATE Werksaufträge SET Status='IN_BEARBEITUNG' WHERE WID=$1 AND AID=auftrag;
				UPDATE Werksaufträge SET Herstellungsbeginn=CURRENT_DATE WHERE WID=$1 AND AID=auftrag;
				RETURN true;
			END IF;
		END IF;
	END LOOP;
	RETURN false;
END; $$ LANGUAGE plpgsql;

--car parts arrived
CREATE FUNCTION carPartsArrived() RETURNS TRIGGER AS
	$$ 
	DECLARE
		teilid integer;
		countNeeded integer;
		available boolean;
		counter integer;
	BEGIN
		counter:=OLD.Anzahl;
		IF (OLD.Status='ARCHIVIERT' OR NEW.Status!='ARCHIVIERT') THEN RETURN NEW; END IF;
		LOOP
		EXIT WHEN counter=0;
			INSERT INTO Autoteile (TeiletypID, lagert_in, Lieferdatum, AID) VALUES (OLD.TeiletypID, OLD.WID, now(), OLD.AID);
			UPDATE Autoteile SET Lieferdatum=CURRENT_DATE WHERE TeileID=lastVal();
			counter=counter-1;		
		END LOOP;	
		PERFORM checkAvailableWork(OLD.WID);
		RETURN NEW;
	END; $$ LANGUAGE plpgsql;
-- TODO Falls wir eine archivtabelle einführen, dann bei OnDelete, ansonsten bei Update
CREATE TRIGGER setOnCarPartsArrived AFTER UPDATE ON bestellt FOR EACH ROW EXECUTE PROCEDURE carPartsArrived();



--on insert Werksaufträge
CREATE FUNCTION getBestManufacturer(integer) RETURNS integer AS 
	$$ BEGIN
		RETURN
		(SELECT HID FROM
			(SELECT * FROM produzieren WHERE TeiletypID=$1
			ORDER BY Zeit ASC
			FETCH FIRST 3 ROWS ONLY
			) AS tmp
		ORDER BY Preis ASC
		FETCH FIRST 1 ROWS ONLY
		);			
	END; $$ LANGUAGE plpgsql;


-- on insert Werksaufträge
CREATE FUNCTION insertInJobs() RETURNS TRIGGER AS
	$$ 
	DECLARE
		missing boolean;
		neededParts integer;
		part integer;
		
		countNeeded integer;
		
	BEGIN		
		countNeeded := (SELECT Anzahl FROM Aufträge WHERE AID=NEW.AID);
		missing:=(EXISTS (SELECT 1 FROM 
			-- Wähle Autoteile, die keinem Auftrag zugeordnet sind (AID ist NULL)
			((SELECT TeiletypID, count(*) FROM Autoteile WHERE lagert_in = NEW.WID AND AID IS NULL GROUP BY TeiletypID) AS tmp1
			 RIGHT OUTER JOIN
			--Anzahl benötigter Teile um NEW.Anzahl Autos herzustellen
			(SELECT TeiletypID, (Anzahl * countNeeded) AS teileNeeded FROM ModellTeile WHERE Modell_ID=(SELECT Modell_ID FROM 				Aufträge WHERE AID = NEW.AID)) AS tmp2
			ON tmp1.TeiletypID=tmp2.TeiletypID)
			WHERE teileNeeded>count OR count IS NULL LIMIT 1));
		--Sind genügend Teile im Lager?
		IF (missing) THEN --NEIN
			--Iteriere über benötigte Teile
			FOR part IN (SELECT TeiletypID FROM Modellteile WHERE Modell_ID=(SELECT Modell_ID FROM Aufträge WHERE AID=NEW.AID))
			LOOP
				--Anzahl wieoft Teil gebraucht wird.
				neededParts := (SELECT Anzahl*(SELECT Anzahl FROM Aufträge WHERE AID=NEW.AID) FROM ModellTeile WHERE Modell_ID=(SELECT Modell_ID FROM Aufträge WHERE AID=NEW.AID) AND TeiletypID = part);

				IF(neededParts > 0) THEN
					--Bestelle die Teile
					INSERT INTO bestellt (HID, WID, TeiletypID, Anzahl, Bestelldatum, AID) VALUES 
							      (getBestManufacturer(part), NEW.WID, part, neededParts, now(), NEW.AID);
				END IF;
			END LOOP;
		ELSE --JA
			--Iteriere über benötigte Teile
			FOR part IN (SELECT TeiletypID FROM Modellteile WHERE Modell_ID=(SELECT Modell_ID FROM Aufträge WHERE AID=NEW.AID))
			LOOP
				--Anzahl wieoft Teil gebraucht wird.
				neededParts:=(SELECT Anzahl*(SELECT Anzahl FROM Aufträge WHERE AID=NEW.AID) FROM ModellTeile WHERE Modell_ID=(SELECT Modell_ID FROM Aufträge WHERE AID=NEW.AID) AND TeiletypID=part);
				IF(neededParts > 0) THEN
					--Bestelle die Teile
					INSERT INTO bestellt (HID, WID, TeiletypID, Anzahl, Bestelldatum, AID) VALUES 
							      (getBestManufacturer(part), NEW.WID, part, neededParts, now(), NULL);
					--Setze bei genau einem Teil des benötigten Typs den Auftragsstatus
					UPDATE Autoteile SET AID=NEW.AID FROM (SELECT TeileID FROM Autoteile WHERE TeiletypID=part AND AID IS NULL ORDER BY ID ASC LIMIT neededParts) AS alias;
				END IF;
			END LOOP;
			-- Es sind alle Teile da, wird irgendein auftrag gerade aufgeführt? Wenn nein dann führe diesen hier aus.
			IF(NOT EXISTS (SELECT * FROM Werksaufträge WHERE Status='IN_BEARBEITUNG' AND WID=NEW.WID)) THEN
				UPDATE Werksaufträge SET Status='IN_BEARBEITUNG' WHERE WID=NEW.WID AND AID=NEW.AID;
				UPDATE Werksaufträge SET Herstellungsbeginn=CURRENT_DATE WHERE WID=NEW.WID AND AID=NEW.AID;
			END IF;
		END IF;	
		RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;

CREATE TRIGGER onInsertWerksaufträge AFTER INSERT ON Werksaufträge FOR EACH ROW EXECUTE PROCEDURE insertInJobs();




-- get estimated time for car production in days
CREATE OR REPLACE FUNCTION getWerksauslastung(integer) RETURNS interval AS
	$$
	DECLARE
	auftrag integer;
	expectedTime integer;
	liefer date;
		
	BEGIN
	expectedTime=0;
	FOR auftrag IN (SELECT Werksaufträge.AID FROM Werksaufträge WHERE WID=$1)
	LOOP

		liefer:=(SELECT Vorraussichtliches_Lieferdatum FROM Aufträge WHERE AID=auftrag);
		expectedTime = expectedTime + (liefer - CURRENT_DATE)+1;
	END LOOP;
	RETURN expectedTime * interval '1 days';
	END;
	$$ LANGUAGE plpgsql;


-- returns the estimated delivery time for a given distance
CREATE OR REPLACE FUNCTION getTimeForDistance(integer) RETURNS interval AS
	$$
	BEGIN
	-- 50km/h
	RETURN CEIL(($1/50)/24)*interval '1 days';
	END;
	$$ LANGUAGE plpgsql;


-- checks if ordered cars are already produced
-- Param (Modell_ID, Anzahl)
CREATE OR REPLACE FUNCTION checkCarStock(integer, integer) RETURNS boolean AS
	$$
	DECLARE 
	counting integer;
	BEGIN
	counting = (SELECT count(*) AS Anzahl FROM Autos WHERE Modell_ID = $1 AND Status = 'LAGERND');
	RETURN counting >= $2;
	END;
	$$ LANGUAGE plpgsql;


-- checks if a LKW is available - returns LKW_ID or null
-- Param ()
CREATE OR REPLACE FUNCTION checkLkwAvailable() RETURNS integer AS
	$$
	BEGIN
		RETURN
		(	(SELECT LKW_ID FROM LKWs
			EXCEPT
			SELECT LKW_ID FROM liefert)
			ORDER BY LKW_ID ASC
			FETCH FIRST 1 ROWS ONLY
		);
	END;
	$$ LANGUAGE plpgsql;


-- checks if a driver is available - returns PID or null
CREATE OR REPLACE FUNCTION checkDriverAvailable() RETURNS integer AS
	$$
	BEGIN
	RETURN (	(SELECT PID FROM LKW_Fahrer 
			EXCEPT 
			SELECT MID AS PID FROM liefert) 
			ORDER BY PID ASC 
			FETCH FIRST 1 ROWS ONLY
	);
	END;
	$$ LANGUAGE plpgsql;



-- onInsert Aufträge, teile Auftrag bestimmtem Werk zu oder liefere ggf. direkt zum kunden
-- TODO Modell_ID bei liefert sinnvoll ?!
CREATE OR REPLACE FUNCTION insertInOrders() RETURNS TRIGGER AS
	$$
	DECLARE
	orderInStock boolean;
	counter integer;
	cars integer;
	driver integer;
	lkw integer;
	distance integer;
	werk integer;
	minwerktime interval;
	minwerkid integer;
	
	BEGIN
	minwerkid:=(SELECT WID FROM Werksaufträge LIMIT 1);
	IF(minwerkid IS NULL) THEN minwerkid:=(SELECT WID FROM Werke LIMIT 1); END IF;
	minwerktime:=getWerksauslastung(minwerkid); 
	orderInStock := checkCarStock(NEW.Modell_ID, NEW.Anzahl);
	driver := checkDriverAvailable();
	lkw := checkLkwAvailable();
	distance := (SELECT Distanz FROM Kunden WHERE PID = (SELECT KundenID FROM Aufträge WHERE AID=NEW.AID));
	counter := (SELECT Anzahl FROM Aufträge WHERE AID=NEW.AID);
	
	-- Autos sind schon im Autolager
	IF orderInStock THEN
		UPDATE Aufträge SET Vorraussichtliches_Lieferdatum=now()+getTimeForDistance(distance) WHERE AID=NEW.AID;
		IF (lkw IS NULL OR driver IS NULL) THEN
			--NEIN, dann Lagere Autos vorübergehend
			UPDATE Autos SET Status='WARTEND' WHERE Modell_ID = NEW.Modell_ID AND KFZ_ID IN (SELECT KFZ_ID FROM Autos WHERE Modell_ID=NEW.Modell_ID);
		ELSE --JA, dann liefere sofort.
			FOR cars IN (SELECT KFZ_ID FROM Autos WHERE Modell_ID = NEW.Modell_ID AND Status = 'LAGERND')
			LOOP
			EXIT WHEN counter = 0;
				INSERT INTO liefert (LKW_ID, KFZ_ID, Modell_ID, MID, AID, Lieferdatum) VALUES (lkw, cars, NEW.Modell_ID, driver, NEW.AID, NULL);
				counter=counter-1;
			END LOOP;
		END IF;
	ELSE	--NEIN, dann produziere
		FOR werk IN (SELECT WID FROM Werke)
		LOOP
			RAISE NOTICE 'Minwerktime: % ', minwerktime;
			RAISE NOTICE 'Werksauslastung: %',getWerksauslastung(werk);
			IF (minwerktime>=getWerksauslastung(werk)) THEN
				minwerktime=getWerksauslastung(werk);
				minwerkid=werk;
			END IF;
		END LOOP;
		UPDATE Aufträge SET Vorraussichtliches_Lieferdatum=now()+minwerktime+getTimeForDistance(distance)+(CEIL(counter*1.5/24)*interval '1 days') WHERE AID=NEW.AID;
		INSERT INTO Werksaufträge (WID, AID) VALUES (minwerkid, NEW.AID);			
	
	END IF;
	RETURN NULL;
	END;
	$$ LANGUAGE plpgsql;
	
CREATE TRIGGER onInsertAufträge AFTER INSERT ON Aufträge FOR EACH ROW EXECUTE PROCEDURE insertInOrders();



--Bei Einchecken eines fertigen Auftrags, Einfügen der Autos
CREATE FUNCTION finishedJob() RETURNS TRIGGER AS
	$$
	DECLARE
	counter integer;
	modellid integer;
	werk integer;	
	kfzid integer;
	lkw integer;
	fahrer integer;
	BEGIN
	lkw=checkLkwAvailable();
	fahrer=checkDriverAvailable();
	--Setze Startpunkt in Aufträge
	IF(OLD.Status!='IN_BEARBEITUNG' AND NEW.status='IN_BEARBEITUNG')THEN
		UPDATE Aufträge SET Status = 'IN_BEARBEITUNG' WHERE NEW.Aid = Aufträge.AID;
	END IF;
	--Es wird nur etwas getan, falls die Änderung auch von bel Status zu AUSGEFÜHRT war
	IF (OLD.Status='ARCHIVIERT' OR NEW.Status!='ARCHIVIERT') THEN 
		RETURN NULL;
	END IF;
	modellid=(SELECT Modell_ID FROM Aufträge WHERE AID=OLD.AID);
	werk=(SELECT WID FROM Werksaufträge WHERE AID=OLD.AID);
	counter=(SELECT Anzahl FROM Aufträge WHERE AID=OLD.AID);
	UPDATE Werksaufträge SET Herstellungsende=CURRENT_DATE WHERE WID=OLD.WID AND AID=OLD.AID;
	--Gibt es einen freien LKW und Fahrer?
	IF (lkw IS NULL OR fahrer IS NULL) THEN --NEIN, dann Lagere Autos vorübergehend
		LOOP
			EXIT WHEN counter=0;
			INSERT INTO Autos (Modell_ID, Status, produziertVon) VALUES (modellid, 'WARTEND', werk);
			counter=counter-1;
		END LOOP;
	ELSE --JA, dann liefere sofort.
		LOOP
			EXIT WHEN counter=0;
			INSERT INTO Autos (Modell_ID, Status, produziertVon) VALUES (modellid, 'LAGERND', werk);
			kfzid=(SELECT max(KFZ_ID) FROM Autos);
			INSERT INTO liefert (LKW_ID, KFZ_ID, Modell_ID, MID, AID, Lieferdatum) VALUES (lkw, kfzid, modellid, fahrer, OLD.AID, NULL);
			counter=counter-1;
		END LOOP;
	DELETE FROM Autoteile WHERE AID=OLD.AID;
	END IF;
	RETURN NEW;
	END;
	$$ LANGUAGE plpgsql;

CREATE TRIGGER onFinishedJob AFTER UPDATE ON Werksaufträge FOR EACH ROW EXECUTE PROCEDURE finishedJob();


CREATE FUNCTION insertInAutoteile() RETURNS TRIGGER AS
	$$
	BEGIN
	SELECT AID FROM Werksaufträge WHERE WID=NEW.lagert_in GROUP BY WID HAVING Status='ARCHIVIERT';
	END; $$ LANGUAGE plpgsql;



-- calculate price for inserted order
CREATE FUNCTION calculatePrice() RETURNS TRIGGER AS
	$$
	DECLARE
	var_rabatt integer;
	price numeric(10,2);
	
	BEGIN
	var_rabatt := 0;
	-- Kunde ist Kontaktperson / Großhändler
	IF (EXISTS (SELECT 1 FROM Kontaktpersonen WHERE PID = NEW.KundenID)) THEN
		var_rabatt := (SELECT Rabatt FROM ( SELECT *
						FROM Aufträge
						JOIN Kontaktpersonen
						ON NEW.KundenID = Kontaktpersonen.PID
					     ) AS tmp1
					JOIN Großhändler
					ON tmp1.GID = Großhändler.GID LIMIT 1);	
	END IF;
	price := (100-var_rabatt) * (SELECT Preis FROM Modelle WHERE NEW.Modell_ID = Modelle.Modell_ID) * NEW.Anzahl/100;
	UPDATE Aufträge SET Preis = price WHERE Aufträge.AID = NEW.AID;
	RETURN NEW;
	END; $$ LANGUAGE plpgsql;
	
CREATE TRIGGER calculatePrice AFTER INSERT ON Aufträge FOR EACH ROW EXECUTE PROCEDURE calculatePrice();
		

