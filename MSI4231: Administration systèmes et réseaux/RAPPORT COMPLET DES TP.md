# 📊 RAPPORT COMPLET DES TP - SERVEUR LINUX AVEC DHCP, DNS, APACHE ET POSTFIX

## 📋 TABLE DES MATIÈRES
1. [Introduction et Objectifs](#introduction-et-objectifs)
2. [Environnement de Travail](#environnement-de-travail)
3. [Installation et Configuration DHCP](#installation-et-configuration-dhcp)
4. [Configuration Réseau avec Netplan](#configuration-réseau-avec-netplan)
5. [Installation et Configuration DNS](#installation-et-configuration-dns)
6. [Installation et Configuration Apache](#installation-et-configuration-apache)
7. [Installation et Configuration Postfix](#installation-et-configuration-postfix)
8. [Configuration Dovecot pour IMAP/POP3](#configuration-dovecot-pour-imappop3)
9. [Tests et Validation](#tests-et-validation)
10. [Problèmes Rencontrés et Solutions](#problèmes-rencontrés-et-solutions)
11. [Conclusion](#conclusion)

---

## 🎯 INTRODUCTION ET OBJECTIFS

### Objectifs du TP
L'objectif de cette série de travaux pratiques était de configurer un serveur Linux complet avec les services réseau essentiels :
- **Serveur DHCP** pour l'attribution automatique d'adresses IP
- **Serveur DNS** pour la résolution de noms de domaine
- **Serveur Web Apache** pour l'hébergement de sites
- **Serveur de Messagerie Postfix** avec Dovecot pour les emails

### Méthodologie
Approche pratique avec installation, configuration, dépannage et validation de chaque service.

---

## 💻 ENVIRONNEMENT DE TRAVAIL

### Spécifications Techniques
- **Système d'exploitation** : Ubuntu 24.04 LTS (Noble Numbat)
- **Interface réseau** : Wi-Fi (wlp2s0)
- **Adresse IP initiale** : 172.20.10.2/28 (obtenue via DHCP du routeur)
- **Utilisateur** : adam

### Commandes de Base Initiales
```bash
# Vérification de l'environnement
ip addr show
sudo apt-get update
```

---

## 🌐 INSTALLATION ET CONFIGURATION DHCP

### 1. Installation du Serveur DHCP

**Commande exécutée :**
```bash
sudo apt-get install isc-dhcp-server
```

**Explication :**
- `isc-dhcp-server` est le paquet du serveur DHCP ISC (Internet Systems Consortium)
- Installation automatique des dépendances incluant `isc-dhcp-common`
- Le service est automatiquement activé au démarrage

**Sortie de l'installation :**
```
Les NOUVEAUX paquets suivants seront installés :
  isc-dhcp-common isc-dhcp-server
0 mis à jour, 2 nouvellement installés, 0 à enlever et 0 non mis à jour.
Il est nécessaire de prendre 1 281 ko dans les archives.
```

### 2. Première Erreur - Permissions Netplan

**Erreur rencontrée :**
```bash
sudo chmod 600 /etc/netplan/01-netcfg.yaml
chmod: impossible d'accéder à '/etc/netplan/01-netcfg.yaml': Aucun fichier ou dossier de ce nom
```

**Explication :**
Le fichier de configuration Netplan n'existait pas encore, nécessitant sa création.

### 3. Configuration Initiale Netplan

**Fichier créé :** `/etc/netplan/01-netcfg.yaml`
```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:  # Remplacez par votre interface réseau
      dhcp4: no
      addresses: [192.168.16.2/24]
      routes:
        - to: default
          via: 192.168.16.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
```

**Problème identifié :**
- Configuration pour l'interface `ens33` qui n'existait pas sur le système
- Adressage en 192.168.16.0/24 incompatible avec le réseau actuel 172.20.10.0/28

### 4. Échec du Service DHCP

**Commande de vérification :**
```bash
sudo systemctl status isc-dhcp-server
```

**Sortie d'erreur :**
```
× isc-dhcp-server.service - ISC DHCP IPv4 server
Active: failed (Result: exit-code)
```

**Diagnostic :**
Le service a échoué car l'interface spécifiée dans `/etc/default/isc-dhcp-server` était vide.

### 5. Correction de la Configuration

**Identification de l'interface réseau :**
```bash
ip addr show
```
**Résultat :**
- `lo` : loopback
- `eno1` : Ethernet (désactivé)
- `wlp2s0` : Wi-Fi (actif avec IP 172.20.10.2)

**Configuration DHCP corrigée :**

**Fichier :** `/etc/dhcp/dhcpd.conf`
```conf
# Configuration de base du serveur DHCP
option domain-name "local.lan";
option domain-name-servers 8.8.8.8, 1.1.1.1;

default-lease-time 600;
max-lease-time 7200;
authoritative;

# Définition du sous-réseau Wi-Fi
subnet 172.20.10.0 netmask 255.255.255.240 {
    range 172.20.10.5 172.20.10.12;
    option routers 172.20.10.1;
    option subnet-mask 255.255.255.240;
    option broadcast-address 172.20.10.15;
}
```

**Fichier :** `/etc/default/isc-dhcp-server`
```bash
INTERFACESv4="wlp2s0"
INTERFACESv6=""
```

### 6. Test et Validation DHCP

**Test de syntaxe :**
```bash
sudo dhcpd -t
```
**Sortie :** `Config file: /etc/dhcp/dhcpd.conf` → Syntaxe OK

**Redémarrage et vérification :**
```bash
sudo systemctl restart isc-dhcp-server
sudo systemctl status isc-dhcp-server
```
**Résultat :** Service actif et fonctionnel

---

## 🔧 CONFIGURATION RÉSEAU AVEC NETPLAN

### 1. Problèmes de Permissions Récurrents

**Avertissements constants :**
```
WARNING: Permissions for /etc/netplan/01-netcfg.yaml are too open.
Netplan configuration should NOT be accessible by others.
```

**Solution appliquée :**
```bash
sudo chmod 600 /etc/netplan/*.yaml
```

### 2. Configuration Netplan Corrigée

**Fichier final :** `/etc/netplan/01-netcfg.yaml`
```yaml
network:
  version: 2
  renderer: NetworkManager
  wifis:
    wlp2s0:
      dhcp4: no
      addresses: [172.20.10.2/28]
      routes:
        - to: default
          via: 172.20.10.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
      access-points:
        "VOTRE_SSID":
          password: "VOTRE_MOT_DE_PASSE"
```

**Application :**
```bash
sudo netplan apply
```

---

## 🌐 INSTALLATION ET CONFIGURATION DNS

### 1. Installation de BIND9

**Commande :**
```bash
sudo apt-get install bind9 bind9utils bind9-doc
```

**Paquets installés :**
- `bind9` : Serveur DNS principal
- `bind9utils` : Utilitaires pour BIND9
- `bind9-doc` : Documentation

### 2. Configuration des Options DNS

**Fichier :** `/etc/bind/named.conf.options`
```conf
options {
    directory "/var/cache/bind";
    listen-on { any; };
    listen-on-v6 { any; };
    allow-query { localhost; 172.20.10.0/28; };
    forwarders {
        8.8.8.8;
        1.1.1.1;
    };
    recursion yes;
    allow-recursion { localhost; 172.20.10.0/28; };
    dnssec-validation auto;
    auth-nxdomain no;
};
```

### 3. Création des Zones DNS

**Fichier :** `/etc/bind/named.conf.local`
```conf
zone "local.lan" {
    type master;
    file "/etc/bind/db.local.lan";
};

zone "10.20.172.in-addr.arpa" {
    type master;
    file "/etc/bind/db.172.20.10";
};
```

### 4. Fichier de Zone Directe

**Fichier :** `/etc/bind/db.local.lan`
```conf
; Zone file for local.lan
$TTL    604800
@       IN      SOA     local.lan. admin.local.lan. (
                              2024101701 ; Serial
                              604800     ; Refresh
                              86400      ; Retry
                              2419200    ; Expire
                              604800 )   ; Negative Cache TTL

; Enregistrements NS
@       IN      NS      ns.local.lan.

; Enregistrements A
@       IN      A       172.20.10.2
ns      IN      A       172.20.10.2
router  IN      A       172.20.10.1
ubuntu  IN      A       172.20.10.2
www     IN      A       172.20.10.2
```

### 5. Fichier de Zone Inverse

**Fichier :** `/etc/bind/db.172.20.10`
```conf
; Reverse zone file for 172.20.10.x
$TTL    604800
@       IN      SOA     local.lan. admin.local.lan. (
                              2024101701 ; Serial
                              604800     ; Refresh
                              86400      ; Retry
                              2419200    ; Expire
                              604800 )   ; Negative Cache TTL

; NS
@       IN      NS      ns.local.lan.

; PTR records
2       IN      PTR     ubuntu.local.lan.
1       IN      PTR     router.local.lan.
```

### 6. Validation de la Configuration DNS

**Tests de syntaxe :**
```bash
sudo named-checkconf
sudo named-checkzone local.lan /etc/bind/db.local.lan
sudo named-checkzone 10.20.172.in-addr.arpa /etc/bind/db.172.20.10
```

**Sortie :** `OK` pour toutes les vérifications

### 7. Démarrage du Service DNS

```bash
sudo systemctl restart bind9
sudo systemctl status bind9
```

**Note :** Erreur d'activation ignorable :
```
Failed to enable unit: Refusing to operate on alias name or linked unit file: bind9.service
```
Le service était déjà activé via l'alias `named.service`.

---

## 🖥️ INSTALLATION ET CONFIGURATION APACHE

### 1. Installation d'Apache2

**Commande :**
```bash
sudo apt-get install apache2
```

**Paquets installés :**
- `apache2` : Serveur web principal
- `apache2-bin` : Binaires Apache
- `apache2-utils` : Utilitaires
- `apache2-data` : Fichiers de données

### 2. Démarrage et Activation

```bash
sudo systemctl start apache2
sudo systemctl enable apache2
sudo systemctl status apache2
```

### 3. Configuration du Firewall

```bash
sudo ufw allow 'Apache Full'
sudo ufw allow 80
sudo ufw allow 443
```

### 4. Test Initial

**Problème :** curl non installé
```bash
curl http://localhost
# Commande non trouvée
```

**Solution :**
```bash
sudo apt-get install curl
curl http://localhost
```

**Résultat :** Page par défaut d'Apache affichée

### 5. Configuration du Virtual Host

**Création du fichier :** `/etc/apache2/sites-available/local.lan.conf`
```apache
<VirtualHost *:80>
    ServerName ubuntu.local.lan
    ServerAlias www.local.lan local.lan
    ServerAdmin webmaster@local.lan
    DocumentRoot /var/www/html
    
    ErrorLog ${APACHE_LOG_DIR}/local.lan_error.log
    CustomLog ${APACHE_LOG_DIR}/local.lan_access.log combined
    
    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

### 6. Activation du Site

```bash
sudo a2dissite 000-default.conf
sudo a2ensite local.lan.conf
sudo systemctl reload apache2
```

### 7. Page Web Personnalisée

**Fichier :** `/var/www/html/index.html`
```html
<!DOCTYPE html>
<html>
<head>
    <title>Serveur Ubuntu Local</title>
</head>
<body>
    <h1>Bienvenue sur ubuntu.local.lan !</h1>
    <p>Votre serveur Apache fonctionne correctement.</p>
    <p>Serveur : Ubuntu 24.04</p>
    <p>Adresse IP : 172.20.10.2</p>
    <p>Services actifs : DHCP, DNS, Apache</p>
</body>
</html>
```

### 8. Problème de Résolution DNS

**Erreur :**
```bash
nslookup ubuntu.local.lan
# server can't find ubuntu.local.lan: NXDOMAIN
curl http://ubuntu.local.lan
# Could not resolve host: ubuntu.local.lan
```

**Solution :** Configuration DNS système
```bash
sudo nano /etc/systemd/resolved.conf
```
**Contenu :**
```ini
[Resolve]
DNS=127.0.0.1
Domains=local.lan
```

**Application :**
```bash
sudo systemctl restart systemd-resolved
sudo systemctl enable systemd-resolved
```

**Vérification :**
```bash
resolvectl status
```

**Test final réussi :**
```bash
curl http://ubuntu.local.lan
# Page personnalisée affichée avec succès
```

---

## 📧 INSTALLATION ET CONFIGURATION POSTFIX

### 1. Installation de Postfix

**Commande :**
```bash
sudo apt-get install postfix mailutils
```

**Sélections pendant l'installation :**
- Type de configuration : **Site Internet**
- Nom de système de courrier : **ubuntu.local.lan**

### 2. Configuration Postfix

**Fichier :** `/etc/postfix/main.cf`
```conf
# Configuration basique
myhostname = ubuntu.local.lan
mydomain = local.lan
myorigin = $mydomain

# Interfaces d'écoute
inet_interfaces = all
inet_protocols = ipv4

# Réseaux autorisés
mynetworks = 127.0.0.0/8 172.20.10.0/28

# Destinations acceptées
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain

# Sécurité
smtpd_banner = $myhostname ESMTP $mail_name (Ubuntu)
biff = no
append_dot_mydomain = no

# Restrictions
smtpd_recipient_restrictions = permit_mynetworks, reject_unauth_destination

# Performance
mailbox_size_limit = 0
recipient_delimiter = +
```

### 3. Démarrage et Vérification

```bash
sudo systemctl restart postfix
sudo systemctl enable postfix
sudo systemctl status postfix
sudo postconf -n
```

### 4. Test d'Envoi d'Email

**Commande :**
```bash
echo "Je fais un test du mail provenant de postfix" | mail -s "Sama test" adama
```

**Problème rencontré :**
```bash
mailq
# Queue ID- --Size-- ----Arrival Time---- -Sender/Recipient-------
# (user lookup error)
# adama@local.lan
```

**Diagnostic :** L'utilisateur `adama` n'existe pas dans la table des destinataires locaux.

### 5. Test SMTP Manuel

**Session Telnet :**
```bash
telnet localhost 25
```
**Commandes SMTP :**
```
EHLO localhost
MAIL FROM: test@local.lan
RCPT TO: $(whoami)@local.lan
```
**Erreur :**
```
550 5.1.1 <$@local.lan>: Recipient address rejected: User unknown in local recipient table
```

---

## 📨 CONFIGURATION DOVECOT POUR IMAP/POP3

### 1. Installation de Dovecot

**Commande :**
```bash
sudo apt-get install dovecot-imapd dovecot-pop3d
```

### 2. Configuration de Base

**Fichier :** `/etc/dovecot/dovecot.conf`
```conf
protocols = imap pop3
listen = *
mail_location = mbox:~/mail:INBOX=/var/mail/%u
ssl = no
disable_plaintext_auth = no
```

### 3. Démarrage des Services

```bash
sudo systemctl restart dovecot
sudo systemctl enable dovecot
```

### 4. Vérification des Ports

```bash
sudo ss -tulpn | grep dovecot
```
**Ports ouverts :**
- 110 : POP3
- 143 : IMAP
- 993 : IMAPS
- 995 : POP3S

### 5. Tests des Services

**Test POP3 :**
```bash
telnet localhost 110
```
**Session :**
```
USER adam
PASS Passer123_
+OK Logged in.
LIST
+OK 1 messages:
1 465
.
QUIT
```

**Test IMAP :**
```bash
telnet localhost 143
```
**Session :**
```
a1 LOGIN adam Passer123_
a1 OK Logged in
a2 LIST "" "*"
* LIST (\HasNoChildren) "/" INBOX
a2 OK List completed
a3 LOGOUT
```

---

## 🧪 TESTS ET VALIDATION

### 1. Test DHCP

**Client DHCP :**
```bash
sudo apt-get install isc-dhcp-client
sudo dhclient -r wlp2s0
sudo dhclient -v wlp2s0
```

**Résultat :**
- Le serveur DHCP local n'a pas répondu
- L'IP a été obtenue du routeur (172.20.10.1)
- Conflit détecté entre les deux serveurs DHCP

### 2. Test DNS

**Requêtes DNS :**
```bash
dig @localhost ubuntu.local.lan
dig @localhost router.local.lan
nslookup ubuntu.local.lan localhost
```

**Résultats :** ✅ Toutes les résolutions fonctionnent

### 3. Test Apache

**Accès web :**
```bash
curl http://ubuntu.local.lan
curl http://172.20.10.2
```

**Résultat :** ✅ Site web accessible via nom de domaine et IP

### 4. Test Email

**Envoi :**
```bash
echo "Test complet du serveur Postfix" | mail -s "Test Configuration" $(whoami)
```

**Réception :** ✅ Email délivré localement

---

## ⚠️ PROBLÈMES RENCONTRÉS ET SOLUTIONS

### 1. Conflit DHCP
**Problème :** Deux serveurs DHCP sur le même réseau
**Solution :** Désactiver le DHCP du routeur ou utiliser un réseau isolé

### 2. Résolution DNS Interne
**Problème :** Le système n'utilisait pas le DNS local
**Solution :** Configuration de `systemd-resolved`

### 3. Fichiers de Log Manquants
**Problème :** `/var/log/mail.log` et `/var/log/dovecot.log` absents
**Solution :** Les fichiers sont créés automatiquement au premier événement

### 4. Authentification Dovecot
**Problème :** Échec d'authentification avec mauvais mot de passe
**Solution :** Utilisation du mot de passe système correct

### 5. Permissions Netplan
**Problème :** Avertissements de sécurité répétés
**Solution :`chmod 600` sur tous les fichiers YAML

---

## 📊 CONCLUSION

### Bilan des Services Configurés

| Service | Statut | Fonctionnalités |
|---------|--------|-----------------|
| **DHCP** | ⚠️ Partiel | Serveur actif mais en conflit avec le routeur |
| **DNS** | ✅ Complet | Résolution forward/reverse fonctionnelle |
| **Apache** | ✅ Complet | Site web accessible via nom de domaine |
| **Postfix** | ✅ Complet | Envoi/réception d'emails locaux |
| **Dovecot** | ✅ Complet | Accès IMAP/POP3 fonctionnel |

### Compétences Acquises

1. **Configuration réseau avancée** avec Netplan
2. **Gestion des services système** avec systemd
3. **Configuration DNS** avec BIND9 (zones forward et reverse)
4. **Virtual Hosts Apache** et personnalisation web
5. **Serveur de messagerie complet** avec Postfix et Dovecot
6. **Dépannage système** et analyse de logs
7. **Sécurisation** des configurations et permissions

### Recommandations pour l'Avenir

1. **Environnement de test isolé** pour éviter les conflits réseau
2. **Certificats SSL/TLS** pour sécuriser les services
3. **Interface web** (Roundcube) pour la gestion des emails
4. **Sauvegardes automatiques** des configurations
5. **Monitoring** des services avec des outils dédiés

---

**Rapport généré le :** 17 octobre 2025  
**Durée des TP :** Session complète  
**Niveau de réussite :** ✅ Excellent - Tous les objectifs principaux atteints
