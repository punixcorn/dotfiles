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

function initfeh() {
	feh ~/.config/i3/wallpaper/wallpaper.png --bg-fill >/dev/null 2>&1 &
	disown
}

# Restore wallpaper
[ -f /bin/feh ] && [ -d "$HOME/.config/wallpaper" ] && initfeh || {
	feh --bg-scale ~/.config/i3/wallpaper.png >/dev/null 2>&1 &
}

# Lauch polybar
[ -f /bin/polybar ] && polybar -c ~/.config/i3/polybar/polybar.ini >/dev/null 2>&1 &
disown

# Lauch notification daemon
[ -f /bin/dunst ] && dunst -config ~/.config/i3/dunstrc >/dev/null 2>&1 &

# Lauch compositor
picom --experimental-backends --conf ~/.config/i3/picom.conf >/dev/null 2>&1 &
disown

# Start mpd
[ -f /bin/mpd ] && exec mpd &

# i3lock
[ -f /bin/xss-lock ] && [ -f /bin/i3lock ] && xss-lock -- $HOME/.config/i3/bin/lockscreen --transfer-sleep-lock --nofork >/dev/null 2>&1 &
disown

# conky
[ -f /bin/conky ] && ~/.config/i3/conky/start.sh >/dev/null 2>&1

# wal
[ -f /bin/wal ] && [ ! -d "$HOME/.cache/wal/" ] && wal -i ~/.config/i3/wallpaper.png 2>/dev/null
exit 0
