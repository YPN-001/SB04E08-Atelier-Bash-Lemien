#!/bin/bash

# On récupère l'argument ( --force)
OPTION="$1"

# Configuration des chemins absolus
BASE_PATH="/home/loken/Github/AIS/BLOC_B_TechnicienInfrastructure/SB04E08-Atelier-Bash-LeMien/scripts"
LOG_DIR="${BASE_PATH}/logs"
LOG_FILE="${LOG_DIR}/cleanup.log"

# Création du dossier de logs s'il n'existe pas
mkdir -p "$LOG_DIR"

# Vérification des droits
# Il faut être root pour nettoyer /var/log et faire apt clean
if [[ $EUID -ne 0 ]]; then
   echo "ERREUR : Tu dois être root (sudo) pour lancer le nettoyage."
   exit 1
fi

# DÉTECTION DU MODE (DRY-RUN ou FORCE)

MODE="SIMULATION" # Par défaut, on simule

if [[ "$OPTION" == "--force" || "$OPTION" == "-f" ]]; then
    
    # Demande de confirmation ultime
    echo "/!\\ ATTENTION /!\\"
    echo "Tu es sur le point d'effacer définitivement des fichiers."
    read -p "Es-tu certain de vouloir continuer ? (y/n) : " confirm
    
    if [[ "$confirm" == "y" ]]; then
        MODE="ACTIF"
    else
        echo "Annulation."
        exit 0
    fi
else
    echo "--- MODE SIMULATION (DRY-RUN) ---"
    echo "Utilise --force ou -f pour exécuter réellement les suppressions."
    echo "---------------------------------"
fi

# Fonction pour logger
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - [$MODE] - $1" >> "$LOG_FILE"
}

# EXÉCUTION DU NETTOYAGE

echo ">>> Espace disque AVANT nettoyage :"
df -h / | grep /    # df = Disk Free // -h = Human-readable  // | grep / = permet de garder uniquement la ligne qui contient un " / "
log_action "Démarrage du script."

# ÉTAPE 1 : Nettoyage de /tmp (Fichiers > 7 jours)
echo "1. Analyse de /tmp..."
if [[ "$MODE" == "ACTIF" ]]; then   # Vérification du mode ( --force)
    # On supprime (-delete)
    find /tmp -type f -mtime +7 -delete # -type f = uniquement les fichiers / -mtime = dont la date est plus vielle que + xx
    echo "[OK] Fichiers temporaires supprimés."
    log_action "Nettoyage /tmp effectué."
else
    # On affiche seulement (-print)
    count=$(find /tmp -type f -mtime +7 | wc -l)    # On lance "find" | wc -1 = qui envoie la commande Word Count avec l'option -1 (Lines)
    echo "[SIMULATION] J'aurais supprimé $count fichiers dans /tmp."
fi


# ÉTAPE 2 : Logs compressés .gz (> 30 jours)
echo "2. Analyse de /var/log..."
if [[ "$MODE" == "ACTIF" ]]; then
    find /var/log -name "*.gz" -mtime +30 -delete
    echo "[OK] Vieux logs compressés supprimés."
    log_action "Nettoyage logs effectué."
else
    count=$(find /var/log -name "*.gz" -mtime +30 | wc -l)
    echo "[SIMULATION] J'aurais supprimé $count fichiers .gz dans /var/log."
fi

# ÉTAPE 3 : Nettoyage du cache Gestionnaire de Paquets
echo "3. Nettoyage du cache système..."

if [[ "$MODE" == "ACTIF" ]]; then
    
    # >> VERSION DEBIAN / UBUNTU / KALI (Active)
    apt-get clean
    echo "[OK] Cache APT vidé."
    log_action "Cache APT vidé."

    # >> VERSION ARCH LINUX (Commentée) - La version pour mon pc
    # Pour Arch, on utilise pacman.
    # -Sc : Supprime les paquets du cache qui ne sont plus installés
    # --noconfirm : Pour ne pas qu'il demande confirmation à chaque fois
    
    # pacman -Sc --noconfirm
    # echo "[OK] Cache Pacman vidé."
    # log_action "Cache Pacman vidé."

else
    # Mode Simulation
    echo "[SIMULATION] J'aurais exécuté 'apt-get clean' (Debian)."
    # echo "[SIMULATION] J'aurais exécuté 'pacman -Sc' (Arch Linux)."
fi

# ÉTAPE 4 : Corbeille des utilisateurs
# Attention : ceci vide la corbeille de TOUS les utilisateurs si lancé en root
echo "4. Vidage des corbeilles utilisateurs..."
if [[ "$MODE" == "ACTIF" ]]; then
    rm -rf /home/*/.local/share/Trash/* # La commande de tout les dangers ! :D
    echo "[OK] Corbeilles vidées."
    log_action "Corbeilles utilisateurs vidées."
else
    echo "[SIMULATION] J'aurais vidé le dossier /home/*/.local/share/Trash/."
fi

# 5. Rapport final

echo "---------------------------------"
echo ">>> Espace disque APRÈS nettoyage :"
df -h / | grep /    # # df = Disk Free // -h = Human-readable  // | grep / = permet de garder uniquement la ligne qui contient un " / "
echo "Terminé."
log_action "Fin du script."