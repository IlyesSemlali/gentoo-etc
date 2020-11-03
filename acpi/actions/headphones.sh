#!/bin/bash
case "$3" in
    unplug)
        amixer set Master mute
    ;;
    plug)
        amixer set Headphone unmute
        amixer set Master unmute
    ;;
esac
