#!/bin/bash

while true; do

  if read -t 0.1 -n 1; then
    
    break

  fi

  clear
  echo "Drücke eine Taste, um die Schleife zu beenden..."
  echo "CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES"
  sudo docker ps | grep svws-server-

  sleep 1
done