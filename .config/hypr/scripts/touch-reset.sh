#!/usr/bin/env bash
# touch-reset.sh - recover from hyprgrass's stuck touch/gesture state
# (upstream issue #147: extra touches during an active edge workspace-swipe
# are not blocked and corrupt the gesture tracker). Reloading the plugin
# rebuilds its gesture state machine.
set -euo pipefail

hyprpm reload hyprgrass >/dev/null
notify-send -a touch "Touchscreen" "Touch gestures reset"
