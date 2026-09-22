#!/usr/bin/env bash
# Smartphone-style power button (XF86PowerOff), wired from bindings.lua as a
# press + release bind pair:
#   tap  (< HOLD_MS)  -> screen off + lock; tap again -> screen on.
#   hold (>= HOLD_MS) -> wlogout power menu (screen forced on first).
# Runs detached from the bind exec, so hyprctl calls here are safe (io.popen
# from inside a Lua bind would deadlock the compositor IPC).
#
# Two device realities this works around:
# - The power button AUTO-REPEATS while held (hardware key repeat — extra
#   press events keep arriving). A press while one is pending is treated as
#   a repeat and ignored, so the hold timer keeps the ORIGINAL timestamp.
# - Engaging the omarchy lock force-wakes the display shortly after it maps
#   (the lock view's wake-on-input fires as the surface appears). The blank
#   is therefore re-asserted for a settle window (GUARD_MS) while the lock
#   engages in the background; the lock's own 5s idle blank is the backstop.
#   Intentional wakes (tap-on, hold) set stop-guard so the guard yields.
set -u

HOLD_MS=600
GUARD_MS=2500
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/power-button"
press_file="$state_dir/press.ms"
stop_guard="$state_dir/stop-guard"
mkdir -p "$state_dir"

screen_on() { hyprctl monitors -j | jq -e 'any(.[]; .dpmsStatus)' >/dev/null; }
blank()     { hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })' >/dev/null; omarchy-brightness-keyboard off; }
wake()      { : >"$stop_guard"; omarchy-system-wake; }
guard_blank() {
  rm -f "$stop_guard"
  local end=$(( $(date +%s%3N) + GUARD_MS ))
  while (( $(date +%s%3N) < end )); do
    [ -f "$stop_guard" ] && exit 0
    screen_on && blank
    sleep 0.1
  done
}

case "${1:-}" in
press)
  # Hardware key repeat: swallow presses while one is pending.
  [ -f "$press_file" ] && exit 0
  now=$(date +%s%3N)
  printf '%s' "$now" >"$press_file"
  # Arm the hold: fire only if the key is still down after HOLD_MS — a quick
  # release deletes press_file first and disarms us.
  (
    sleep "$(awk "BEGIN{printf \"%.3f\", $HOLD_MS/1000}")"
    [ "$(cat "$press_file" 2>/dev/null)" = "$now" ] || exit 0
    rm -f "$press_file"
    wake                  # menu must be visible even if screen was off
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
    blank                        # instant black, then lock behind it
    omarchy-system-lock &
    guard_blank                  # re-blank the lock's engage-wake
  else
    wake
  fi
  ;;
esac
