#!/bin/bash

function log() {
	printf "\e[32m[*]\e[0m %s\n" "$1"
}

function logerr() {
	printf "\e[33m[-]\e[0m %s\n" "$1"
}

log "Pre dependencies setup"
git clone https://github.com/punixcorn/arch-setup
[ -d arch-setup ] && {
	chmod +x arch-setup/*
	./arch-setup/install-choatic-aur.sh
	./arch-setup/install-yay.sh
	./arch-setup/install-zsh.sh
} || logerr "Cloning failed skipping..."

log "Installing Dependencies"
sudo pacman -Sy i3-wm picom dunst polybar xss-lock xfce4-power-manager mpd feh i3lock rofi alacritty conky uthash meson base-devel cmake ninja python-pywal picom feh

[ -f /bin/yay ] && yay -S light xfce-polkit || logerr "Failed to install from yay"
sudo pacman -S networkmanager-dmenu-git || logerr "Failed to install networkmanager-dmenu-git, please do it mannually"

# making picom always fails do mannually
# cd /tmp
# git clone https://github.com/pijulius/picom.git
# cd picom
# git submodule update --init --recursive
# meson --buildtype=release . build
# ninja -C build
# ninja -C build install

log "Copying files over"
[ ! -d "$HOME/.config/i3/" ] && mkdir -p $HOME/.config/i3 || {
	echo "i3 config found"
	mv $HOME/.config/i3/ $HOME/.config/i3-backup
	echo "backup done"
	mkdir -p "$HOME/.config/i3/"

}
cp -r * "$HOME/.config/i3/"
cp -r ./networkmanager_dmenu/ "$HOME/.config/"
[ ! -d $HOME/.local/share/fonts ] && mkdir -p $HOME/.local/share/fonts
sudo cp -r $HOME/.config/i3/fonts/* $HOME/.local/share/fonts
fc-cache -fv

[ -f /bin/wal ] && wal -i $HOME/.config/i3/wallpaper.png || logerr "wal failed, Mannual intervention needed"
[ -f /bin/feh ] && feh $HOME/.config/i3/wallpaper.png --bg-scale || logerr "feh failed, Mannual intervention needed"

log "Creating Xinitrc"
cat <<EOF >$HOME/.xinitrc
exec i3
EOF
