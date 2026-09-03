#!/usr/bin/env bash

# omarchy:summary=Toggle the layout on the current workspace between master and scrolling
# Stock omarchy-hyprland-workspace-layout-toggle cycles dwindle<->scrolling;
# this box pins general:layout = master (looknfeel.lua), so the stock toggle
# always lands on dwindle first. This cycles master<->scrolling instead.
# State files are re-applied on every config reload by omarchy's
# default/hypr/workspace-layouts.lua.

set -euo pipefail

ws_id=$(hyprctl activeworkspace -j | jq -r '.id')
[[ $ws_id =~ ^-?[0-9]+$ ]] || exit 1

current=$(hyprctl activeworkspace -j | jq -r '.tiledLayout')
case "$current" in
  scrolling) new_layout=master ;;
  *)         new_layout=scrolling ;;
esac

layouts_dir="$HOME/.local/state/omarchy/workspace-layouts"
mkdir -p "$layouts_dir"
printf 'hl.workspace_rule({ workspace = "%s", layout = "%s" })\n' "$ws_id" "$new_layout" >"$layouts_dir/$ws_id.lua"

hyprctl eval "hl.workspace_rule({ workspace = \"$ws_id\", layout = \"$new_layout\" })" >/dev/null
omarchy-notification-send -g 󱂬 "Workspace layout set to $new_layout"
