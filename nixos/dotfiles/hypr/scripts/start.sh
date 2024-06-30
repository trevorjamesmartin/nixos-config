#!/usr/bin/env bash
/etc/nixos/dotfiles/hypr/external.sh
gsettings set org.gnome.desktop.interface cursor-size $XCURSOR_SIZE
gsettings set org.gnome.desktop.interface cursor-theme $XCURSOR_THEME

. ~/.nix-profile/etc/profile.d/hm-session-vars.sh
# initialize wallpaper daemon
swww init &

# requires: pkgs.networkmanagerapplet
nm-applet --indicator &

# set cursor
hyprctl setcursor $XCURSOR_THEME $XCURSOR_SIZE

libinput-gestures &

# dunst
dunst
