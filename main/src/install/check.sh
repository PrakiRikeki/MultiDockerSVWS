# Prüfe ob ein Container mit dem Namen "svws-server-" existiert
if docker ps --format '{{.Names}}' | grep -q "svws-server-"; then
    echo "FEHLER: Es läuft bereits ein SVWS-Server Container!"
    echo "Bitte beenden Sie zuerst den laufenden Container mit 'docker stop <container-name>'"
    echo "Laufende Container mit diesem Präfix:"
    docker ps --format 'table {{.Names}}\t{{.Status}}' | grep "svws-server-"
    exit 0
fi

# Wenn kein Container gefunden wurde, fahre mit dem Skript fort
log "Kein laufender SVWS-Server Container gefunden. Fahre fort..."

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

