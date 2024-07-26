#!/bin/bash

clear

# Überprüfen, ob die Konfigurationsdatei existiert
config_file="config.txt"
if [ -f "$config_file" ]; then

    echo "WAS"
    sleep 2

    # Benutzerabfrage, ob das Skript fortgesetzt werden soll
    read -p "Config überschreiben? [Yn] " response
    response=${response:-y}

    if [[ $response !== "n" || $response !== "N" ]]; then
    
    rm config.txt

    touch config.txt

cat <<EOF > config.txt
[Server1]
ID=0
DIR_PATH=./server
MariaDB_HOST=localhost:3306
MariaDB_ROOT_PASSWORD=root
MariaDB_DATABASE=db
MariaDB_USER=user
MariaDB_PASSWORD=pass
SVWS_TLS_KEYSTORE_PASSWORD=keystorepass
SVWS_TLS_KEY_ALIAS=alias
SVWS_HOST_IP=192.168.1.1
SVWS_HOST_PORT=4431
EOF

    nano config.txt

    else 

    nano config.txt

    fi

else 

    echo "WAS GEHT"
    sleep 2
    touch config.txt

cat <<EOF > config.txt
[Server1]
ID=0
DIR_PATH=./server
MariaDB_HOST=localhost:3306
MariaDB_ROOT_PASSWORD=root
MariaDB_DATABASE=db
MariaDB_USER=user
MariaDB_PASSWORD=pass
SVWS_TLS_KEYSTORE_PASSWORD=keystorepass
SVWS_TLS_KEY_ALIAS=alias
SVWS_HOST_IP=192.168.1.1
SVWS_HOST_PORT=4431
EOF

    nano config.txt

fi