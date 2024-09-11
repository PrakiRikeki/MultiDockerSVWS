#!/bin/bash
clear

echo "In den folgenden Schritten werden Docker und andere Komponenten installiert,"
echo "sodass das Erstellen und Starten eines oder mehrerer SVWS-Server möglich ist."

sleep 2

# Überprüfen, ob das Skript als Root ausgeführt wird
if [ "$(id -u)" -ne 0 ]; then
    echo "Dieses Skript muss als Root ausgeführt werden." 1>&2
    # Kurze Pause, damit der Benutzer die Nachricht sehen kann
    read -n 1 -s -r -p "Drücke irgendeine Taste um fortzufahren..."
    exit 1
fi

# Überprüfen, ob die Konfigurationsdatei existiert
config_file="svws_docker_config.txt"
if [ ! -f "$config_file" ]; then
    echo 'Die Datei "svws_docker_config.txt" wurde nicht gefunden.'
    echo 'Bitte erstelle Sie diese.'
    # Kurze Pause, damit der Benutzer die Nachricht sehen kann
    read -n 1 -s -r -p "Drücke irgendeine Taste um fortzufahren..."
    break
fi



# Kurze Pause, damit der Benutzer die Nachricht sehen kann
read -n 1 -s -r -p "Drücke irgendeine Taste um fortzufahren..."


# Funktion zum Einlesen der Konfigurationsdatei
parse_config() {
    local server_block="$1"
    local config_file="svws_docker_config.txt"
    local block_found=0
    local line

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
}

# Überprüfen, ob die Konfigurationsdatei existiert
config_file="svws_docker_config.txt"
if [[ ! -f "$config_file" ]]; then
    echo "Fehler: Die Konfigurationsdatei '$config_file' wurde nicht gefunden."
    break
fi

# Liste der Serverblöcke aus der Konfigurationsdatei holen
server_blocks=$(awk '/^\[.*\]/{gsub(/[\[\]]/,""); print $1}' "$config_file")

    # Docker wird installiert
    echo "Docker wird installiert"

    sudo apt update
    sudo apt install docker.io docker-compose-v2 nano default-jdk && docker --version

    clear

    echo "Docker wird installiert"


        # Benutzerabfrage, ob das Skript fortgesetzt werden soll
    read -p "Wollen Sie fortfahren? [Yn] " response
    response=${response:-y}

    if [[ $response == "n" || $response == "N" ]]; then
      echo "Abbruch..."
      sleep 1
      break
    fi

# Schleife über jeden Serverblock
for server in $server_blocks; do
    clear
    echo "Verarbeite Konfiguration für: $server"
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

    sleep 1

    clear
    clear


    #SSL-Zertifikat erstellen
    echo "SSL-Zertifikat wird erstellt"

    # Verzeichnis erstellen, falls nicht vorhanden
    if [ ! -d "$DIR_PATH" ]; then
        echo "Verzeichnis $DIR_PATH existiert nicht. Erstelle es..."
        mkdir -p "$DIR_PATH"
    fi

    # Datein erstellen
    echo "Dateien werden erstellt in $DIR_PATH"


    cd $DIR_PATH && mkdir svws-server-$ID && cd svws-server-$ID && touch docker-compose.yml && touch .env

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


    # Keystore erstellen
    echo "Keystore wird erstellt"
    echo
    sleep 1

    mkdir keystore
    keytool -genkeypair -alias $SVWS_TLS_KEY_ALIAS -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore keystore/keystore -validity 365 -storepass $SVWS_TLS_KEYSTORE_PASSWORD -keypass $SVWS_TLS_KEYSTORE_PASSWORD -dname "CN=localhost, OU=IT, O=MyCompany, L=City, ST=State, C=Country"


    # Container starten
    echo
    echo "Container wird gestartet"

    sleep 3

    clear

    docker compose up -d

    clear

    # Zurück ins Haupt Verzeichnis
    cd ..
    cd ..

    # So sieht dein System jetzt aus
    echo "########################"
    echo "Der SVWS-Server $server läuft!"
    echo
    echo "Der soeben aufgesetzte Server hat die ID  $ID"
    docker ps | grep svws-server-$ID
    echo "########################"
    echo
    echo

    sleep 5

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
