#!/bin/bash


main="$(dirname "$(realpath "$0")")"
main="$main/src"


# Unterordner festlegen
DIR_START="$main/start"
export DIR_START

DIR_MENU="$main/menu"
export $DIR_MENU

DIR_EDIT="$main/edit"
export $DIR_EDIT

DIR_UPDATE="$main/update"
export $DIR_UPDATE

DIR_CHECK="$main/check"
export $DIR_CHECK

DIR_SAVE="$main/save"
export $DIR_SAVE

DIR_INSTALL="$main/install"
export $DIR_INSTALL

DIR_TEST="$main/test"
export $DIR_TEST

. $DIR_START/main.sh


