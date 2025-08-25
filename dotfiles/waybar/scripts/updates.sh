#!/usr/bin/env bash
# Count pacman updates; if yay exists, include AUR


if ! command -v checkupdates >/dev/null 2>&1; then
echo '{"text":"0","icon":""}'
exit 0
fi


pac=$(checkupdates 2>/dev/null | wc -l)
aur=0
if command -v yay >/dev/null 2>&1; then
aur=$(yay -Qua 2>/dev/null | wc -l)
fi


total=$((pac + aur))
class=""
[ "$total" -ge 10 ] && class="attn"


printf '{"text":"%d","class":"%s","icon":""}\n' "$total" "$class"
