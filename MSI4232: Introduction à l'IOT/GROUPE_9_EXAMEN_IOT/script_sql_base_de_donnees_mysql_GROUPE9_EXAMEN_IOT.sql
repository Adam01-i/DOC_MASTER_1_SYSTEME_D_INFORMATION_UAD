-- Création de la base de données
CREATE DATABASE IF NOT EXISTS iot_supervision;
USE iot_supervision;

-- Suppression des tables si elles existent (pour éviter les conflits)
DROP TABLE IF EXISTS evenements;
DROP TABLE IF EXISTS mesures;
DROP TABLE IF EXISTS stations;

-- Table des stations
CREATE TABLE stations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nom_station VARCHAR(50) UNIQUE NOT NULL,
    emplacement VARCHAR(100) NOT NULL,
    date_installation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    statut ENUM('ACTIVE', 'INACTIVE', 'MAINTENANCE') DEFAULT 'ACTIVE',
    derniere_communication DATETIME NULL,
    INDEX idx_statut (statut)
);

-- Table des mesures
CREATE TABLE mesures (
    id INT PRIMARY KEY AUTO_INCREMENT,
    station_id INT NOT NULL,
    date_mesure DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    temperature DECIMAL(5,2) NOT NULL,
    humidite DECIMAL(5,2) NOT NULL,
    distance DECIMAL(5,2) NOT NULL,
    presence TINYINT(1) DEFAULT 0,
    etat VARCHAR(20) DEFAULT 'AUTORISE',
    FOREIGN KEY (station_id) REFERENCES stations(id) ON DELETE CASCADE,
    INDEX idx_station_date (station_id, date_mesure)
);

-- Table des événements
CREATE TABLE evenements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    station_id INT NOT NULL,
    date_evenement DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    type_evenement VARCHAR(50) NOT NULL,
    description TEXT NULL,
    FOREIGN KEY (station_id) REFERENCES stations(id) ON DELETE CASCADE,
    INDEX idx_station_evenement (station_id, date_evenement)
);

-- Insertion d'une station exemple
INSERT INTO stations (nom_station, emplacement, date_installation, statut, derniere_communication)
VALUES ('SALLE_01', 'Salle TP', '2026-07-09 15:34:16', 'ACTIVE', NULL);

-- Insertion des données de mesures (8 enregistrements)
INSERT INTO mesures (station_id, date_mesure, temperature, humidite, distance, presence, etat)
VALUES
(1, '2026-07-09 15:49:21', 30.00, 48.00, 239.00, 0, 'PREALERTE'),
(1, '2026-07-09 15:49:22', 30.00, 48.00, 239.00, 0, 'PREALERTE'),
(1, '2026-07-09 15:49:23', 30.00, 48.00, 238.00, 0, 'PREALERTE'),
(1, '2026-07-09 15:49:24', 30.00, 48.00, 238.00, 0, 'PREALERTE'),
(1, '2026-07-09 15:49:25', 30.00, 48.00, 240.00, 0, 'PREALERTE'),
(1, '2026-07-09 15:49:26', 30.00, 48.00, 239.00, 0, 'PREALERTE'),
(1, '2026-07-09 15:49:27', 30.00, 48.00, 240.00, 0, 'PREALERTE'),
(1, '2026-07-09 15:49:28', 30.00, 48.00, 239.00, 0, 'PREALERTE');

-- Création de la vue des dernières mesures
CREATE OR REPLACE VIEW vue_dernieres_mesures AS
SELECT 
    s.nom_station,
    s.emplacement,
    s.statut,
    m.temperature,
    m.humidite,
    m.distance,
    m.presence,
    m.etat,
    m.date_mesure
FROM stations s
LEFT JOIN mesures m ON s.id = m.station_id
WHERE m.date_mesure = (
    SELECT MAX(m2.date_mesure) 
    FROM mesures m2 
    WHERE m2.station_id = m.station_id
)
ORDER BY s.nom_station;

-- Création de la vue des statistiques globales
CREATE OR REPLACE VIEW vue_statistiques_globales AS
SELECT 
    (SELECT COUNT(*) FROM stations) AS total_salles,
    (SELECT COUNT(*) FROM stations WHERE statut = 'ACTIVE') AS salles_actives,
    (SELECT AVG(temperature) FROM mesures) AS temperature_moyenne,
    (SELECT COUNT(*) FROM mesures WHERE etat = 'AUTORISE') AS acces_autorises,
    (SELECT COUNT(*) FROM mesures WHERE etat LIKE '%ALERTE%') AS alertes,
    (SELECT COUNT(*) FROM evenements) AS total_evenements;

-- Vérification des données
SELECT '=== Stations ===' AS '';
SELECT * FROM stations;

SELECT '=== Mesures ===' AS '';
SELECT * FROM mesures;

SELECT '=== Événements ===' AS '';
SELECT * FROM evenements;

SELECT '=== Vue Dernières Mesures ===' AS '';
SELECT * FROM vue_dernieres_mesures;

SELECT '=== Vue Statistiques Globales ===' AS '';
SELECT * FROM vue_statistiques_globales;

-- Affichage des structures des tables
SELECT '=== Structure des tables ===' AS '';
DESCRIBE stations;
DESCRIBE mesures;
DESCRIBE evenements;
DESCRIBE vue_dernieres_mesures;
DESCRIBE vue_statistiques_globales;
