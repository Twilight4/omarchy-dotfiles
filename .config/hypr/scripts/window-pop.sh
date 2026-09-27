#!/usr/bin/env bash
# Pop the active window out (float + pin) keeping its current size AND
# position. Stock omarchy-hyprland-window-pop defaults to 1300x900 centered,
# which exceeds the 1200x750 logical panel and looks like fullscreen. When the
# window is already popped, the stock script ignores geometry args (unpin
# branch), so this stays a clean toggle.
set -euo pipefail

read -r w h x y < <(hyprctl activewindow -j | jq -r '"\(.size[0]) \(.size[1]) \(.at[0]) \(.at[1])"')
exec omarchy-hyprland-window-pop "$w" "$h" "$x" "$y"
