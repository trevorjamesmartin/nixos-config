# make sure we're only running 1 waybar
ps -ea |grep waybar|awk '{print $1}' | xargs kill -9 --

#waybar -c ~/dotfiles/waybar/config.jsonc -s ~/dotfiles/waybar/style.css
waybar -c /etc/nixos/dotfiles/waybar/config.json -s /etc/nixos/dotfiles/waybar/style.css


