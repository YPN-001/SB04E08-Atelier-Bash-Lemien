#!/bin/bash

# --- CONFIGURATION (Chemins) ---
BASE_PATH="/home/loken/Github/AIS/BLOC_B_TechnicienInfrastructure/SB04E08-Atelier-Bash-LeMien/scripts"
LOG_FILE="${BASE_PATH}/logs/sysadmin_tools.log"
VERSION="1.0"
AUTHOR="Loken"

# Couleurs (tput)
TITRE=$(tput setaf 6; tput bold) # Cyan gras
VERT=$(tput setaf 2)
ROUGE=$(tput setaf 1)
NC=$(tput sgr0)

# Liste des scripts attendus (à adapter si les noms changent)
SCRIPT_BACKUP="${BASE_PATH}/backup.sh"
SCRIPT_MONITOR="${BASE_PATH}/monitor.sh"
SCRIPT_USERS="${BASE_PATH}/create-users.sh"

# --- FONCTIONS ---

# Logger l'utilisation de l'outil
log_usage() {
    local action="$1"
    local user=$(whoami)
    local date_now=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$date_now - USER: $user - ACTION: $action" >> "$LOG_FILE"
}

# Pause pour laisser le temps de lire avant de revenir au menu
pause() {
    echo -e "\nAppuyez sur [Entrée] pour revenir au menu..."
    read
}

# En-tête avec Version et Auteur
show_header() {
    clear
    echo "=========================================="
    echo "${TITRE}   OUTILS D'ADMINISTRATION SYSADMIN   ${NC}"
    echo "=========================================="
    echo "Version : $VERSION | Auteur : $AUTHOR"
    echo "=========================================="
}

# Vérifier que les scripts existent au démarrage
check_scripts() {
    for script in "$SCRIPT_BACKUP" "$SCRIPT_MONITOR" "$SCRIPT_USERS"; do
        if [ ! -f "$script" ]; then
            echo "${ROUGE}Attention : Le script $script est introuvable !${NC}"
            echo "Certaines options ne fonctionneront pas."
            sleep 2
        fi
    done
}

# DÉBUT DU SCRIPT

check_scripts

# Boucle infinie pour le menu
while true; do
    show_header
    echo "1. Sauvegarde de répertoire"
    echo "2. Monitoring système"
    echo "3. Créer des utilisateurs"
    echo "4. Nettoyage système (apt clean)"
    echo "5. Vérifier les services"
    echo "6. Quitter"
    echo "=========================================="
    echo -n "Votre choix : " # echo -n = No newline
    read choix

    case $choix in
        1)
            # Gestion des arguments (Demander le dossier)
            # echo -e = Enable interpretation
            echo -e "\n[Mode Sauvegarde]"
            read -p "Quel répertoire voulez-vous sauvegarder ? (ex: /home/user/docs) : " dossier
            if [ -d "$dossier" ]; then
                log_usage "Lancement Sauvegarde sur $dossier"
                # On lance le script externe
                bash "$SCRIPT_BACKUP" "$dossier"
            else
                echo "${ROUGE}Erreur : Dossier invalide.${NC}"
            fi
            pause
            ;;
        2)
            echo -e "\n[Mode Monitoring]"
            log_usage "Lancement Monitoring"
            bash "$SCRIPT_MONITOR"
            pause
            ;;
        3)
            # Gestion des arguments (Demander le CSV)
            echo -e "\n[Mode Création Utilisateurs]"
            read -p "Chemin du fichier CSV : " csv_file
            if [ -f "$csv_file" ]; then
                log_usage "Lancement Création Users avec $csv_file"
                # On utilise sudo car create-users a besoin des droits root
                sudo bash "$SCRIPT_USERS" "$csv_file"
            else
                echo "${ROUGE}Erreur : Fichier CSV introuvable.${NC}"
            fi
            pause
            ;;
        4)
            # Implémentation simple pour l'exemple
            echo -e "\n[Nettoyage Système]"
            log_usage "Nettoyage apt"
            sudo apt-get clean && echo "${VERT}Cache apt nettoyé.${NC}"
            pause
            ;;
        5)
            # Implémentation simple pour l'exemple
            echo -e "\n[Vérification Services]"
            read -p "Quel service vérifier ? (ex: ssh, cron) : " service
            log_usage "Check service $service"
            systemctl status "$service" --no-pager
            pause
            ;;
        6)
            echo "Au revoir !"
            log_usage "Quitter"
            exit 0
            ;;
        *)
            echo "${ROUGE}Choix invalide.${NC}"
            sleep 1
            ;;
    esac
done