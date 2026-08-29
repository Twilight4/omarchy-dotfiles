#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
#
# Bibata cursor theme (same as the official dotfiles): Bibata-Modern-Classic
# at size 24. Persistent state lives in the deployed configs:
#   - ~/.config/gtk-3.0/settings.ini + gtk-4.0/settings.ini (GTK apps)
#   - ~/.config/hypr/autostart.lua (hyprctl setcursor + XCURSOR env)
# This module applies it to the RUNNING session and GNOME schema so it takes
# effect without re-login.

CURSOR_THEME="Bibata-Modern-Classic"
CURSOR_SIZE="24"

info "Applying cursor theme: $CURSOR_THEME $CURSOR_SIZE"

# GNOME/gsettings path (gtk4-layer-shell, nautilus, etc.)
if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface cursor-theme "$CURSOR_THEME" \
        && gsettings set org.gnome.desktop.interface cursor-size "$CURSOR_SIZE" \
        && ok "gsettings cursor set." \
        || warn "gsettings cursor failed (schema present?)."
else
    warn "gsettings not available; gtk settings.ini files carry the config."
fi

# Live Hyprland session (persistent line is in hypr/autostart.lua)
if command -v hyprctl &>/dev/null && hyprctl version &>/dev/null 2>&1; then
    hyprctl setcursor "$CURSOR_THEME" "$CURSOR_SIZE" &>/dev/null \
        && ok "Hyprland cursor set." \
        || warn "hyprctl setcursor failed (theme installed?)."
fi
