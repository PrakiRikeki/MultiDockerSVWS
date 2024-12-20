#!/bin/bash

show_menu() {
    echo "=================================="
    echo "   SVWS-Server-Verwaltungs Menü   "
    echo "=================================="
    ls
    echo "elias.missal@ribeka.com"
    echo
    echo "Server-Status"
    echo "1) Laufende SVWS-Server anzeigen"
    echo

    echo "Installation"
    config_file="svws_docker.conf"
    if [ -e "$config_file" ]; then
        echo "2) SVWS-Server installieren"
    else
        echo "2) SVWS-Server installieren (svws_docker.conf nicht vorhanden)"
    fi
    echo "2.1) Konfigurationsdatei (svws_docker.conf) erstellen/bearbeiten"
    echo

    echo "Server-Verwaltung"
    echo "3) Config aus aktuellen Servern exportieren"
    echo "3.1) Alle Server stoppen und unwiederruflich löschen"
    echo

    echo "Testgelände"
    echo "4) Aktuelle Test Datei ausführen"
    echo

    echo "q) exit) Beenden"
}


process_choice() {
    read -p "> " response
    response=${response:-y}

    case "$response" in
        1)
            echo "Einen Moment"
            sleep 0.5
            echo "Laufende Docker-Container werden geladen"
            sleep 2
            . $DIR_MENU/docker_runner.sh
            ;;
        2)
            echo "Einen Moment"
            sleep 0.5
            echo "Vorbereitungen laufen"
            sleep 2
            . $DIR_INSTALL/main.sh
            ;;
        2.1)
            echo "Einen Moment"
            sleep 0.5
            . $DIR_INSTALL/config.sh
            ;;
        3)
            echo "Einen Moment"
            sleep 0.5
            echo "Server werden geladen"
            . $DIR_EXPORT/main.sh
            sleep 2
            ;;
        3.1)
            echo "Einen Moment"
            sleep 0.5
            echo "Laufende Docker-Container werden geladen"
            sleep 2
            . $DIR_DELETE/main.sh
            ;;
        4)
            echo "Test startet"
            . $DIR_TEST/main.sh
            ;;
        q)
            echo "Einen Moment"
            sleep 0.5
            echo "Tool wird beendet"
            sleep 2
            exit 0
            ;;
        exit)
            exit 0
            ;;
        *)
            . $DIR_START/main.sh
            ;;
    esac
}

while true; do
    echo 
    echo 
    echo
    show_menu
    process_choice
done