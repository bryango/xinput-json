#!/bin/bash
# set up the wingcool touchscreen

set -x

export DISPLAY=:0
export XAUTHORITY=/run/user/1000/gdm/Xauthority

xinput-json \
  | jq '.[] | select( .name == "WingCool Inc. TouchScreen" ) | .id' \
  | xargs -I _ xinput map-to-output _ DP-1
