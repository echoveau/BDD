--exercice 3

--1

drop table note cascade;
drop table matiere cascade;
drop table formation cascade;
drop table etudiant cascade;
drop table enseignant cascade;
drop table stat_resultat;

drop function info_etudiant(NE integer);
drop function moyNote();
drop function moyFormat(format VARCHAR(30));
drop function statForm();
drop function collegues(Nens integer);
drop function Enseig_Etudiant(NE integer);
drop function suppr();
drop function statUpdate();

drop trigger desinscription on etudiant cascade;
drop trigger maj on note cascade;

CREATE TABLE etudiant (
NumEt  integer,
Nom varchar(30),
Prenom varchar(30),
PRIMARY KEY (NumEt)
);

CREATE TABLE enseignant (
NumEns INTEGER,
NomEns VARCHAR(30),
PrenomEns VARCHAR(30),
PRIMARY KEY (NumEns)
);

CREATE TABLE formation (
NomForm VARCHAR(30),
NbrEtud INTEGER,
EnseigResponsable INTEGER,
PRIMARY KEY (NomForm),
FOREIGN KEY (EnseigResponsable) REFERENCES enseignant(NumEns)
);

CREATE TABLE matiere (
NomMat VARCHAR(30),
NomForm VARCHAR(30),
NumEns INTEGER,
Coef INTEGER,
PRIMARY KEY (NomMat, NomForm),
FOREIGN KEY (NomForm) REFERENCES formation(NomForm)
);

CREATE TABLE note (
NumEtud INTEGER,
NomForm VARCHAR(30),
NomMat VARCHAR(30),
Note FLOAT,
PRIMARY KEY (NomMat, NomForm, NumEtud),
FOREIGN KEY (NomMat, NomForm) REFERENCES matiere(NomMat, NomForm),
FOREIGN KEY (NomForm) REFERENCES formation(NomForm),
FOREIGN KEY (NumEtud) REFERENCES etudiant(NumEt),
CONSTRAINT notemax check (Note >=0 and Note <=20)
);

CREATE TABLE stat_resultat (
NomFormation VARCHAR(30),
MoyenneGenerale FLOAT,
NbrRecu INTEGER,
NbrEtudPresent INTEGER,
NoteMax FLOAT,
NoteMin FLOAT
);



INSERT INTO etudiant VALUES (1,'Balavoine','Kevin'),
(2,'Denoes','Matrix'),
(3,'Choveau','Etienne'),
(4,'Dupont','Jean');

INSERT INTO enseignant VALUES (1,'Genest','David'),
(2,'Lefevre','Claire'),
(3,'Richer','JM'),
(4,'Garcia','Laurent');

INSERT INTO formation VALUES ('L3 Informatique',73,2),
('L3 Math',34,4),
('L1 MPCIE',50,1),
('Master Dev',120,3);

INSERT INTO matiere VALUES ('Base de donnee','L3 Informatique',1,5),
('Prog Fonctionnelle','L3 Informatique',2,4),
('Algebre','L3 Math',3,7),
('C++','L1 MPCIE',4,6);

INSERT INTO note VALUES (2,'L3 Informatique','Base de donnee',20),
(1,'L3 Informatique','Prog Fonctionnelle',15),
(1,'L3 Informatique','Base de donnee',12),
(3,'L3 Math','Algebre',5.5),
(4,'L1 MPCIE','C++',17);

--2

CREATE FUNCTION moyNote() RETURNS float as $$

DECLARE 
	noteM CURSOR FOR SELECT * FROM note FULL JOIN matiere ON matiere.NomMat = note.NomMat AND matiere.NomForm = note.NomForm ;
	somme_note float;
	somme_coef integer;
BEGIN
	somme_note=0;
	somme_coef=0;
	FOR n IN noteM LOOP
		somme_note = somme_note+n.note*n.coef;
		somme_coef = somme_coef+n.coef;
	END LOOP;

	IF somme_coef=0 THEN raise notice 'Pas de notes';  ELSE return somme_note/somme_coef;
	END IF;
END;

$$ language plpgsql;

select moyNote();

--3

SELECT e.Nom,e.Prenom,n.note FROM note n join etudiant e on n.NumEtud = e.NumEt where n.Note > moyNote();


-------------------------------------4


CREATE FUNCTION moyFormat(format VARCHAR(30)) RETURNS float as $$

