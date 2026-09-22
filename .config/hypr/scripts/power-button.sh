#!/usr/bin/env bash
# Smartphone-style power button (XF86PowerOff), wired from bindings.lua as a
# press + release bind pair:
#   tap  (< HOLD_MS)  -> screen off + lock; tap again -> screen on.
#                        Touch never wakes it: looknfeel.lua sets
#                        mouse_move_enables_dpms=false, and touch motion
#                        routes through that unified wake path.
#   hold (>= HOLD_MS) -> wlogout power menu (screen forced on first).
# Runs detached from the bind exec, so hyprctl/dispatch calls are safe here
# (io.popen from inside a Lua bind would deadlock the compositor IPC).
set -u

HOLD_MS=600
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/power-button"
press_file="$state_dir/press.ms"
mkdir -p "$state_dir"

screen_on() { hyprctl monitors -j | jq -e 'any(.[]; .dpmsStatus)' >/dev/null; }
dpms()      { hyprctl dispatch "hl.dsp.dpms($1)" >/dev/null; }

case "${1:-}" in
press)
  now=$(date +%s%3N)
  printf '%s' "$now" >"$press_file"
  # Arm the hold: fire only if the key is still down after HOLD_MS — a quick
  # release deletes press_file first and disarms us.
  (
    sleep "$(awk "BEGIN{printf \"%.3f\", $HOLD_MS/1000}")"
    [ "$(cat "$press_file" 2>/dev/null)" = "$now" ] || exit 0
    rm -f "$press_file"
    dpms true                # menu must be visible even if screen was off
    pkill wlogout 2>/dev/null || wlogout
  ) &
  ;;
release)
  [ -f "$press_file" ] || exit 0   # hold already fired, or stray release
  now=$(date +%s%3N)
  was=$(cat "$press_file")
  rm -f "$press_file"
  (( now - was >= HOLD_MS )) && exit 0
  if screen_on; then
    omarchy-system-lock
    dpms false
  else
    dpms true
  fi
  ;;
esac
