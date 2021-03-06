CREATE TABLE Personen (
	PID integer,
	Vorname varchar NOT NULL,
	Nachname varchar NOT NULL,
	PLZ varchar(10) NOT NULL,
	Straße varchar(50) NOT NULL,
	Wohnort varchar(50) NOT NULL,
	Email varchar(50) NOT NULL,
	Tel bigint NOT NULL,
	
	CONSTRAINT personenPK PRIMARY KEY (PID)
	--PLZ die mit 00 beginnen sind definitiv ungültig.
	--CONSTRAINT validPLZ CHECK (PLZ ~ '/^([0]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{3}$/'),
	--CONSTRAINT validEmail CHECK (Email ~* '^[a-zA-Z0-9_-.]+@[a-zA-Z0-9-]+.[a-zA-Z0-9-.]+$')
);

CREATE TABLE Werke (
	WID integer,
	Name varchar NOT NULL,
	
	CONSTRAINT werkePK PRIMARY KEY (WID)
);

CREATE TABLE Teilelager (
	WID integer,
	
	FOREIGN KEY (WID) REFERENCES Werke,
	
	CONSTRAINT teilelagerPK PRIMARY KEY (WID)
);

CREATE TABLE Mitarbeiter (
	PID integer,
	Beschäftigungsbegin date NOT NULL,
	Gehalt numeric(10,2) NOT NULL,
	
	FOREIGN KEY (PID) REFERENCES Personen,

	CONSTRAINT mitarbeiterPK PRIMARY KEY (PID),
	CONSTRAINT notSlave CHECK (Gehalt>0)
);

CREATE TABLE Werksarbeiter (
	PID integer,
	WID integer REFERENCES Werke,
	
	FOREIGN KEY (PID) REFERENCES Mitarbeiter,

	CONSTRAINT werksarbeiterPK PRIMARY KEY (PID)
);


CREATE TABLE LKW_Fahrer (
	PID integer,
	Führerscheindatum date NOT NULL,
	
	FOREIGN KEY (PID) REFERENCES Mitarbeiter,

	CONSTRAINT lkwFahrerPK PRIMARY KEY (PID)
);


CREATE TABLE Verwaltungsangestellte (
	PID integer,
	
	FOREIGN KEY (PID) REFERENCES Mitarbeiter,

	CONSTRAINT verwaltungsangestelltePK PRIMARY KEY (PID)
);
CREATE TABLE Lagerarbeiter (
	PID integer NOT NULL,
	
	FOREIGN KEY (PID) REFERENCES Mitarbeiter,

	CONSTRAINT lagerarbeiterPK PRIMARY KEY (PID)
);


CREATE TABLE Teilelagerarbeiter (
	PID integer,
	WID integer NOT NULL,
	
	FOREIGN KEY (WID) REFERENCES Teilelager,
	FOREIGN KEY (PID) REFERENCES Lagerarbeiter,

	CONSTRAINT teilelagerarbeiterPK PRIMARY KEY (PID)
);

CREATE TABLE Autolagerarbeiter (
	PID integer,
	
	FOREIGN KEY (PID) REFERENCES Lagerarbeiter,

	CONSTRAINT autolagerarbeiterPK PRIMARY KEY (PID)
);


CREATE TABLE Großhändler (
	GID integer,
	Firmenname varchar(50) NOT NULL,
	Straße varchar(50) NOT NULL,
	PLZ varchar (10) NOT NULL,
	Ort varchar(50) NOT NULL,
	Rabatt integer,
	
	--CONSTRAINT validPLZ CHECK (PLZ ~ '/^([0]{1}[1-9]{1}|[1-9]{1}[0-9]{1})[0-9]{3}$/'),
	CONSTRAINT großhändlerPK PRIMARY KEY (GID)
);

CREATE TABLE Modelle (
	ModellID integer,
	Preis numeric(10,2) NOT NULL,
	Bezeichnung varchar NOT NULL,
	
	CONSTRAINT modellePK PRIMARY KEY (ModellID)
);

CREATE TABLE Kunden (
	PID integer,
	Distanz integer NOT NULL,
	
	FOREIGN KEY (PID) REFERENCES Personen,

	CONSTRAINT kundenPK PRIMARY KEY (PID)
);


CREATE TABLE Privatkunden (
	PID integer,
	
	FOREIGN KEY (PID) REFERENCES Kunden,

	CONSTRAINT privatkundenPK PRIMARY KEY (PID)
);


CREATE TABLE Kontaktpersonen (
	PID integer,
	GID integer NOT NULL,
	
	FOREIGN KEY (GID) REFERENCES Großhändler,
	FOREIGN KEY (PID) REFERENCES Kunden,

	CONSTRAINT kontaktpersonenPK PRIMARY KEY (PID)
);

CREATE TABLE Aufträge (
	AID integer,
	Preis numeric(10,2) NOT NULL,
	Vorraussichtliches_Lieferdatum date,
	Modell_ID integer NOT NULL,
	Anzahl integer NOT NULL,
	Datum date NOT NULL,
	KundenID integer NOT NULL,
	MitarbeiterID integer NOT NULL,
	
	FOREIGN KEY (Modell_ID) REFERENCES Modelle,
	FOREIGN KEY (KundenID) REFERENCES Kunden,
	FOREIGN KEY (MitarbeiterID) REFERENCES Verwaltungsangestellte,

	CONSTRAINT aufträgePK PRIMARY KEY (AID)
);

-- TODO: Was ist hier möglich?
CREATE DOMAIN Auftragsstatus AS varchar(14)
	CHECK (VALUE ~ 'WARTEND' OR VALUE~'IN_BEARBEITUNG' OR VALUE~'AUSGEFÜHRT');

