#!/bin/bash

# Funktion zum Überprüfen der Argumente
check_arguments() {
    if [ $# -lt 1 ]; then
        echo "Verwendung: $0 ausgabedatei.txt"
        echo "Beispiel: $0 kinder.txt"
        exit 1
    fi
}

# Funktion zum Schreiben des Kopfteils
write_header() {
    local output_file=$1
    cat << 'EOF' > "$output_file"
===============================
        Kinderliste
===============================
Erstellt am: $(date +%d.%m.%Y)

EOF
}

# Funktion zum Schreiben des sich wiederholenden Teils für jedes Kind
write_child_entry() {
    local output_file=$1
    local child_name=$2
    local child_age=$3
    
    cat << EOF >> "$output_file"
Kind: $child_name
Alter: $child_age Jahre
---------------------------

EOF
}

# Funktion zum Schreiben des Fußteils
write_footer() {
    local output_file=$1
    cat << 'EOF' >> "$output_file"
===============================
        Ende der Liste
===============================
EOF
}

# Hauptprogramm
main() {
    local output_file=$1
    
    # Kopfteil schreiben
    write_header "$output_file"
    
    # Benutzer nach Kinderdaten fragen
    while true; do
        read -p "Name des Kindes (oder 'fertig' zum Beenden): " name
        if [ "$name" = "fertig" ]; then
            break
        fi
        
        read -p "Alter des Kindes: " age
        write_child_entry "$output_file" "$name" "$age"
    done
    
    # Fußteil schreiben
    write_footer "$output_file"
    
    echo "Datei wurde erfolgreich erstellt: $output_file"
}

# Argumente überprüfen und Hauptprogramm starten
check_arguments "$@"
main "$1"