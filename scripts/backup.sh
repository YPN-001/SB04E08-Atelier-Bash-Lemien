#!/bin/bash

# Configuration des chemins absolus explicites
BASE_PATH="/home/loken/Github/AIS/BLOC_B_TechnicienInfrastructure/SB04E08-Atelier-Bash-LeMien/scripts"
LOG_DIR="${BASE_PATH}/logs"
BACKUP_DIR="${BASE_PATH}/backup"
LOG_FILE="${LOG_DIR}/backup.log"

# Création des répertoires si nécessaire (mais c'était déjà fait :D )
mkdir -p "${LOG_DIR}" "${BACKUP_DIR}"

# À l'utilisation du script, une entrée dans le log
if [ -z "$1" ]; then
    echo "Usage: $0 <répertoire_à_sauvegarder>"
    # On écrit directement dans le log sans passer par une fonction
    echo "$(date +'%Y-%m-%d %H:%M:%S') - ERREUR : Argument manquant." >> "${LOG_FILE}"
    exit 1
fi

SOURCE_DIR="$1"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"

# Vérification de l'existence du dossier
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Erreur : Le dossier $SOURCE_DIR n'existe pas." | tee -a "${LOG_FILE}"
    exit 1
fi

# Utilisation de awk pour l'espace libre (car il gère mieux les chiffres à virgule)
FREE_SPACE=$(df -k "${BACKUP_DIR}" | awk 'NR==2 {print $4}')
if [ "$FREE_SPACE" -lt 102400 ]; then
    echo "Erreur : Espace disque insuffisant." | tee -a "${LOG_FILE}"
    exit 1
fi

# Création de l'archive tar.gz
# On tente la compression
if tar -czf "${BACKUP_DIR}/${ARCHIVE_NAME}" "$SOURCE_DIR" 2>/dev/null; then
    SIZE=$(du -sh "${BACKUP_DIR}/${ARCHIVE_NAME}" | cut -f1)
    # Affichage et log en une seule ligne avec tee
    echo "$(date +'%Y-%m-%d %H:%M:%S') - SUCCÈS : Archive ${ARCHIVE_NAME} (${SIZE})" | tee -a "${LOG_FILE}"
else
    echo "$(date +'%Y-%m-%d %H:%M:%S') - ERREUR : Échec compression" | tee -a "${LOG_FILE}"
    exit 1
fi

# Rotation des 7 dernières backup
COUNT=$(ls -1 "${BACKUP_DIR}"/backup_*.tar.gz 2>/dev/null | wc -l)
if [ "$COUNT" -gt 7 ]; then
    REMOVE_COUNT=$((COUNT - 7))
    # On utilise xargs pour la suppression
    ls -t "${BACKUP_DIR}"/backup_*.tar.gz | tail -n "$REMOVE_COUNT" | xargs rm -f
    echo "ROTATION : ${REMOVE_COUNT} ancienne(s) sauvegarde(s) supprimée(s)." | tee -a "${LOG_FILE}"
fi