CREATE TABLE Werksaufträge (
	WID integer,
	AID integer,
	Status Auftragsstatus,
	
	FOREIGN KEY (WID) REFERENCES Werke,
	FOREIGN KEY (AID) REFERENCES Aufträge,

	CONSTRAINT werksaufträgePK PRIMARY KEY (WID, AID)
);

CREATE TABLE Autoteiltypen (
	TeiletypID integer,
	maxPreis numeric(10,2) NOT NULL,
	Bezeichnung varchar NOT NULL,
	
	CONSTRAINT autoteiltypenPK PRIMARY KEY (TeiletypID)
);

CREATE TABLE Modellteile (
	Modell_ID integer,
	TeiletypID integer,

	FOREIGN KEY (Modell_ID) REFERENCES Modelle,
	FOREIGN KEY (TeiletypID) REFERENCES Autoteiltypen,

	CONSTRAINT modellteilePK PRIMARY KEY (Modell_ID, TeiletypID)
);

CREATE DOMAIN Autostatus AS varchar(10) CHECK (VALUE~'LAGERND' OR VALUE~'LIEFERND' OR VALUE~'ARCHIVIERT' OR VALUE~'WARTEND');

CREATE TABLE Autos (
	KFZ_ID integer,
	Modell_ID integer,
	Status Autostatus,
	produziertVon integer NOT NULL,

	FOREIGN KEY (Modell_ID) REFERENCES Modelle,
	FOREIGN KEY (produziertVon) REFERENCES Werke,

	CONSTRAINT autosPK PRIMARY KEY (Modell_ID, KFZ_ID)
);

CREATE TABLE LKWs (
	LKW_ID integer,
	Kaufdatum date NOT NULL,

	CONSTRAINT lkwsPK PRIMARY KEY (LKW_ID)
);

CREATE TABLE liefert (
	LKW_ID integer NOT NULL,
	KFZ_ID integer,
	Modell_ID integer,
	MID integer,
	AID integer,
	Lieferdatum date,

	FOREIGN KEY (KFZ_ID, Modell_ID) REFERENCES Autos,
	FOREIGN KEY (MID) REFERENCES LKW_Fahrer,
	FOREIGN KEY (LKW_ID) REFERENCES LKWs,
	FOREIGN KEY (AID) REFERENCES Aufträge,
	
	CONSTRAINT liefertPK PRIMARY KEY (KFZ_ID, MID, AID)
);

CREATE TABLE Hersteller (
	HID integer NOT NULL,
	Firmennamen varchar NOT NULL,

	CONSTRAINT herstellerPK PRIMARY KEY (HID)
);

CREATE TABLE produzieren (
	TeiletypID integer,
	HID integer,
	Preis numeric(10,2),

	FOREIGN KEY (TeiletypID) REFERENCES Autoteiltypen,
	FOREIGN KEY (HID) REFERENCES Hersteller,
	
	CONSTRAINT produzierenPK PRIMARY KEY (TeiletypID, HID)
);

CREATE TABLE bestellt (
	HID integer,
	WID integer,
	TeiletypID integer,
	Bestelldatum date,
	
	FOREIGN KEY (HID) REFERENCES Hersteller,
	FOREIGN KEY (WID) REFERENCES Werke,
	FOREIGN KEY (TeiletypID) REFERENCES Autoteiltypen,
	
	CONSTRAINT bestelltPK PRIMARY KEY (HID, WID, TeiletypID, Bestelldatum)
);

CREATE DOMAIN Teilestatus AS varchar(10) CHECK (VALUE~'RESERVIERT' OR VALUE~'VERFÜGBAR');

CREATE TABLE Autoteile (
	TeileID integer,
	TeiletypID integer,
	lagert_in integer,
	Lieferdatum date,
	Status Teilestatus,
	
	FOREIGN KEY (TeiletypID) REFERENCES Autoteiltypen,
	FOREIGN KEY (lagert_in) REFERENCES Teilelager,
	
	CONSTRAINT autoteilePK PRIMARY KEY (TeileID, TeiletypID, lagert_in)
);

CREATE TABLE Motoren (
	TeiletypID integer,
	PS integer NOT NULL,
	Drehzahl integer NOT NULL,
	Verbrauch integer NOT NULL,
	Spritart varchar NOT NULL,

	FOREIGN KEY (TeiletypID) REFERENCES Autoteiltypen,

	CONSTRAINT motorenPK PRIMARY KEY (TeiletypID)
);

CREATE TABLE Karosserien (
	TeiletypID integer,
	Farbe varchar NOT NULL,
	Material varchar NOT NULL,
	Höhe integer NOT NULL,
	Breite integer NOT NULL,
	Länge integer NOT NULL,

	FOREIGN KEY (TeiletypID) REFERENCES Autoteiltypen,

	CONSTRAINT karosserienPK PRIMARY KEY (TeiletypID)
);


CREATE TABLE Türen (
	TeiletypID integer,
	Farbe varchar NOT NULL,
	Türart varchar,
	
	FOREIGN KEY (TeiletypID) REFERENCES Autoteiltypen,

	CONSTRAINT türenPK PRIMARY KEY (TeiletypID)
);

CREATE TABLE Fenster (
	TeiletypID integer,
	Tönung varchar NOT NULL,
	Glasart varchar NOT NULL,

	FOREIGN KEY (TeiletypID) REFERENCES Autoteiltypen,

	CONSTRAINT fensterPK PRIMARY KEY (TeiletypID)
);

CREATE TABLE Reifen (
	TeiletypID integer,
	Farbe varchar NOT NULL,
	Zoll integer NOT NULL,
	Felgenmaterial varchar NOT NULL,

	FOREIGN KEY (TeiletypID) REFERENCES Autoteiltypen,

	CONSTRAINT reifenPK PRIMARY KEY (TeiletypID)
);
