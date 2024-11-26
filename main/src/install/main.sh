#!/bin/bash
clear

# Überprüfen, ob das Skript als Root ausgeführt wird
if [ "$(id -u)" -ne 0 ]; then
    echo "Dieses Skript muss als Root ausgeführt werden." 1>&2
    # Kurze Pause, damit der Benutzer die Nachricht sehen kann
    read -n 1 -s -r -p "Drücke irgendeine Taste um fortzufahren..."
    exit 1
fi

echo "Das Skript wurde als Root ausgeführt"

# Überprüfen, ob die Konfigurationsdatei existiert
config_file="svws_docker.conf"
if [ ! -f "$config_file" ]; then
    echo 'Die Datei "svws_docker.conf" wurde nicht gefunden.'
    echo 'Bitte erstelle Sie diese.'
    # Kurze Pause, damit der Benutzer die Nachricht sehen kann
    read -n 1 -s -r -p "Drücke irgendeine Taste um fortzufahren..."
    break
fi

echo "eine config Datei ist vorhanden"
echo ""




# Funktion zum Einlesen der Konfigurationsdatei
parse_config() {
    local server_block="$1"
    local config_file="svws_docker.conf"
    local block_found=0
    local line

    # Prüfen, ob die Konfigurationsdatei existiert
    if [ ! -f "$config_file" ]; then
        echo "Fehler: Konfigurationsdatei $config_file nicht gefunden"
        return 1
    fi

    echo "Config Datei wird eingelesen"

    # Einlesen der Konfigurationsdatei
    while IFS= read -r line || [ -n "$line" ]; do
        # Leere Zeilen und Kommentare überspringen
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Entferne führende und folgende Leerzeichen
        line=$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

        # Überprüfen, ob die Zeile ein Abschnittsheader ist
        if [[ "$line" =~ ^\[(.*)\]$ ]]; then
            # Extrahiere den Abschnittsnamen ohne Klammern
            current_section=$(echo "$line" | sed -e 's/^\[\(.*\)\]$/\1/')
            
            if [ "$current_section" = "$server_block" ]; then
                block_found=1
            else
                block_found=0
            fi
            continue
        fi

        # Wenn wir im richtigen Block sind und die Zeile enthält ein '='
        if [ $block_found -eq 1 ] && [[ "$line" =~ = ]]; then
            # Aufteilen der Zeile in Schlüssel und Wert
            key=$(echo "$line" | cut -d'=' -f1 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            value=$(echo "$line" | cut -d'=' -f2- | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
            
            # Setzen der Umgebungsvariablen
            if [ -n "$key" ] && [ -n "$value" ]; then
                export "$key"="$value"
            fi
        fi
    done < "$config_file"

    if [ $block_found -eq 0 ]; then
        echo
        return 1
    fi

    echo "Config Datei wurde erfolgreich eingelesen"
}

# Funktion zum Auflisten aller verfügbaren Serverblöcke
list_server_blocks() {
    local config_file="svws_docker.conf"
    
    if [ ! -f "$config_file" ]; then
        echo "Fehler: Konfigurationsdatei $config_file nicht gefunden"
        return 1
    fi

    echo "Verfügbare Server-Blöcke:"
    grep '^\[.*\]' "$config_file" | sed -e 's/^\[\(.*\)\]$/\1/'
}

    # Systeminstallationsquellenupdate falls vorhanden
    echo "Installationsquellen werden geprüft."

    sudo apt update


    # Updates werden durchgeführt
    echo "Updates werden durchgeführt."

    sudo apt upgrade


    # Docker wird installiert
    echo "Docker wird installiert oder ein Update wird durchgeführt."

    sudo apt install docker.io


    # Docker Compose wird installiert
    echo "Docker Compose wird installiert, falls nicht vorhanden."

    sudo apt install docker-compose-v2
    

    # Nano wird geprüft
    echo "Nano wird geprüft."

    sudo apt install nano 


    # Java wird gegebenenfalls installiert, wenn nicht bereits vorhanden
    echo "Java wird gegebenenfalls installiert, wenn nicht bereits vorhanden."
    
    sudo apt install default-jdk
    
    
    # Java wird gegebenenfalls installiert, wenn nicht bereits vorhanden
    echo "Docker Versions überprüfung."
    
    docker --version

    clear

    echo "Alle benötigten Programme wurden installiert und auf den neusten Stand gebracht."


    # Benutzerabfrage, ob das Skript fortgesetzt werden soll
    read -p "Wollen Sie fortfahren? [Yn] " response
    response=${response:-y}

    if [[ $response == "n" || $response == "N" ]]; then
      echo "Abbruch..."
      sleep 1
      break
    fi

    echo "Installation wird fortgesetzt"


    clear
    echo "Config wird eingelesen."
    echo
    
    # Aufruf der Funktion zur Verarbeitung des Serverblocks
    parse_config "server"

    # Ausgabe der eingelesenen Variablen
    echo "ID: ${ID:-nicht gesetzt}"
    echo "Verzeichnispfad: ${DIR_PATH:-nicht gesetzt}"
    echo "MariaDB Host: ${MariaDB_HOST:-nicht gesetzt}"
    echo "MariaDB Root Passwort: ${MariaDB_ROOT_PASSWORD:-nicht gesetzt}"
    echo "MariaDB Datenbank: ${MariaDB_DATABASE:-nicht gesetzt}"
    echo "MariaDB User: ${MariaDB_USER:-nicht gesetzt}"
    echo "MariaDB Passwort: ${MariaDB_PASSWORD:-nicht gesetzt}"
    echo "SVWS TLS Keystore Passwort: ${SVWS_TLS_KEYSTORE_PASSWORD:-nicht gesetzt}"
    echo "SVWS TLS Key Alias: ${SVWS_TLS_KEY_ALIAS:-nicht gesetzt}"
    echo "SVWS Host IP: ${SVWS_HOST_IP:-nicht gesetzt}"
    echo "SVWS Host Port: ${SVWS_HOST_PORT:-nicht gesetzt}"
    echo
    echo


    # Benutzerabfrage, ob das Skript fortgesetzt werden soll
    read -p "Wollen Sie fortfahren? [Yn] " response
    response=${response:-y}

    if [[ $response == "n" || $response == "N" ]]; then
      echo "Abbruch..."
      sleep 1
      break
    fi

    echo "Diese Config wird nun verarbeitet."
    sleep 1

    clear

    mkdir server
    cd server

    mkdir data



    if [ ! -f "linux-installer-1.0.1.tar.gz" ]; then
        DOWNLOAD_PFAD=https://github.com/SVWS-NRW/SVWS-Server/releases/download/v1.0.1/linux-installer-1.0.1.tar.gz
    fi

    # SVWS laden und auspacken
    echo "Lade SVWS ..."

    # Wenn DOWNLOAD_PFAD gesetzt ist, lade Datei herunter
    if [ ! -z "$DOWNLOAD_PFAD" ]; then
    echo "Lade Datei herunter von $DOWNLOAD_PFAD..."
    wget $DOWNLOAD_PFAD
    echo "Herunterladen abgeschlossen."
    fi

    # Entpacke die SVWS-Installationsdatei
    tar xzf ./linux-installer-1.0.1.tar.gz

    # Erstelle Verzeichnisse
    mkdir -p ./data
    mkdir ./data/client
    mkdir ./data/adminclient
    mkdir ./data/conf

    # Kopiere App, Konfigurationen und Zertifikate
    cp -r ./svws/app ./data

    # Entpacke den Client in das Client-Verzeichnis
    unzip -d ./data/client ./data/app/SVWS-Client*.zip

    # Lösche die entpackte Client-Datei
    rm -rf ./data/app/SVWS-Client*.zip

    # Entpacke den Admin-Client in das Admin-Client-Verzeichnis
    unzip -d ./data/adminclient ./data/app/SVWS-Admin-Client*.zip

    # Lösche die entpackte Admin-Client-Datei
    rm -rf ./data/app/SVWS-Admin-Client*.zip

    # Erstelle Service-Datei und kopiere sie in das System-Verzeichnis
    envsubst < ./svws/svws-template.service > ./svws/svws.service
    cp ./svws/svws.service /etc/systemd/system/



    # svwsconfig.json erstellen und mit Inhalt beschreiben
    ./main.sh config.conf svwsconfig.json



        # Definiere den Pfad zur startup.sh
        STARTUP_FILE="startup.sh"

        # Erstelle den Inhalt der startup.sh
        cat > "${STARTUP_FILE}" << 'EOL'
        #!/bin/bash

        # Konfigurationsdatei generieren
        if [[ ! -f /opt/app/svws/svwsconfig.json ]]; then
            echo "Konfigurationsdatei nicht vorhanden. Erstelle Konfigurationsdatei..."
            envsubst < /etc/app/svws/conf/svwsconfig-template.json > /opt/app/svws/svwsconfig.json
        else
            echo "Konfigurationsdatei bereits vorhanden."
        fi

        # Testdatenbank importieren
        if [[ -d $INIT_SCRIPTS_DIR ]]; then
            echo "INIT_SCRIPTS_DIR: $INIT_SCRIPTS_DIR"
            for f in "$INIT_SCRIPTS_DIR"/*.sh; do
                echo "Starte Shell script: $f"
                /bin/bash "$f"
            done
        fi

        # SVWS-Server starten
        echo "Starte SVWS-Server ..."
        java -cp "svws-server-app-*.jar:./*:./lib/*" de.svws_nrw.server.jetty.Main
EOL

        # Mache die startup.sh ausführbar
        chmod +x "${STARTUP_FILE}"

        echo "startup.sh wurde erfolgreich erstellt und ist nun ausführbar."



    # Dockerverzeichnis wird wieder betreten
    cd ..
    

    # Nun werden die beiden beötigten Daten erstellt
    echo "benötigte Daten werden generiert."
    touch docker-compose.yml && touch .env

    # Datei wird mit Inhalt beschrieben
    echo "docker-compose bekommt Inhalt..."

    cat <<EOF > docker-compose.yml
    version: "3"
    services:
      svws-$ID:
        image: svwsnrw/svws-server:latest
        container_name: svws-server-$ID
        restart: always
        ports:
          - "$SVWS_HOST_PORT:8443"
        environment:
          MariaDB_HOST: "${MariaDB_HOST}"
          MariaDB_ROOT_PASSWORD: "${MariaDB_ROOT_PASSWORD}"
          MariaDB_DATABASE: "${MariaDB_DATABASE}"
          MariaDB_USER: "${MariaDB_USER}"
          MariaDB_PASSWORD: "${MariaDB_PASSWORD}"
          SVWS_TLS_KEY_ALIAS: "${SVWS_TLS_KEY_ALIAS}"
          SVWS_TLS_KEYSTORE_PATH: "/etc/app/svws/conf/keystore"
          SVWS_TLS_KEYSTORE_PASSWORD: "${SVWS_TLS_KEYSTORE_PASSWORD}"
          SVWS_HOST_IP: "${SVWS_HOST_IP}"
        volumes:
          - ./keystore:/etc/app/svws/conf/keystore
    
EOF

    # weitere Terminal ausgeben
    echo "fertig"
    echo ".env bekommt Inhalt..."

cat <<EOF > .env
  MariaDB_ROOT_PASSWORD=$MariaDB_ROOT_PASSWORD
  MariaDB_DATABASE=$MariaDB_DATABASE
  MariaDB_HOST=$MariaDB_HOST
  MariaDB_USER=$MariaDB_USER
  MariaDB_PASSWORD=$MariaDB_PASSWORD
  SVWS_TLS_KEYSTORE_PATH=/etc/app/svws/conf/keystore
  SVWS_TLS_KEYSTORE_PASSWORD=$SVWS_TLS_KEYSTORE_PASSWORD
  SVWS_TLS_KEY_ALIAS=$SVWS_TLS_KEY_ALIAS

EOF
    echo "fertig"
    echo "Abhänigkeiten werden erstellt."

    # Keystore erstellen
    echo "Keystore wird erstellt"
    echo
    sleep 1

    mkdir keystore
    keytool -genkeypair -alias $SVWS_TLS_KEY_ALIAS -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore keystore/keystore -validity 365 -storepass $SVWS_TLS_KEYSTORE_PASSWORD -keypass $SVWS_TLS_KEYSTORE_PASSWORD -dname "CN=localhost, OU=IT, O=MyCompany, L=City, ST=State, C=Country"


    # Container starten
    echo
    echo "Docker Container wird gestartet"

    docker compose up -d -y 

    # Zurück ins Haupt Verzeichnis
    cd ..
    cd ..

    echo "Hauptverzeichnis wurde wieder betreten."

    # Statusmeldung wird abgegeben

    gelb="\033[1;33m"
    rot="\033[1;31m"
    blau="\033[1;30m"
    gruen="\033[1;34m"
    gruen2="\033[1;34m"
    normal="\033[0;37m"

    echo "$normal Status des Servers:   $gruen gestartet, $gruen2 ja, wirklich! $normal"


    echo "Der SVWS-Server $server läuft!"
    echo
    echo "Der soeben aufgesetzte Server hat die ID  $ID"
    if ! docker ps | grep -q svws-server-$ID; then
    echo "Fehler: Der Container svws-server-$ID wurde nicht gestartet."
    else
    echo "Der Container läuft erfolgreich."
    fi
    echo
    echo


# Benutzerabfrage, ob das Skript fortgesetzt werden soll
read -p "Aktuell laufende Container anzeigen? [Yn] " response_2
response_2=${response_2:-y}

if [[ $response_2 == "y" || $response_2 == "Y" ]]; then
  docker ps


  # Kurze Pause, damit der Benutzer die Nachricht sehen kann
  echo
  echo
  read -n 1 -s -r -p "Drücke irgendeine Taste um fortzufahren..."


  clear
fi
