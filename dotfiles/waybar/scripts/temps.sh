#!/usr/bin/env bash
# Outputs JSON for Waybar (CPU temp); tries common AMD/Intel labels via sensors


best=$(sensors 2>/dev/null | awk '
/Tctl:|Tdie:|Package id 0:|CPU Temp:/ {gsub("+","",$2); gsub("°C","",$2); print int($2)}' | head -n1)


[ -z "$best" ] && best=0


icon=""
class=""
if [ "$best" -ge 85 ]; then class="hot"; fi


printf '{"text":"%s°C","class":"%s","icon":"%s"}\n' "$best" "$class" "$icon"
