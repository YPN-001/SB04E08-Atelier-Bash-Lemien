# Atelier Bash - Automatisation de l'administration système

## Contexte professionnel

Vous venez d'être recruté(e) en tant qu'administrateur système Linux chez **TechSecure**, une entreprise hébergeant des applications web pour ses clients. L'infrastructure comprend une vingtaine de serveurs Linux (Debian/Ubuntu) répartis sur plusieurs environnements (développement, staging, production).

Actuellement, la plupart des tâches d'administration sont effectuées **manuellement**, ce qui prend beaucoup de temps et génère des erreurs. Votre manager vous demande de créer une **suite de scripts Bash** pour automatiser les tâches récurrentes d'administration système.

Votre mission : développer des outils d'automatisation robustes, réutilisables et bien documentés qui faciliteront le travail quotidien de l'équipe d'exploitation.

## Objectifs de l'atelier

À l'issue de cet atelier, vous serez capable de :
- Créer des scripts Bash professionnels et maintenables
- Automatiser les tâches courantes d'administration système
- Gérer les erreurs et valider les entrées utilisateur
- Produire des rapports et des logs d'exécution
- Documenter vos scripts pour faciliter leur utilisation

---

## Partie 1 : Script de sauvegarde automatisée

### Contexte
Les développeurs perdent régulièrement du travail car les sauvegardes sont faites manuellement et de manière irrégulière. Vous devez créer un script de sauvegarde fiable.

### Objectif
Créer un script `backup.sh` qui automatise la sauvegarde des répertoires critiques.

### Travail à réaliser

**1.1** - Créez un script qui :
- Prend en argument le répertoire à sauvegarder
- Crée une archive tar.gz du répertoire
- Nomme l'archive avec la date et l'heure (format: `backup_YYYYMMDD_HHMMSS.tar.gz`)
- Stocke l'archive dans un dossier `/backup` (à créer s'il n'existe pas)
- Affiche un message de confirmation avec la taille de l'archive créée

**1.2** - Améliorez le script pour :
- Vérifier que le répertoire source existe avant de commencer
- Vérifier qu'il y a suffisamment d'espace disque disponible
- Créer un fichier de log `/var/log/backup.log` avec date, heure et résultat de chaque sauvegarde
- Gérer les erreurs avec des messages explicites

**1.3** - Ajoutez une rotation des sauvegardes :
- Le script ne garde que les 7 dernières sauvegardes
- Les sauvegardes plus anciennes sont automatiquement supprimées
- Afficher un message indiquant combien de sauvegardes ont été supprimées

**1.4** - Testez votre script avec différents scénarios :
- Sauvegarde d'un dossier existant
- Tentative de sauvegarde d'un dossier inexistant
- Exécutions multiples pour vérifier la rotation

---

## Partie 2 : Moniteur de ressources système

### Contexte
L'équipe a besoin de surveiller l'état des serveurs pour détecter les problèmes avant qu'ils n'affectent les utilisateurs.

### Objectif
Créer un script `monitor.sh` qui collecte et affiche les informations système importantes.

### Travail à réaliser

**2.1** - Créez un script qui affiche :
- Le nom du serveur (hostname)
- La date et l'heure actuelles
- L'uptime du système
- L'utilisation CPU (en pourcentage)
- L'utilisation mémoire (utilisée/totale en Go et en pourcentage)
- L'utilisation de chaque partition (en pourcentage)
- Le nombre de processus en cours d'exécution

**2.2** - Ajoutez un système d'alertes colorées :
- Vert : utilisation < 70%
- Jaune : utilisation entre 70% et 85%
- Rouge : utilisation > 85%

**2.3** - Créez une option pour générer un rapport texte :
- Le rapport doit être sauvegardé dans `/var/log/monitor_YYYYMMDD.txt`
- Format lisible et structuré
- Inclure toutes les informations collectées

**2.4** - Ajoutez l'affichage des 5 processus consommant le plus de :
- CPU
- Mémoire

---

## Partie 3 : Gestionnaire d'utilisateurs en masse

### Contexte
L'entreprise recrute 15 nouveaux collaborateurs. Le service RH vous fournit un fichier CSV avec leurs informations. Vous devez automatiser la création de leurs comptes.

