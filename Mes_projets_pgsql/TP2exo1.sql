--Exercice 1:

--PRODUIT
DROP TABLE produit

CREATE TABLE produit (
	NumProd 	integer,
	Desigation 	varchar(30),
	Prix		float,
	PRIMARY KEY (NumProd)
);

INSERT INTO produit VALUES (1,'pq',15.66);
INSERT INTO produit VALUES (2,'vin',17.3);
INSERT INTO produit VALUES (3,'chili',NULL);


--PRODUIT2
DROP TABLE produit2

CREATE TABLE produit2 (
	NumProd 	integer,
	Desigation 	varchar(30),
	Prix		float,
);

CREATE FUNCTION remplip2() RETURNS void as $$
DECLARE
	curs CURSOR FOR SELECT * FROM produit;
BEGIN
	IF SELECT COUNT(*) FROM produit == 0 THEN
		INSERT INTO produit2 VALUES (0,'Pas de produit',NULL);
	ELSE
		FOR i IN curs LOOP
			IF i.Prix is NULL THEN
				INSERT INTO produit2 VALUES (i.NumProd,SELECT UPPER(i.Designation);,i.Prix/6.55957);
			ELSE
				INSERT INTO produit2 VALUES (i.NumProd,SELECT UPPER(i.Designation);,0);	
END IF;
END LOOP;
END;

$$ language plpgsql;

/*
CREATE FUNCTION remplip2 RETURNS void as $$
DECLARE
	curs CURSOR FOR SELECT * FROM produit;
BEGIN
	IF SELECT COUNT(*) FROM produit == 0 THEN
		INSERT INTO produit2 VALUES (0,'Pas de produit',NULL);
	ELSE
		FOR i IN curs LOOP
				INSERT INTO produit2 VALUES (i.NumProd,SELECT UPPER(i.Designation);,i.Prix/6.55957);
END IF;
END LOOP;
END;
*/
