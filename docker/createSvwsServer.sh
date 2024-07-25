#!/bin/bash

clear

# Überprüfen, ob das Skript als Root ausgeführt wird
if [ "$(id -u)" -ne 0 ]; then
    echo "Dieses Skript muss als Root ausgeführt werden." 1>&2
    exit 1
fi

# Überprüfen, ob die Datei config existiert
if [ ! -f "config" ]; then
    echo 'Die Datei "config" wurde nicht gefunden.'
    exit 1
fi

# Funktion zum Anzeigen einer Fortschrittsanzeige
show_progress_right() {
  duration=$1
  interval=0.2
  steps=$(echo "$duration / $interval" | bc)
  bar="####################"
  
  # Terminalbreite erfassen
  terminal_width=$(tput cols)
  bar_width=20  # Länge der Fortschrittsleiste
  
  for i in $(seq 0 $steps); do
    percentage=$(echo "($i / $steps) * 100" | bc -l | awk '{printf "%.0f", $1}')
    progress=$(echo "$i * $bar_width / $steps" | bc)
    
    # Fortschrittsbalken und Prozentsatz erstellen
    progress_bar=$(printf "%-${bar_width}s" "${bar:0:$progress}")
    output=$(printf "[%-${bar_width}s] %d%%" "$progress_bar" "$percentage")
    
    # Cursor an die rechte Seite bewegen und Status aktualisieren
    tput sc  # Cursor-Position speichern
    tput cup 0 $(tput cols)  # Cursor an die rechte Seite bewegen
    echo -n "$output"  # Fortschrittsbalken ausgeben
    tput rc  # Cursor-Position wiederherstellen
    
    sleep $interval
  done
  echo  # Neue Zeile am Ende der Fortschrittsanzeige
}

# aktuelles Verzeichnis feststellen
current_dir=$(pwd)





# Anleitung
clear
echo "Das Schreiben der Anleitung und das Sammeln der Informationen war nicht einfach."
echo "Über gute Kritik freue ich mich. Viel Spaß mit Ihrem neuen Server"
sleep 5


# Vorraussetzungen
echo
echo
echo "## Vorraussetzungen ##"
echo
sleep 0.3
echo -e "- Linux Betriebsystem (Ubuntu empfohlen)"
echo -e "   - Docker läuft am besten auf Linux" 
sleep 0.1
echo -e "- MariaDB"
sleep 0.1
echo -e "- 1GB Ram"
sleep 0.1
echo -e "- 1 CPU Kern"
sleep 0.1
echo -e "- Die folgenden Ports frei:"
sleep 0.1
echo -e "   - ein beliebiger Port"
sleep 0.1
echo -e "- ein bisschen Geduld"
sleep 0.1
echo

# Benutzerabfrage, ob das Skript fortgesetzt werden soll
read -p "Wollen Sie fortfahren? [Yn] " response
response=${response:-y}

if [[ $response == "n" || $response == "N" ]]; then
  echo "Abbruch..."
  exit 1
fi


clear
clear



#!/bin/bash

# Überprüfen, ob die Datei config existiert
if [ ! -f "config" ]; then
    echo
    echo 'Die Datei "config" wurde nicht gefunden.'
    echo "Bitte erstelle Sie diese"
    exit 1
fi


# Konfigurationsdatei einbinden
source config

# Funktion zum Einlesen der Konfigurationsdatei und Setzen der Variablen
parse_config() {
    local server_block="$1"
    # Extrahiere die Konfiguration für den spezifischen Serverblock
    awk -v section="[$server_block]" '
    $0 == section {flag=1; next}
    /^\[.*\]/ {flag=0}
    flag && NF {print}
    ' config | while IFS='=' read -r key value; do
        if [[ $key && $value ]]; then
            export "$key"="$value"
        fi
    done
}

# Funktion zur Benutzereingabe oder zum Beibehalten des bestehenden Wertes
prompt_user() {
    local var_name="$1"
    local prompt_message="$2"
    local default_value="$3"

    read -p "$prompt_message [$default_value]: " user_input
    if [ -n "$user_input" ]; then
        export "$var_name"="$user_input"
    else
        export "$var_name"="$default_value"
    fi
}

# Liste der Serverblöcke aus der Konfigurationsdatei holen
server_blocks=$(awk '/^\[.*\]/{gsub(/[\[\]]/,""); print $1}' config)

