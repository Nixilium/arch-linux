#!/usr/bin/env bash
# Power menu wrapper: use wlogout if present, else wofi + systemctl


if [ "$1" = "--menu" ]; then
if command -v wlogout >/dev/null 2>&1; then
exec wlogout
else
choice=$(printf "lock\nsuspend\nreboot\npoweroff\nlogout" | wofi --show dmenu --prompt "power" )
case "$choice" in
lock) loginctl lock-session ;;
suspend) systemctl suspend ;;
reboot) systemctl reboot ;;
poweroff) systemctl poweroff ;;
logout) hyprctl dispatch exit ;;
esac
fi
exit 0
fi


# default JSON for the bar button
printf '{"text":"","icon":""}\n'
