#!/usr/bin/env bash
# Match the Plymouth boot screen (and SDDM login) to the CURRENT Omarchy
# theme. Wraps omarchy-plymouth-set with the theme's colors.toml palette.
# The stock omarchy-plymouth-set-by-theme requires an unlock.png logo that
# user-generated wp-* themes don't carry, so fall back to the theme's
# background wallpaper, dereferenced (the staged copy must not be a symlink)
# and cover-cropped to the panel's native resolution, then patch the
# installed Plymouth script to draw it FULLSCREEN (stock centers the logo at
# native size). Needs sudo; the keybind runs it in a floating kitty for the
# password prompt + mkinitcpio progress.
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

fullscreen=0
logo="$theme_dir/unlock.png"
if [[ ! -f $logo ]]; then
  wallpaper=$(find -L "$theme_dir/backgrounds" -maxdepth 1 -type f | head -1)
  [[ -n $wallpaper ]] || { echo "No unlock.png and no background in $theme_dir" >&2; exit 1; }
  logo=$(mktemp --suffix=.png)
  trap 'rm -f "$logo"' EXIT
  read -r w h < <(hyprctl monitors -j | jq -r '.[] | "\(.width) \(.height)"' 2>/dev/null | head -1)
  w=${w:-1920}; h=${h:-1080}
  magick "$wallpaper" -resize "${w}x${h}^" -gravity center -extent "${w}x${h}" "$logo"
  fullscreen=1
fi

omarchy-plymouth-set "$bg" "$text" "$logo"

if (( fullscreen )); then
  # Stock script centers the logo at native size and anchors the password
  # entry just under it. Redraw the logo as a fullscreen cover-fit sprite and
  # re-anchor the (hidden-until-needed) password/progress UI below center.
  sudo python3 - "$w" "$h" <<'EOF'
import sys
w, h = int(sys.argv[1]), int(sys.argv[2])
p = "/usr/share/plymouth/themes/omarchy/omarchy.script"
s = open(p).read()
old_logo = """logo.image = Image("logo.png");
logo.sprite = Sprite(logo.image);
logo.sprite.SetX(Window.GetWidth() / 2 - logo.image.GetWidth() / 2);
logo.sprite.SetY(Window.GetHeight() / 2 - logo.image.GetHeight() / 2);"""
new_logo = f"""logo_src = Image("logo.png");
logo_ratio = {w} / logo_src.GetWidth();
if ({h} / logo_src.GetHeight() > logo_ratio) logo_ratio = {h} / logo_src.GetHeight();
logo.image = logo_src.Scale(logo_src.GetWidth() * logo_ratio, logo_src.GetHeight() * logo_ratio);
logo.sprite = Sprite(logo.image);
logo.sprite.SetX(({w} - logo.image.GetWidth()) / 2);
logo.sprite.SetY(({h} - logo.image.GetHeight()) / 2);"""
old_entry = "entry.y = logo.sprite.GetY() + logo.image.GetHeight() + 40;"
new_entry = "entry.y = Window.GetHeight() * 0.6;"
for old, new in ((old_logo, new_logo), (old_entry, new_entry)):
    if old not in s:
        sys.exit(f"patch target missing: {old[:40]!r}")
    s = s.replace(old, new)
open(p, "w").write(s)
EOF
  # omarchy-plymouth-set already rebuilt the initramfs with the STOCK script;
  # rebuild once more to pick up the fullscreen patch.
  if omarchy-cmd-present limine-mkinitcpio; then
    sudo limine-mkinitcpio
  else
    sudo mkinitcpio -P
  fi
fi
