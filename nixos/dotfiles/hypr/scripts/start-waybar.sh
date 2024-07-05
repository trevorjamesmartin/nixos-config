# make sure we're only running 1 waybar
pidof waybar | xargs kill -9 --
waybar -c /etc/nixos/dotfiles/waybar/config.json -s /etc/nixos/dotfiles/waybar/style.css

