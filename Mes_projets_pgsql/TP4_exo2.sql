--Exercice 2
drop type t_station cascade;
drop type t_hotel cascade;
drop type t_client cascade;
drop type t_chambre cascade;
drop type t_statistique cascade;
drop type t_adresse cascade;

drop table station cascade;
drop table hotel cascade;
drop table client cascade;
drop table chambre cascade;
drop table reservation cascade;

drop function chambreLibre(Monhotel t_hotel, date_r date, nbpersonne integer);
drop function nbLit(laregion varchar(30), lacategorie varchar(30), ladate date);
drop function liste_client(Monhotel varchar(30));
drop function hotel_libre(madate date);
drop function maj();
drop function verif();

drop trigger maj_nbchamb on chambre cascade;
drop trigger ajoutres on reservation;

--question 1

create type t_adresse as(
	nbRue integer,
	rue varchar(30),
	ville varchar(30),
	codePostale integer
);

create type t_station as ( 
	NomSta varchar(30),
	Alltitude varchar,
	Region varchar(30)
);

create table station of t_station;

insert into station values ('Avoriaz','1941m','Haute-Savoie');
insert into station values ('Arc 2000','2000m','Alpes');
insert into station values ('Arc 2500','2500m','Alpes');
insert into station values ('Arc 3000','3000m','Alpes');

create type t_hotel as (
	Nom varchar(30),
	station t_station,
	Categorie varchar(30),
	NbChamb integer
);

create table hotel of t_hotel;

insert into hotel values ('Club Med',(select s from station s where s.NomSta='Avoriaz') ,'3 etoile', 150);

insert into hotel values ('Novotel',(select s from station s where s.NomSta='Arc 2000') ,'3 etoile', 200);
insert into hotel values ('Luigi',(select s from station s where s.NomSta='Arc 2000') ,'3 etoile', 120);

insert into hotel values ('F1',(select s from station s where s.NomSta='Arc 2500') ,'3 etoile', 100);

insert into hotel values ('Hotel',(select s from station s where s.NomSta='Arc 3000') ,'3 etoile', 80);



create type t_chambre as (
	hotel t_hotel,
	NumCh varchar(30),
	Nblits integer
);

create table chambre of t_chambre;

insert into chambre values ((select h from hotel h where h.Nom='Club Med') ,'145A', 4);
insert into chambre values ((select h from hotel h where h.Nom='Club Med') ,'147A', 3);
insert into chambre values ((select h from hotel h where h.Nom='Club Med') ,'146A', 3);
insert into chambre values ((select h from hotel h where h.Nom='Club Med') ,'144A', 2);

insert into chambre values ((select h from hotel h where h.Nom='Novotel') ,'145B', 1);
insert into chambre values ((select h from hotel h where h.Nom='Novotel') ,'147B', 2);
insert into chambre values ((select h from hotel h where h.Nom='Novotel') ,'146B', 3);
insert into chambre values ((select h from hotel h where h.Nom='Novotel') ,'144B', 2);

insert into chambre values ((select h from hotel h where h.Nom='F1') ,'145C', 1);
insert into chambre values ((select h from hotel h where h.Nom='F1') ,'147C', 1);
insert into chambre values ((select h from hotel h where h.Nom='F1') ,'146C', 1);
insert into chambre values ((select h from hotel h where h.Nom='F1') ,'144C', 1);

insert into chambre values ((select h from hotel h where h.Nom='Luigi') ,'145D', 1);
insert into chambre values ((select h from hotel h where h.Nom='Luigi') ,'147D', 2);
insert into chambre values ((select h from hotel h where h.Nom='Luigi') ,'146D', 3);
insert into chambre values ((select h from hotel h where h.Nom='Luigi') ,'144D', 4);

insert into chambre values ((select h from hotel h where h.Nom='Hotel') ,'145E', 4);
insert into chambre values ((select h from hotel h where h.Nom='Hotel') ,'147E', 3);
insert into chambre values ((select h from hotel h where h.Nom='Hotel') ,'146E', 3);
insert into chambre values ((select h from hotel h where h.Nom='Hotel') ,'144E', 4);



create type t_client as (
	Nom varchar(30),
	Adresse t_adresse,
	Tel integer
);

create table client of t_client;

insert into client values ('Kayser',row(12,'rue de cotte','Paris',75012) ,0666666666);
insert into client values ('George',row(24,'rue de rue','Angers',49000) ,0777777777);
insert into client values ('Bryan',row(23,'rue de rue','Angers',49000) ,0777777778);
insert into client values ('Kevin',row(22,'rue de rue','Angers',49000) ,0777777779);

create table reservation (
	client t_client,
	hotel t_hotel,
	chambre t_chambre,
	DateDeb date,
	DateFin date,
	NbPers integer
);

insert into reservation values ((select c from client c where Nom='Kayser'),(select h from hotel h where h.Nom='Club Med'),(select c from chambre c where c.NumCh='145A'),'2018-04-10','2018-04-14',3);

