#!/bin/bash


# region textausgabe

echo "       <------- ### HAUPTMENÜ ### ------->      "
echo "                    Option 1                    "
echo "                    Option 2                    "
echo "                    Option 3                    "
echo "                    Option 4                    "


#!/bin/bash

show_menu() {
    echo "Status"
    echo "1) Laufende SVWS-Server anzeigen"
    echo
    echo "Installation"

# Überprüfen, ob die Konfigurationsdatei existiert
config_file="config.txt"
if [ ! -f "$config_file" ]; then
    echo '2) Einen oder mehrere SVWS-Server aufsetzten      (config.txt nicht vorhanden)'
      
 else 
    echo '2) Einen oder mehrere SVWS-Server aufsetzten'
fi
    echo "2.1) config.txt erstellen und/oder bearbeiten                 (noch in Arbeit)"
    echo
    echo "SVWS-Server bearbeiten"
    echo "3) Einen laufenden SVWS-Server bearbeiten                     (noch in Arbeit)"
    echo "4) Einen laufenden SVWS-Server stoppen                        (noch in Arbeit)"
    echo "5) Einen laufenden SVWS-Server löschen                        (noch in Arbeit)"
    echo "q) Quit"
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
            echo "Laufende Docker-Container werden geladen"
            sleep 2
            ;;
        4)
            echo "Einen Moment"
            sleep 0.5
            echo "Laufende Docker-Container werden geladen"
            sleep 2
            ;;
        q)
            echo "Einen Moment"
            sleep 0.5
            echo "Tool wird beendet"
            sleep 2
            exit 0
            ;;
        *)
            . $DIR_START/main.sh
            ;;
    esac
}

while true; do
    clear
    show_menu
    process_choice
done





# endregion