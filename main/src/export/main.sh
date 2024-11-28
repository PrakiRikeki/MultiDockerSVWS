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
        # Extract port from docker-compose.yml using grep and cut
        local port=$(grep -E '^\s*-\s*"[0-9]+:' "$server_dir/docker-compose.yml" | cut -d'"' -f2 | cut -d':' -f1)
        echo "$port"
    else
        echo "Error: docker-compose.yml not found in $server_dir" >&2
        return 1
    fi
}

# Function to parse svwsconfig.json
parse_svws_config() {
    local server_dir="$1"
    local config_file="$server_dir/data/svwsconfig.json"
    
    if [ -f "$config_file" ]; then
        # Extract database location and port
        local db_info=$(grep '"location":' "$config_file" | cut -d'"' -f4)
        local db_location=$(echo "$db_info" | cut -d':' -f1)
        local db_port=$(echo "$db_info" | cut -d':' -f2)
        
        # Create temporary file for school information
        local temp_file=$(mktemp)
        
        # Write server information
        echo "Host Port=$port" > "$temp_file"
        echo "Database Location=$db_location" >> "$temp_file"
        echo "Database Port=$db_port" >> "$temp_file"
        
        # Extract and write school information
        grep -A 3 '"name":' "$config_file" | while read -r line; do
            if echo "$line" | grep -q '"name":'; then
                echo "    name=$(echo "$line" | cut -d'"' -f4)" >> "$temp_file"
            elif echo "$line" | grep -q '"username":'; then
                echo "    user=$(echo "$line" | cut -d'"' -f4)" >> "$temp_file"
            elif echo "$line" | grep -q '"password":'; then
                echo "    pass=$(echo "$line" | cut -d'"' -f4)" >> "$temp_file"
                echo "" >> "$temp_file"  # Add blank line between school entries
            fi
        done
        
        echo "$temp_file"
    else
        echo "Error: svwsconfig.json not found in $server_dir/data" >&2
        return 1
    fi
}

# Main script
output_file="svws_docker.conf"
> "$output_file"  # Clear or create output file

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