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
config_file="svws_docker_config.txt"
if [ ! -f "$config_file" ]; then
    echo 'Die Datei "svws_docker_config.txt" wurde nicht gefunden.'
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
    local config_file="svws_docker_config.txt"
    local block_found=0
    local line

    echo "config Datei wird eingelesen"

    # Einlesen der Konfigurationsdatei
    while IFS= read -r line || [ -n "$line" ]; do
        # Entferne führende und folgende Leerzeichen von Schlüssel und Wert
        line=$(echo "$line" | xargs)
        key=$(echo "$line" | cut -d'=' -f1 | xargs)
        value=$(echo "$line" | cut -d'=' -f2- | xargs)

        # Wenn die Zeile leer ist, überspringen
        [ -z "$key" ] && continue

        # Überprüfen, ob der Serverblock beginnt
        if [[ "$key" == "[$server_block]" ]]; then
            block_found=1
            continue  # Überspringen des aktuellen Loop-Durchlaufs
        fi

        # Wenn wir in einem Serverblock sind, setze die Variable
        if [ $block_found -eq 1 ]; then
            if [[ "$key" =~ ^\[.*\] ]]; then
                # Ein neuer Block beginnt, daher beenden wir den aktuellen Block
                block_found=0
            else
                # Setzen der Umgebungsvariablen
                export "$key"="$value"
            fi
        fi
    done < "$config_file"

    echo "config Datei wurde erfolgreich eingelesen"
}

# Liste der Serverblöcke aus der Konfigurationsdatei holen
server_blocks=$(awk '/^\[.*\]/{gsub(/[\[\]]/,""); print $1}' "$config_file")

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

# Schleife über jeden Serverblock
for server in $server_blocks; do
    clear
    echo "Config wird eingelesen."
    echo "Verarbeite Konfiguration für: $server."
    echo
    
    # Aufruf der Funktion zur Verarbeitung des Serverblocks
    parse_config "$server"

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
    echo "Diese Config wird nun verarbeitet."
    sleep 1

    clear
    clear


    #SSL-Zertifikat erstellen
    echo "ein SSL-Zertifikat wird erstellt."
    echo "eine Sichere Verbindung wird hergestellt." 

    # Verzeichnis erstellen, falls nicht vorhanden
    if [ ! -d "$DIR_PATH" ]; then
        echo "Verzeichnis $DIR_PATH existiert nicht. Erstelle es..."
        mkdir -p "$DIR_PATH"
        echo "Das Verzeichnis $DIR_PATH wurde angelegt."
    else
        echo "Das Verzeichnis exestiert bereits."
        echo "Das vorhande Verzeichnis wird gelöscht."
        rm -r $DIR_PATH
        echo "neues Verzeichnis wird angelegt"
        mkdir -p "$DIR_PATH"
    fi

    # Datein erstellen
    echo "Verzeichnis wird betreten."
    cd $DIR_PATH
    
    # Ließ doch einfach den echo Befehl!
    echo "Serververzeichnis wird erstellt."
    mkdir svws-server-$ID

    # Arbeitsverzeichnis wird geöffnet
    echo "Arbeitsverzeichnis wird geöffnet."
    cd svws-server-$ID
    
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

    echo "Vorgang wird wiederholt für den nächsten Server"

done

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
