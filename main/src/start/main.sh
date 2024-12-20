#!/bin/bash



text="
 
§ |                                       Guten Tag!                                        |
§ |                                                                                         |
§ | Dieses Tool ermöglicht eine einfache und unkomplizierte Installation von einem oder     |
§ | mehreren SVWS-Servern, die innerhalb von Docker-Containern betrieben werden. Docker-    |
§ | Container bieten eine isolierte Umgebung, die sicherstellt, dass Ihre Server in einem   |
§ | stabilen und konsistenten Zustand laufen, unabhängig von der zugrunde liegenden         |
§ | Infrastruktur.                                                                          |
§ |                                                                                         |
§ | Zusätzlich zur Installation bietet das Tool umfassende Möglichkeiten zur Anpassung      |
§ | bereits eingerichteter SVWS-Server. So können Sie bestehende Server-Konfigurationen     |
§ | nach Ihren Wünschen modifizieren und optimieren. Dies umfasst sowohl die Anpassung von  |
§ | Server-Einstellungen als auch die Erweiterung um zusätzliche Funktionen oder Dienste.   |
§ |                                                                                         |
§ | Sollten Sie Fragen haben oder Unterstützung benötigen, steht Ihnen unser Support-Team   |
§ | jederzeit zur Verfügung.                                                                |
§ |                                                                                         |
§ | Herausgeber:                                                                            |
§ | elias.missal@ribeka.com                                                                 |
§ | Ribeka GmbH, Bornheim                                                                   |
§ |                                                                                         |

"

# Verzögerung in Sekunden (z.B. 0.1 für 100 Millisekunden)
delay=0.0000001  


# Breite und Höhe des Terminals berechnen
terminal_width=$(tput cols)
terminal_height=$(tput lines)

horizontal_offset=$(( (terminal_width / 2)  - 50))

# Berechnung der Position
horizontal_position=$(( (terminal_width - 80) / 2 ))
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