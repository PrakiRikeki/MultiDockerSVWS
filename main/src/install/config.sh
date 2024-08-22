#!/bin/bash

clear

# Überprüfen, ob die Konfigurationsdatei existiert
config_file="config.txt"
if [ -x "$config_file" ]; then

    sleep 2

    # Benutzerabfrage, ob das Skript fortgesetzt werden soll
    read -p "Config überschreiben? [Yn] " response
    response=${response:-y}

    read -p "Are you sure you want to continue? <y/N> " prompt
    if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
    then
    
    rm config.txt

    touch config.txt

cat <<EOF > config.txt
[Server1]
ID=0
DIR_PATH=./server
MariaDB_HOST=localhost:3306
MariaDB_ROOT_PASSWORD=
MariaDB_DATABASE=db
MariaDB_USER=
MariaDB_PASSWORD=
SVWS_TLS_KEYSTORE_PASSWORD=
SVWS_TLS_KEY_ALIAS=alias
SVWS_HOST_IP=192.168.1.1
SVWS_HOST_PORT=4431
EOF

    nano config.txt

# Pfad zur config.txt
config_file="config.txt"

# Fehlerflag setzen
error_found=false

# Datei Zeile für Zeile durchgehen
while IFS= read -r line; do
  # Prüfen, ob die Zeile ein Gleichzeichen enthält
  if [[ "$line" == *"="* ]]; then
    # Extrahiere den Teil nach dem Gleichzeichen
    value="${line#*=}"
    # Prüfen, ob nach dem Gleichzeichen etwas steht
    if [[ -z "$value" ]]; then
      echo "Fehler: Leerer Wert in Zeile: $line"
      error_found=true
    fi
  else
    echo "Fehler: Kein Gleichzeichen in Zeile: $line"
    error_found=true
  fi
done < "$config_file"

# Wenn Fehler gefunden wurden, mit Fehlercode beenden
if [ "$error_found" = true ]; then
  exit 1
else
  echo "Alle Zeilen sind korrekt."
fi

    else 

    nano config.txt

# Pfad zur config.txt
config_file="config.txt"

# Fehlerflag setzen
error_found=false

# Datei Zeile für Zeile durchgehen
while IFS= read -r line; do
  # Prüfen, ob die Zeile ein Gleichzeichen enthält
  if [[ "$line" == *"="* ]]; then
    # Extrahiere den Teil nach dem Gleichzeichen
    value="${line#*=}"
    # Prüfen, ob nach dem Gleichzeichen etwas steht
    if [[ -z "$value" ]]; then
      echo "Fehler: Leerer Wert in Zeile: $line"
      error_found=true
    fi
  else
    echo "Fehler: Kein Gleichzeichen in Zeile: $line"
    error_found=true
  fi
done < "$config_file"

# Wenn Fehler gefunden wurden, mit Fehlercode beenden
if [ "$error_found" = true ]; then
  exit 1
else
  echo "Alle Zeilen sind korrekt."
fi

    fi

else 

    touch config.txt

cat <<EOF > config.txt
[Server1]
ID=0
DIR_PATH=./server
MariaDB_HOST=localhost:3306
MariaDB_ROOT_PASSWORD=
MariaDB_DATABASE=db
MariaDB_USER=
MariaDB_PASSWORD=
SVWS_TLS_KEYSTORE_PASSWORD=
SVWS_TLS_KEY_ALIAS=alias
SVWS_HOST_IP=192.168.1.1
SVWS_HOST_PORT=4431
EOF

    nano config.txt

    # Pfad zur config.txt
    config_file="config.txt"

    # Fehlerflag setzen
    error_found=false

    # Datei Zeile für Zeile durchgehen
    while IFS= read -r line; do
    # Prüfen, ob die Zeile ein Gleichzeichen enthält
    if [[ "$line" == *"="* ]]; then
        # Extrahiere den Teil nach dem Gleichzeichen
        value="${line#*=}"
        # Prüfen, ob nach dem Gleichzeichen etwas steht
        if [[ -z "$value" ]]; then
        echo "Fehler: Leerer Wert in Zeile: $line"
        error_found=true
        fi
    else
        if [[ "$line" == *"["* ]]; then
        echo
        else

        echo "Fehler: Kein Gleichzeichen in Zeile: $line"
        error_found=true
        fi
    fi
    done < "$config_file"

    # Wenn Fehler gefunden wurden, mit Fehlercode beenden
    if [ "$error_found" = true ]; then
    echo "Fehler gefunden."
    break
    else
    echo "Alle Zeilen sind korrekt."
    fi

fi