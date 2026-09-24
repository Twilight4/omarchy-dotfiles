#!/usr/bin/env bash
# SUPER+ALT+D — "Download video from web app": Chromium-extension-free port of
# Omarchy's yt-dlp extension for Zen. Synthesizes Ctrl+L + Ctrl+C into the
# focused browser window via hl.dsp.send_key_state (the same path the
# keybindings menu's static "Download Video from Web App" row dispatches;
# synthetic keys enter at the compositor seat, so xremap's C-l remap is
# bypassed and zen receives the real URL-bar shortcut), reads the URL from the
# Wayland clipboard, then re-execs this script's --download worker inside a
# focused floating kitty (class video-download) running yt-dlp with the user's
# ydl flags (mp4, --restrict-filenames) into $(xdg-user-dir VIDEOS)/youtube,
# mirroring the omarchy native host (omarchy-chromium-ytdlp-host --download)
# minus its OSD.

set -euo pipefail

SCRIPT_PATH="${BASH_SOURCE[0]}"
DOWNLOAD_DIR="${OMARCHY_YTDLP_DIR:-$(xdg-user-dir VIDEOS)/youtube}"
# ponytail: activewindow is the only real target; VD_WINDOW exists so tests can
# drive a specific window by address ("address:0x…") without stealing focus.
VD_WINDOW="${VD_WINDOW:-activewindow}"

say() { omarchy-notification-send -g 󰇚 "$1" "$2" || true; }

send_key() { # send_key <mods> <key>
  hyprctl dispatch "hl.dsp.send_key_state({ mods = \"$1\", key = \"$2\", state = \"down\", window = \"$VD_WINDOW\" })" >/dev/null
  hyprctl dispatch "hl.dsp.send_key_state({ mods = \"$1\", key = \"$2\", state = \"up\", window = \"$VD_WINDOW\" })" >/dev/null
}

download() {
  local url=$1 records filepath
  mkdir -p "$DOWNLOAD_DIR"
  records=$(mktemp)

  # ponytail: no --simulate precheck — the terminal is the feedback surface
  # ydl parity (scripts.zsh): --restrict-filenames -f mp4. --no-playlist kept
  # because the grabbed URL carries &list= — without it a music radio queue
  # would dump dozens of videos.
  yt-dlp --no-playlist --restrict-filenames -f mp4 --progress --newline \
    --paths "$DOWNLOAD_DIR" -o '%(title)s.%(ext)s' \
    --print 'after_move:VD_FILE %(filepath)s' -- "$url" | tee "$records" || true

  # after_move only prints on a successful download+move (same contract as the
  # native host's OMARCHY_FILE record).
  filepath=$(sed -n 's/^VD_FILE //p' "$records" | tail -n1)
  rm -f "$records"

  if [[ -n $filepath && -f $filepath ]]; then
    omarchy-notification-send -g 󰄬 "Download complete" "${filepath##*/}" \
      -t 10000 --exec mpv -- "$filepath" || true
    printf '\n✅ %s\n' "$filepath"
  else
    omarchy-notification-send -u critical -g 󰅖 "Download failed" "$url" || true
    printf '\n❌ download failed\n'

  fi

  printf '\nPress any key to close…'
  read -r -n1 -s
}

grab_and_launch() {
  local class url
  class=$(hyprctl activewindow -j | jq -r '.class // ""')
  case $class in
    zen | webapp-*) ;;
    *)
      say "Not a browser window" "Focus a browser tab playing the video first"
      exit 0
      ;;
  esac

  # The URL stays on the clipboard afterwards — that's the feature.
  send_key CTRL L # focus + select the URL bar contents
  sleep 0.3
  send_key CTRL C
  sleep 0.2
  send_key "" Escape # hand focus back to the page

  url=$(wl-paste --no-newline 2>/dev/null || true)
  if [[ ! $url =~ ^https?:// ]]; then
    say "No URL captured" "Ctrl+L + Ctrl+C didn't copy one"
    exit 0
  fi

  uwsm app -- kitty --class video-download -e bash "$SCRIPT_PATH" --download "$url"
}

if [[ ${1:-} == --download && -n ${2:-} ]]; then
  download "$2"
else
  grab_and_launch
fi
