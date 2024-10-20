#!/bin/bash

# Kill already running process
_ps=(picom dunst mpd xfce-polkit xfce4-power-manager)
for _prs in "${_ps[@]}"; do
    if [[ $(pidof ${_prs}) ]]; then
        killall -9 ${_prs} 2>/dev/null
    fi
done

# Fix cursor
xsetroot -cursor_name left_ptr 2>/dev/null

# Polkit agent
[ -f /usr/lib/xfce-polkit/xfce-polkit ] && /usr/lib/xfce-polkit/xfce-polkit >/dev/null 2>&1 &

# Enable power management
# xfce4-power-manager &

# Restore wallpaper
[ -f /bin/feh ] && [ -d "$HOME/.config/wallpaper" ] && feh --bg-scale ~/.config/wallpaper/wallpaper.png >/dev/null 2>&1 &

# Lauch polybar
[ -f /bin/polybar ] && polybar -c ~/.config/polybar/polybar.ini >/dev/null 2>&1 &
disown

# Lauch notification daemon
[ -f /bin/dunst ] && dunst -config ~/.config/dunst/dunstrc >/dev/null 2>&1 &

# Lauch compositor
picom --experimental-backends --conf ~/.config/picom/picom.conf >/dev/null 2>&1 &
disown

# Start mpd
[ -f /bin/mpd ] && exec mpd &

# i3lock
[ -f /bin/xss-lock ] && [ -f /bin/i3lock ] && xss-lock -- $HOME/.config/bin/lockscreen --transfer-sleep-lock --nofork >/dev/null 2>&1 &
disown

# conky
[ -f /bin/conky ] && ~/.config/conky/start.sh >/dev/null 2>&1

# wal
[ -f /bin/wal ] && [ ! -d "$HOME/.cache/wal/" ] && wal -i ~/.config/wallpaper/wallpaper.png 2>/dev/null
exit 0

## Polybar env varibales
export DEFAULT_NETWORK_INTERFACE=$(ip route | grep '^default' | awk '{print $5}' | head -n1)
export DEFAULT_BATTERY=$(ls -1 /sys/class/power_supply | awk '{ print $1 }' | grep BAT)
export DEFAULT_ADAPTER=$(ls -1 /sys/class/power_supply | awk '{ print $1 }' | grep ADP)
