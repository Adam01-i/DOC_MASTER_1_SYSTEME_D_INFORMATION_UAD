create table station(nom varchar(20) primary key,capacite integer,lieu varchar(20), region varchar(20),tarif varchar(20));
create table client(id integer primary key, nom varchar(20),prenom varchar(20),ville varchar(20),region varchar(20), solde integer);
create table activite(nomstation varchar(20), libelle varchar(20),prix integer, primary key(nomstation,libelle), foreign key(nomstation) references station(nom));
create table sejour(idclient integer, station varchar(20), debut date, nbplaces integer,primary key(idclient,station,debut),foreign key(station) references station(nom),
foreign key(idclient) references client(id));

insert into station values('Venusa',350,'Guadeloupe','Antilles',1200);
insert into station values('Farniente',200,'Seychelles','Ocean Idien',800000);
insert into station values('Santalba',150,'Martinique','Antilles',2000);
insert into station values('Passac',400,'Alpes','Europe',1000);
insert into client values(10,'Fogg','Phileas','Londre','Europe',12465);
insert into client values(20,'Pascal','Blaise','Paris','Europe',6763);
insert into client values(30,'Kerouac','Jack','New York','Amerique',9812);
insert into sejour values(10,'Passac',to_date('2025-07-01','yyyy-mm-dd'),2);
insert into sejour values(30,'Santalba',to_date('2021-08-14','yyyy-mm-dd'),5);
insert into sejour values(20,'Santalba',to_date('2025-08-03','yyyy-mm-dd'),4);
insert into sejour values(30,'Passac',to_date('2025-08-15','yyyy-mm-dd'),3);
insert into sejour values(30,'Venusa',to_date('2025-08-03','yyyy-mm-dd'),3);
insert into sejour values(20,'Venusa',to_date('2025-08-03','yyyy-mm-dd'),6);
insert into sejour values(30,'Farniente',to_date('2022-05-24','yyyy-mm-dd'),5);
insert into sejour values(10,'Farniente',to_date('2025-09-05','yyyy-mm-dd'),3); 
insert into activite values('Venusa','Voile',150);
insert into activite values('Venusa','Plongee',120);
insert into activite values('Farniente','Plongee',130);
insert into activite values('Passac','Ski',200);
insert into activite values('Passac','Piscine',20);
insert into activite values('Santalba','Kayac',50);


insert into station values('DIOURBEL',700,'BAMBEY','UADB',20000);
