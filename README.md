# dotfiles for i3 and Bspwm

| ~               | Tool                                    |
| --------------- | --------------------------------------- |
| Terminal        | alacritty                               |
| Network Manager | networkmanager and networkmanager-dmenu |
| Menu            | dmenu & rofi                            |
| theme           | pywal                                   |
| browser         | firefox-esr & chromium                  |
| Notifications   | dunst                                   |
| compositor      | picom                                   |
| bar             | polybar                                 |

# install

- you must pass a one of these window manager to `install.sh`:
  - i3
  - bspwm

```sh
    cd dotfiles && chmod +x install.sh && ./install.sh i3
```

- After installation, you can using your display manager or

```sh
startx
```

# More Info

### 1.Needed Keybindings

| tool              | keybindings     |
| ----------------- | --------------- |
| Close Application | **WIN + C**     |
| Terminal          | **WIN + ENTER** |
| Firefox           | **WIN + W**     |
| Network Menu      | **WIN + N**     |
| Application Menu  | **WIN + D**     |
| Themes menu       | **WIN + T**     |
| Discord           | **WIN + Z**     |
| Telegram          | **WIN+A**       |

### 2.Wallpapers and Themes

- wallpapers are to placed in `~/.config/wallpaper/` in `png` format
- theme is made by pywal based on wallpapers in `~/.config/wallpaper/`
- Choose a theme by calling `WIN+T`

# ERRORS

- calling terminal fails
  - you probably don't have mesa-drivers installed
- calling networkmanager-dmenu fails
  - it probably didn't install well
  - make sure `~/.config/networkmanager-dmenu/config.ini` exists
- polybar doesn't show all the stuff
  - need to mannually edit polybar variables
