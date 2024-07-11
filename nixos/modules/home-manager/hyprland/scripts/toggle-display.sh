#!/usr/bin/env bash

if [ $# -eq 0 ] 
  then primary=$(wlr-randr --json |jq -r '.[0]| .name');
fi

if [ $# -eq 1 ] 
  then primary=$1;
fi

outputs=$(wlr-randr --json |jq '.[]| {name: .name, enabled: .enabled }'|jq -s)
disabled=$(echo $outputs |jq -r '.[]|if .enabled == false then .name else empty end');

if [[ ${#disabled} -gt 0 ]] then
    wlr-randr --output $disabled --on; else
    # echo $outputs
    wlr-randr --output $primary --off;
fi
wlr-randr --json |jq '.[]| {name: .name, enabled: .enabled }'|jq -s
