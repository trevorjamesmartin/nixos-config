# if we have more than 1 display available
if [[ $(wlr-randr --json |jq length) -gt 1 ]] then
    # locate the primary display
    primary=$(wlr-randr --json |jq -r '.[0]| .name');
    # turn it off
    wlr-randr --output $primary --off;
    echo "internal display: OFF"; else

    echo "single display, no changes were made.";
fi

