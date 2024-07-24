#!/bin/bash

# Funktion zum Anzeigen einer Fortschrittsanzeige
show_progress() {
  duration=$1
  interval=0.2
  steps=$(echo "$duration / $interval" | bc)
  bar="####################"
  
  for i in $(seq 0 $steps); do
    percentage=$(echo "($i / $steps) * 100" | bc -l | awk '{printf "%.0f", $1}')
    progress=$(echo "$i * 20 / $steps" | bc)
    printf "\r[%-20s] %d%%" "${bar:0:$progress}" "$percentage"
    sleep $interval
  done
  echo
}

# Anleitung
echo
echo "Das Schreiben der Anleitung und das Sammeln der Informationen war nicht einfach."
echo "Gerne freue ich mich über gute Kritik. Viel Spaß beim Befolgen der Anleitung."
sleep 5


# Vorraussetzungen
echo
echo
echo "## Vorraussetzungen ##"
echo
sleep 0.3
echo -e "- Linux Betriebsystem (Ubuntu empfohlen)"
sleep 0.3
echo -e "- Docker läuft am besten auf Linux" 
sleep 0.3
echo -e "- MariaDB"
sleep 0.3
echo -e "- 1GB Ram"
sleep 0.3
echo -e "- CPU Kern"
sleep 0.3
echo -e "- Die folgenden Ports frei:"
sleep 0.3
echo -e "   - 443 (bevorzugt),"
sleep 0.3
echo -e "   - 8443"
sleep 0.3
echo -e "- ein bisschen Geduld"
echo

# Benutzerabfrage, ob das Skript fortgesetzt werden soll
read -p "Wollen Sie fortfahren? [Ny] " response
response=${response:-n}

if [[ $response == "n" || $response == "N" ]]; then
  echo "Abbruch..."
  exit 1
fi

# Docker installieren
echo
echo
echo "########################"
echo "Docker wird installiert"
echo "########################"
echo
sleep 2
sudo apt install docker.io docker-compose-v2 nano && docker --version

# Id des SVWS-Server wird abgefragt
echo
read -p "Eine beliebige ID, diese darf kein zweites Mal exestieren [1]:  " ID
ID=${ID:-1}
echo
# Eingabeaufforderungen für Benutzereingaben
echo
echo "Bitte gebe im folgenden die Zugangsdaten der MariaDB ein"
sleep 1

read -p "Die IP-Adresse der MariaDB, gefolgt von dem Port [localhost:3306]:  " MariaDB_HOST
MariaDB_ROOT_PASSWORD=${MariaDB_ROOT_PASSWORD:-localhost:3306}
echo
read -p "Bitte geben Sie das MariaDB Root Passwort ein: " MariaDB_ROOT_PASSWORD
MariaDB_ROOT_PASSWORD=${MariaDB_ROOT_PASSWORD:-root}
echo
read -p "Bitte geben Sie den MariaDB Datenbanknamen ein [Schild98547_prod]: " MariaDB_DATABASE
MariaDB_DATABASE=${MariaDB_DATABASE:-test}
echo
read -p "Bitte geben Sie den MariaDB Benutzernamen ein [test]: " MariaDB_USER
MariaDB_USER=${MariaDB_USER:-test}
echo
read -s -p "Bitte geben Sie das MariaDB Passwort ein [****]: " MariaDB_PASSWORD
MariaDB_PASSWORD=${MariaDB_PASSWORD:-test}
sleep 2


echo
echo
echo "Nun müssen wir ein SSL Zertifikat erstellen"
echo
sleep 1
read -s -p "Bitte geben Sie das SVWS TLS Keystore Passwort ein: " SVWS_TLS_KEYSTORE_PASSWORD
SVWS_TLS_KEYSTORE_PASSWORD=${SVWS_TLS_KEYSTORE_PASSWORD:-}
echo
read -p "Bitte geben Sie den SVWS TLS Key Alias ein [test]: " SVWS_TLS_KEY_ALIAS
SVWS_TLS_KEY_ALIAS=${SVWS_TLS_KEY_ALIAS:-test}
echo
echo


# Datein erstellen
echo
echo
echo "########################"
echo "Dateien werden erstellt"
echo "########################"
sleep 1
echo

cd /home && mkdir svws-server-$ID && cd svws-server-$ID && touch docker-compose.yml && touch .env

cat <<EOF > docker-compose.yml
version: "3"
services:
  svws-$ID:
    image: svwsnrw/svws-server:latest
    container_name: svws-server-$ID
    ports:
      - "8443:8443"
      - "443:443"
    environment:
      MariaDB_HOST: "$MariaDB_HOST"
      MariaDB_ROOT_PASSWORD: "$MariaDB_ROOT_PASSWORD"
      MariaDB_DATABASE: "$MariaDB_DATABASE"
      MariaDB_USER: "$MariaDB_USER"
      MariaDB_PASSWORD: "$MariaDB_PASSWORD"
      SVWS_TLS_KEY_ALIAS: "$SVWS_TLS_KEY_ALIAS"
      SVWS_TLS_KEYSTORE_PATH: "/etc/app/svws/conf/keystore "
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

echo
# Keystore erstellen
echo "########################"
echo "Keystore wird erstellt"
echo "########################"
echo
sleep 1

mkdir keystore && cd keystore
keytool -genkeypair -alias $SVWS_TLS_KEY_ALIAS -keyalg RSA -keysize 2048 -storetype PKCS12 -keystore keystore -validity 365 -storepass $SVWS_TLS_KEYSTORE_PASSWORD -keypass $SVWS_TLS_KEYSTORE_PASSWORD -dname "CN=localhost, OU=IT, O=MyCompany, L=City, ST=State, C=Country"

# Zurück ins Verzeichnis
cd ..
sleep 1

# Container starten
echo
echo "########################"
echo "Container wird gestartet"
echo "########################"
echo
sleep 1

ls -a
sleep 1
echo
cat docker-compose.yml
sleep 1
echo
docker compose up -d
show_progress 30
docker logs svws-server-$ID | tail -n 20
echo
echo
echo "##########################################################################"
echo "Du hast es geschafft!"
echo "Dein SVWS-Server wurde erfolgreich aufgesetzt und läuft bereits."
echo "##########################################################################"


# So sieht dein System jetzt aus
echo "########################"
echo "Der SVWS-Server läuft!"
echo
echo "Der soeben aufgesetzte Server hat die ID  $ID"
echo
echo "schau dir gerne mal die "

echo "########################"