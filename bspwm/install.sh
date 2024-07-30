#!/bin/bash

function log() {
	printf "\e[32m[*]\e[0m %s\n" "$1"
}

function logerr() {
	printf "\e[33m[-]\e[0m %s\n" "$1"
}

function pacman() {
	log "Pre dependencies setup"
	git clone https://github.com/punixcorn/arch-setup
	[ -d arch-setup ] && {
		chmod +x arch-setup/*
		./arch-setup/install-choatic-aur.sh
		./arch-setup/install-yay.sh
		./arch-setup/install-zsh.sh
	} || logerr "Cloning failed skipping..."

	sudo pacman -S bspwm sxhkd rofi polybar alacritty dunst feh \
		xcb-util-cursor xsettingsd mpc mpd dmenu ncmpcpp python-gobject \
		xfce4-power-manager maim xclip xorg-xbacklight netcat \
		viewnior python-pywal xdg-user-dirs firefox chromium xorg-xrandr python --noconfirm
}

function debain() {
	sudo apt update
	sudo apt install bspwm sxhkd rofi polybar alacritty dunst feh \
		xsettingsd mpc mpd dmenu ncmpcpp \
		xfce4-power-manager maim xclip xorg-xbacklight netcat \
		viewnior xdg-user-dirs firefox chromium xorg-xrandr python3 -y

	python -m pip install --upgrade gobject pywal
}

log "Installing Dependencies"
[ -f /bin/pacman ] && pacman || debain

log "Copying files over"
CONFDIR="$HOME/.config/bspwm/"

[ -d $CONFDIR ] && mv $CONFDIR $HOME/.config/bspwm-backup
[ ! -d $CONFDIR ] && mkdir -p $CONFDIR
cp -r ** $CONFDIR

[ -d $CONFDIR/others ] && {
	[ ! -d $HOME/.config/networkmanager-dmenu/ ] && mkdir -p $HOME/.config/networkmanager-dmenu
	cp -r $CONFDIR/others/config.ini $HOME/.config/networkmanager-dmenu
	[ ! -d $HOME/.local/share/fonts ] && mkdir -p $HOME/.local/share/fonts
	sudo cp -r $CONFDIR/others/fonts/* $HOME/.local/share/fonts
	fc-cache -fv
} || logerr "Minor Dependencies not found (others folder not found)"

[ -f /bin/wal ] && wal -i $CONFDIR/wallpaper.png || logerr "wal failed, Mannual intervention needed"
[ -f /bin/feh ] && feh $CONFDIR/wallpaper.png --bg-scale || logerr "feh failed, Mannual intervention needed"

log "Creating Xinitrc"
cat <<EOF >$HOME/.xinitrc
exec bspwm
EOF
# sudo usermod -aG video $USER

exit 0
