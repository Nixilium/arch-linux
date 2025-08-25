#!/usr/bin/env bash
# Requires: playerctl, jq

PLAYER="${PLAYER:-spotify}"
BAR_STYLE="${BAR_STYLE:-ascii}"   # "ascii" or "unicode"
BAR_WIDTH="${BAR_WIDTH:-16}"

have_player=1
if ! playerctl -p "$PLAYER" status &>/dev/null; then
  have_player=0
fi

if (( have_player == 0 )); then
  # Show a launcher when no player is present
  icon=""
  [[ -z "$icon" ]] && icon="♪"
  text="$icon  Open Spotify"
  tooltip="Open Spotify"
  jq -cn --arg text "$text" --arg tooltip "$tooltip" --arg alt "stopped" --arg class "stopped" --argjson percentage 0 \
    '{text:$text, tooltip:$tooltip, alt:$alt, class:$class, percentage:$percentage}'
  exit 0
fi

status=$(playerctl -p "$PLAYER" status 2>/dev/null)
title=$(playerctl -p "$PLAYER" metadata xesam:title 2>/dev/null)
artist=$(playerctl -p "$PLAYER" metadata xesam:artist 2>/dev/null)
album=$(playerctl -p "$PLAYER" metadata xesam:album 2>/dev/null)
len_us=$(playerctl -p "$PLAYER" metadata mpris:length 2>/dev/null)
pos_s=$(playerctl -p "$PLAYER" position 2>/dev/null)

title=${title:-Unknown Title}
artist=${artist:-Unknown Artist}
album=${album:-}

length_s=0
[[ "$len_us" =~ ^[0-9]+$ ]] && length_s=$((len_us/1000000))
fmt_time() { local s=$1; ((s<0)) && s=0; printf "%d:%02d" $((s/60)) $((s%60)); }
pos_i=${pos_s%.*}
pos_fmt=$(fmt_time "${pos_i:-0}")
len_fmt=$(fmt_time "${length_s:-0}")

trim() { local s="$1" n="$2"; (( ${#s} > n )) && echo "${s:0:n-1}…" || echo "$s"; }
title=$(trim "$title" 32)
artist=$(trim "$artist" 22)

perc=0
if [[ "$length_s" -gt 0 ]]; then
  perc=$(( 100 * ${pos_i:-0} / length_s ))
  (( perc>100 )) && perc=100
  (( perc<0 )) && perc=0
fi

# Build progress bar
filled=$(( perc * BAR_WIDTH / 100 ))
empty=$(( BAR_WIDTH - filled ))
if [[ "$BAR_STYLE" == "unicode" ]]; then
  bar="$(printf '%*s' "$filled" '' | tr ' ' '█')$(printf '%*s' "$empty" '' | tr ' ' '░')"
else
  bar="$(printf '%*s' "$filled" '' | tr ' ' '#')$(printf '%*s' "$empty" '' | tr ' ' '-')"
fi

icon=""
[[ -z "$icon" ]] && icon="♪"
text="$icon  $title - $artist  $pos_fmt / $len_fmt  [$bar]"
tooltip="$title\n$artist${album:+\n$album}\n$status"

jq -cn --arg text "$text" --arg tooltip "$tooltip" --arg alt "$status" --arg class "$status" --argjson percentage "$perc" \
  '{text:$text, tooltip:$tooltip, alt:$alt, class:$class, percentage:$percentage}'
