--TP4

--exercice 1
--1
drop table eleveurs cascade;
drop table elevages cascade;
drop type t_eleveur cascade;
drop type t_adresse cascade;
drop type t_elevage cascade;


CREATE TYPE t_adresse AS(
	nrue		integer,
	rue		varchar(20),
	ville		varchar(20),
	code_postale	integer
	
);


CREATE TYPE t_elevage AS(
	animal		varchar(20),
	ageMin		integer,
	nbrMax		integer
);


create table elevages OF t_elevage;
INSERT INTO elevages VALUES ('ovins',5,40);
INSERT INTO elevages VALUES ('bovin',6,39);
INSERT INTO elevages VALUES ('volaille',2,38);
INSERT INTO elevages VALUES ('porcin',1,37);


CREATE TYPE t_eleveur AS(
	NumLicence	integer,
	elevage		t_elevage,
	adr		t_adresse
);

create table eleveurs OF t_eleveur;
--2
INSERT INTO eleveurs VALUES (3,(select e from elevages e where e.animal='ovins'),ROW(50,'rue du petitBonhomme','Vallée sur Erdre',45412));

--3
INSERT INTO eleveurs VALUES (2,(select e from elevages e where e.animal='volaille'),ROW(32,'rue Delahousse','Paris',75000));
SELECT * FROM eleveurs ;
UPDATE eleveurs SET elevage=(select e from elevages e where e.animal='porcin') WHERE NumLicence=2;

--4
INSERT INTO eleveurs VALUES (1,(select e from elevages e where e.animal='bovin'),ROW(32,'rue de la rue','Angers',49120));
SELECT * FROM eleveurs ;

UPDATE eleveurs SET elevage=(select e from elevages e where e.animal='volaille') WHERE (adr).ville='Angers';
SELECT * FROM eleveurs ;


--5
INSERT INTO eleveurs VALUES (4,(select e from elevages e where e.animal='ovins'),ROW(45,'rue ok','Lille',59000));
UPDATE eleveurs e SET adr=row(null,null,'Bordeaux',30072) WHERE elevage=(select e from elevages e where e.animal='ovins');
SELECT * FROM eleveurs ;

--6
DELETE FROM eleveurs e WHERE (adr).ville='Paris';
SELECT * FROM eleveurs ;




















