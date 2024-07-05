if [[ $(wlr-randr --json |jq length) -gt 1 ]] then wlr-randr --output "eDP-1" --off; else wlr-randr --output "eDP-1" --on; fi

