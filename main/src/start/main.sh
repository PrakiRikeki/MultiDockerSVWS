#!/bin/bash


# region Text einlaufen lassen


text="
§                      Guten Tag!
§ | Dieses Tool ist zur einfachen Installation von  |
§ | einem oder mehreren SVWS-Servern, welche unter  |
§ | Docker erstellt werden.                         |
§ |                                                 |
§ | Darüber hinaus, kann man bereits erstellt       |
§ | SVWS-Server #berbeiten löschen oder stoppen     |
§ |                                                 |
§ | Herrausgeber:                                   |
§ | Ribeka GmbH Bornheim                            |

"

# Verzögerung in Sekunden (z.B. 0.1 für 100 Millisekunden)
delay=0.005  


# Breite und Höhe des Terminals berechnen
terminal_width=$(tput cols)
terminal_height=$(tput lines)

horizontal_offset=$(( (terminal_width / 2)  - 28))

# Berechnung der Position
horizontal_position=$(( (terminal_width - 50) / 2 ))
vertical_position=$(( (terminal_height / 2 ) - 7))

# Oben Platz machen
clear
tput cup $vertical_position $horizontal_position

# Ausgabe des Textes mit Verzögerung
for (( i=0; i<${#text}; i++ )); do
  char="${text:$i:1}"
  if [[ "$char" == $'§' ]]; then
    # Bei Zeilenumbruch zum Anfang der nächsten Zeile springen
    echo
    # Optionalen horizontalen Versatz hinzufügen
    for (( j=0; j<$horizontal_offset; j++ )); do
      echo -n " "
    done
  else
    # Zeichen ausgeben
    echo -n "$char"
    sleep $delay
  fi
done
# Berechnung der vertikalen Position für den Text in der unteren Hälfte
lower_half_start=$(( vertical_position + 1 ))

# Positionieren des Cursors und Ausgabe des Textes in der unteren Hälfte
tput cup $lower_half_start 0

# Hier können Sie den Text oder andere Ausgaben für die untere Hälfte einfügen
for (( i=lower_half_start; i<terminal_height; i++ )); do
  echo
done

tput sgr0
# endregion

# region Abfrage ob fortfahren



    # Kurze Pause, damit der Benutzer die Nachricht sehen kann
    read -n 1 -s -r -p "Drücke irgendeine Taste um fortzufahren..."

clear


# endregion

# region Überleitung ins Hauptmenü
. $DIR_MENU/main.sh