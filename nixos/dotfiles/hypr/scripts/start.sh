#!/usr/bin/env bash
/etc/nixos/dotfiles/hypr/external.sh

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
