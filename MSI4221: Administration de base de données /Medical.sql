create table Medecin(matricule varchar(20) not null,
                       nom varchar(20) not null,
                       primary key (matricule)
                       );
 create table Patient(noSS varchar(20) not null,
                       nom varchar(20) not null,
                       primary key (noSS)
                       );
 create table Medicament(code varchar(20) not null,
                       libelle varchar(20) not null,
                       primary key (code)
                       );
 create table Consultation(no integer  not null,
                       matricule varchar(20) not null,
                       noSS  varchar(20) not null,
                       primary key (no),
                       foreign key (matricule) references Medecin(matricule),
                       foreign key (noSS) references Patient(noSS)
                       );
create table Prescription (codeMedicament varchar(20) not null,
                       noConsultation integer not null,
                       nbPrises integer not null,
                       primary key (codeMedicament, noConsultation),
                       foreign key (codeMedicament) references Medicament(code),
                       foreign key (noConsultation) references Consultation(no)
                       );

insert into Medecin (matricule, nom) values ('aa', 'DIALLO');
insert into Medecin (matricule, nom) values ('bb', 'FAYE');
insert into Medecin (matricule, nom) values ('cc', 'DIATTA');
insert into Medecin (matricule, nom) values ('dd', 'NDIAYE');

insert into Patient (noSS, nom) values ('198', 'Fatou');
insert into Patient (noSS, nom) values ('199', 'Cheikh');
insert into Patient (noSS, nom) values ('200', 'Maha');
insert into Patient (noSS, nom) values ('201', 'Binetou');
insert into Patient (noSS, nom) values ('202', 'Mamita');
insert into Patient (noSS, nom) values ('203', 'Maty');
insert into Patient (noSS, nom) values ('204', 'Abdoulaye');
insert into Patient (noSS, nom) values ('205', 'Modou');

insert into Medicament (code, libelle) values ('tm', 'Trucmyl');
insert into Medicament (code, libelle) values ('pm', 'Paracetamol');
insert into Medicament (code, libelle) values ('fv', 'Fervexe');
insert into Medicament (code, libelle) values ('tl', 'Tylenol');

insert into Consultation (no, matricule, noSS) values (1, 'aa', '198');
insert into Consultation (no, matricule, noSS) values (2, 'bb', '199');
insert into Consultation (no, matricule, noSS) values (3, 'bb', '203');
insert into Consultation (no, matricule, noSS) values (4, 'cc', '205');
insert into Consultation (no, matricule, noSS) values (5, 'cc', '202');
insert into Consultation (no, matricule, noSS) values (6, 'cc', '200');
insert into Consultation (no, matricule, noSS) values (7, 'dd', '204');
insert into Consultation (no, matricule, noSS) values (8, 'dd', '201');

insert into Prescription (codeMedicament, noConsultation, nbPrises) values ('tm', 1, 3);
insert into Prescription (codeMedicament, noConsultation, nbPrises) values ('fv', 4, 2);
insert into Prescription (codeMedicament, noConsultation, nbPrises) values ('fv', 6, 1);
insert into Prescription (codeMedicament, noConsultation, nbPrises) values ('tl', 3, 2);
insert into Prescription (codeMedicament, noConsultation, nbPrises) values ('tm', 2, 1);
insert into Prescription (codeMedicament, noConsultation, nbPrises) values ('pm', 8, 1);
insert into Prescription (codeMedicament, noConsultation, nbPrises) values ('tl', 7, 3);
insert into Prescription (codeMedicament, noConsultation, nbPrises) values ('fv', 5, 2);
insert into Prescription (codeMedicament, noConsultation, nbPrises) values ('pm', 2, 2);
insert into Prescription (codeMedicament, noConsultation, nbPrises) values ('tm', 5, 3);
