#!/usr/bin/env bash
# dock-toggle.sh - show/hide the nwg-dock-hyprland app dock without
# restarting it. The dock runs in auto-hide mode (-d): the process stays
# alive with its layer unmapped, and SIGUSR1 toggles visibility (verified
# bidirectionally). First press launches it (hidden) and nudges it visible.
# Bonus of -d: hovering the bottom-edge hotspot reveals the dock, and it
# hides itself when the pointer leaves it or a launcher button is clicked.
# Triggered by 3-finger swipe up (see bindings.lua) and SUPER+D.
set -euo pipefail

if pgrep -f nwg-dock-hyprland >/dev/null; then
    pkill -USR1 -f nwg-dock-hyprland
else
    # GDK_SCALE=2: GTK3 renders a 2x buffer for the same logical size —
    # without it the 1.6 monitor scale upscales a 1x surface (blurry icons).
    GDK_SCALE=2 nwg-dock-hyprland -d -i 30 -w 5 -mb 10 -ml 10 -mr 10 \
        -c "$HOME/.config/hypr/scripts/app-launcher.sh" \
        -g "monitoring-kitty kitty-cliamp" >/dev/null 2>&1 &
    # -d starts hidden; nudge visible only if it is still hidden once the
    # GTK app has actually mapped (a too-early USR1 races the main loop)
    ( sleep 2
      if pgrep -f nwg-dock-hyprland >/dev/null && ! hyprctl layers -j | grep -q nwg-dock; then
          pkill -USR1 -f nwg-dock-hyprland
      fi
    ) >/dev/null 2>&1 &
fi
