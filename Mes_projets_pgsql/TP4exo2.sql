--exercice 2
drop table reservation;
drop table statistique;
drop table station;
drop table hotel;
drop table chambre;
drop table client;

drop type t_client cascade;
drop type t_adresse cascade;
drop type t_chambre cascade;
drop type t_hotel cascade;
drop type t_station cascade;

drop function chambre_libre(hot t_hotel,dat varchar(20), nbpers integer);
drop function nblits_libre(reg varchar(20),cat varchar(20),dat varchar(20));
drop function hotels_libres(dat varchar(20));

drop trigger majNbChamb on chambre cascade;
drop function majnc();

CREATE TYPE t_station AS(
	NomSta		varchar(20),
	Altitude	integer,
	Region		varchar(20)
);
CREATE TABLE station OF t_station;
insert into station VALUES ('Avoriaz',1841,'Haute-Savoie');


CREATE TYPE t_hotel AS(
	Nom		varchar(20),
	Station		t_station,
	Categorie	varchar(20),
	NbChamb		integer
);
CREATE TABLE hotel OF t_hotel;
insert into hotel VALUES ('club med',(select s from station s where s.NomSta='Avoriaz'),'3 étoile',150);


CREATE TYPE t_chambre AS(
	Hotel		t_hotel,
	NumCh		integer,
	Nblits		integer
);
CREATE TABLE chambre OF t_chambre;
insert into chambre VALUES ((select h from hotel h where h.Nom='club med'),145,4);


CREATE TYPE t_adresse AS(
	num		integer,
	rue		varchar(20),
	ville		varchar(20),
	codePostal	integer
);

CREATE TYPE t_client AS(
	Nom		varchar(20),
	Adresse		t_adresse,
	Tel		integer
);
CREATE TABLE client OF t_client;
insert into client VALUES ('Kayser',row(12,'rue de cotte','Paris',75012),0666666666);


CREATE TABLE reservation(
	Client		t_client,
	Hotel		t_hotel,
	Chambre		t_chambre,
	DateDeb		varchar(20),
	DateFin		varchar(20),
	NbPers		integer
);
insert into reservation VALUES ((select c from client c where c.Nom='Kayser'),(select h from hotel h where h.Nom='club med'),(select a from chambre a where a.NumCh=145),'14/02/2018','22/02/2018',3);


CREATE TABLE statistique(
	Station		t_station,
	nb_de_visiteur	integer
);



--#####################################################################

CREATE FUNCTION chambre_libre(hot t_hotel,dat varchar(20), nbpers integer) RETURNS setof VARCHAR as $$
DECLARE
	inet CURSOR FOR (SELECT c FROM chambre c WHERE c.Hotel=hot and c.Nblits >= nbpers)
			except
			(SELECT r.chambre FROM reservation r WHERE r.Hotel=hot and r.DateDeb=dat);
BEGIN
	for i in inet LOOP
		return next i.c;
	END LOOP;
	return;
END;
$$ language plpgsql;

select * from chambre_libre((select h from hotel h where h.Nom='club med'),'13/02/2018',2);


--#####################################################################

CREATE FUNCTION nblits_libre(reg varchar(20),cat varchar(20),dat varchar(20)) RETURNS setof VARCHAR as $$
DECLARE
	inet CURSOR FOR (SELECT h.Categorie,h.Station,h.NbChamb FROM Hotel h WHERE h.Categorie=cat);
BEGIN
	for i in inet LOOP
		IF i.Categorie=cat and (i.Station).Region=reg then
			return next i.NbChamb;
		END IF;
	END LOOP;
	return;
END;
$$ language plpgsql;

select * from nblits_libre('Haute-Savoie','3 étoile','13/02/2018');



--#####################################################################

CREATE FUNCTION liste_clients(hot t_hotel) RETURNS setof VARCHAR as $$
DECLARE
	inet CURSOR FOR (SELECT r.DateDeb,r.DateFin,(r.Client).Nom,(r.Chambre).NumCh  FROM reservation r WHERE hot=r.Hotel);
BEGIN
	FOR i in inet LOOP
		return next i.Nom||' -> '||i.NumCh||' -> '||i.DateDeb||' -> '||i.DateFin;
	END LOOP;
	return;
END;
$$ language plpgsql;

select liste_clients((select h from hotel h where h.Nom='club med'));



--#####################################################################

CREATE FUNCTION hotels_libres(dat varchar(20)) RETURNS setof VARCHAR as $$
DECLARE
	inet CURSOR FOR (SELECT r.Hotel FROM reservation r WHERE dat=r.DateDeb);
BEGIN
	FOR i in inet LOOP
		if (SELECT count(r.Hotel) FROM reservation r WHERE r.DateDeb=dat)<(i.Hotel).NbChamb 
		then
			return next (i.Hotel).Nom;
		END IF;
	END LOOP;
	return;
END;
$$ language plpgsql;


select hotels_libres('14/02/2018');


--#####################################################################

CREATE FUNCTION majnc() RETURNS trigger as $$
BEGIN
	if TG_OP = 'insert' then UPDATE hotel h SET h.NbChamb=h.NbChamb+1 WHERE h.Nom=new.Hotel.Nom;
	END IF;
	if TG_OP = 'delete' then UPDATE hotel h SET h.NbChamb=h.NbChamb-1 WHERE h.Nom=new.Hotel.Nom;
	END IF;
	return OLD;	
END;
$$ language plpgsql;


CREATE TRIGGER majNbChamb 
	BEFORE INSERT OR DELETE
	ON chambre FOR EACH ROW
	EXECUTE PROCEDURE majnc();


INSERT INTO chambre VALUES((select h from hotel h where h.Nom='club med'),146,10);
--DELETE FROM chambre WHERE NumCh=146;
select * from hotel;


















