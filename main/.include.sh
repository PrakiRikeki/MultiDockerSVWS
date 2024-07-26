#!/bin/bash


main="$(dirname "$(realpath "$0")")"
main="$main/src"


# Unterordner festlegen
DIR_START="$main/start"
export DIR_START

DIR_MENU="$main/menu"
export $DIR_MENU

DIR_INSTALL="$main/install"
export $DIR_INSTALL

. $DIR_START/main.sh


