#!/bin/dash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/.config/chadwm/scripts/bar_themes/nord

cpu() {
  cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

  printf "^c$black^ ^b$green^ CPU"
  printf "^c$white^ ^b$grey^ $cpu_val"
}

pkg_updates() {
  # updates=$(doas xbps-install -un | wc -l) # void
  updates=$(pacman -Qu | wc -l)   # arch
  # updates=$(aptitude search '~U' | wc -l)  # apt (ubuntu,debian etc)

  if [ "$updates" -eq "0" ]; then
    result="^c$green^  Fully Updated"
  else
    result="^c$green^  $updates"" updates"
  fi

  printf "$result"
}

battery() {
  get_capacity="$(cat /sys/class/power_supply/BAT1/capacity)"
  printf "^c$blue^   $get_capacity"
}

brightness() {
  printf "^c$red^   "
  printf "^c$red^%.0f\n" $(cat /sys/class/backlight/*/brightness)
}

mem() {
  printf "^c$blue^^b$black^  "
  printf "^c$blue^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
	case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
	up) printf "^c$black^ ^b$blue^ 󰤨 ^d^%s" " ^c$blue^Connected" ;;
	down) printf "^c$black^ ^b$blue^ 󰤭 ^d^%s" " ^c$blue^Disconnected" ;;
	esac
}

clock() {
	printf "^c$black^ ^b$darkblue^ 󱑆 "
	printf "^c$black^^b$blue^ $(date '+%H:%M %d-%b')  "
}

volume() {
  vol=$(amixer get Master | tail -n1 | sed -r 's/.*\[(.*)%\].*/\1/')
  muted=$(amixer get Master | tail -2 | grep -c '\[on\]')

  if [ "$muted" -eq "2" ]; then
    result="^b$darkblue^^c$grey^  $vol ^d^"
  else
    result="^b$darkblue^^c$grey^  Muted ^d^"
  fi

  printf "$result"
}

weather() {
  temp=$(curl -s 'wttr.in/Cambridge?format=%C+%t')

  printf "^b$grey^^c$white^ $temp ^d^"
}

spotify() {
   playstatus=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'PlaybackStatus'|egrep -A 1 "string"|cut -b 26-|cut -d '"' -f 1|egrep -v ^$)
   # artist=`dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 2 "artist"|egrep -v "artist"|egrep -v "array"|cut -b 27-|cut -d '"' -f 1|egrep -v ^$`
   # album=`dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 1 "album"|egrep -v "album"|cut -b 44-|cut -d '"' -f 1|egrep -v ^$`
   title=$(dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata'|egrep -A 1 "title"|egrep -v "title"|cut -b 44-|cut -d '"' -f 1|egrep -v ^$)

   if [ "$playstatus" = "Playing" ]; then
      result="^b$darkblue^^c$grey^  $title ^d^"
   else
      result="^b$darkblue^^c$grey^  $title ^d^"
   fi

  printf "$result"
}

while true; do

  [ $interval = 0 ] || [ $(($interval % 3600)) = 0 ] && updates=$(pkg_updates) && weather=$(weather)
  interval=$((interval + 1))

  spotifypid="$(pidof -s spotify || pidof -s .spotify-wrapped)"
  if [ -z "$spotifypid"]; then
     sleep 1 && xsetroot -name "$updates $weather $(cpu) $(mem) $(wlan) $(volume) $(clock)"
  else
     sleep 1 && xsetroot -name "$updates $weather $(spotify) $(cpu) $(mem) $(wlan) $(volume) $(clock)"
  fi
done
