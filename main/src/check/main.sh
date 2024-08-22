#!/bin/bash

clear

# Basisverzeichnis, das die Unterordner enthält
BASE_DIR="server"
# Durchlaufe alle Unterordner im Basisverzeichnis
for dir in "$BASE_DIR"/*; do
    if [ -d "$dir" ]; then

        echo "Verarbeite Verzeichnis: $dir"

        # Überprüfen, ob eine docker-compose.yml existiert
        compose_file="$dir/docker-compose.yml"
        if [ -f "$compose_file" ]; then
            echo "  Gefunden: docker-compose.yml"

            nummers=19
            svwsID="svws-${dir:$nummers}"

            # Container-Name abrufen (ersetzen Sie 'my-service' durch den tatsächlichen Namen)
            container_id=$(docker-compose -f "$compose_file" ps -q $svwsID)

            # Überprüfen, ob Container-ID existiert
            if [ -z "$container_id" ]; then
                echo "    Kein laufender Container gefunden für Service 'egal'."
                continue
            fi

            # Umgebungsvariable SVWS_HOST_IP aus dem Container abrufen
            server_host=$(docker inspect --format '{{range .Config.Env}}{{println .}}{{end}}' "$container_id" | grep 'SVWS_HOST_IP' | awk -F '=' '{print $2}')

            # Überprüfen, ob SVWS_HOST_IP gesetzt ist
            if [ -z "$server_host" ]; then
                echo "    SVWS_HOST_IP Umgebungsvariable nicht gefunden."
                continue
            fi

            # Ping-Test durchführen
            ping_result=$(ping -c 10 "$server_host")

            # Formatierte Ausgabe des Ping-Tests
            echo "    Ping-Test für $server_host:"
            echo "$ping_result"
            
            # Optional: Zusammenfassung der Round-Trip-Zeiten
            echo "    Zusammenfassung:"
            echo "$ping_result" | grep 'rtt min/avg/max/mdev'

            echo 
            echo
        else
            ls
            echo "  Keine docker-compose.yml gefunden im Verzeichnis."
        fi
    fi
done





echo
echo
read -n 1 -s -r -p "Drücke irgendeine Taste um fortzufahren..."



