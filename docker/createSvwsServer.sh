#!/bin/bash

# Funktion zum Anzeigen einer Fortschrittsanzeige
show_progress_right() {
  duration=$1
  interval=0.2
  steps=$(echo "$duration / $interval" | bc)
  bar="####################"
  
  # Terminalbreite erfassen
  terminal_width=$(tput cols)
  bar_width=20  # Länge der Fortschrittsleiste
  
  for i in $(seq 0 $steps); do
    percentage=$(echo "($i / $steps) * 100" | bc -l | awk '{printf "%.0f", $1}')
    progress=$(echo "$i * $bar_width / $steps" | bc)
    
    # Fortschrittsbalken und Prozentsatz erstellen
    progress_bar=$(printf "%-${bar_width}s" "${bar:0:$progress}")
    output=$(printf "[%-${bar_width}s] %d%%" "$progress_bar" "$percentage")
    
    # Cursor an die rechte Seite bewegen und Status aktualisieren
    tput sc  # Cursor-Position speichern
    tput cup 0 $(tput cols)  # Cursor an die rechte Seite bewegen
    echo -n "$output"  # Fortschrittsbalken ausgeben
    tput rc  # Cursor-Position wiederherstellen
    
    sleep $interval
  done
  echo  # Neue Zeile am Ende der Fortschrittsanzeige
}

# aktuelles Verzeichnis feststellen
current_dir=$(pwd)

# Anleitung
clear
echo "Das Schreiben der Anleitung und das Sammeln der Informationen war nicht einfach."
echo "Über gute Kritik freue ich mich. Viel Spaß mit Ihrem neuen Server"
sleep 5


# Vorraussetzungen
echo
echo
echo "## Vorraussetzungen ##"
echo
sleep 0.3
echo -e "- Linux Betriebsystem (Ubuntu empfohlen)"
echo -e "   - Docker läuft am besten auf Linux" 
sleep 0.1
echo -e "- MariaDB"
sleep 0.1
echo -e "- 1GB Ram"
sleep 0.1
echo -e "- 1 CPU Kern"
sleep 0.1
echo -e "- Die folgenden Ports frei:"
sleep 0.1
echo -e "   - ein beliebiger Port"
sleep 0.1
echo -e "- ein bisschen Geduld"
sleep 0.1
echo

# Benutzerabfrage, ob das Skript fortgesetzt werden soll
read -p "Wollen Sie fortfahren? [Yn] " response
response=${response:-y}

if [[ $response == "n" || $response == "N" ]]; then
  echo "Abbruch..."
  exit 1
fi


clear
clear

# Id des SVWS-Server wird abgefragt
echo "Eine beliebige ID, diese darf kein zweites Mal exestieren [1]: "
read -p "> " ID
ID=${ID:-1}
echo


  while true; do
    # Eingabeaufforderung für das Verzeichnis
    read -p "Bitte geben Sie einen gültigen Verzeichnispfad ein [$current_dir]: " dir_path

    # Überprüfen, ob das Verzeichnis existiert
    if [ -d "$dir_path" ]; then
      break  # Schleife beenden, wenn das Verzeichnis existiert
    else
      echo "Das Verzeichnis existiert nicht. Bitte versuchen Sie es erneut."
    fi
  done

clear
clear

# Eingabeaufforderungen für Benutzereingaben
echo "Bitte gebe im folgenden die Zugangsdaten der MariaDB ein"
sleep 1


echo "Die IP-Adresse der MariaDB, gefolgt von dem Port [localhost:3306]:" 
read -p "> " MariaDB_HOST
MariaDB_HOST=${MariaDB_HOST:-localhost:3306}
echo

echo "Nun wird das Root Passwort benötigt [****]:"
read -s -p "> " MariaDB_ROOT_PASSWORD
MariaDB_ROOT_PASSWORD=${MariaDB_ROOT_PASSWORD:-root}
echo

echo "Wie heißt die Datenbank? [Schild98547_prod]: "
read -p "> " MariaDB_DATABASE
MariaDB_DATABASE=${MariaDB_DATABASE:-test}
echo

echo "Geben Sie einen nicht Root User ein [test]: "
read -p "> " MariaDB_USER
MariaDB_USER=${MariaDB_USER:-test}
echo

echo "Bitte geben Sie das MariaDB Passwort ein [****]: "
read -s -p "> " MariaDB_PASSWORD
MariaDB_PASSWORD=${MariaDB_PASSWORD:-test}

clear