# Schleife über jeden Serverblock
for server in $server_blocks; do
    echo "Verarbeite Konfiguration für: $server"
    parse_config "$server"

    # Benutzerdefinierte Eingaben für alle Variablen
    prompt_user "ID" "Eine beliebige ID, diese darf kein zweites Mal existieren" "$ID"
    prompt_user "DIR_PATH" "Bitte geben Sie einen gültigen Verzeichnispfad ein" "$DIR_PATH"
    prompt_user "MariaDB_HOST" "Die IP-Adresse der MariaDB, gefolgt von dem Port" "$MariaDB_HOST"
    prompt_user "MariaDB_ROOT_PASSWORD" "Das Root Passwort der MariaDB" "$MariaDB_ROOT_PASSWORD"
    prompt_user "MariaDB_DATABASE" "Wie heißt die Datenbank?" "$MariaDB_DATABASE"
    prompt_user "MariaDB_USER" "Geben Sie einen nicht Root User ein" "$MariaDB_USER"
    prompt_user "MariaDB_PASSWORD" "Bitte geben Sie das MariaDB Passwort ein" "$MariaDB_PASSWORD"
    prompt_user "SVWS_TLS_KEYSTORE_PASSWORD" "Das SVWS TLS Keystore Passwort" "$SVWS_TLS_KEYSTORE_PASSWORD"
    prompt_user "SVWS_TLS_KEY_ALIAS" "Der SVWS TLS Key Alias" "$SVWS_TLS_KEY_ALIAS"
    prompt_user "SVWS_HOST_IP" "Die IP-Adresse des SVWS-Servers" "$SVWS_HOST_IP"
    prompt_user "SVWS_HOST_PORT" "Der Port des SVWS-Servers" "$SVWS_HOST_PORT"


    # ID des SVWS-Servers
    echo "eine beliebige ID, diese darf kein zweites Mal existieren [$ID]: "
    read -p "> " input_ID
    ID=${input_ID:-$ID}
    echo

    # Verzeichnis abfragen und überprüfen
    current_dir=$(pwd)
    while true; do
        read -p "Bitte geben Sie einen gültigen Verzeichnispfad ein [$DIR_PATH]: " input_dir_path
        dir_path=${input_dir_path:-$DIR_PATH}

        if [ -d "$dir_path" ]; then
          break
        else
          echo "Das Verzeichnis existiert nicht. Bitte versuchen Sie es erneut."
        fi
    done

    clear

    # MariaDB Zugangsdaten
    echo "Bitte geben Sie im Folgenden die Zugangsdaten der MariaDB ein"
    sleep 1

    echo "Die IP-Adresse der MariaDB, gefolgt von dem Port [$MariaDB_HOST]:"
    read -p "> " input_MariaDB_HOST
    MariaDB_HOST=${input_MariaDB_HOST:-$MariaDB_HOST}
    echo

    echo "Nun wird das Root Passwort benötigt [****]:"
    read -s -p "> " input_MariaDB_ROOT_PASSWORD
    MariaDB_ROOT_PASSWORD=${input_MariaDB_ROOT_PASSWORD:-$MariaDB_ROOT_PASSWORD}
    echo

    echo "Wie heißt die Datenbank? [$MariaDB_DATABASE]: "
    read -p "> " input_MariaDB_DATABASE
    MariaDB_DATABASE=${input_MariaDB_DATABASE:-$MariaDB_DATABASE}
    echo

    echo "Geben Sie einen nicht Root User ein [$MariaDB_USER]: "
    read -p "> " input_MariaDB_USER
    MariaDB_USER=${input_MariaDB_USER:-$MariaDB_USER}
    echo

    echo "Bitte geben Sie das MariaDB Passwort ein [****]: "
    read -s -p "> " input_MariaDB_PASSWORD
    MariaDB_PASSWORD=${input_MariaDB_PASSWORD:-$MariaDB_PASSWORD}
    echo

    clear

    # SSL-Zertifikat
    echo "Es muss für eine sichere Verbindung ein SSL-Zertifikat erstellt werden"
    echo "Bitte geben Sie das SVWS TLS Keystore Passwort ein [****]: "
    read -s -p "> " input_SVWS_TLS_KEYSTORE_PASSWORD
    SVWS_TLS_KEYSTORE_PASSWORD=${input_SVWS_TLS_KEYSTORE_PASSWORD:-$SVWS_TLS_KEYSTORE_PASSWORD}
    echo

    echo "Bitte geben Sie den SVWS TLS Key Alias ein [$SVWS_TLS_KEY_ALIAS]: "
    read -p "> " input_SVWS_TLS_KEY_ALIAS
    SVWS_TLS_KEY_ALIAS=${input_SVWS_TLS_KEY_ALIAS:-$SVWS_TLS_KEY_ALIAS}
    echo

    clear

    # SVWS-Host-Daten
    echo "Geben Sie die Host-Daten ein"
    echo "Über welche IP-Adresse soll der Server erreichbar sein? [$SVWS_HOST_IP]"
    read -p "> " input_SVWS_HOST_IP
    SVWS_HOST_IP=${input_SVWS_HOST_IP:-$SVWS_HOST_IP}
    echo

    echo "Über welchen Port soll der Server erreichbar sein? [$SVWS_HOST_PORT]"
    read -p "> " input_SVWS_HOST_PORT
    SVWS_HOST_PORT=${input_SVWS_HOST_PORT:-$SVWS_HOST_PORT}
    echo

    clear

    # Ausgabe der eingelesenen und ggf. überschriebenen Variablen
    echo "ID: $ID"
    echo "Verzeichnispfad: $dir_path"
    echo "MariaDB Host: $MariaDB_HOST"
    echo "MariaDB Root Passwort: $MariaDB_ROOT_PASSWORD"
    echo "MariaDB Datenbank: $MariaDB_DATABASE"
    echo "MariaDB User: $MariaDB_USER"
    echo "MariaDB Passwort: $MariaDB_PASSWORD"
    echo "SVWS TLS Keystore Passwort: $SVWS_TLS_KEYSTORE_PASSWORD"
    echo "SVWS TLS Key Alias: $SVWS_TLS_KEY_ALIAS"

    # Benutzerabfrage, ob das Skript fortgesetzt werden soll
    read -p "Wollen Sie fortfahren? [Yn] " response
    response=${response:-y}

    if [[ $response == "n" || $response == "N" ]]; then
      echo "Abbruch..."
      exit 1
    fi


    clear
    clear

    # Docker wird installiert
    echo "Docker wird installiert"

    {
      sudo apt install docker.io docker-compose-v2 nano && docker --version
    } &> /dev/null &

    pid=$!
    show_progress_right 1
    wait $pid


    #SSL-Zertifikat erstellen
    echo "SSL-Zertifikat wird erstellt"

    # Datein erstellen
    echo "Dateien werden erstellt in $dir_path"


    cd $dir_path && mkdir svws-server-$ID && cd svws-server-$ID && touch docker-compose.yml && touch .env

    cat <<EOF > docker-compose.yml
    version: "3"
    services:
      svws-$ID:
        image: svwsnrw/svws-server:latest
        container_name: svws-server-$ID
        ports:
          - "$SVWS_HOST_PORT:8443"
        environment:
          MariaDB_HOST: "$MariaDB_HOST"
          MariaDB_ROOT_PASSWORD: "$MariaDB_ROOT_PASSWORD"
          MariaDB_DATABASE: "$MariaDB_DATABASE"
          MariaDB_USER: "$MariaDB_USER"
          MariaDB_PASSWORD: "$MariaDB_PASSWORD"
          SVWS_TLS_KEY_ALIAS: "$SVWS_TLS_KEY_ALIAS"
          SVWS_TLS_KEYSTORE_PATH: "/etc/app/svws/conf/keystore"
          SVWS_TLS_KEYSTORE_PASSWORD: "$SVWS_TLS_KEYSTORE_PASSWORD"
        volumes:
          - ./keystore:/etc/app/svws/conf/keystore
    
