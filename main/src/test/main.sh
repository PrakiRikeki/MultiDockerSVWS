#!/bin/bash

# Funktion zum Überprüfen der Argumente
check_arguments() {
    if [ $# -lt 2 ]; then
        echo "Verwendung: $0 input.conf output.json"
        echo "Beispiel: $0 config.conf svwsconfig.json"
        exit 1
    fi
}

# Funktion zum Lesen der Server-Konfiguration
read_server_config() {
    local config_file="$1"
    # Initialisiere Variablen mit Standardwerten
    SVWS_TLS_KEYSTORE_PASSWORD="test123"
    SVWS_HOST_IP="localhost"
    SVWS_HOST_PORT="8443"
    
    # Lese Server-Sektion
    while IFS='=' read -r key value; do
        # Entferne führende und nachfolgende Leerzeichen
        key=$(echo "$key" | tr -d '[:space:]')
        value=$(echo "$value" | tr -d '[:space:]')
        
        case "$key" in
            "SVWS_TLS_KEYSTORE_PASSWORD") SVWS_TLS_KEYSTORE_PASSWORD="$value" ;;
            "SVWS_HOST_IP") SVWS_HOST_IP="$value" ;;
            "SVWS_HOST_PORT") SVWS_HOST_PORT="$value" ;;
        esac
    done < <(sed -n '/^\[server\]/,/^\[/p' "$config_file" | grep -v '^\[')
}

# Funktion zum Lesen der Schul-Konfigurationen
read_school_configs() {
    local config_file="$1"
    local section_content=""
    local in_school_section=false
    declare -ag names=()
    declare -ag usernames=()
    declare -ag passwords=()

    while IFS= read -r line; do
        # Überspringe leere Zeilen
        [[ -z "$line" ]] && continue
        
        # Neue Schul-Sektion gefunden
        if [[ "$line" =~ ^\[schule ]]; then
            in_school_section=true
            continue
        fi
        
        # Andere Sektion gefunden
        if [[ "$line" =~ ^\[ && ! "$line" =~ ^\[schule ]]; then
            in_school_section=false
            continue
        fi
        
        # Wenn wir in einer Schul-Sektion sind, verarbeite die Daten
        if $in_school_section; then
            if [[ "$line" =~ ^name= ]]; then
                names+=("${line#name=}")
            elif [[ "$line" =~ ^username= ]]; then
                usernames+=("${line#username=}")
            elif [[ "$line" =~ ^password= ]]; then
                passwords+=("${line#password=}")
            fi
        fi
    done < "$config_file"
}

# Funktion zum Schreiben des Kopfteils
write_header() {
    local output_file="$1"
    
    cat << EOF > "$output_file"
{
  "EnableClientProtection" : null,
  "DisableDBRootAccess" : null,
  "DisableAutoUpdates" : null,
  "DisableTLS" : null,
  "PortHTTP" : null,
  "UseHTTPDefaultv11" : null,
  "PortHTTPS" : 8443,
  "PortHTTPPrivilegedAccess" : null,
  "UseCORSHeader" : false,
  "TempPath" : "tmp",
  "TLSKeyAlias" : null,
  "TLSKeystorePath" : "/etc/app/svws/conf/keystore",
  "TLSKeystorePassword" : "${SVWS_TLS_KEYSTORE_PASSWORD}",
  "ClientPath" : "./client",
  "AdminClientPath" : "./adminclient",
  "LoggingEnabled" : true,
  "LoggingPath" : "logs",
  "ServerMode" : "stable",
  "PrivilegedDatabaseUser" : "ZentralSchemaAdmin",
  "DBKonfiguration" : {
    "dbms" : "MARIA_DB",
    "location" : "${SVWS_HOST_IP}:3306",
    "defaultschema" : "",
    "SchemaKonfiguration" : [
EOF
}

# Funktion zum Schreiben eines Eintrags
write_entry() {
    local output_file="$1"
    local name="$2"
    local username="$3"
    local password="$4"
    local is_last="$5"
    
    if [ "$is_last" = "true" ]; then
        # Letzter Eintrag ohne Komma
        cat << EOF >> "$output_file"
      {
        "name" : "$name",
        "svwslogin" : false,
        "username" : "$username",
        "password" : "$password"
      }
EOF
    else
        # Normale Einträge mit Komma
        cat << EOF >> "$output_file"
      {
        "name" : "$name",
        "svwslogin" : false,
        "username" : "$username",
        "password" : "$password"
      },
EOF
    fi
}

# Funktion zum Schreiben des Fußteils
write_footer() {
    local output_file="$1"
    cat << EOF >> "$output_file"
    ],
    "connectionRetries" : 0,
    "retryTimeout" : 0
  }
}
EOF
}

# Hauptprogramm
main() {
    local input_file="$1"
    local output_file="$2"
    
    # Server-Konfiguration lesen
    read_server_config "$input_file"
    
    # Schul-Konfigurationen lesen
    read_school_configs "$input_file"
    
    # Kopfteil schreiben
    write_header "$output_file"
    
    # Einträge schreiben
    local total_entries=${#names[@]}
    for (( i=0; i<$total_entries; i++ )); do
        if [ $i -eq $(($total_entries - 1)) ]; then
            # Letzter Eintrag
            write_entry "$output_file" "${names[$i]}" "${usernames[$i]}" "${passwords[$i]}" "true"
        else
            # Normale Einträge
            write_entry "$output_file" "${names[$i]}" "${usernames[$i]}" "${passwords[$i]}" "false"
        fi
    done
    
    # Fußteil schreiben
    write_footer "$output_file"
    
    echo "Konfigurationsdatei wurde erfolgreich erstellt: $output_file"
}

# Argumente überprüfen und Hauptprogramm starten
check_arguments "$@"
main "$1" "$2"