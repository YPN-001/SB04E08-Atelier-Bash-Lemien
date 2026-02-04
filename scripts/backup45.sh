#!/bin/bash

# Configuration des chemins explicites
BASE_PATH="/home/loken/Github/AIS/BLOC_B_TechnicienInfrastructure/SB04E08-Atelier-Bash-LeMien/scripts"
LOG_DIR="${BASE_PATH}/logs"
BACKUP_DIR="${BASE_PATH}/backup"
LOG_FILE="${LOG_DIR}/backup.log"

# Création des répertoires si nécessaire (mais c'était déjà fait :D )
mkdir -p "${LOG_DIR}" "${BACKUP_DIR}"

# À l'utilisation du script, une entrée dans le log
log_message() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "${LOG_FILE}"
}

# 1. Validation du répertoire source (puis arrêt du script s'il n'a pas de destination)
if [ -z "$1" ]; then
    echo "Usage: $0 <répertoire_à_sauvegarder>"
    log_message "ERREUR : Argument manquant."
    exit 1 [cite: 199]
fi


SOURCE_DIR="$1"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"

# 2. Vérification de l'existence du dossier source
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Erreur : Le dossier $SOURCE_DIR n'existe pas."
    log_message "ERREUR : Source $SOURCE_DIR introuvable."
    exit 1
fi

# 3. Vérification de l'espace disque (minimum 100 Mo requis)
FREE_SPACE=$(df -k "${BACKUP_DIR}" | awk 'NR==2 {print $4}')
if [ "$FREE_SPACE" -lt 102400 ]; then
    echo "Erreur : Espace disque insuffisant sur la destination."
    log_message "ERREUR : Espace disque insuffisant."
    exit 1
fi

# 4. Création de l'archive tar.gz
if tar -czf "${BACKUP_DIR}/${ARCHIVE_NAME}" "$SOURCE_DIR" 2>/dev/null; then
    SIZE=$(du -sh "${BACKUP_DIR}/${ARCHIVE_NAME}" | cut -f1)
    echo "Succès : Archive créée (${SIZE})."
    log_message "SUCCÈS : Archive ${ARCHIVE_NAME} créée (Taille : ${SIZE})."
else
    echo "Erreur : Échec de la compression."
    log_message "ERREUR : Échec lors du tar -czf."
    exit 1
fi

# 5. Rotation : ne garder que les 7 dernières sauvegardes
COUNT=$(ls -1 "${BACKUP_DIR}"/backup_*.tar.gz 2>/dev/null | wc -l)
if [ "$COUNT" -gt 7 ]; then
    REMOVE_COUNT=$((COUNT - 7))
    # Suppression des fichiers les plus anciens
    ls -t "${BACKUP_DIR}"/backup_*.tar.gz | tail -n "$REMOVE_COUNT" | xargs rm -f
    echo "${REMOVE_COUNT} ancienne(s) sauvegarde(s) supprimée(s)." [cite: 36]
    log_message "ROTATION : ${REMOVE_COUNT} archives supprimées."
fi