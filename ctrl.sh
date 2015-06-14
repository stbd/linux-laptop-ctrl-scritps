#!/bin/bash -eu

function usage()
{
    printf "\n\tLenovo control script\n\n"
    echo "-b - print battery state"
    echo "-v [mode] - set video mode"
    printf "\t0 - use only laptop screen\n"
    printf "\t1 - use secondary screen with auto resolution\n"
    printf "\t2 - use seoncdary screen with selected resolution\n"

}

function print-battery-state()
{
    output="$(upower -i /org/freedesktop/UPower/devices/battery_BAT0)"
    p=$(echo "$output" | grep 'percentage' | sed 's/  */ /g' | cut -d ' ' -f3)
    s=$(echo "$output" | grep 'state' | sed 's/  */ /g' | cut -d ' ' -f3)
    t=$(echo "$output" | grep 'time' | sed 's/  */ /g' | cut -d ' ' -f5-6)
    echo "Battery: $p, $t ($s)"
}

current_folder=$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")
options="bhv:l:a:shg:x"
while getopts $options opt; do
    case $opt in
        h)
            usage
            ;;
        b)
            print-battery-state
            ;;
        v)
            case $OPTARG in
                0)
                    xrandr --output eDP-0 --auto --output HDMI-1 --off
                    echo "Using laptop screen"
                    ;;
                1)
                    xrandr --output eDP-0 --auto --output HDMI-1 --mode auto --right-of eDP-0
                    echo "Dual screen: auto resolution"
                    ;;
                t)
                    # Custom settings for TV which has quite annoing overscan with max resolution
                    xrandr --output eDP-0 --auto --output HDMI-1 --mode 1600x1200 --right-of eDP-0
                    echo "TV mode"
                    ;;
                s)
                    # Custom setting for external screen
                    xrandr --output eDP-0 --auto --output HDMI-1 --mode 1920x1080  --right-of eDP-0
                    echo "Dual external screen"
                    ;;
                \?)
                    xrandr --prop
                    ;;
                *)
                    echo "Invalid mode $OPTARG"
                    ;;
            esac
            ;;
        a)
            if [ "${#OPTARG}" -eq "1" ]; then
                case $OPTARG in
                    s)
                        $(pacmd set-default-sink alsa_output.pci-0000_00_1b.0.analog-stereo)
                        echo "Audio Forwarded to speakers"
                        ;;
                    h)
                        $(pacmd set-default-sink alsa_output.pci-0000_00_03.0.hdmi-stereo-extra1)
                        echo "Audio forwarded to HDMI"
                        ;;
                    *)
                        echo "Invalid option $OPTARG, use either s or h"
                        ;;
                esac
            else
                # Format: [device]:[+/-][percentage]
                dev=${OPTARG%:*}
                vol=${OPTARG#*:}
                case $dev in
                    s)
                        $(pactl set-sink-volume alsa_output.pci-0000_00_1b.0.analog-stereo "$vol%")
                        ;;
                    h)
                        $(pactl set-sink-volume alsa_output.pci-0000_00_03.0.hdmi-stereo-extra1 "$vol%")
                        ;;
                    *)
                        echo "Invalid device $dev"
                        ;;
                esac
            fi

            ;;
        l)
            case $OPTARG in
                +)
                    $(sudo ${current_folder}/ctrl-brihtnesh.sh -inc 10)
                    ;;
                -)
                    $(sudo ${current_folder}/ctrl-brihtnesh.sh -dec 10)
                    ;;
                *)
                    echo "Invalid option $OPTARG, use + or -"
                    ;;
            esac
            ;;
        s)
            # Suspend to memory
            $(systemctl suspend)
            ;;
        h)
            # save to disk
            $(systemctl hibernate)
            ;;
        x)
            # Lock screen
            $(slock)
            ;;
        *)
            echo "Invalid option $opt"
            ;;
    esac
done
