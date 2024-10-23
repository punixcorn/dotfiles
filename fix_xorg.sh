#!/bin/bash

if [ -z "$(pidof Xorg)" ]; then
    echo "run this when you start Xorg"
    exit 1
fi

function fix_xorg() {
    log "Trying to fix display"
    monitor=$(xrandr --listactivemonitors | awk '{ print $2 }' 2>/dev/null)
    log "Found monitor : $monitor"

    if [ -z "$monitor" ]; then
        logerr "No Display found"
        xrandr --listactivemonitors
        log "Enter Display name eg eDP1 : "
        read displayName
    fi

    question "What is the resolution of your display?\nExample: 1920x1080\n>>"
    read dismode
    sudo mkdir -p /etc/X11/xorg.conf.d
    sudo tee /etc/X11/xorg.conf.d/00-resolution.conf <<!
Section "Screen"
Identifier "Screen0"
Monitor "$displayName"
DefaultDepth 24
SubSection "Display"
    Modes "$dismode"
EndSubSection
EndSection
!
}
