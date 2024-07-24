#!/bin/sh


initialize_file () {
        [[ -f /tmp/hyprpapertemp ]] && rm /tmp/hyprpapertemp;
        for ((c=1; c<=$(hyprctl hyprpaper listactive|wc -l);c++)) 
        do      
                current=$(hyprctl hyprpaper listactive | head -n $c |tail -n 1);
                cur_name=$(echo $current| cut -d'=' -f1|xargs);
                cur_wallpaper=$(echo $current| cut -d'=' -f2|xargs);
                echo ''preload = ${cur_wallpaper}'' >> /tmp/hyprpapertemp;
                echo ''wallpaper = ${cur_name},${cur_wallpaper}'' >> /tmp/hyprpapertemp;
        done
        echo "splash = false" >> /tmp/hyprpapertemp;
        cat /tmp/hyprpapertemp|sort > ~/.config/hypr/hyprpaper.conf
        echo "wrote ~/.config/hypr/hyprpaper.conf";
}


[[ ! -f /tmp/hyprpapertemp ]] && initialize_file;

