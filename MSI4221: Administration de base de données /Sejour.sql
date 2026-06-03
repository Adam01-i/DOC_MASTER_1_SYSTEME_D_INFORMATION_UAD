create table station(nom varchar(20) primary key,capacite integer,lieu varchar(20), region varchar(20),tarif varchar(20));
create table client(id integer primary key, nom varchar(20),prenom varchar(20),ville varchar(20),region varchar(20), solde integer);
create table activite(nomstation varchar(20), libelle varchar(20),prix integer, primary key(nomstation,libelle), foreign key(nomstation) references station(nom));
create table sejour(idclient integer, station varchar(20), debut date, nbplaces integer,primary key(idclient,station,debut),foreign key(station) references station(nom),
foreign key(idclient) references client(id));
insert into station values('SalyPortugal',1350,'Saly','Thies',1600000);
insert into station values('Capskring',200,'Oussouye','Ziguinchor',800000);
insert into station values('Pullman',150,'DakarPlateau','Thies',2000000);
insert into station values('Phoenix',400,'Hydrobase','Saint Louis',700000);
insert into client values(10,'GUEYE','Moussa','Fegherbe','Saint Louis',1500000);
insert into client values(20,'NDIAYE','Oumar','Gandiol','Saint Louis',1200000);
insert into client values(30,'YAW','Nana','Labone','Accra',750000);
insert into sejour values(10,'Phoenix',to_date('2023-07-01','yyyy-mm-dd'),2);
insert into sejour values(30,'Pullman',to_date('2021-08-14','yyyy-mm-dd'),5);
insert into sejour values(20,'Pullman',to_date('2023-08-03','yyyy-mm-dd'),4);
insert into sejour values(30,'Phoenix',to_date('2023-08-15','yyyy-mm-dd'),3);
insert into sejour values(30,'SalyPortugal',to_date('2023-08-03','yyyy-mm-dd'),3);
insert into sejour values(20,'SalyPortugal',to_date('2023-08-03','yyyy-mm-dd'),6);
insert into sejour values(30,'Capskring',to_date('2024-05-24','yyyy-mm-dd'),5);
insert into sejour values(10,'Capskring',to_date('2023-09-05','yyyy-mm-dd'),3); 
insert into activite values('SalyPortugal','parc',15000);
insert into activite values('SalyPortugal','peche',12000);
insert into activite values('Capskring','peche',15000);
insert into activite values('Phoenix','excursion',20000);
insert into activite values('Phoenix','piscine',5000);
insert into activite values('Pullman','kayac',10000);





