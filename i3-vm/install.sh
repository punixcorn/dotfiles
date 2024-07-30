#!/bin/bash

function log(){
	printf "\e[32m[*]\e[0m%s\n" "$1"
}

function logerr(){
	printf "\e[32m[-]\e[0m%s\n" "$1"
}


function full_setup(){
   # networkmanager
	[ ! -d ~/.config/networkmanager-dmenu/ ] && mkdir -p ~/.config/networkmanager-dmenu/
	cp -r ./rofi/network/config.ini ~/.config/networkmanager-dmenu/

    # light
    [ -f /bin/light ] && sudo usermod -aG video $USER
}


#  === start ===

log "Pre dependencies setup"
git clone https://github.com/punixcorn/arch-setup
[ -d arch-setup ] && {
	chmod +x arch-setup/*
	./arch-setup/install-choatic-aur.sh
	./arch-setup/install-yay.sh
	./arch-setup/install-zsh.sh
} || logerr "Cloning failed skipping..."

log "Installing Dependencies"
sudo pacman -S i3-wm rofi mpd alacritty polybar dmenu dunst feh i3lock xss-lock xsettingsd xsettings-client git --noconfirm

[ -f /bin/yay ] && yay -S light xfce-polkit || logerr "Failed to install from yay"
sudo pacman -S networkmanager-dmenu-git || logerr "Failed to install networkmanager-dmenu-git, please do it mannually"

log "Copying files over"
CONFDIR="$HOME/.config/i3/"
[ -d $CONFDIR ] && mv $CONFDIR $HOME/.config/i3-backup
[ ! -d $CONFDIR ] && mkdir -p $CONFDIR
cp -r ** $CONFDIR

log "Setting up fonts"
[ -d $CONFDIR/others ] && {
	[ ! -d $HOME/.local/share/fonts ] && mkdir -p $HOME/.local/share/fonts
	sudo cp -r $CONFDIR/others/fonts/* $HOME/.local/share/fonts
	fc-cache -fv
} || logerr "Minor Dependencies not found (others folder not found)"

[ -f /bin/feh ] && feh $HOME/.config/i3/wallpaper.png --bg-scale || logerr "feh failed, Mannual intervention needed"

[ ! -z "$1" ] && [ "$1" = "full" ] &&  log "Full Installation triggered, setting up network,backlight..."  && full_setup

log "Creating Xinitrc"
cat <<EOF >$HOME/.xinitrc
exec i3
EOF
