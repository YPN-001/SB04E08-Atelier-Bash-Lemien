#!/bin/bash

# Configuration des chemins absolus explicites
BASE_PATH="/home/loken/Github/AIS/BLOC_B_TechnicienInfrastructure/SB04E08-Atelier-Bash-LeMien/scripts"
LOG_DIR="${BASE_PATH}/logs"
DATE_FILE=$(date "+%Y%m%d_%H%M%S") # Ton format avec l'heure
REPORT_FILE="${LOG_DIR}/monitor_${DATE_FILE}.txt"

# Oui je n'utilise pas le chemin /var/log .. car c'est mon pc et je fais ce que je veux ! ^_^ 

# bc = An Arbitrary Precision Calculator Language
    # sudo pacman -S bc
    # sudo apt update && sudo apt install bc
    # sudo dnf install bc
    #apk add bc
if ! command -v bc &> /dev/null; then
    echo "Erreur : 'bc' n'est pas installé. Veuillez l'installer. '"
    exit 1
fi

# Définition de la colorémetrie des alertes (méthode TPUT)
# Parce que c'est trop long de trouver la bonne couleur en ANSI ... :D 
VERT=$(tput setaf 2)
JAUNE=$(tput setaf 3)
ROUGE=$(tput setaf 1)
GRAS=$(tput bold)
NC=$(tput sgr0) # "Normal Color" (Reset)

# Collecte des données
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
MEM_TOTAL=$(free -g | awk '/^Mem:/{print $2}')
MEM_USED=$(free -g | awk '/^Mem:/{print $3}')
MEM_PCT=$(( 100 * MEM_USED / MEM_TOTAL ))

# Génération du rapport

# Initialisation du fichier
echo "=== MONITORING TECHSECURE - $HOSTNAME ===" > "${REPORT_FILE}"
echo "=== MONITORING TECHSECURE - $HOSTNAME ==="

# Informations de base (Utilisation de tee pour la simplicité ... xD )
echo "DATE   : $(date '+%d/%m/%Y %H:%M:%S')" | tee -a "${REPORT_FILE}"
echo "UPTIME : $(uptime -p)" | tee -a "${REPORT_FILE}"
echo "-------------------------------------------" | tee -a "${REPORT_FILE}"

# Section CPU (utilisation de bc au lieux de awk - Pour ne pas complexifier les commandes)
if (( $(echo "$CPU_USAGE > 85" | bc -l) )); then
    echo "${ROUGE}${GRAS}CPU    : $CPU_USAGE% [ALERTE]${NC}"
    echo "CPU    : $CPU_USAGE% [ALERTE]" >> "${REPORT_FILE}"
elif (( $(echo "$CPU_USAGE > 70" | bc -l) )); then
    echo "${JAUNE}CPU    : $CPU_USAGE% [ATTENTION]${NC}"
    echo "CPU    : $CPU_USAGE% [ATTENTION]" >> "${REPORT_FILE}"
else
    echo "${VERT}CPU    : $CPU_USAGE% [OK]${NC}"
    echo "CPU    : $CPU_USAGE% [OK]" >> "${REPORT_FILE}"
fi

# Section Mémoire
if [ "$MEM_PCT" -ge 85 ]; then
    echo "${ROUGE}${GRAS}MEM    : $MEM_PCT% ($MEM_USED Go / $MEM_TOTAL Go)${NC}"
    echo "MEM    : $MEM_PCT% ($MEM_USED Go / $MEM_TOTAL Go)" >> "${REPORT_FILE}"
else
    echo "${VERT}MEM    : $MEM_PCT% ($MEM_USED Go / $MEM_TOTAL Go)${NC}"
    echo "MEM    : $MEM_PCT% ($MEM_USED Go / $MEM_TOTAL Go)" >> "${REPORT_FILE}"
fi

# Partition & Processus (head -n 6 car la ligne de titre compte pour 1)
echo -e "\nUTILISATION DISQUES :" | tee -a "${REPORT_FILE}"
df -h --output=target,pcent | grep '^/' | tee -a "${REPORT_FILE}"

echo -e "\nTOP 5 PROCESSUS (CPU) :" | tee -a "${REPORT_FILE}"
ps -eo pid,cmd,%cpu --sort=-%cpu | head -n 6 | tee -a "${REPORT_FILE}"

echo -e "\n[Rapport terminé : $REPORT_FILE]"