EOF

    cat <<EOF > .env
    MariaDB_ROOT_PASSWORD=$MariaDB_ROOT_PASSWORD
    MariaDB_DATABASE=$MariaDB_DATABASE
    MariaDB_HOST=$MariaDB_HOST
    MariaDB_USER=$MariaDB_USER
    MariaDB_PASSWORD=$MariaDB_PASSWORD
    SVWS_TLS_KEYSTORE_PATH=$SVWS_TLS_KEYSTORE_PATH
    SVWS_TLS_KEYSTORE_PASSWORD=$SVWS_TLS_KEYSTORE_PASSWORD
    SVWS_TLS_KEY_ALIAS=$SVWS_TLS_KEY_ALIAS

EOF


    # Keystore erstellen
    echo "Keystore wird erstellt"
    echo
    sleep 1

    mkdir keystore && cd keystore
    keytool -genkeypair -alias $SVWS_TLS_KEY_ALIAS -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore keystore -validity 365 -storepass $SVWS_TLS_KEYSTORE_PASSWORD -keypass $SVWS_TLS_KEYSTORE_PASSWORD -dname "CN=localhost, OU=IT, O=MyCompany, L=City, ST=State, C=Country"

    # Zurück ins Verzeichnis
    cd ..
    sleep 1

    # Container starten
    echo
    echo "Container wird gestartet"
    sleep 3

    clear

    docker compose up -d
    show_progress_right 30


    clear

    # So sieht dein System jetzt aus
    echo "########################"
    echo "Der SVWS-Server $server läuft!"
    echo
    echo "Der soeben aufgesetzte Server hat die ID  $ID"
    docker ps | grep svws-server-$ID
    echo "########################"
    echo
    echo



done

rm createSvwsServer.sh startskript config_example

# Benutzerabfrage, ob das Skript fortgesetzt werden soll
read -p "Aktuell laufende Container anzeigen? [Yn] " response_2
response_2=${response_2:-y}

if [[ $response_2 == "y" || $response_2 == "Y" ]]; then
  docker ps
  exit 1
fi
