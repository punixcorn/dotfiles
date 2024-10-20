#/bin/bash
pgrep -U 1000 -x conky | xargs kill -9
conky -c ~/.config/conky/config.conf &
conky -c ~/.config/conky/activate-windows.conf &
exit
