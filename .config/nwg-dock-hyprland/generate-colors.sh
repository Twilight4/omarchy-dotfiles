#!/bin/bash
# Re-tint the nwg dock window background from the current Omarchy theme —
# the same source the terminal background comes from
# (~/.local/state/omarchy/current/theme/colors.toml). Only the RGB is
# replaced; the alpha you tuned in style.css line 2 is preserved.
# Re-run by the theme-set.d/nwg-dock-colors.sh hook on every theme change.

set -euo pipefail

COLORS_TOML="$HOME/.local/state/omarchy/current/theme/colors.toml"
CSS="$HOME/.config/nwg-dock-hyprland/style.css"

[[ -f $COLORS_TOML && -f $CSS ]] || { echo "missing theme colors or style.css" >&2; exit 1; }

bg=$(sed -n 's/^background = "\(#[0-9a-fA-F]*\)".*/\1/p' "$COLORS_TOML")
[[ -n $bg ]] || { echo "no background color in $COLORS_TOML" >&2; exit 1; }

alpha=$(sed -n '2s/.*rgba([^,]*,[^,]*,[^,]*, *\([0-9.]*\)).*/\1/p' "$CSS")

r=$((16#${bg:1:2})); g=$((16#${bg:3:2})); b=$((16#${bg:5:2}))
sed -i "2s/.*/  background: rgba($r, $g, $b, ${alpha:-0.4});/" "$CSS"
echo "nwg-dock style.css tinted to theme background $bg"
