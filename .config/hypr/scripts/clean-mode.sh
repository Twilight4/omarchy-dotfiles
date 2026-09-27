#!/usr/bin/env bash
# Clean mode: panel off + ALL touch swallowed by the taeryn.cleanmode overlay
# (fullscreen black layer-shell surface). The touchscreen device stays enabled
# so the overlay's MultiPointTouchArea can recognize the restoring 4-finger
# LEFT swipe — restoring is therefore touchscreen-only, exactly like entering
# (4-finger left, or SUPER+ALT+Y, or the touchpad mirror in input.lua).
# hyprgrass actions are gated on this flag file in bindings.lua, so raw touch
# events the plugin still sees cannot fire gestures underneath the overlay.
# The overlay itself watches this file (FileView) — it is the visibility truth.
set -euo pipefail

flag=$HOME/.local/state/omarchy/toggles/taeryn-clean-mode

if [[ -f $flag ]]; then
  rm -f "$flag"
  hyprctl dispatch 'hl.dsp.dpms({action="enable"})' >/dev/null
  omarchy-notification-send -g 󰐤 "Clean mode off" "Panel + touch on" || true
else
  mkdir -p "$(dirname "$flag")"
  touch "$flag"
  hyprctl dispatch 'hl.dsp.dpms({action="disable"})' >/dev/null
fi
