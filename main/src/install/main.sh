#!/bin/bash
clear

# Logging-Funktion
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

error_exit() {
    log "ERROR: $1" >&2
    read -n 1 -s -r -p "Drücke eine Taste zum Beenden..."
    exit 1
}

. $DIR_INSTALL/check.sh

# Abhängigkeiten installieren
install_dependencies() {
    log "Installiere benötigte Pakete..."
    apt update >/dev/null 2>&1 || error_exit "Apt update fehlgeschlagen"
    apt install -y docker.io zip docker-compose-v2 nano default-jdk >/dev/null 2>&1 || error_exit "Installation der Abhängigkeiten fehlgeschlagen"
    
    # Docker Version prüfen
    docker --version >/dev/null 2>&1 || error_exit "Docker Installation fehlgeschlagen"
    log "Alle Abhängigkeiten erfolgreich installiert"
}

parse_config() {
    local config_file="$1"
    local version="$2"
    local incomplete_containers=0
    local container_count=0
    local current_host_port=""
    local current_db_location=""
    local current_db_port=""
    local current_svws_user=""
    local schools=()
    local current_school_name=""
    local current_school_user=""
    local current_school_pass=""
    local is_valid_container=1

    while IFS= read -r line || [ -n "$line" ]; do
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        if [[ "$line" =~ ^[[:space:]]*([^=]+)=(.*)$ ]]; then
            key=$(echo "${BASH_REMATCH[1]}" | xargs)
            value=$(echo "${BASH_REMATCH[2]}" | xargs)
            case "$key" in
                "Host Port")
                    if [ -n "$current_host_port" ]; then
                        if [ "$is_valid_container" -eq 1 ]; then
                            ((container_count++))
                            print_container "$container_count" "$current_host_port" "$current_db_location" "$current_db_port" "$current_svws_user" "${schools[@]}"
                            setup_container "$current_host_port" "$current_db_location" "$current_db_port" "$current_svws_user" "$container_count" "$version" "${schools[@]}"
                        else
                            ((incomplete_containers++))
                        fi
                        schools=()
                        is_valid_container=1
                    fi
                    current_host_port="$value"
                    ;;
                "Database Location")
                    current_db_location="$value"
                    ;;
                "Database Port")
                    current_db_port="$value"
                    ;;
                "SVWS User")
                    current_svws_user="$value"
                    ;;
                "name")
                    current_school_name="$value"
                    if [ -z "$value" ]; then
                        is_valid_container=0
                    fi
                    ;;
                "user")
                    current_school_user="$value"
                    if [ -z "$value" ]; then
                        is_valid_container=0
                    fi
                    ;;
                "pass")
                    current_school_pass="$value"
                    if [ -z "$value" ]; then
                        is_valid_container=0
                    fi
                    if [ -n "$current_school_name" ] && [ -n "$current_school_user" ] && [ -n "$current_school_pass" ]; then
                        schools+=("$current_school_name" "$current_school_user" "$current_school_pass")
                        current_school_name=""
                        current_school_user=""
                        current_school_pass=""
                    fi
                    ;;
                *)
                    echo "Unbekannter Parameter: $key"
                    ;;
            esac
        fi
    done < "$config_file"

    # Process the last container
    if [ -n "$current_host_port" ]; then
        if [ "$is_valid_container" -eq 1 ]; then
            ((container_count++))
            print_container "$container_count" "$current_host_port" "$current_db_location" "$current_db_port" "$current_svws_user" "${schools[@]}"
            setup_container "$current_host_port" "$current_db_location" "$current_db_port" "$current_svws_user" "$container_count" "$version" "${schools[@]}"
        else
            ((incomplete_containers++))
        fi
    fi

    echo "Es wurden $container_count Server aufgesetzt und gestartet. Dabei sind $incomplete_containers fehlerhaft."
}


