#!/bin/sh

SELECTED=$(find /run/current-system/sw/share/icons -maxdepth 1 -type d| cut -d '/' -f 7|sort |tail -n +2|rofi -dmenu -i -p "Cursor theme")

if [ -n "$SELECTED" ]; then
    
    THEME="$SELECTED"

    SIZE=$(rofi -dmenu -p "Cursor Size" -theme-str 'listview {lines: 0;}')

    if [ -n "$SIZE" ]; then
        export XCURSOR_THEME="$THEME"
        export XCURSOR_SIZE="$SIZE"
        hyprctl setcursor $XCURSOR_THEME $XCURSOR_SIZE
        mkdir -p ~/.icons/default
        echo "[Icon Theme]" > ~/.icons/default/index.theme
        echo "Inherits=$XCURSOR_THEME" >> ~/.icons/default/index.theme
    fi

fi


