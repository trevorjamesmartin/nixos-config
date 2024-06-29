#!/bin/sh

for plg in $(ls ~/.local/lib/hyprPlugins)
do
    hyprctl plugin load $(readlink ~/.local/lib/hyprPlugins/$plg)
done

