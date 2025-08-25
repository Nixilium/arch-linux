#!/usr/bin/env bash
# Focus Spotify if running; otherwise launch it (native first, then Flatpak).

# Try to focus an existing window (Hyprland)
if command -v hyprctl >/dev/null 2>&1; then
  if hyprctl clients | grep -qE 'class: +Spotify\b'; then
    hyprctl dispatch focuswindow class:^(Spotify)$
    exit 0
  fi
fi

# Launch
if command -v spotify >/dev/null 2>&1; then
  (spotify >/dev/null 2>&1 & disown)
elif command -v flatpak >/dev/null 2>&1; then
  (flatpak run com.spotify.Client >/dev/null 2>&1 & disown)
fi
