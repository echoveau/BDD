--Exercice 2:

DROP TABLE vol;
DROP TABLE avion;
DROP TABLE pilote;

DROP FUNCTION maj();

CREATE TABLE avion (
	AvNum		integer,
	AvNom		varchar(30),
	Capacite	integer, 
	Localisation	integer,
	PRIMARY KEY (AvNum)
);


CREATE TABLE pilote(
	PiNum		integer,
	PiNom		varchar(30),
	PiPrenom	varchar(30), 
	Ville		varchar(30),
	Salaire		integer,
	PRIMARY KEY (PiNum)
);


CREATE TABLE vol(
	VolNum		integer,
	PiNum		integer,
	AvNum		integer, 
	VilleDep	varchar(30),
	VilleArr	varchar(30),
	HeureDep	float,
	HeureArr	float,
	PRIMARY KEY (VolNum)
/*
	FOREIGN KEY (AvNum) REFERENCES avion(AvNum),
	FOREIGN KEY (PiNum) REFERENCES pilote(PiNum)
*/
);



INSERT INTO vol VALUES (1,1,1,'Angers','Nantes',5,10);

CREATE FUNCTION maj() RETURNS void as $$
DECLARE
	curs CURSOR FOR SELECT VolNum,HeureDep,HeureArr,AvNum FROM vol WHERE AvNum=1 OR AvNum=2 OR AvNum=4 OR AvNum=8;
BEGIN
	FOR i IN curs LOOP
		IF i.AvNum==1 OR i.AvNum==4 THEN
			UPDATE vol SET i.HeureArr=i.HeureDep+(i.HeureArr-i.HeureDep-(i.HeureArr-i.HeureDep*10/100)) WHERE VolNum=i.VolNum;
		ELSE
			UPDATE vol SET i.HeureArr=i.HeureDep+(i.HeureArr-i.HeureDep-(i.HeureArr-i.HeureDep*15/100)) WHERE VolNum=i.VolNum;
		END IF;
END;

$$ language plpgsql;
