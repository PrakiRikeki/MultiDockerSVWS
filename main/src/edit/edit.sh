#!/bin/bash

clear
echo "CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES"
sudo docker ps | grep svws-server-

read -p "Server ID? [1]" prompt
if [[ $prompt =~ ^-?[0-9]+$ ]]
then


echo


else
clear
echo "Bitte eine Zahl eingeben."
. $DIR_EDIT/edit.sh

fi