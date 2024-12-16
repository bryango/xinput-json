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

# touchscreen input maps to its display
xinput-json \
  | jq '.[] | select( .name == "WingCool Inc. TouchScreen" ) | .id' \
  | xargs -I _ xinput map-to-output _ DP-1

# cursor input maps to the builtin display
xinput-json \
  | jq '.[] | select( .name == "Virtual core XTEST pointer" ) | .id' \
  | xargs -I _ xinput map-to-output _ eDP-1
