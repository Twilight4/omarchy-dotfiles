#!/usr/bin/env bash
# touch-reset.sh - recover from hyprgrass's stuck touch/gesture state
# (upstream issue #147: extra touches during an active edge workspace-swipe
# are not blocked and corrupt the gesture tracker). Two resets: bounce the touch device off/on in Hyprland (resets libinput
# touch state; `hyprpm reload` alone is a no-op for an already-loaded
# plugin), then reload the plugin to rebuild its gesture state machine.
set -euo pipefail

DEV="elan9008:00-04f3:2ed7"
hyprctl eval "hl.config({device={{name=\"$DEV\", enabled=false}}})" >/dev/null
sleep 1
hyprctl eval "hl.config({device={{name=\"$DEV\", enabled=true}}})" >/dev/null
hyprpm reload hyprgrass >/dev/null
notify-send -a touch "Touchscreen" "Touch gestures reset"
