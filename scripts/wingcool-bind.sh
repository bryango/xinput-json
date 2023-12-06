#!/bin/bash
# set up the wingcool touchscreen

# print a timestamp
echo
date --rfc-3339=s

# sleep a bit
sleep 0.5
export DISPLAY=:0
export XAUTHORITY=/run/user/1000/gdm/Xauthority

set -x
xinput-json \
  | jq '.[] | select( .name == "WingCool Inc. TouchScreen" ) | .id' \
  | xargs -I _ xinput map-to-output _ DP-1
