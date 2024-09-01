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

function debain() {
    sudo apt update
    sudo apt install i3 rofi polybar alacritty dunst feh xss-lock \
        xsettingsd mpc mpd dmenu ncmpcpp alsa-utils network-manager network-manager-dev  \
        xfce4-power-manager maim xclip light netcat-openbsd picom \
        viewnior xdg-user-dirs firefox-esr chromium python3 -y

    python -m pip install --upgrade gobject pywal
}

function pacman() {
    log "Pre dependencies setup"
    git clone https://github.com/punixcorn/arch-setup
    [ -d arch-setup ] && {
        chmod +x arch-setup/*
        [ -z "$(grep "choatic" /etc/pacman.conf)" ] && echo "choatic available" || ./arch-setup/install-choatic-aur.sh
        [ ! -f /bin/yay ] && ./arch-setup/install-yay.sh || echo "yay found"
        [ ! -f /bin/zsh ] && ./arch-setup/install-zsh.sh || echo "zsh found"
    } || logerr "Cloning failed skipping..."

    sudo pacman -Sy i3-wm picom dunst polybar xss-lock xfce4-power-manager mpd feh i3lock rofi alacritty conky uthash meson base-devel cmake ninja python-pywal picom feh -no-confirm

    [ -f /bin/yay ] && yay -S light xfce-polkit || logerr "Failed to install from yay"
    sudo pacman -S networkmanager-dmenu-git || logerr "Failed to install networkmanager-dmenu-git, please do it mannually"

}

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


log "fixing light"
sudo usermod -aG video $USER

# log "Laptop touchpad fix"
# xorg_touch_file="50-libinput.conf"
# [ -f /etc/X11/xorg.conf.d/${xorg_touch_file} ] && xorg_touch_file="231-libinput.conf"
# sudo cat <<EOF >/etc/X11/xorg.conf.d/$xorg_touch_file
# Section "InputClass"
#         Identifier "libinput touchpad catchall"
#         MatchIsTouchpad "on"
#         MatchDevicePath "/dev/input/event*"
#         Driver "libinput"
#         Option "Tapping" "on"
# EndSection
# EOF

echo "install nvim and vim configs? [y,N]"
read ans

if [ $ans = 'Y' ] || [ $ans = 'y' ];then 
    [ -f /bin/pacman ] && sudo pacman -S neovim vim || sudo apt install neovim vim 
    [ -d ~/.vim ] && mv ~/.vim ~/.vim-$(date "+%a-%T")
    [ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim-$(date "+%a-%T")

    log "Installing vim"
    git clone https://github.com/punixcorn/vim-dots ~/.vim 
    chmod +x ~/.vim/install.sh
    bash ~/.vim/install.sh

    log "Installing neovim"
    git clone https://github.com/punixcorn/nvim-dots ~/.config/nvim
    chmod +x ~/.config/nvim 
    bash ~/.config/nvim/install.sh
fi