DECLARE 
	noteF CURSOR FOR SELECT * FROM note FULL JOIN matiere ON matiere.NomMat = note.NomMat AND matiere.NomForm = note.NomForm WHERE note.NomForm = format and matiere.NomForm = format ;
	somme_note float;
	somme_coef integer;
BEGIN
	somme_note=0;
	somme_coef=0;
	FOR n IN noteF LOOP
		somme_note = somme_note+n.note*n.coef;
		somme_coef = somme_coef+n.coef;
	END LOOP;

	IF somme_coef=0 THEN return -1;  ELSE return somme_note/somme_coef;
	END IF;
END;

$$ language plpgsql;

select moyFormat('L3 Informatique');


--////////////////////////////5


CREATE FUNCTION statForm() RETURNS void as $$

DECLARE 
	insf CURSOR FOR SELECT NomForm, NbrEtud FROM formation;
	nbrecu integer;
	maxn float;
	minn float;
BEGIN
	nbrecu = 0;
	maxn = 0;
	minn = 0;
	FOR n IN insf LOOP
		select count(NumEtud) into nbrecu from note where Note>10 and n.NomForm= NomForm;
		select max(Note) into maxn from note where n.NomForm= NomForm;
		select min(Note) into minn from note where n.NomForm= NomForm;

		INSERT INTO stat_resultat VALUES (n.NomForm,moyFormat(n.NomForm),nbrecu,n.NbrEtud,maxn,minn);
	END LOOP;
END;

$$ language plpgsql;

select statForm();
select * from stat_resultat;


--////----/////---//////----/////6


CREATE FUNCTION info_etudiant(NE integer) RETURNS setof VARCHAR as $$
DECLARE
	inet CURSOR FOR SELECT n.NomForm,n.NomMat  FROM note n WHERE n.NumEtud=NE;
BEGIN
	FOR i IN inet LOOP
		return next i.NomMat || ' -> ' ||i.NomForm;
	END LOOP;
	return;

END;
$$ language plpgsql;

select info_etudiant(3);


--////----/////---//////----/////7


CREATE FUNCTION collegues(Nens integer) RETURNS setof VARCHAR as $$
DECLARE
	inet CURSOR FOR SELECT e.NomEns,e.PrenomEns,e.NumEns FROM enseignant e NATURAL JOIN matiere m WHERE (SELECT m2.NomForm FROM matiere m2 WHERE m2.NumEns=Nens)=m.NomForm;
BEGIN
	FOR i IN inet LOOP
		IF i.NumEns != Nens THEN return next i.NomEns || ' ' ||i.PrenomEns;
		END IF;
	END LOOP;
	return;
END;
$$ language plpgsql;

select collegues(2);


--////----/////---//////----/////8

CREATE FUNCTION Enseig_Etudiant(NE integer) RETURNS setof VARCHAR as $$
DECLARE
	inet CURSOR FOR SELECT e.NomEns,e.PrenomEns,e.NumEns FROM enseignant e NATURAL JOIN matiere m NATURAL JOIN note n WHERE e.NumEns=m.NumEns and m.NomMat=n.NomMat and NE=NumEtud;
BEGIN
	FOR i IN inet LOOP
		return next i.NomEns || ' ' ||i.PrenomEns;
	END LOOP;
	return;
END;
$$ language plpgsql;

select Enseig_Etudiant(1);


--////----/////---//////----/////9
CREATE FUNCTION suppr() RETURNS trigger as $$
BEGIN
	DELETE FROM note WHERE NumEtud=OLD.NumEt;
	return OLD;
END;
$$ language plpgsql;


CREATE TRIGGER desinscription
	BEFORE DELETE
	ON etudiant FOR EACH ROW
	EXECUTE PROCEDURE suppr();

--////----/////---//////----/////10
CREATE FUNCTION statUpdate() RETURNS trigger as $$
BEGIN
	delete from stat_resultat;
	PERFORM statForm();
	return OLD;
END;
$$ language plpgsql;


CREATE TRIGGER maj
	AFTER INSERT OR UPDATE OR DELETE
	on note FOR EACH ROW
	EXECUTE PROCEDURE statUpdate();

SELECT * FROM note;
SELECT * FROM stat_resultat;
INSERT INTO note VALUES (2,'L3 Informatique','Prog Fonctionnelle',3);
--DELETE FROM note WHERE NumEtud=1 and Note=12;
SELECT * FROM stat_resultat;
SELECT * FROM note;


















