#!/bin/bash

clear

# Überprüfen, ob die Konfigurationsdatei existiert
config_file="svws_docker.conf"

if [ -f "$config_file" ]; then

    sleep 2

    # Benutzerabfrage, ob das Skript fortgesetzt werden soll
    read -p "Config überschreiben? [Yn] " response
    response=${response:-y}

    if [[ $response == "y" || $response == "Y" || $response == "yes" || $response == "Yes" ]]
    then
    
    rm svws_docker.conf

    touch svws_docker.conf

cat <<EOF > svws_docker.conf
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

    nano svws_docker.conf

# Pfad zur svws_docker.conf
config_file="svws_docker.conf"

# Fehlerflag setzen
error_found=false

# Trennzeichen (kann angepasst werden)
delimiter="="
# Kommentarzeichen (kann angepasst werden)
comment_char="#"

while IFS= read -r line; do
  # Ignoriere Kommentarzeilen
  if [[ "${line:0:1}" == "$comment_char" ]]; then
    continue
  fi

  # Suche nach dem Trennzeichen
  if [[ "$line" == *"$delimiter"* ]]; then
    # Extrahiere Schlüssel und Wert
    key="${line%%$delimiter*}"
    value="${line#*$delimiter}"

    # Prüfe, ob ein Wert vorhanden ist
    if [[ -z "$value" ]]; then
      echo "Fehler: Kein Wert für Schlüssel '$key' in Zeile: $line"
      error_found=true
    fi
  else
    echo "Fehler: Ungültiges Format in Zeile: $line"
    error_found=true
  fi
done < "$config_file"

# Fehlerbehandlung
if $error_found; then
  echo "Fehler beim Parsen der Konfigurationsdatei"
  # Optional: Fehler in eine Logdatei schreiben
  # log_errors "errors.log"
fi


# Wenn Fehler gefunden wurden, mit Fehlercode beenden
if [ "$error_found" = true ]; then
  break
else
  echo "Alle Zeilen sind korrekt."
fi

    else 

    nano svws_docker.conf

# Pfad zur svws_docker.conf
config_file="svws_docker.conf"

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
      # Bestimmte Fehlermeldungen ignorieren
      if [[ "$line" == "MariaDB_ROOT_PASSWORD=" ]]; then
        continue
      fi
      echo "Fehler: Leerer Wert in Zeile: $line"
      error_found=true
    fi
  else
    # Bestimmte Fehlermeldungen ignorieren
    if [[ "$line" == "[Server199345]" ]]; then
      continue
    fi
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

    touch svws_docker.conf

cat <<EOF > svws_docker.conf
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

    nano svws_docker.conf

    # Pfad zur svws_docker.conf
    config_file="svws_docker.conf"

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