echo "Es muss für eine Sichere Verbindung ein SSL-Zertifikat erstellt werden"
echo "Bitte geben Sie das SVWS TLS Keystore Passwort ein [****]: "
read -s -p "> " SVWS_TLS_KEYSTORE_PASSWORD
SVWS_TLS_KEYSTORE_PASSWORD=${SVWS_TLS_KEYSTORE_PASSWORD:-}
echo

echo "Bitte geben Sie den SVWS TLS Key Alias ein [test]: "
read -p "> " SVWS_TLS_KEY_ALIAS
SVWS_TLS_KEY_ALIAS=${SVWS_TLS_KEY_ALIAS:-test}

clear

echo "Gebe die Host Daten ein"
echo "Über welche IP-Adresse soll der Server erreichbar sein?"
read -p "> " SVWS_HOST_IP
SVWS_HOST_IP=${SVWS_HOST_IP:-localhost}
echo

echo "Über welchen Port soll der Server erreichbar sein?"
read -p "> " SVWS_HOST_PORT
SVWS_HOST_PORT=${SVWS_HOST_PORT:-443}
echo


clear
clear

# Docker wird installiert
echo "Docker wird installiert"

{
  sudo apt install docker.io docker-compose-v2 nano && docker --version
} &> /dev/null &

pid=$!
show_progress_right 1
wait $pid


#SSL-Zertifikat erstellen
echo "SSL-Zertifikat wird erstellt"

# Datein erstellen
echo "Dateien werden erstellt in $dir_path"


cd $dir_path && mkdir svws-server-$ID && cd svws-server-$ID && touch docker-compose.yml && touch .env

cat <<EOF > docker-compose.yml
version: "3"
services:
  svws-$ID:
    image: svwsnrw/svws-server:latest
    container_name: svws-server-$ID
    ports:
      - "$SVWS_HOST_PORT:8443"
    environment:
      MariaDB_HOST: "$MariaDB_HOST"
      MariaDB_ROOT_PASSWORD: "$MariaDB_ROOT_PASSWORD"
      MariaDB_DATABASE: "$MariaDB_DATABASE"
      MariaDB_USER: "$MariaDB_USER"
      MariaDB_PASSWORD: "$MariaDB_PASSWORD"
      SVWS_TLS_KEY_ALIAS: "$SVWS_TLS_KEY_ALIAS"
      SVWS_TLS_KEYSTORE_PATH: "/etc/app/svws/conf/keystore"
      SVWS_TLS_KEYSTORE_PASSWORD: "$SVWS_TLS_KEYSTORE_PASSWORD"
    volumes:
      - ./keystore:/etc/app/svws/conf/keystore
EOF

cat <<EOF > .env
MariaDB_ROOT_PASSWORD=$MariaDB_ROOT_PASSWORD
MariaDB_DATABASE=$MariaDB_DATABASE
MariaDB_HOST=$MariaDB_HOST
MariaDB_USER=$MariaDB_USER
MariaDB_PASSWORD=$MariaDB_PASSWORD
SVWS_TLS_KEYSTORE_PATH=$SVWS_TLS_KEYSTORE_PATH
SVWS_TLS_KEYSTORE_PASSWORD=$SVWS_TLS_KEYSTORE_PASSWORD
SVWS_TLS_KEY_ALIAS=$SVWS_TLS_KEY_ALIAS
EOF


# Keystore erstellen
echo "Keystore wird erstellt"
echo
sleep 1

mkdir keystore && cd keystore
keytool -genkeypair -alias $SVWS_TLS_KEY_ALIAS -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore keystore -validity 365 -storepass $SVWS_TLS_KEYSTORE_PASSWORD -keypass $SVWS_TLS_KEYSTORE_PASSWORD -dname "CN=localhost, OU=IT, O=MyCompany, L=City, ST=State, C=Country"

# Zurück ins Verzeichnis
cd ..
sleep 1

# Container starten
echo
echo "Container wird gestartet"
sleep 3

clear

docker compose up -d

clear

# Contaier logs ausgeben
docker logs svws-server-$ID | tail -n 15
sleep 5

clear

# So sieht dein System jetzt aus
echo "########################"
echo "Der SVWS-Server läuft!"
echo
echo "Der soeben aufgesetzte Server hat die ID  $ID"
echo "########################"
echo
echo


# Benutzerabfrage, ob das Skript fortgesetzt werden soll
read -p "Aktuell laufende Container anzeigen? [Yn] " response_2
response_2=${response_2:-y}

if [[ $response_2 == "y" || $response_2 == "Y" ]]; then
  docker ps
  exit 1
fi
