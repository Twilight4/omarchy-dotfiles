#!/bin/bash
# Toggle the quickshell app-grid launcher (rofi-style; .config/qs-applauncher).
# Process-per-summon like rofi: pkill closes an open instance, otherwise a
# fresh quickshell instance is started against the standalone config.

set -euo pipefail

if pgrep -f "quickshell.*qs-applauncher" >/dev/null; then
    pkill -f "quickshell.*qs-applauncher"
else
    quickshell -p "$HOME/.config/qs-applauncher" >/dev/null 2>&1 &
fi
