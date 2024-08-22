#!/bin/bash

show_menu() {
    echo "=================================="
    echo "   SVWS-Server-Verwaltungs Menü   "
    echo "=================================="
    echo
    echo "Server-Status"
    echo "1) Laufende SVWS-Server anzeigen"
    echo

    echo "Installation"
    config_file="config.txt"
    if [ -e "$config_file" ]; then
        echo "2) SVWS-Server installieren"
    else
        echo "2) SVWS-Server installieren (config.txt nicht vorhanden)"
    fi
    echo "2.1) Konfigurationsdatei (config.txt) erstellen/bearbeiten"
    echo

    echo "Server-Überprüfung"
    echo "3) Alle SVWS-Server vollständig prüfen                     (in Arbeit)"
    echo "3.1) Erreichbarkeit aller SVWS-Server testen               (in Arbeit)"
    echo "3.2) Server-Logs auf Fehler prüfen                         (in Arbeit)"
    echo

    echo "Server-Verwaltung"
    echo "4.1) Laufenden SVWS-Server bearbeiten                      (in Arbeit)"
    echo "4.2) Laufenden SVWS-Server stoppen                         (in Arbeit)"
    echo "4.3) Laufenden SVWS-Server löschen                         (in Arbeit)"
    echo

    echo "Server-Sicherung"
    echo "5) Alle SVWS-Server sichern                                (in Arbeit)"
    echo "5.1) SVWS-Server wiederherstellen                          (in Arbeit)"
    echo "5.2) Sicherungsdatei überprüfen                            (in Arbeit)"
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
            echo "Überprüfung wird gestartet"
            sleep 2
            ls
            echo $DIR_CHECK
            . $DIR_CHECK/main.sh
            ;;
        3.1)
            echo "Einen Moment"
            sleep 0.5
            echo "Überprüfung wird gestartet"
            sleep 2
            . $DIR_CHECK/ping.sh
            ;;
        3.2)
            echo "Einen Moment"
            sleep 0.5
            echo "Überprüfung wird gestartet"
            sleep 2
            . $DIR_CHECK/log.sh
            ;;
        4.1)
            echo "Einen Moment"
            sleep 0.5
            echo "Laufende Docker-Container werden geladen"
            sleep 2
            . $DIR_EDIT/edit.sh
            ;;
        4.2)
            echo "Einen Moment"
            sleep 0.5
            echo "Laufende Docker-Container werden geladen"
            sleep 2
            . $DIR_EDIT/stop.sh
            ;;
        4.3)
            echo "Einen Moment"
            sleep 0.5
            echo "Laufende Docker-Container werden geladen"
            sleep 2
            . $DIR_EDIT/delete.sh
            ;;
        5)
            echo "Einen Moment"
            sleep 0.5
            echo "Laufende Docker-Container werden geladen"
            sleep 2
            . $DIR_SAVE/save.sh
            ;;
        5.1)
            echo "Einen Moment"
            sleep 0.5
            echo "Laufende Docker-Container werden geladen"
            sleep 2
            . $DIR_SAVE/recovery.sh
            ;;
        5.2)
            echo "Einen Moment"
            sleep 0.5
            echo "Laufende Docker-Container werden geladen"
            sleep 2
            . $DIR_SAVE/check.sh
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





# endregion