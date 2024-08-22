#!/bin/bash

clear


# Alle Container auflisten, die den Namen "svws-server-" enthalten
containers=$(docker ps --filter "name=svws-server-" --format "{{.ID}} {{.Names}} {{.Image}}")

# Durch alle gefundenen Container iterieren
echo "$containers" | while read -r container_id container_name container_image; do
    # Port-Informationen für den aktuellen Container abrufen
    ports=$(docker port "$container_id")

    # Version aus dem Image-Tag extrahieren (angenommen, es ist im Tag enthalten)
    # Beispiel: svws-server:1.0.0 -> Version: 1.0.0
    image_version=$(echo "$container_image" | awk -F':' '{print $2}')

    # Ausgabe der Informationen
    echo "Container ID: $container_id"
    echo "Container Name: $container_name"
    echo "Image: $container_image"
    echo "Version: $image_version"
    echo "Ports: $ports"
    echo "-----------------------------"
done
