#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
#
# Deploys the tracked configs into ~/.config. NON-destructive on purpose:
# unlike the official dotfiles deploy (rm -rf + cp), this copies tracked paths
# over the live tree so Omarchy-managed files we don't track survive, and
# omarchy-update/refresh can keep doing its per-file .bak backups.

info "Deploying configs into ~/.config ..."

# Tracked top-level dirs under .config/
deploy_dirs=(
    hypr
    systemd
    omarchy
    kitty
    gtk-3.0
    gtk-4.0
    wlogout
    nwg-dock-hyprland
    xremap
    qs-applauncher
)

for d in "${deploy_dirs[@]}"; do
    src="$REPO_DIR/.config/$d"
    dst="$HOME/.config/$d"
    [[ -d $src ]] || { warn "Tracked dir missing, skipping: $src"; continue; }
    mkdir -p "$dst"
    cp -a "$src/." "$dst/"
    ok "Deployed ~/.config/$d"
done
# Tracked top-level files under .config/
deploy_files=("user-dirs.dirs")
for f in "${deploy_files[@]}"; do
  src="$REPO_DIR/.config/$f"
  dst="$HOME/.config/$f"
  [[ -f $src ]] || { warn "Tracked file missing, skipping: $src"; continue; }
  cp -a "$src" "$dst" && ok "Deployed ~/.config/$f"
done
# Tracked webapp launchers + icons (~/.local/share): .desktop entries made by
# omarchy-webapp-install are user data, not omarchy-managed, so track them here.
for sub in applications icons; do
    src="$REPO_DIR/.local/share/$sub"
    dst="$HOME/.local/share/$sub"
    [[ -d $src ]] || continue
    mkdir -p "$dst"
    cp -a "$src/." "$dst/"
    ok "Deployed ~/.local/share/$sub"
done

# Tracked user scripts (~/.config/.local/bin, the same layout as the Garuda
# repo): webcam pop-ups (webcam0/2.sh) and the taeryn-capture-rect helper the
# taeryn.capture bar plugin calls.
if [[ -d $REPO_DIR/.config/.local/bin ]]; then
    mkdir -p "$HOME/.config/.local/bin"
    cp -a "$REPO_DIR/.config/.local/bin/." "$HOME/.config/.local/bin/"
    ok "Deployed ~/.config/.local/bin"
fi

# wlogout colors are generated from the current Omarchy theme (colors.css is
# gitignored); the theme-set.d/wlogout-colors.sh hook regenerates on theme
# changes, but seed it once here so a fresh deploy has colors immediately.
if [[ -x $HOME/.config/wlogout/generate-colors.sh ]]; then
    "$HOME/.config/wlogout/generate-colors.sh" && ok "Generated wlogout colors.css" \
        || warn "wlogout color generation failed (no theme applied yet?)"
fi

# shell.json is watched by the quickshell shell; a running session picks it
# up live. Hyprland reloads Lua configs on `hyprctl reload`.
if command -v hyprctl &>/dev/null && hyprctl version &>/dev/null 2>&1; then
    hyprctl reload &>/dev/null && ok "Hyprland reloaded." || true
fi