### Objectif
Créer un script `create-users.sh` qui crée des utilisateurs depuis un fichier CSV.

### Travail à réaliser

**3.1** - Créez un fichier CSV de test `users.csv` avec la structure suivante :
```
prenom,nom,departement,fonction
Alice,Martin,IT,Developpeur
Bob,Dubois,RH,Recruteur
Claire,Bernard,Commercial,Manager
```
Ajoutez au moins 10 utilisateurs.

**3.2** - Créez le script qui :
- Lit le fichier CSV fourni en argument
- Pour chaque ligne, crée un utilisateur avec :
  - Login : première lettre du prénom + nom (en minuscules)
  - Nom complet : Prénom Nom
  - Groupe principal selon le département
  - Répertoire personnel créé automatiquement
- Génère un mot de passe aléatoire sécurisé pour chaque utilisateur
- Affiche login et mot de passe pour chaque utilisateur créé

**3.3** - Améliorez le script pour :
- Vérifier que l'utilisateur n'existe pas déjà
- Créer les groupes de département s'ils n'existent pas
- Générer un fichier récapitulatif `users_created.txt` avec login et mot de passe
- Logger toutes les opérations dans `/var/log/user-creation.log`
- Gérer les erreurs (CSV invalide, permissions insuffisantes, etc.)

**3.4** - Ajoutez une option de suppression :
- Le script doit pouvoir supprimer les utilisateurs créés depuis le même CSV
- Demander confirmation avant chaque suppression
- Logger les suppressions

---

## Partie 4 : Nettoyeur de système automatique

### Contexte
Les serveurs accumulent des fichiers temporaires et des logs qui consomment de l'espace disque. Vous devez créer un outil de nettoyage automatique.

### Objectif
Créer un script `cleanup.sh` qui nettoie intelligemment le système.

### Travail à réaliser

**4.1** - Créez un script qui :
- Affiche l'espace disque disponible avant le nettoyage
- Supprime les fichiers dans `/tmp` plus vieux que 7 jours
- Supprime les logs compressés (`.gz`) dans `/var/log` plus vieux que 30 jours
- Vide la corbeille des utilisateurs
- Nettoie le cache APT (`apt clean`)
- Affiche l'espace disque récupéré

**4.2** - Ajoutez un mode sécurisé :
- Par défaut, le script affiche ce qui sera supprimé sans rien supprimer (mode dry-run)
- Option `--force` ou `-f` pour effectuer réellement les suppressions
- Demander confirmation avant toute suppression en mode force

**4.3** - Améliorez avec :
- Un rapport détaillé de ce qui a été nettoyé
- Des statistiques par catégorie (tmp, logs, cache, etc.)
- Un fichier de log `/var/log/cleanup.log`
- Option pour choisir l'âge des fichiers à supprimer (paramètre en jours)

---

## Partie 5 : Vérificateur de santé des services

### Contexte
Plusieurs incidents ont été causés par des services arrêtés sans que personne ne s'en rende compte. Vous devez créer un outil de surveillance.

### Objectif
Créer un script `check-services.sh` qui vérifie l'état des services critiques.

### Travail à réaliser

**5.1** - Créez un fichier de configuration `services.conf` listant les services à surveiller :
```
ssh
cron
apache2
mysql
```

**5.2** - Créez le script qui :
- Lit la liste des services depuis le fichier de configuration
- Vérifie l'état de chaque service (actif/inactif)
- Affiche un rapport coloré :
  - Vert : service actif
  - Rouge : service inactif
- Compte le nombre de services actifs et inactifs

**5.3** - Ajoutez des fonctionnalités avancées :
- Option pour tenter de redémarrer automatiquement les services inactifs
- Envoi d'une alerte (simulation avec echo) si un service critique est down
- Vérification que le service est bien enabled au démarrage
- Création d'un rapport JSON avec tous les détails

**5.4** - Créez un mode monitoring :
- Option `--watch` qui vérifie en boucle toutes les 30 secondes
- Rafraîchissement de l'affichage à chaque itération
- Possibilité d'arrêter avec Ctrl+C

---

## Partie 6 : Outil centralisé de gestion

