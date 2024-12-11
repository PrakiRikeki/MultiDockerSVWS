#!/bin/bash
clear

# Logging-Funktion
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to parse docker-compose.yml and extract port
parse_docker_compose() {
    local server_dir="$1"
    if [ -f "$server_dir/docker-compose.yml" ]; then
        # Verwende readpe für besseres Parsen der YAML-Datei
        local port=$(grep -E '^\s*ports:' -A 1 "$server_dir/docker-compose.yml" | grep -oE '[0-9]+:8443' | cut -d':' -f1)
        echo "$port"
    else
        echo "Error: docker-compose.yml not found in $server_dir" >&2
        return 1
    fi
}

#Erstell nun die config
parse_svws_config() {
    local server_dir="$1"
    local server_number="${server_dir#server_}"  # Extrahiert die Nummer aus dem Verzeichnisnamen
    local config_file="$server_dir/data/svwsconfig.json"
    
    if [ -f "$config_file" ]; then
        local db_info=$(grep '"location":' "$config_file" | tr -d '\n\r' | cut -d'"' -f4)
        local db_location=$(echo "$db_info" | cut -d':' -f1)
        local db_port=$(echo "$db_info" | cut -d':' -f2)
        local svws_user=$(grep '"PrivilegedDatabaseUser":' "$config_file" | tr -d '\n\r' | cut -d'"' -f4)
        
        local temp_file=$(mktemp)
        
        # Füge Kommentarzeile mit Server-ID hinzu
        echo "# Server $server_number" > "$temp_file"
        echo "Host Port=$port" >> "$temp_file"
        echo "Database Location=$db_location" >> "$temp_file"
        echo "Database Port=$db_port" >> "$temp_file"
        echo "SVWS User=$svws_user" >> "$temp_file"
        echo "" >> "$temp_file"
        
        # Extract and write school information with proper indentation
        local in_schema=false
        while IFS= read -r line; do
            if [[ $line =~ \"SchemaKonfiguration\" ]]; then
                in_schema=true
                continue
            fi
            if [ "$in_schema" = true ]; then
                if [[ $line =~ \"name\" ]]; then
                    echo "    name=$(echo "$line" | tr -d '\n\r' | cut -d'"' -f4)" >> "$temp_file"
                elif [[ $line =~ \"username\" ]]; then
                    echo "    user=$(echo "$line" | tr -d '\n\r' | cut -d'"' -f4)" >> "$temp_file"
                elif [[ $line =~ \"password\" ]]; then
                    echo "    pass=$(echo "$line" | tr -d '\n\r' | cut -d'"' -f4)" >> "$temp_file"
                    echo "" >> "$temp_file"
                fi
            fi
        done < "$config_file"
        
        echo "$temp_file"
    else
        echo "Error: svwsconfig.json not found in $server_dir/data" >&2
        return 1
    fi
}

# Main script anpassen
output_file="svws_docker.conf"

# Schreibe Header in die Datei
cat > "$output_file" << EOF
# Konfigurationsdatei für SVWS-Docker
# Jeder Server-Block beginnt mit einem Host Port

EOF


# Process each server directory
for server_dir in server_*; do
    if [ -d "$server_dir" ]; then
        # Get port from docker-compose.yml
        port=$(parse_docker_compose "$server_dir")
        
        # Process svwsconfig.json and append to output file
        temp_file=$(parse_svws_config "$server_dir")
        if [ -f "$temp_file" ]; then
            cat "$temp_file" >> "$output_file"
            rm "$temp_file"
        fi
    fi
done

log "conf Datei wurde erstellt: $output_file"