print_container() {
    local container_number="$1"
    local host_port="$2"
    local db_location="$3"
    local db_port="$4"
    local svws_user="$5"
    shift 5
    local schools=("$@")
    
    echo ""
    echo "Docker Container $container_number:"
    echo " Host Port          = $host_port"
    echo " Database Location  = $db_location"
    echo " Database Port      = $db_port"
    echo " SVWS User          = $svws_user"
    echo " Schulen:"
    
    # Tabellenüberschrift
    printf "  +-----+----------------------+------------------+------------------+\n"
    printf "  | %-3s | %-20s | %-16s | %-16s |\n" "Nr" "Name" "User" "Pass"
    printf "  +-----+----------------------+------------------+------------------+\n"
    
    # Schuleinträge
    local count=1
    for ((i=0; i<${#schools[@]}; i+=3)); do
        printf "  | %-3d | %-20s | %-16s | %-16s |\n" \
            "$count" \
            "${schools[i]}" \
            "${schools[i+1]}" \
            "${schools[i+2]}"
        ((count++))
    done
    
    # Tabellenende
    printf "  +-----+----------------------+------------------+------------------+\n"
}


# SVWS-Config für eine Schule erstellen
create_school_config() {
    local name="$1"
    local user="$2"
    local pass="$3"
    
    cat <<EOF
    {
      "name": "$name",
      "user": "$user",-
      "pass": "$pass"
    }
EOF
}


# Funktion zum Abrufen der neuesten Version von GitHub
get_latest_version() {
    latest_version=$(curl -s https://api.github.com/repos/SVWS-NRW/SVWS-Server/releases/latest | grep -o '"tag_name": "v[^"]*"' | cut -d'"' -f4 | sed 's/v//')

    if [ -z "$latest_version" ]; then
        log "FEHLER: Konnte die neueste Version nicht abrufen. Fallback auf Version 1.0.1."
        latest_version="1.0.1"  # Fallback-Wert
    fi
    echo "$latest_version"
}

# Funktion zum Überprüfen, ob eine Version existiert
check_version_exists() {
    local version=$1
    http_code=$(curl -s -o /dev/null -w "%{http_code}" "https://github.com/SVWS-NRW/SVWS-Server/releases/tag/v${version}")

    if [ "$http_code" -eq 200 ]; then
        return 0  # Version existiert
    else
        return 1  # Version existiert nicht
    fi
}

# Hauptfunktion zur Versionsauswahl
welcheVersion() {
    # Hole die neueste Version
    local latest_version
    latest_version=$(get_latest_version)

    # Benutzer nach der gewünschten Version fragen
    log "Die neueste verfügbare Version ist: $latest_version"
    read -p "Welche SVWS-Server Version möchten Sie verwenden? [$latest_version] " version
    version=${version:-$latest_version}  # Fall-back auf die neueste Version

    # Überprüfen, ob die gewählte Version existiert
    if ! check_version_exists "$version"; then
        log "FEHLER: Die Version v$version existiert nicht auf GitHub! Automatisch wird v$latest_version verwendet."
        version="$latest_version"
    fi

    log "Verwende Version v$version..."
    echo "$version"

    export VERSION="$version"

}

# Container-Setup
setup_container() {
    local host_port="$1"
    local db_location="$2"
    local db_port="$3"
    local svws_user="$4"
    local container_id="$5"
    local version="$6"
    
    # Erstelle einen eindeutigen Container-Namen
    local container_name="svws_server_${container_id}"

    # Erstelle Verzeichnis mit Container-ID statt SVWS User
    mkdir -p "server_${container_id}"
    cd "server_${container_id}"

    echo

    log "Setze Container $container_id auf..."
    
    # Verzeichnisstruktur erstellen
    mkdir -p "$container_dir"/{data,keystore}
    cd "$container_dir" >/dev/null 2>&1 || error_exit "Konnte nicht in Container-Verzeichnis wechseln"

    # SVWS laden und auspacken
    if [ ! -f "linux-installer-$VERSION.tar.gz" ]; then
        DOWNLOAD_PFAD="https://github.com/SVWS-NRW/SVWS-Server/releases/download/v$VERSION/linux-installer-$VERSION.tar.gz"
    fi

    log "Lade Datei herunter von $DOWNLOAD_PFAD..."
    wget "$DOWNLOAD_PFAD" -O "linux-installer-$VERSION.tar.gz" >/dev/null 2>&1 || error_exit "Herunterladen fehlgeschlagen"
    log "Herunterladen abgeschlossen."

    # Entpacken der Installationsdatei
    tar xzf "linux-installer-$VERSION.tar.gz" >/dev/null 2>&1 || error_exit "Entpacken der Installationsdatei fehlgeschlagen."

    # Erstelle Verzeichnisse
    mkdir -p ./data
    mkdir ./data/client
    mkdir ./data/adminclient
    mkdir ./data/conf
    mkdir ./keystore

    # Kopiere App, Konfigurationen und Zertifikate
    cp -r ./svws/app/* ./data

    # Entpacke den Client in das Client-Verzeichnis
    unzip -d ./data/client ./svws/app/SVWS-Client*.zip >/dev/null 2>&1 || error_exit "Entpacken des Client in das Client-Verzeichnis fehlgeschlagen"

    # Lösche die entpackte Client-Datei
    rm -rf ./data/app/SVWS-Client*.zip

    # Entpacke den Admin-Client in das Admin-Client-Verzeichnis
    unzip -d ./data/adminclient ./svws/app/SVWS-Admin-Client*.zip >/dev/null 2>&1 || error_exit "Entpacken des Admin in das Admin-Verzeichnis fehlgeschlagen"

    # Lösche die entpackte Admin-Client-Datei
    rm -rf ./data/app/SVWS-Admin-Client*.zip svws init-scripts

    # Standard-Werte setzen
    local mariadb_host="${db_location:-localhost}"
    local mariadb_port="${db_port:-3306}"
    local mariadb_database="svws_$container_id"
    local mariadb_user="svws_user_$container_id"
    local mariadb_password="${MariaDB_PASSWORD:-$(openssl rand -base64 12)}"
    local keystore_password="${SVWS_TLS_KEYSTORE_PASSWORD:-$(openssl rand -base64 12)}"
    local key_alias="svws_$container_id"

    # Erstelle den Inhalt der startup.sh
        cat > "./data/startup.sh" << 'EOL'
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
        chmod +x "./data/startup.sh"

    

    # Funktion zum Erstellen der SVWS-Konfiguration
create_svws_config() {
    local container_id="$1"
    local db_location="$2"
    local db_port="$3"
    local svws_user="$4"
    shift 4
    local schools=("$@") 
    local config_file="data/svwsconfig.json"
    
    # Entferne mögliche Zeilenumbrüche aus den Variablen
    db_location=$(echo "$db_location" | tr -d '\n\r')
    db_port=$(echo "$db_port" | tr -d '\n\r')
    svws_user=$(echo "$svws_user" | tr -d '\n\r')
    
    # Header
    cat > "$config_file" << EOF
{
  "EnableClientProtection": false,
  "DisableDBRootAccess": false,
  "DisableAutoUpdates": false,
  "DisableTLS": false,
  "PortHTTPS": 8443,
  "TLSKeystorePath": "/etc/app/svws/conf/keystore",
  "TLSKeystorePassword": "${keystore_password}",
  "ClientPath": "./client",
  "AdminClientPath": "./adminclient",
  "LoggingEnabled": true,
  "LoggingPath": "logs",
  "ServerMode": "stable",
  "PrivilegedDatabaseUser": "${svws_user}",
  "DBKonfiguration": {
    "dbms": "MARIA_DB",
    "location": "${db_location}:${db_port}",
    "defaultschema": "",
    "SchemaKonfiguration": [
EOF

    # Schulen hinzufügen
    local first=true
    for ((i=0; i<${#schools[@]}; i+=3)); do
        # Extrahiere nur den Schulnamen ohne user und pass
        local school_name=$(echo "${schools[i]}" | cut -d' ' -f1 | tr -d '\n\r')
        local school_user=$(echo "${schools[i+1]}" | tr -d '\n\r')
        local school_pass=$(echo "${schools[i+2]}" | tr -d '\n\r')
        
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$config_file"
        fi
        cat >> "$config_file" << EOF
      {
        "name": "${school_name}",
        "svwslogin": false,
        "username": "${school_user}",
        "password": "${school_pass}"
      }
EOF
    done

    # Footer
    cat >> "$config_file" << EOF
    ],
    "connectionRetries": 3,
    "retryTimeout": 5000
  }
}
EOF
}


# In der setup_container Funktion vor dem Docker Compose Start einfügen:
create_svws_config "$container_id" "$db_location" "$db_port" "$svws_user" "${schools[@]}"


remove_newlines() {
    echo "$1" | tr -d '\n\r'
}
host_port=$(remove_newlines "$host_port")

    # Docker-Compose erstellen
    cat > docker-compose.yml <<EOF
services:
  svws-server-$container_id:
    image: svwsnrw/svws-server:latest
    container_name: svws-server-$container_id
    restart: always
    ports:
      - "${host_port:-8443}:8443"
    environment:
      - MariaDB_HOST=$mariadb_host
      - MariaDB_PORT=$mariadb_port
      - MariaDB_DATABASE=$mariadb_database
      - MariaDB_USER=$mariadb_user
      - MariaDB_PASSWORD=$mariadb_password
      - SVWS_TLS_KEYSTORE_PASSWORD=$keystore_password
      - SVWS_TLS_KEY_ALIAS=$key_alias
    volumes:
      - ./data:/opt/app/svws
      - ./keystore:/etc/app/svws/conf/keystore
EOF

    # Keystore erstellen
    keytool -genkeypair \
        -alias "$key_alias" \
        -keyalg RSA \
        -keysize 2048 \
        -storetype PKCS12 \
        -keystore keystore/keystore \
        -validity 365 \
        -storepass "$keystore_password" \
        -keypass "$keystore_password" \
        -dname "CN=localhost, OU=SVWS, O=School, L=City, ST=State, C=DE" >/dev/null 2>&1 || \
        error_exit "Keystore-Erstellung fehlgeschlagen"

    # Container starten
    docker compose up -d >/dev/null 2>&1 || error_exit "Container-Start fehlgeschlagen"
    
    log "Container $container_id erfolgreich gestartet"

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

    cd ..
    return 0
}

# Hauptfunktion
main() {
    check_root
    check_config "svws_docker.conf"
    install_dependencies
    welcheVersion
    parse_config "svws_docker.conf"
}

# Skript ausführen
main "$@"