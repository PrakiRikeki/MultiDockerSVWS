#!/bin/bash
clear

# Logging-Funktion
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "=== SVWS Server Löschen ==="
log "Suche nach Server-Instanzen..."

# Finde alle Ordner die mit server_ beginnen und eine Zahl enthalten
server_dirs=$(find . -maxdepth 1 -type d -name "server_*" | grep "server_[0-9]")
server_count=$(echo "$server_dirs" | grep -c "^")

# Finde alle laufenden Docker Container mit dem Präfix svws-server-
docker_containers=$(docker ps -a --format '{{.Names}}' | grep "svws-server-")
container_count=$(echo "$docker_containers" | grep -c "^")

# Wenn keine Instanzen gefunden wurden
if [ $server_count -eq 0 ] && [ $container_count -eq 0 ]; then
    log "Keine Server-Instanzen oder Docker Container gefunden."
    exit 0
fi

log "Gefundene Server-Verzeichnisse:"
log "$server_dirs"
log "Gefundene Docker Container:"
if [ -n "$docker_containers" ]; then
    docker ps -a --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' | grep "svws-server-"
else
    log "Keine Docker Container gefunden."
fi

# Sicherheitsabfrage
log "WARNUNG: Dies wird alle gefundenen Server-Instanzen und zugehörige Docker Container unwiderruflich löschen!"
read -p "Möchten Sie fortfahren? (y/N): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    log "Abbruch auf Benutzeranfrage."
    exit 1
fi

# Zweite Sicherheitsabfrage
read -p "Sind Sie WIRKLICH sicher? Dies kann nicht rückgängig gemacht werden! (y/N): " confirm2

if [[ "$confirm2" != "y" && "$confirm2" != "Y" ]]; then
    log "Abbruch auf Benutzeranfrage."
    exit 1
fi

log "Starte Bereinigung..."

# Stoppe und entferne Docker Container
if [ -n "$docker_containers" ]; then
    log "Stoppe Docker Container..."
    echo "$docker_containers" | while read container; do
        log "Stoppe $container..."
        docker stop "$container"
        log "Entferne $container..."
        docker rm "$container"
    done
fi

# Lösche Server-Verzeichnisse
if [ -n "$server_dirs" ]; then
    log "Lösche Server-Verzeichnisse..."
    echo "$server_dirs" | while read dir; do
        log "Lösche $dir..."
        rm -rf "$dir"
    done
fi

log "Bereinigung abgeschlossen!"
log "Gelöschte Verzeichnisse: $server_count"
log "Gelöschte Container: $container_count"