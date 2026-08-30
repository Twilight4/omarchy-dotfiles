#!/usr/bin/env bash
# webapp-wmclass.sh - add StartupWMClass to omarchy webapp .desktop files so
# the nwg dock (and any taskbar) maps webapp windows to their icons.
#
# Zen renders --app windows with class:
#   chrome-<host><path with / replaced by _>-Default
# e.g. https://youtube.com/ -> chrome-youtube.com__-Default
#      https://discord.com/channels/@me -> chrome-discord.com__channels_@me-Default
# (URL fragments/queries are dropped; no-path URLs normalize to "/".)
# Classes verified by launching each webapp and reading hyprctl clients —
# re-verify if zen changes the scheme. Handlers (omarchy-webapp-handler-*)
# open fixed URLs, mapped by name.
#
# Idempotent: entries that already have StartupWMClass are skipped.
# Usage: webapp-wmclass.sh [applications-dir]   (default: ~/.local/share/applications)
set -euo pipefail

apps_dir="${1:-${HOME}/.local/share/applications}"

handler_url() {
    case "$1" in
        hey)  echo "https://app.hey.com/" ;;
        zoom) echo "https://app.zoom.us/wc/home" ;;
        *)    return 1 ;;
    esac
}

class_from() { # $1 = url -> chrome class
    local url host path
    url="${1%%#*}"; url="${url%%\?*}"
    url="${url#https://}"; url="${url#http://}"
    host="${url%%/*}"
    path="${url#"$host"}"; [[ -z $path ]] && path="/"
    printf 'chrome-%s_%s' "$host" "${path//\//_}"
}

for f in "$apps_dir"/*.desktop; do
    [[ -e $f ]] || continue
    grep -q '^StartupWMClass=' "$f" && continue
    exec_line=$(grep -m1 '^Exec=' "$f" | sed 's/^Exec=//') || continue
    case "$exec_line" in
        *omarchy-webapp-handler*)
            url=$(handler_url "$(printf '%s' "$exec_line" | grep -oE 'handler-[a-z0-9]+' | head -1 | cut -d- -f2)") || continue
            ;;
        omarchy-launch-webapp*)
            url=$(printf '%s' "$exec_line" | awk '{print $2}')
            ;;
        *)  continue ;;
    esac
    [[ -n $url ]] || continue
    wmclass="$(class_from "$url")-Default"
    sed -i "/^Icon=/a StartupWMClass=$wmclass" "$f"
    echo "$(basename "$f"): $wmclass"
done

update-desktop-database "$apps_dir" 2>/dev/null || true
