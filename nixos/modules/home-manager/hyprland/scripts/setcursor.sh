echo $XCURSOR_THEME $XCURSOR_SIZE
gsettings set org.gnome.desktop.interface cursor-theme $XCURSOR_THEME &&
gsettings set org.gnome.desktop.interface cursor-size $XCURSOR_SIZE &&
hyprctl setcursor $XCURSOR_THEME $XCURSOR_SIZE

