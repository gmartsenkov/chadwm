#!/bin/sh

xrdb merge ~/.Xresources
xrandr --output HDMI-0 --mode 3840x2160 --rate 143.99
xbacklight -set 10 &
feh --bg-fill ~/Pictures/wallpaper.png &
xset r rate 200 50 &
picom &

~/.config/chadwm/scripts/bar.sh &
while type dwm >/dev/null; do dwm && continue || break; done
