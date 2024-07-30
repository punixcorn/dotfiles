#/bin/bash
pgrep -U 1000 -x conky | xargs kill -9
conky -c ~/.config/i3/conky/config.conf &
conky -c ~/.config/i3/conky/activate-windows.conf &
exit
