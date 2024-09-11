#!/bin/bash

# install files for bspwm
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
        [ -z "$(grep "choatic" /etc/pacman.conf)" ] && echo "choatic available" || ./arch-setup/install-choatic-aur.sh
        [ ! -f /bin/yay ] && ./arch-setup/install-yay.sh || echo "yay found"
        [ ! -f /bin/zsh ] && ./arch-setup/install-zsh.sh || echo "zsh found"
    } || logerr "Cloning failed skipping..."

    sudo pacman -Sy bspwm sxhkd rofi polybar alacritty dunst feh \
        xcb-util-cursor xsettingsd mpc mpd dmenu ncmpcpp python-gobject \
        xfce4-power-manager maim xclip xorg-xbacklight netcat \
        viewnior python-pywal xdg-user-dirs firefox chromium xorg-xrandr python --noconfirm

    [ -f /bin/yay ] && yay -S light xfce-polkit || logerr "Failed to install from yay"
    sudo pacman -S networkmanager-dmenu-git || logerr "Failed to install networkmanager-dmenu-git, please do it mannually"
}

function debain() {
    sudo apt update
    sudo apt install bspwm sxhkd rofi polybar alacritty dunst feh \
        xsettingsd mpc mpd dmenu ncmpcpp alsa-utils network-manager network-manager-dev xfce4-power-manager maim xclip light netcat-openbsd xss-lock picom xbacklight \
        viewnior xdg-user-dirs firefox-esr chromium python3 -y

    python -m pip install --upgrade gobject pywal
}

log "Installing Dependencies"
[ -f /bin/pacman ] && pacman || debain

log "Installing network Manager"
if [ ! -f /bin/networkmanager_dmenu ]; then
    git clone https://github.com/firecat53/networkmanager-dmenu.git
    chmod +x networkmanager-dmenu/networkmanager_dmenu
    sudo cp networkmanager-dmenu/networkmanager_dmenu /usr/bin/
    rm -rf networkmanager-dmenu
fi

log "Copying files over"
CONFDIR="$HOME/.config/bspwm/"

[ -d $CONFDIR ] && mv $CONFDIR $HOME/.config/bspwm-backup-$(date "+%a-%T")
[ ! -d $CONFDIR ] && mkdir -p $CONFDIR
cp -r -- * "$CONFDIR"

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

log "fixing light"
sudo usermod -aG video $USER

log "Laptop touchpad fix"
xorg_touch_file="50-libinput.conf"
[ -f /etc/X11/xorg.conf.d/${xorg_touch_file} ] && xorg_touch_file="231-libinput.conf"
echo "Section \"InputClass\"
        Identifier \"libinput touchpad catchall\"
        MatchIsTouchpad \"on\"
        MatchDevicePath \"/dev/input/event*\"
        Driver \"libinput\"
        Option \"Tapping\" \"on\"
     EndSection" | sudo tee /etc/X11/xorg.conf.d/$xorg_touch_file

EOF

if [ $ans = 'Y' ] || [ $ans = 'y' ]; then
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

log "Running Theme for colors"
./bin/applyTheme 1
exit 0