insert into reservation values ((select c from client c where Nom='George'),(select h from hotel h where h.Nom='Novotel'),(select c from chambre c where c.NumCh='146B'),'2018-04-25','2018-05-01',3);

create type t_statistique as ( 
	station t_station,
	nb_de_visiteur integer
);

create table statistique of t_statistique;

--question 2:


CREATE FUNCTION chambreLibre(Monhotel t_hotel, date_r date, nbpersonne integer) RETURNS setof t_chambre as $$

DECLARE 
	chambre cursor for select c from chambre c where c.hotel=Monhotel and c.Nblits >= nbpersonne EXCEPT select r.chambre from reservation r where date_r between r.DateDeb and r.DateFin;
	
BEGIN
	for n in chambre LOOP 
		return next n.c;
	end LOOP;
	return;
END;

$$ language plpgsql;

select * from chambreLibre((select h from hotel h where h.Nom='Club Med'),'2018-04-15',3);

--question 3:

CREATE FUNCTION nbLit(laregion varchar(30), lacategorie varchar(30), ladate date) RETURNS setof varchar as $$

DECLARE
	ihotel CURSOR FOR SELECT h.Nom FROM hotel h WHERE h.Categorie=lacategorie and (h.station).Region=laregion;
	nbLits integer;
	nbtot integer;

BEGIN
	FOR i in ihotel LOOP
		nbtot = (SELECT sum(c.Nblits) FROM chambre c WHERE (c.hotel).Nom = i.Nom );	
		nbLits =(SELECT sum((r.chambre).Nblits) FROM reservation r WHERE (((r.chambre).hotel).station).Region=laregion and ladate between r.DateDeb and r.DateFin);
	
		if nbLits>0 then
			return next i.Nom||' : '||nbtot-nbLits;
		else 		return next i.Nom||' : '||nbtot;
		END IF;
	END LOOP;
	return;
END;
$$ language plpgsql;

select nbLit('Alpes','3 etoile','2018-04-02');


--question 4:

CREATE FUNCTION liste_client(Monhotel varchar(30)) RETURNS setof varchar as $$

DECLARE 
	chambre cursor for select (r.client).Nom, (r.chambre).NumCh, r.DateDeb, r.DateFin from reservation r where (r.hotel).Nom=Monhotel;
	
BEGIN
	for n in chambre LOOP 
		return next n.Nom || ' ' || n.NumCh || ' ' || n.DateDeb ||' '|| n.DateFin;
	end LOOP;
	return;
END;

$$ language plpgsql;

select liste_client('Club Med');


--question 5:

CREATE FUNCTION hotel_libre(madate date) RETURNS setof varchar as $$

DECLARE 
	chambre cursor for select r.hotel from reservation r where madate between r.DateDeb and r.DateFin group by ((r.hotel).Categorie,r.hotel);
	
BEGIN
	for n in chambre LOOP 
		if (n.hotel).NbChamb >= (select count(r.chambre) from reservation r where (r.hotel).Nom= (n.hotel).Nom)
		then
			return next (n.hotel).Nom;
		end if;
	end LOOP;
	return;
END;

$$ language plpgsql;

select hotel_libre('2018-04-02');


--question 6 :

CREATE FUNCTION maj() RETURNS trigger as $$
BEGIN
	if TG_OP = 'INSERT' then
		UPDATE hotel
		SET NbChamb = NbChamb +1
		WHERE Nom = (NEW.hotel).Nom;
	else if TG_OP = 'DELETE' then
		UPDATE hotel
		SET NbChamb = NbChamb -1
		WHERE Nom = (OLD.hotel).Nom;
	     end if;
	end if;
	return OLD;
END;
$$ language plpgsql;

CREATE TRIGGER maj_nbchamb 
	after INSERT OR DELETE 
	ON chambre FOR EACH row 
	EXECUTE PROCEDURE maj(); 

insert into chambre values ((select h from hotel h where h.Nom='Club Med') ,'148A', 4);
select * from hotel;


--question 7 :


CREATE FUNCTION verif() RETURNS trigger as $$
DECLARE
	curs CURSOR FOR SELECT r.DateDeb,r.DateFin FROM reservation r WHERE r.hotel=new.hotel and r.chambre=new.chambre;
BEGIN
	for i in curs LOOP
		if new.DateDeb<i.DateFin and new.DateFin>i.DateDeb then return null;
		END IF;
	END LOOP;
	return new;
END;
$$ language plpgsql;



CREATE TRIGGER ajoutres 
	before INSERT 
	ON reservation FOR EACH row 
	EXECUTE PROCEDURE verif(); 

--marche
insert into reservation values ((select c from client c where Nom='Kevin'),(select h from hotel h where h.Nom='Novotel'),(select c from chambre c where c.NumCh='146B'),'2018-05-25','2018-05-27',3);

--ne marche pas
insert into reservation values ((select c from client c where Nom='Bryan'),(select h from hotel h where h.Nom='Novotel'),(select c from chambre c where c.NumCh='146B'),'2018-04-26','2018-04-28',3);


select client,DateDeb,DateFin from reservation;









