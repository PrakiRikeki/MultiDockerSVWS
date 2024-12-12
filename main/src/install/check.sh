# Hilfsfunktionen für Logging
log() {
    echo "[INFO] $1"
}

error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Prüfe ob Docker installiert ist und läuft
check_docker() {
    if ! command -v docker &> /dev/null; then
        error_exit "Docker ist nicht installiert"
    fi
    if ! docker info &> /dev/null; then
        error_exit "Docker-Daemon läuft nicht oder keine Berechtigungen"
    fi
    log "Docker-Installation und Service überprüft"
}

# Prüfe ob ein Container mit dem Namen "svws-server-" existiert
check_existing_container() {
    if docker ps --format '{{.Names}}' | grep -q "svws-server-"; then
        echo "FEHLER: Es läuft bereits ein SVWS-Server Container!"
        echo "Bitte beenden Sie zuerst den laufenden Container mit 'docker stop <container-name>'"
        echo "Laufende Container mit diesem Präfix:"
        docker ps --format 'table {{.Names}}\t{{.Status}}' | grep "svws-server-"
        exit 1
    fi
    log "Kein laufender SVWS-Server Container gefunden"
}

# Root-Überprüfung
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error_exit "Dieses Skript muss als Root ausgeführt werden"
    fi
    log "Root-Berechtigungen bestätigt"
}

# Konfigurationsdatei überprüfen
check_config() {
    local config_file="$1"
    if [ ! -f "$config_file" ]; then
        error_exit "Die Datei '$config_file' wurde nicht gefunden"
    fi
    if [ ! -r "$config_file" ]; then
        error_exit "Keine Leserechte für die Datei '$config_file'"
    fi
    log "Konfigurationsdatei gefunden und lesbar: $config_file"
}

# Verzeichnisberechtigungen prüfen
check_directories() {
    local dirs=("./data" "./keystore")
    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir" || error_exit "Konnte Verzeichnis $dir nicht erstellen"
        fi
        if [ ! -w "$dir" ]; then
            error_exit "Keine Schreibrechte für Verzeichnis $dir"
        fi
    done
    log "Verzeichnisberechtigungen überprüft"
}

# Speicherplatz prüfen
check_disk_space() {
    local min_space=1024  # Minimum 1GB in MB
    local available_space=$(df -m . | awk 'NR==2 {print $4}')
    if [ "$available_space" -lt "$min_space" ]; then
        error_exit "Nicht genügend Speicherplatz verfügbar (mindestens ${min_space}MB benötigt)"
    fi
    log "Ausreichend Speicherplatz verfügbar"
}

# Hauptausführung der Prüfungen
main() {
    check_root
    check_docker
    check_existing_container
    check_config "$config_file"
    check_directories
    check_disk_space
    log "Alle Prüfungen erfolgreich abgeschlossen"
}

# Skript ausführen
main
