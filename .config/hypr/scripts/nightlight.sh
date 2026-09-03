#!/usr/bin/env bash
# nightlight.sh - toggle the night light, or step its temperature, with a
# desktop notification. Binds: SUPER+\ toggle, SUPER+ALT+\ warmer,
# SUPER+SHIFT+\ cooler (10% steps of the current temperature, clamped).
set -euo pipefail

OFF_TEMP=6500
MIN_TEMP=1000

notify() { notify-send -a nightlight "Night light" "$1"; }

case "${1:-}" in
  toggle)
    omarchy-toggle-nightlight
    temp=$(omarchy-toggle-nightlight --status | jq -r '.temperature // empty')
    if [[ -n $temp && $temp -lt 6000 ]]; then
      notify "On (${temp}K)"
    else
      notify "Off"
    fi
    ;;
  warmer|cooler)
    if ! pgrep -x hyprsunset >/dev/null; then
      setsid uwsm-app -- hyprsunset &
      sleep 0.3
    fi
    cur=$(hyprctl hyprsunset temperature | grep -oE '[0-9]+' | head -n1)
    [[ -z $cur ]] && exit 0
    step=$(( cur / 10 ))
    [[ $step -lt 100 ]] && step=100
    if [[ $1 == warmer ]]; then new=$(( cur - step )); else new=$(( cur + step )); fi
    (( new < MIN_TEMP )) && new=$MIN_TEMP
    (( new > OFF_TEMP )) && new=$OFF_TEMP
    [[ $new == "$cur" ]] && exit 0
    hyprctl hyprsunset temperature "$new" >/dev/null
    omarchy-shell -q nightlight refresh
    notify "${new}K"
    ;;
  *) echo "usage: nightlight.sh toggle|warmer|cooler" >&2; exit 1 ;;
esac
