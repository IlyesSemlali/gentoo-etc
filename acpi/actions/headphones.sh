#!/bin/bash
case "$3" in
    plug)
        sudo touch /tmp/headphones-plugged
    ;;
    unplug)
        rm /tmp/headphones-plugged
    ;;
esac
