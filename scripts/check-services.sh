#!/bin/bash

# 1. CONFIGURATION ET CHEMINS EXPLICITES

OPTION="$1" # Pour récupérer l'option --watch ou --restart

# Chemins absolus explicites
BASE_PATH="/home/loken/Github/AIS/BLOC_B_TechnicienInfrastructure/SB04E08-Atelier-Bash-LeMien/scripts"
CONFIG_FILE="${BASE_PATH}/services.conf"
JSON_FILE="${BASE_PATH}/services_report.json"

# DÉFINITION DES COULEURS AVEC TPUT (Terminal OutPUT)... parce que je suis un flemmard xD
# setaf = Set ANSI Foreground (Couleur du texte)
# 1 = Rouge, 2 = Vert, 3 = Jaune, 4 = Bleu
# sgr0 = Remise à zéro (Neutre)

ROUGE=$(tput setaf 1)
VERT=$(tput setaf 2)
JAUNE=$(tput setaf 3)
BLEU=$(tput setaf 4)
NEUTRE=$(tput sgr0)

# Vérification du fichier de conf
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "${ROUGE}ERREUR : Fichier de configuration introuvable !${NEUTRE}"
    echo "Attendu ici : $CONFIG_FILE"
    exit 1
fi

# 2. FONCTION DE VÉRIFICATION AVANCÉE   -   Boucle principale

check_all_services() {      # Création de la fonction
    local total_actif=0             # Pour mettre le compteur
    local total_inactif=0           #         à zéro

    # Initialisation du fichier JSON (Ouverture du tableau)
    echo "[" > "$JSON_FILE"

    echo "----------------------------------------------------------------"
    echo "ÉTAT DES SERVICES - $(date '+%H:%M:%S')"      # Le fait de voir une heure différente permet de 
    echo "----------------------------------------------------------------"
                                                        # controler que le script n'a pas planté
    # Entête du tableau pour faire joli avec printf
    printf "%-15s %-15s %-15s %s\n" "SERVICE" "ÉTAT" "BOOT (Enabled)" "INFO"
    echo "----------------------------------------------------------------"

    # Lecture du fichier
    while read -r service; do   # read -r service = lit une ligne // la met dans la variable 
                                #     "service" (juste en bas) et entre dans la boucle     
        # Ignorer les lignes vides
        if [[ -z "$service" ]]; then continue; fi   # -z = Vérifie si la variable est vide 
                                                    # Si le script tombe sur une ligne vide, il la saute directement

        # --- VÉRIFICATION ÉTAT (Active) ---
        if systemctl is-active --quiet "$service"; then
            etat="active"
            display_etat="${VERT}ACTIF${NEUTRE}"
            ((total_actif++))
            msg="OK"
        else
            etat="inactive"
            display_etat="${ROUGE}DOWN${NEUTRE}"
            ((total_inactif++))
            
            # --- ALERTE ---
            msg="${ROUGE}/!\ ALERTE${NEUTRE}"
            
            # --- REDÉMARRAGE AUTOMATIQUE ---
            if [[ "$OPTION" == "--restart" ]]; then
                # echo -n évite le saut de ligne
                echo -n " Tentative restart..." 
                sudo systemctl restart "$service"
                
                # On revérifie après le restart
                if systemctl is-active --quiet "$service"; then
                     msg="${VERT}RÉPARÉ !${NEUTRE}"
                     etat="recovered"
                else
                     msg="${ROUGE}ÉCHEC RESTART${NEUTRE}"
                fi
            fi
        fi

        # --- VÉRIFICATION DÉMARRAGE (Enabled) ---
        if systemctl is-enabled --quiet "$service"; then
            boot_status="OUI"
            json_enabled="true"
        else
            boot_status="${JAUNE}NON${NEUTRE}"
            json_enabled="false"
        fi
        
        # --- AFFICHAGE LIGNE ---
        # printf remplace echo pour aligner les colonnes proprement
        printf "%-15s %-24s %-24s %b\n" "$service" "$display_etat" "$boot_status" "$msg"

        # --CRÉATION DU JSON ---
        # On ajoute l'info dans le fichier json
        # EOF = End Of File = Heredoc
        # Va lire/prendre tout le contenu jusqu'à voir le mot EOF
        cat <<EOF >> "$JSON_FILE"
  {
    "service": "$service",
    "status": "$etat",
    "enabled": $json_enabled,
    "timestamp": "$(date '+%Y-%m-%d %H:%M:%S')"
  },
EOF

    done < "$CONFIG_FILE"

    # --- NETTOYAGE JSON ---
    # Astuce sed : retire la virgule du dernier élément pour que le JSON soit valide
    sed -i '$ s/,$//' "$JSON_FILE"
    echo "]" >> "$JSON_FILE"

    echo "----------------------------------------------------------------"
    echo "Bilan : ${VERT}$total_actif actifs${NEUTRE} / ${ROUGE}$total_inactif inactifs${NEUTRE}"
    echo "Rapport JSON généré : $JSON_FILE"
}

# 3. LOGIQUE PRINCIPALE     -   Boucle Watch / Restart / Normal

if [[ "$OPTION" == "--watch" ]]; then
    
    echo ">>> Démarrage du mode MONITORING (Ctrl+C pour arrêter)..."
    sleep 1     # C'est seulement du ... User eXperience (UX) - simulation de temps d'arrêt

    # Boucle infinie
    while true; do
        tput clear              # Nettoie l'écran (version tput plus propre que clear)
        check_all_services      # Lance la vérification
        sleep 5                 # Attend 5 secondes
    done

elif [[ "$OPTION" == "--restart" ]]; then
    echo ">>> Mode RÉPARATION AUTOMATIQUE activé."
    check_all_services

else
    # Mode normal (une seule fois)
    check_all_services
fi