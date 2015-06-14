#!/bin/bash -eu

# Small script to allow controlling screen brightness as with xbacklight
# Usefull when xbacklight decides to use wrong destination
# It might be good idea to give this file sudo acess with something like this in visudo:
# %wheel ALL=(ALL) NOPASSWD: /home/[path]/lenovo-ctl/ctrl-brihtnesh.sh

function usage()
{
    echo "Usage: $0 -inc/-dec percentage"
}

if [ "$#" -ne 2 ]; then
    usage
    exit 1
fi

cmd=$1
percentage=$2
max=$(</sys/class/backlight/intel_backlight/max_brightness)
current=$(</sys/class/backlight/intel_backlight/brightness)
unit=$((max/100))

if [ "$cmd" == "-inc" ]; then
    updated=$((current+unit*percentage))
elif [ "$cmd" == "-dec" ]; then
    updated=$((current-unit*percentage))
else
    usage
    exit 1
fi

echo "$updated" > /sys/class/backlight/intel_backlight/brightness
