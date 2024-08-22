#!/bin/bash

clear

echo "Updates werden runtergeladen"
sudo docker pull svwsnrw/svws-server:latest
clear

echo "Updates werden runtergeladen"




# Basisverzeichnis, das die docker-compose.yml-Dateien enthält
BASE_DIR="server"

# Durchlaufe alle Unterordner im Basisverzeichnis
for dir in "$BASE_DIR"/*; do
    if [ -d "$dir" ]; then
        echo "Verarbeite Verzeichnis: $dir"

        # Docker-Compose Befehl zur Auflistung der Container-IDs und Namen
        container_ids=$(docker-compose -f "$dir/docker-compose.yml" ps -q)
        container_names=$(docker-compose -f "$dir/docker-compose.yml" ps -q | xargs -r docker inspect --format '{{.Name}}' | sed 's/^.\{1\}//')

        if [ -z "$container_ids" ]; then
            echo "  Keine laufenden Container gefunden."
            continue
        fi

        echo "  Gefundene Container-IDs:"
        echo "$container_ids"

        # Stoppen und Entfernen der Container
        for container_id in $container_ids; do
            echo "    Stoppe Container: $container_id"
            sudo docker stop "$container_id"
            echo "    Entferne Container: $container_id"
            sudo docker rm "$container_id"
            echo "    Starte Contaner: $container_id" 
            docker compose "$dir/docker-compose.yml" up -d 
        done
        
        echo "  Gefundene Container-Namen:"
        echo "$container_names"

        for container_name in $container_names; do
            # Container-Namen müssen möglicherweise für das Entfernen in IDs konvertiert werden
            container_id=$(docker ps -q -f name="$container_name")
            if [ -n "$container_id" ]; then
                echo "    Stoppe Container: $container_name"
                sudo docker stop "$container_id"
                echo "    Entferne Container: $container_name"
                sudo docker rm "$container_id"
            fi
        done
    fi
done
