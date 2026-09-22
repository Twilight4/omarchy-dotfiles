#!/usr/bin/env bash
# Power button tap: screen off + lock; tap again to show the lockscreen.
# No hold action, no menu.
#
# Two device facts this respects:
# - The button emits key-repeat churn (extra press/release events per
#   physical press). Only the last event of a burst — after 250ms of
#   quiet — toggles.
# - The omarchy lock force-wakes the panel as it engages. The backlight is
#   dropped to 0 BEFORE locking, so that frame is invisible; the lock's own
#   5s idle blank then powers the panel down for good. Touch can't visibly
#   wake the screen while the backlight is 0 (its wake only re-enables dpms).
set -u
state="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/power-button"
saved="$state/backlight"
mkdir -p "$state"

n=$(date +%s%3N)
printf '%s' "$n" >"$state/burst.tmp" && mv "$state/burst.tmp" "$state/burst"
(
  sleep 0.25
  [ "$(cat "$state/burst" 2>/dev/null)" = "$n" ] || exit 0  # superseded

  awake() {
    hyprctl monitors -j | jq -e 'any(.[]; .dpmsStatus)' >/dev/null \
      && [ "$(omarchy-brightness-display 2>/dev/null || echo x)" != 0 ]
  }
  if awake; then
    b=$(omarchy-brightness-display 2>/dev/null)
    [[ $b =~ ^[0-9]+$ && $b -gt 0 ]] && printf '%s' "$b" >"$saved.tmp" && mv "$saved.tmp" "$saved"
    omarchy-brightness-display --no-osd 0%
    hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })' >/dev/null
    omarchy-brightness-keyboard off
    omarchy-system-lock &
  else
    [ -f "$saved" ] && omarchy-brightness-display --no-osd "$(cat "$saved")%"
    rm -f "$saved"
    omarchy-system-wake
  fi
) &
