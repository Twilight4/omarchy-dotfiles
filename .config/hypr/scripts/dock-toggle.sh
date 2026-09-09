#!/usr/bin/env bash
# dock-toggle.sh - show/hide the nwg-dock-hyprland app dock without
# restarting it. The dock runs in auto-hide mode (-d): the process stays
# alive with its layer unmapped, and SIGUSR1 toggles visibility (verified
# bidirectionally). First press launches it (hidden) and nudges it visible.
# Bonus of -d: hovering the bottom-edge hotspot reveals the dock, and it
# hides itself when the pointer leaves it or a launcher button is clicked.
# Triggered by 3-finger swipe up (see bindings.lua) and SUPER+D.
#
# --refresh: relaunch (hidden) with a rebuilt -g ignore list. Called by
# omarchy-launch-webapp when it creates a NEW web-app profile — the list
# is frozen at dock start, so a new app's class must join it before the
# first window maps. Never resurrects a dock the user killed on purpose.
#
# The -g list = fixed classes + every web-app class, derived from the
# .desktop Exec URLs with the same slug pipeline as the launcher, so
# web-app windows never clutter the dock taskbar.
set -euo pipefail

webapp_classes() {
    local f url
    for f in "$HOME"/.local/share/applications/*.desktop; do
        [[ -f $f ]] || continue
        url=$(sed -n 's/^Exec=.*omarchy-launch-webapp //p' "$f" | head -1)
        [[ -n $url ]] || continue
        printf '%s\n' "$url" | sed -E 's#^[a-z]+://(www\.)?##; s#/.*##; s#[^a-z0-9.-]##g; s#\.#-#g; s/^/webapp-/'
    done
    # zen profile dirs = every web app ever LAUNCHED (ad-hoc URLs never get
    # a .desktop); the launcher creates the profile before it refreshes the
    # dock, so even a first ad-hoc launch's window is covered.
    ls -d "$HOME"/.config/zen/webapp-* 2>/dev/null | xargs -r -n1 basename
}

launch_dock() {
    # GDK_SCALE=2: GTK3 renders a 2x buffer for the same logical size —
    # without it the 1.6 monitor scale upscales a 1x surface (blurry icons).
    GDK_SCALE=2 nwg-dock-hyprland -d -i 30 -w 5 -mb 10 -ml 10 -mr 10 \
        -c "$HOME/.config/hypr/scripts/app-launcher.sh" \
        -g "monitoring-kitty kitty-cliamp $(webapp_classes | sort -u | tr '\n' ' ')" >/dev/null 2>&1 &
}

if [[ ${1:-} == --refresh ]]; then
    pgrep -f nwg-dock-hyprland >/dev/null || exit 0
    pkill -f nwg-dock-hyprland
    sleep 0.5
    launch_dock
    exit 0
fi

if pgrep -f nwg-dock-hyprland >/dev/null; then
    pkill -USR1 -f nwg-dock-hyprland
else
    launch_dock
    # -d starts hidden; nudge visible only if it is still hidden once the
    # GTK app has actually mapped (a too-early USR1 races the main loop)
    ( sleep 2
      if pgrep -f nwg-dock-hyprland >/dev/null && ! hyprctl layers -j | grep -q nwg-dock; then
          pkill -USR1 -f nwg-dock-hyprland
      fi
    ) >/dev/null 2>&1 &
fi
