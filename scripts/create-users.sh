#!/bin/bash

# On récupère les arguments (Le fichier CSV et le mode optionnel)
FICHIER_CSV="$1"
MODE="$2"

# Chemins absolus explicites
BASE_PATH="/home/loken/Github/AIS/BLOC_B_TechnicienInfrastructure/SB04E08-Atelier-Bash-LeMien/scripts"
LOG_DIR="${BASE_PATH}/logs"
LOG_FILE="${LOG_DIR}/user-creation.log"
RECAP_FILE="${BASE_PATH}/users_created.txt"

# Création du dossier de logs s'il n'existe pas encore
mkdir -p "$LOG_DIR"

# Vérification des droits // Est-ce que je suis (G)root ? =D
if [[ $EUID -ne 0 ]]; then
   echo "ERREUR : Tu dois lancer ce script avec sudo."
   exit 1
fi

# Est-ce qu'on m'a donné un fichier ?
if [[ -z "$FICHIER_CSV" ]]; then
    echo "ERREUR : Il manque le fichier CSV."
    echo "Usage : sudo $0 users.csv [--delete]"
    exit 1
fi

# Boucle principale (while)
if [[ "$MODE" == "--delete" ]]; then

    # MODE SUPPRESSION --- (Eraser Head) --delete
    echo ">>> Démarrage du mode SUPPRESSION..."

    # Lecture du fichier (saut de la 1ère ligne avec -n +2 car la ligne des titres compte)
    # Explique que , (virgule) est le séparateur
    tail -n +2 "$FICHIER_CSV" | while IFS=',' read -r prenom nom dept fonction; do
        
        # Calcul du login 
                                            #(tr pour translate = toutes majuscules deviennent minuscules)
                                            #(tr -d = Pour delete)
        login=$(echo "${prenom:0:1}${nom}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

        # Si l'utilisateur existe, on demande confirmation (read -p = demander confirmation)
        if id "$login" &>/dev/null; then
            read -p "Confirmer la suppression de $login ? (y/n) : " confirm
            if [[ "$confirm" == "y" ]]; then
                userdel -r "$login"
                echo "Supprimé : $login"
                echo "$(date) - DELETE - $login a été supprimé." >> "$LOG_FILE"
            else
                echo "Annulé pour $login."
            fi
        else
            echo "Introuvable : $login (déjà supprimé ?)"
        fi
    done

else

    # MODE CRÉATION --- (Par défaut) 
    echo ">>> Démarrage du mode CRÉATION..."
    
    # On initialise le fichier de mots de passe
    echo "Login:MotDePasse" > "$RECAP_FILE"

    tail -n +2 "$FICHIER_CSV" | while IFS=',' read -r prenom nom dept fonction; do
        
        # 1. Calcul du login (tr & tr -d)
        login=$(echo "${prenom:0:1}${nom}" | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')
        nom_complet="$prenom $nom"

        # 2. Vérification existence
        if id "$login" &>/dev/null; then
            echo "Saut : L'utilisateur $login existe déjà."
            echo "$(date) - WARN - Doublon détecté pour $login" >> "$LOG_FILE"
        else
            # 3. Gestion du Groupe (getent = Get Entries) // (! = différent)
            if ! getent group "$dept" &>/dev/null; then
                groupadd "$dept"
                echo "Groupe créé : $dept"
            fi

            # 4. Génération mot de passe (Version Base64 plus robuste)
            password=$(openssl rand -base64 12)

            # 5. Création de l'utilisateur
            # -m = Make Home // -g = Group (défini le groupe principal de l'user) // -c = Comment // -s = Shell
            useradd -m -g "$dept" -c "$nom_complet" -s /bin/bash "$login"

            # 6. Attribution du mot de passe
            # chpasswd = Change Password Batch Mode - Lit les paires login:motdepasse à la chaine
            echo "$login:$password" | chpasswd

            # 7. Validation et Logs
            if [[ $? -eq 0 ]]; then
                echo "Succès : $login créé."
                echo "$login:$password" >> "$RECAP_FILE"
                echo "$(date) - SUCCESS - Création de $login (Groupe: $dept)" >> "$LOG_FILE"
            else
                echo "Erreur sur $login !"
            fi
        fi
    done

    echo "----------------------------------------------------"
    echo "Terminé ! Les mots de passe sont ici : $RECAP_FILE"
    echo "----------------------------------------------------"

fi