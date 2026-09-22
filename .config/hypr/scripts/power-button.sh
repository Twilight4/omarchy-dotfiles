#!/usr/bin/env bash
# Smartphone-style power button (XF86PowerOff), wired from bindings.lua as a
# press + release bind pair:
#   tap  (< HOLD_MS)  -> screen off + lock; tap again -> screen on.
#   hold (>= HOLD_MS) -> wlogout power menu (screen forced on first).
# Runs detached from the bind exec, so hyprctl calls here are safe (io.popen
# from inside a Lua bind would deadlock the compositor IPC).
#
# Device realities handled here:
# - While held, the button emits a STREAM of extra press AND release events
#   (hardware key repeat). Discrimination is therefore two-stage: a press
#   while one is pending only refreshes the "still held" timestamp (the
#   original contact start is kept so the hold timer is unaffected), and a
#   release only counts once no further press arrived within CONFIRM_MS —
#   churn arrives far faster than that, a real finger does not come back.
# - Engaging the omarchy lock force-wakes the panel (its view fires
#   wake-on-input as it maps), which used to flash the lockscreen white for
#   a split second. The backlight is dropped to 0 BEFORE the lock engages,
#   so that frame renders invisibly; a short guard loop re-asserts dpms-off
#   once the wake lands, and the saved backlight level is restored on every
#   wake path. The lock's own 5s idle blank is the backstop.
set -u

HOLD_MS=600
CONFIRM_MS=200
GUARD_MS=2500
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/power-button"
stamp="$state_dir/press.ms"     # first press of the current contact
last="$state_dir/last.ms"       # refreshed by every press event
stop_guard="$state_dir/stop-guard"
saved_bl="$state_dir/backlight" # pre-off backlight % for restore
mkdir -p "$state_dir"

now_ms()    { date +%s%3N; }
wr()        { printf '%s' "$2" >"$1.tmp" && mv "$1.tmp" "$1"; } # churn-safe
screen_on() { hyprctl monitors -j | jq -e 'any(.[]; .dpmsStatus)' >/dev/null; }
dpms_off()  { hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })' >/dev/null; }

blank_screen() {
  dpms_off                                  # instant black
  local cur
  cur=$(omarchy-brightness-display 2>/dev/null) || cur=""
  [[ $cur =~ ^[0-9]+$ && $cur -gt 0 ]] && wr "$saved_bl" "$cur"
  omarchy-brightness-display --no-osd 0%    # hide the lock's engage flash
  omarchy-brightness-keyboard off
}
restore_backlight() {
  [[ -f $saved_bl ]] && omarchy-brightness-display --no-osd "$(cat "$saved_bl")%"
  rm -f "$saved_bl"
}
wake_screen() { : >"$stop_guard"; restore_backlight; omarchy-system-wake; }
guard_blank() {
  rm -f "$stop_guard"
  local end=$(( $(now_ms) + GUARD_MS ))
  while (( $(now_ms) < end )); do
    [[ -f $stop_guard ]] && exit 0
    screen_on && dpms_off
    sleep 0.1
  done
}
tap_off() {
  blank_screen
  omarchy-system-lock &
  guard_blank
}

case "${1:-}" in
press)
  n=$(now_ms)
  if [[ -f $stamp ]]; then
    wr "$last" "$n"                    # repeat press: still holding
    exit 0
  fi
  wr "$stamp" "$n"; wr "$last" "$n"
  (
    sleep "$(awk "BEGIN{printf \"%.3f\", $HOLD_MS/1000}")"
    [[ "$(cat "$stamp" 2>/dev/null)" = "$n" ]] || exit 0
    # Keep $stamp afterwards: post-menu repeat presses must not start a new
    # cycle — the next genuine release cleans it up.
    wake_screen
    pkill wlogout 2>/dev/null || wlogout
  ) &
  ;;
release)
  [[ -f $stamp ]] || exit 0            # nothing pending (post-menu / stray)
  rnow=$(now_ms)
  (
    sleep "$(awk "BEGIN{printf \"%.3f\", $CONFIRM_MS/1000}")"
    # A press after this release started means the contact never ended.
    (( $(cat "$last" 2>/dev/null || echo 0) > rnow )) && exit 0
    was=$(cat "$stamp")
    rm -f "$stamp" "$last"
    (( $(now_ms) - was < HOLD_MS )) || exit 0
    if screen_on; then tap_off; else wake_screen; fi
  ) &
  ;;
esac
