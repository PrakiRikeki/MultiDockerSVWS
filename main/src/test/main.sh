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

# Root-Überprüfung
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error_exit "Dieses Skript muss als Root ausgeführt werden."
    fi
    log "Root-Berechtigungen bestätigt"
}

# Konfigurationsdatei überprüfen
check_config() {
    local config_file="$1"
    if [ ! -f "$config_file" ]; then
        error_exit "Die Datei '$config_file' wurde nicht gefunden."
    fi
    log "Konfigurationsdatei gefunden: $config_file"
}

# Abhängigkeiten installieren
install_dependencies() {
    log "Installiere benötigte Pakete..."
    apt update >/dev/null 2>&1 || error_exit "Apt update fehlgeschlagen"
    apt install -y docker.io unzip zip docker-compose-v2 nano default-jdk >/dev/null 2>&1 || error_exit "Installation der Abhängigkeiten fehlgeschlagen"
    
    # Docker Version prüfen
    docker --version >/dev/null 2>&1 || error_exit "Docker Installation fehlgeschlagen"
    log "Alle Abhängigkeiten erfolgreich installiert"
}

# Funktion zum Einlesen und Anzeigen der Konfigurationsdatei
parse_config() {
    local config_file="$1"
    local incomplete_containers=0
    local container_count=0
    local valid_container_count=0

    local current_host_port=""
    local current_db_location=""
    local current_db_port=""
    declare -a schools=()
    local current_school_name=""
    local current_school_user=""
    local current_school_pass=""

    log "Config-Datei wird eingelesen: $config_file"
    echo ""

    # Funktion zum Ausgeben eines Containers
    print_container() {
        if [ -n "$current_host_port" ] && [ -n "$current_db_location" ] && [ -n "$current_db_port" ] && [ ${#schools[@]} -gt 0 ]; then
            ((valid_container_count++))
            echo "Docker Container $valid_container_count:"
            echo "  Host Port = $current_host_port"
            echo "  Database Location = $current_db_location"
            echo "  Database Port = $current_db_port"
            echo "  Schulen:"
            
            echo "  +-----+----------------------+------------------+------------------+"
            echo "  | Nr  | Name                 | User             | Pass             |"
            echo "  +-----+----------------------+------------------+------------------+"
            
            counter=1
            for ((i=0; i<${#schools[@]}; i+=3)); do
                if [ -n "${schools[i]}" ] && [ -n "${schools[i+1]}" ] && [ -n "${schools[i+2]}" ]; then
                    printf "  | %-3d | %-20s | %-16s | %-16s |\n" "$counter" "${schools[i]}" "${schools[i+1]}" "${schools[i+2]}"
                    ((counter++))
                fi
            done
            
            echo "  +-----+----------------------+------------------+------------------+"
            echo ""

            # Container aufsetzen
            setup_container "$current_host_port" "$current_db_location" "$current_db_port" "$valid_container_count" "${schools[@]}"
        else
            ((incomplete_containers++))
        fi
    }


    while IFS= read -r line || [ -n "$line" ]; do
        if [[ -z "$line" || "$line" =~ ^[[:space:]]*// ]]; then
            continue
        fi

        line=$(echo "$line" | sed 's|//.*||')
        
        if [[ "$line" =~ ^[[:space:]]*([^=]+)=([[:space:]]*.*)$ ]]; then
            key=$(echo "${BASH_REMATCH[1]}" | xargs)
            value=$(echo "${BASH_REMATCH[2]}" | xargs)

            case "$key" in
                "Host Port")
                    if [ -n "$current_host_port" ]; then
                        print_container
                        schools=()
                    fi
                    ((container_count++))
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
                "name")
                    if [ -n "$current_school_name" ] && [ -n "$current_school_user" ] && [ -n "$current_school_pass" ]; then
                        schools+=("$current_school_name" "$current_school_user" "$current_school_pass")
                    fi
                    current_school_name="$value"
                    current_school_user=""
                    current_school_pass=""
                    ;;
                "user")
                    current_school_user="$value"
                    ;;
                "pass")
                    current_school_pass="$value"
                    if [ -n "$current_school_name" ] && [ -n "$current_school_user" ] && [ -n "$current_school_pass" ]; then
                        schools+=("$current_school_name" "$current_school_user" "$current_school_pass")
                        current_school_name=""
                        current_school_user=""
                        current_school_pass=""
                    fi
                    ;;
            esac
        fi
    done < "$config_file"

    # Letzten Container ausgeben
    print_container


    log "Config-Datei erfolgreich verarbeitet."
    if [ $incomplete_containers -gt 0 ]; then
        log "Hinweis: $incomplete_containers von $container_count Container-Blöcke konnten nicht verarbeitet werden (unvollständige Konfiguration)."
    fi
    
    return 0
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

# SVWS-Config erstellen
create_svws_config() {
    local container_data="$1"
    local output_file="$2"
    shift 2
    local schools=("$@")
    
    # Basis-Config erstellen
    cat > "$output_file" <<EOF
{
    "server": {
        "host": "0.0.0.0",
        "port": 8443,
        "context": "/",
        "keystore": {
            "path": "/etc/app/svws/conf/keystore",
            "password": "${SVWS_TLS_KEYSTORE_PASSWORD}",
            "alias": "${SVWS_TLS_KEY_ALIAS}"
        }
    },
    "database": {
        "host": "${MariaDB_HOST}",
        "port": ${MariaDB_PORT:-3306},
        "name": "${MariaDB_DATABASE}",
        "user": "${MariaDB_USER}",
        "password": "${MariaDB_PASSWORD}"
    },
    "schools": [
EOF

    # Schulen hinzufügen
    local first=true
    for ((i=0; i<${#schools[@]}; i+=3)); do
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$output_file"
        fi
        create_school_config "${schools[i]}" "${schools[i+1]}" "${schools[i+2]}" >> "$output_file"
    done

    # Config abschließen
    echo "]}" >> "$output_file"
    
    log "SVWS-Config erstellt: $output_file"
}

# Container Setup
setup_container() {
    local host_port="$1"
    local db_location="$2"
    local db_port="$3"
    local container_id="$4"
    shift 4
    local schools=("$@")
    
    local container_dir="server_$container_id"
    

    # Benutzerabfrage einfügen
    if [[ -t 0 ]]; then
        read -p "Wollen Sie fortfahren? [Yn] " response
    else
        echo "Nicht-interaktive Shell erkannt. Standardwert wird verwendet: 'y'"
        response="y"
    fi



    log "Setze Container $container_id auf..."
    
    # Verzeichnisstruktur erstellen
    mkdir -p "$container_dir"/{data,keystore}
    cd "$container_dir" >/dev/null 2>&1 || error_exit "Konnte nicht in Container-Verzeichnis wechseln"
    
    
    if [ ! -f "linux-installer-1.0.1.tar.gz" ]; then
        DOWNLOAD_PFAD=https://github.com/SVWS-NRW/SVWS-Server/releases/download/v1.0.1/linux-installer-1.0.1.tar.gz 
    fi


    # SVWS laden und auspacken
    echo "Lade SVWS ..."

    # Wenn DOWNLOAD_PFAD gesetzt ist, lade Datei herunter
    if [ ! -z "$DOWNLOAD_PFAD" ]; then
    echo "Lade Datei herunter von $DOWNLOAD_PFAD..."
    wget $DOWNLOAD_PFAD >/dev/null 2>&1 || error_exit "Herrunterladen fehlgeschlagen"
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
    unzip -d ./data/client ./svws/app/SVWS-Client*.zip

    # Lösche die entpackte Client-Datei
    rm -rf ./data/app/SVWS-Client*.zip

    # Entpacke den Admin-Client in das Admin-Client-Verzeichnis
    unzip -d ./data/adminclient ./svws/app/SVWS-Admin-Client*.zip

    # Lösche die entpackte Admin-Client-Datei
    rm -rf ./data/app/SVWS-Admin-Client*.zip

    # Erstelle Service-Datei und kopiere sie in das System-Verzeichnis
    envsubst < ./svws/svws-template.service > ./svws/svws.service
    cp ./svws/svws.service /etc/systemd/system/


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
    shift 3
    local schools=("$@")
    
    local config_file="data/svwsconfig.json"
    
    
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
  "DBKonfiguration": {
    "dbms": "MARIA_DB",
    "location": "${db_location}:${db_port}",
    "defaultschema": "",
    "SchemaKonfiguration": [
EOF

    # Schulen hinzufügen
    local first=true
    for ((i=0; i<${#schools[@]}; i+=3)); do
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$config_file"
        fi
        cat >> "$config_file" << EOF
      {
        "name": "${schools[i]}",
        "svwslogin": false,
        "username": "${schools[i+1]}",
        "password": "${schools[i+2]}"
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
create_svws_config "$container_id" "$db_location" "$db_port" "${schools[@]}"



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
}

# Hauptfunktion
main() {
    check_root
    check_config "svws_docker.conf"
    install_dependencies
    parse_config "svws_docker.conf"
}

# Skript ausführen
main "$@"

ls