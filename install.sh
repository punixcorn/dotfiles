#!/bin/bash

# install files for i3

function question() {
    printf "\e[32m[?]\e[0m %s\n" "$1"

}

function log() {
    printf "\e[32m[*]\e[0m %s\n" "$1"
}

function logwarn() {
    printf "\e[35m[!]\e[0m %s\n" "$1"
}

function logerr() {
    printf "\e[33m[-]\e[0m %s\n" "$1"
}

if [ -z "$1" ]; then
    logerr "Wrong arguments, usage:"
    echo "$0 <window-manager>"
    echo "Avaliable Window Managers:"
    echo -e "\tBspwm"
    echo -e "\ti3"
    exit 0
fi

if [[ "$1" = "Bspwm" ]] || [[ "$1" = "bspwm" ]]; then
    wm_ans=1
elif [ "$1" = "i3" ]; then
    wm_ans=2
fi

# asking which wm to install
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

function pre_installations() {
    log "Pre dependencies setup"
    git clone https://github.com/punixcorn/arch-setup
    [ -d arch-setup ] && {
        chmod +x arch-setup/*
        [ -z "$(grep "chaotic" /etc/pacman.conf)" ] && ./arch-setup/install-choatic-aur.sh || echo "choatic available"
        [ ! -f /bin/yay ] && ./arch-setup/install-yay.sh || echo "yay found"
    } || logerr "Cloning failed skipping..."
}

function install_zsh() {
    [ ! -f /bin/zsh ] && ./arch-setup/install-zsh.sh || {
        echo "zsh found"
        zsh
    }
}

function pacman_i3() {
    pre_installations
    sudo pacman -Sy i3-wm picom dunst polybar xss-lock xfce4-power-manager \
        mpd feh rofi alacritty conky uthash meson base-devel cmake ninja \
        python-pywal picom feh alsa-utils pulseaudio --noconfirm

    [ -f /bin/yay ] && yay -S light xfce-polkit || logerr "Failed to install from yay"
}

function pacman_bspwm() {
    pre_installations
    sudo pacman -Sy bspwm sxhkd rofi polybar alacritty dunst feh \
        xcb-util-cursor xsettingsd mpc mpd dmenu ncmpcpp python-gobject \
        xfce4-power-manager maim xclip xorg-xbacklight netcat alsa-utils \
        viewnior python-pywal xdg-user-dirs firefox chromium xorg-xrandr python pulseaudio --noconfirm

    [ -f /bin/yay ] && yay -S light xfce-polkit || logerr "Failed to install light & xfce-polkit from yay"
}

function debain_i3() {
    sudo apt update
    sudo apt install i3 rofi polybar alacritty dunst feh xss-lock \
        xsettingsd mpc mpd dmenu ncmpcpp alsa-utils network-manager network-manager-dev xbacklight \
        xfce4-power-manager maim xclip light netcat-openbsd picom \
        viewnior xdg-user-dirs firefox-esr chromium python3 -y

    python -m pip install --upgrade gobject pywal --break-system-packages
}

function debain_bspwm() {
    sudo apt update
    sudo apt install bspwm sxhkd rofi polybar alacritty dunst feh \
        xsettingsd mpc mpd dmenu ncmpcpp alsa-utils network-manager network-manager-dev xfce4-power-manager maim xclip light netcat-openbsd xss-lock picom xbacklight \
        viewnior xdg-user-dirs firefox-esr chromium python3 -y

    python -m pip install --upgrade gobject pywal --break-system-packages
}

# Installing Dependencies
log "Installing Dependencies"
if [ -f /bin/pacman ]; then
    if [ "$wm_ans" = "1" ]; then
        pacman_bspwm
    elif [ "$wm_ans" = "2" ]; then
        pacman_i3
    fi
else
    if [ "$wm_ans" = "1" ]; then
        debain_bspwm
    elif [ "$wm_ans" = "2" ]; then
        debain_i3
    fi
fi

log "Installing network Manager"
if [ ! -f /bin/networkmanager_dmenu ]; then
    git clone https://github.com/firecat53/networkmanager-dmenu.git networkmanagerdmenu
    chmod +x networkmanagerdmenu/networkmanager_dmenu
    sudo cp networkmanagerdmenu/networkmanager_dmenu /usr/bin/
    rm -rf networkmanagerdmenu
fi

# making picom always fails do mannually
# cd /tmp
# git clone https://github.com/pijulius/picom.git
# cd picom
# git submodule update --init --recursive
# meson --buildtype=release . build
# ninja -C build
# ninja -C build install

log "Making backups..."

config_home="$HOME/.config"
current_date="$(date '+%D%T')"
backup_dir="$config_home/backups_${current_date}"

# if .config doesn't exist theres probably config there, create backup_folder
if [ ! -d "$config_home" ]; then
    mkdir -p "$config_home"
else
    mkdir -p "$backup_dir"
fi

dirs=(
    "alacritty"
    "bin"
    "bspwm"
    "conky"
    "dunst"
    "fonts"
    "i3"
    "kitty"
    "networkmanager-dmenu"
    "picom"
    "polybar"
    "rofi"
    "wallpaper"
)

# Create a folder to put all the old folders
for dir in ${dirs[@]}; do
    if [ -d "$config_home/$dir" ]; then
        mv "$config_home/$dir" "$backup_dir"
    fi
done

log "Copying files over"
for dir in ${dirs[@]}; do
    cp -r "$dir" "$config_home"
done

log "copying fonts"
if [ ! -d /usr/share/fonts ]; then
    sudo mkdir -p /usr/share/fonts
fi

sudo cp -r fonts/* /usr/share/fonts/
fc-cache -fv

log "Laptop touchpad fix"
xorg_touch_file="50-libinput.conf"
sudo tee /etc/X11/xorg.conf.d/$xorg_touch_file <<!
Section "InputClass"
    Identifier "libinput touchpad catchall"
    MatchIsTouchpad "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    Option "Tapping" "on"
EndSection
!

log "fixing light"
sudo usermod -aG video "$USER"

question "install nvim and vim configs? [y,N]"
read -r ans

if [ "$ans" = 'Y' ] || [ "$ans" = 'y' ]; then
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

# setting up feh & wal
feh "$HOME"/.config/wallpaper/wallpaper.png --bg-scale || logerr "feh failed, Mannual intervention needed"
# incase it was installed using pip
export PATH="$PATH:$HOME/.local/bin/"
wal -i "$HOME"/.config/wallpaper/wallpaper.png || logerr "wal failed, Mannual intervention needed"

log "Creating Xinitrc"
tee "$HOME"/.xinitrc <<!
exec i3
!

# fixing xorg
#log "fixing xorg"
#fix_xorg
logwarn "if you are in vm you will need to run the fix_xorg function after installing and starting xorg"

# setting up variables
log "Setting up enviroment variables"
tee ~/.xprofile <<!
## Polybar env varibales
export DEFAULT_NETWORK_INTERFACE=\$(ip route | grep '^default' | awk '{print \$5}' | head -n1)
export DEFAULT_BATTERY=\$(ls -1 /sys/class/power_supply | awk '{ print \$1 }' | grep BAT)
export DEFAULT_ADAPTER=\$(ls -1 /sys/class/power_supply | awk '{ print \$1 }' | grep ADP)
!

chmod +x ~/.xprofile

#log "Running Theme for colors"
#. ~/.config/bin/applyTheme 1 &
#disown

# install zsh now because it will load into zsh shell after installation
install_zsh

exit 0
