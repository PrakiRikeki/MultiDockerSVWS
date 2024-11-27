#!/bin/bash
clear

# Überprüfen, ob das Skript als Root ausgeführt wird
if [ "$(id -u)" -ne 0 ]; then
    echo "Dieses Skript muss als Root ausgeführt werden." 1>&2
    read -n 1 -s -r -p "Drücke irgendeine Taste, um fortzufahren..."
    exit 1
fi

echo "Das Skript wurde als Root ausgeführt"

# Überprüfen, ob die Konfigurationsdatei existiert
config_file="svws_docker.conf"
if [ ! -f "$config_file" ]; then
    echo 'Die Datei "svws_docker.conf" wurde nicht gefunden.'
    echo 'Bitte erstelle diese.'
    read -n 1 -s -r -p "Drücke irgendeine Taste, um fortzufahren..."
    exit 1
fi

echo "Eine Config-Datei ist vorhanden."
echo ""



# Funktion zum Einlesen und Anzeigen der Konfigurationsdatei
parse_config() {
    local config_file="$1"
    local incomplete_containers=0
    local container_count=0

    local current_host_port=""
    local current_db_location=""
    local current_db_port=""
    local schools=()
    local is_valid_container=1  # 1: gültig, 0: ungültig

    echo "Config-Datei wird eingelesen: $config_file"
    echo ""

    # Datei Zeile für Zeile lesen
    while IFS= read -r line || [ -n "$line" ]; do
        # Leerzeilen und Kommentare ignorieren
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*// ]]; then
            continue
        fi

        # Schlüssel-Wert-Paare extrahieren
        if [[ "$line" =~ ^[[:space:]]*([^=]+)=([[:space:]]*.*)$ ]]; then
            key=$(echo "${BASH_REMATCH[1]}" | xargs)   # Entferne Leerzeichen um den Schlüssel
            value=$(echo "${BASH_REMATCH[2]}" | xargs) # Entferne Leerzeichen um den Wert

            case "$key" in
                "Host Port")
                    # Überprüfen, ob vorheriger Container vollständig ist
                    if [ -n "$current_host_port" ] || [ -n "$current_db_location" ] || [ -n "$current_db_port" ]; then
                        if [ $is_valid_container -eq 1 ]; then
                            # Ausgabe des vorherigen Containers
                            ((container_count++))
                            echo "Docker Container $container_count:"
                            echo "  Host Port = $current_host_port"
                            echo "  Database Location = $current_db_location"
                            echo "  Database Port = $current_db_port"
                            echo "  Schulen:"
                            # Tabelle der Schulen ausgeben
                            printf "%-25s %-15s %-15s\n" "Name" "User" "Pass"
                            printf "%-25s %-15s %-15s\n" "----" "----" "----" # Trennlinie
                            for school in "${schools[@]}"; do
                                printf "%-25s %-15s %-15s\n" ${school[@]}
                            done
                            echo ""
                        else
                            ((incomplete_containers++))
                        fi
                    fi
                    # Containerblock zurücksetzen
                    schools=()
                    is_valid_container=1
                    current_host_port="$value"
                    current_db_location=""
                    current_db_port=""
                    ;;
                "Database Location")
                    current_db_location="$value"
                    ;;
                "Database Port")
                    current_db_port="$value"
                    ;;
                "name" | "user" | "pass")
                    if [ -z "$value" ]; then
                        is_valid_container=0
                    fi
                    # Letzte Schule erweitern oder neue Schule beginnen
                    if [ "$key" == "name" ]; then
                        schools+=("$value")
                    else
                        last_index=$((${#schools[@]} - 1))
                        schools[$last_index]="${schools[$last_index]} $key=$value"
                    fi
                    ;;
                *)
                    echo "Unbekannter Schlüssel: $key"
                    ;;
            esac
        fi
    done < "$config_file"

    # Verarbeite den letzten Containerblock
    if [ -n "$current_host_port" ] || [ -n "$current_db_location" ] || [ -n "$current_db_port" ]; then
        if [ $is_valid_container -eq 1 ]; then
            ((container_count++))
            echo "Docker Container $container_count:"
            echo "  Host Port = $current_host_port"
            echo "  Database Location = $current_db_location"
            echo "  Database Port = $current_db_port"
            echo "  Schulen:"
            # Tabelle der Schulen ausgeben
            printf "%-25s %-15s %-15s\n" "Name" "User" "Pass"
            printf "%-25s %-15s %-15s\n" "----" "----" "----" # Trennlinie
            for school in "${schools[@]}"; do
                printf "%-25s %-15s %-15s\n" ${school[@]}
            done
            echo ""
        else
            ((incomplete_containers++))
        fi
    fi

    echo "Config-Datei erfolgreich verarbeitet."
    if [ $incomplete_containers -gt 0 ]; then
        echo "$incomplete_containers Docker-Container-Blöcke konnten nicht verarbeitet werden."
    fi
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

    sudo apt install docker.io upzip


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
      brea
    fi

    # Version abfragen
    read -p "Welche SVWS-Server Version möchten Sie verwenden? [] " response
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
    
    # Hauptskript
    config_file="svws_docker.conf"
    if [ ! -f "$config_file" ]; then
        echo "Die Konfigurationsdatei '$config_file' wurde nicht gefunden."
        exit 1
    fi

    echo "Config wird eingelesen."
    echo ""
    parse_config "$config_file"

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
    cp -r ./svws/app/* ./data

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

    cd data

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
    services:
      svws-server-$ID:
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

    keytool -genkeypair -alias $SVWS_TLS_KEY_ALIAS -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore keystore/keystore -validity 365 -storepass $SVWS_TLS_KEYSTORE_PASSWORD -keypass $SVWS_TLS_KEYSTORE_PASSWORD -dname "CN=localhost, OU=IT, O=MyCompany, L=City, ST=State, C=Country"


    # Container starten
    echo
    echo "Docker Container wird gestartet"

    docker compose up -d


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

# Benutzerabfrage, ob das Skript fortgesetzt werden soll
read -p "Logs anschauen? [Yn] " response_3
response_3=${response_3:-y}

if [[ $response_3 == "y" || $response_3 == "Y" ]]; then
  docker compose logs -f


  # Kurze Pause, damit der Benutzer die Nachricht sehen kann
  echo
  echo
  read -n 1 -s -r -p "Drücke irgendeine Taste um fortzufahren..."


  clear
fi
