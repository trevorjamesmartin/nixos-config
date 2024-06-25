#!/usr/bin/env bash
/etc/nixos/dotfiles/hypr/external.sh
gsettings set org.gnome.desktop.interface cursor-size $XCURSOR_SIZE
gsettings set org.gnome.desktop.interface cursor-theme $XCURSOR_THEME

. ~/.nix-profile/etc/profile.d/hm-session-vars.sh
# initialize wallpaper daemon
swww init &
# set wallpaper
swww img ~/Pictures/BigSurLatestWalls/Tree-1-dragged.jpg &

# requires: pkgs.networkmanagerapplet
nm-applet --indicator &

. ~/.nix-profile/etc/profile.d/hm-session-vars.sh
# set cursor
hyprctl setcursor $XCURSOR_THEME $XCURSOR_SIZE

# dunst
dunst