### Objectif
Créer un menu interactif qui regroupe tous vos outils.

### Travail à réaliser

**6.1** - Créez un script `sysadmin-tools.sh` avec un menu :
```
=================================
    OUTILS D'ADMINISTRATION
=================================
1. Sauvegarde de répertoire
2. Monitoring système
3. Créer des utilisateurs
4. Nettoyage système
5. Vérifier les services
6. Quitter
=================================
Votre choix :
```

**6.2** - Implémentez chaque option du menu :
- Chaque option lance le script correspondant
- Gestion des arguments nécessaires (demander à l'utilisateur)
- Retour au menu après l'exécution de chaque script
- Gestion des erreurs (choix invalide, script manquant, etc.)

**6.3** - Améliorations finales :
- Vérifier que tous les scripts existent avant de lancer le menu
- Afficher un en-tête avec la version et l'auteur
- Logger l'utilisation de l'outil (qui a lancé quoi et quand)
- Ajouter une option "Aide" qui affiche la documentation de chaque outil

---

## Livrables attendus

À la fin de l'atelier, vous devez avoir créé :

### Scripts
- `backup.sh` - Script de sauvegarde
- `monitor.sh` - Moniteur de ressources
- `create-users.sh` - Gestionnaire d'utilisateurs
- `cleanup.sh` - Nettoyeur de système
- `check-services.sh` - Vérificateur de services
- `sysadmin-tools.sh` - Menu centralisé

### Fichiers de configuration
- `users.csv` - Exemple de fichier utilisateurs
- `services.conf` - Liste des services à surveiller

### Documentation
- `README.md` - Documentation complète de tous vos outils
- Instructions d'installation
- Exemples d'utilisation
- Liste des dépendances

---

## Bonnes pratiques à respecter

### Structure des scripts

Chaque script doit contenir :
- Un shebang `#!/bin/bash` en première ligne
- Des commentaires expliquant le but du script
- Une section d'aide accessible avec `-h` ou `--help`
- Une validation des arguments et des permissions
- Une gestion des erreurs propre
- Des messages clairs pour l'utilisateur

### Gestion des erreurs

- Vérifier les codes de retour des commandes importantes
- Afficher des messages d'erreur explicites
- Arrêter le script en cas d'erreur critique avec `exit 1`
- Logger les erreurs dans un fichier de log

### Sécurité

- Ne jamais stocker de mots de passe en clair dans les scripts
- Valider toutes les entrées utilisateur
- Utiliser des chemins absolus pour les commandes critiques
- Vérifier les permissions avant d'exécuter des actions sensibles

### Lisibilité

- Utiliser des noms de variables explicites
- Indenter correctement le code
- Commenter les parties complexes
- Utiliser des fonctions pour éviter la duplication de code

---

## Ressources utiles

### Commandes importantes

- `tar` - Créer des archives
- `df`, `du` - Espace disque
- `free` - Mémoire
- `top`, `ps` - Processus
- `systemctl` - Gestion des services
- `useradd`, `groupadd` - Gestion des utilisateurs
- `find` - Recherche de fichiers
- `awk`, `sed`, `cut` - Manipulation de texte

### Documentation

- `man bash` - Manuel Bash complet
- `help` - Aide sur les commandes intégrées
- https://fr.wikibooks.org/wiki/Programmation_Bash

---

## Conseils pour réussir

**Organisation** :
- Créez un dossier `~/scripts/` pour tous vos scripts
- Créez un dossier `~/scripts/logs/` pour les fichiers de log
- Testez chaque script au fur et à mesure

**Développement** :
- Commencez simple, puis ajoutez des fonctionnalités
- Testez après chaque ajout de fonctionnalité
- Utilisez `set -x` pour déboguer (affiche les commandes exécutées)

**Permissions** :
- N'oubliez pas `chmod +x` pour rendre vos scripts exécutables
- Certaines opérations nécessitent `sudo` (création d'utilisateurs, services, etc.)

**Tests** :
- Testez vos scripts dans un environnement de test
- Testez les cas d'erreur (fichier inexistant, permissions insuffisantes, etc.)
- Vérifiez que vos scripts fonctionnent même avec des entrées inattendues

