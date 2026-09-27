#!/usr/bin/env bash
# Match the Plymouth boot screen (and SDDM login) to the CURRENT Omarchy
# theme. Wraps omarchy-plymouth-set with the theme's colors.toml palette.
# The stock omarchy-plymouth-set-by-theme requires an unlock.png logo that
# user-generated wp-* themes don't carry, so fall back to the theme's
# background wallpaper, dereferenced (the staged copy must not be a symlink)
# and shrunk (Plymouth centers the logo at NATIVE size — a full wallpaper
# would overflow the boot screen). Needs sudo; the keybind runs it in a
# floating kitty for the password prompt + mkinitcpio progress.
set -euo pipefail

slug=$(cat "$HOME/.local/state/omarchy/current/theme.name")
theme_dir=$(omarchy-theme-dir "$slug")

theme_color() { # <key> — same parsing as omarchy-plymouth-set-by-theme
  awk -F= -v key="$1" '
    function clean(raw) {
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", raw)
      if (raw ~ /^"/) { sub(/^"/, "", raw); sub(/".*$/, "", raw) }
      return raw
    }
    { field = $1; gsub(/^[[:space:]]+|[[:space:]]+$/, "", field)
      if (field == key) { print clean($2); exit } }
  ' "$theme_dir/colors.toml"
}

bg=$(theme_color background)
text=$(theme_color foreground)

logo="$theme_dir/unlock.png"
if [[ ! -f $logo ]]; then
  wallpaper=$(find -L "$theme_dir/backgrounds" -maxdepth 1 -type f | head -1)
  [[ -n $wallpaper ]] || { echo "No unlock.png and no background in $theme_dir" >&2; exit 1; }
  logo=$(mktemp --suffix=.png)
  trap 'rm -f "$logo"' EXIT
  magick "$wallpaper" -resize '700x400>' "$logo"
fi

exec omarchy-plymouth-set "$bg" "$text" "$logo"
