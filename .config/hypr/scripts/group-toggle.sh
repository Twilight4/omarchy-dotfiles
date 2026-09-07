#!/usr/bin/env bash
# SUPER+SHIFT+G: move the focused window into or out of this workspace's
# group. One group per workspace: a grouped focused window leaves the group,
# an ungrouped one joins the group (direction = dominant axis toward it).
# No group on this workspace: no-op (SUPER+G creates one).
#
# Runs as an exec_cmd binding, NOT inside `hyprctl eval`: group state isn't
# exposed on Lua window objects (w.grouped is nil), and io.popen("hyprctl …")
# from a Lua bind deadlocks the compositor's IPC (~5s freeze) — exec_cmd
# detaches so the hyprctl calls below answer normally.
set -euo pipefail

active=$(hyprctl activewindow -j)
if [ "$active" = "null" ]; then exit 0; fi
addr=$(jq -r .address <<<"$active")
ws=$(jq -r .workspace.id <<<"$active")
at=$(jq -c .at <<<"$active")
clients=$(hyprctl -j clients)

# Focused window already in a group -> leave it.
if jq -e --arg a "$addr" 'any(.[]; .address == $a and (.grouped | length > 0))' <<<"$clients" >/dev/null; then
  hyprctl eval "hl.dispatch(hl.dsp.window.move({out_of_group=true}))" >/dev/null
  exit 0
fi

# Join the group on this workspace (first grouped window), toward its position.
g=$(jq -r --arg a "$addr" --argjson w "$ws" '
  [.[] | select(.address != $a and .workspace.id == $w and (.grouped | length > 0))]
  | if length > 0 then "\(.[0].at[0]) \(.[0].at[1])" else "" end' <<<"$clients")
if [ -z "$g" ]; then exit 0; fi
read -r gx gy <<<"$g"
dir=$(jq -rn --argjson a "$at" --argjson g "[$gx,$gy]" '
  ($g[0] - $a[0]) as $dx | ($g[1] - $a[1]) as $dy |
  if ($dx * $dx) >= ($dy * $dy) then (if $dx > 0 then "r" else "l" end)
  else (if $dy > 0 then "d" else "u" end) end')
hyprctl eval "hl.dispatch(hl.dsp.window.move({into_group='$dir'}))" >/dev/null
