#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
#
# Installs ONLY the delta on top of a stock Omarchy install. Everything
# Omarchy already ships is deliberately excluded — including the rice tools
# we keep as-is:
#
#   quickshell (omarchy dep: bar/launcher/notifications/OSD)
#   aether (theme builder), plymouth (boot splash), hyprpicker (color picker)
#   imv (image viewer), ufw + ufw-docker, power-profiles-daemon
#   hypridle/hyprlock/hyprsunset, swaybg, grim/slurp, wl-clipboard
#   waybar/mako/walker are NOT installed by Omarchy 4 — quickshell covers them
#
# Overlapping tools that come pre-installed (btop, mpv, nautilus, fzf, bat,
# fd, ripgrep, zoxide, lazygit, lazydocker, bluetui, wiremix, mise, gum,
# github-cli, neovim + omarchy-nvim, starship removed in remove-bloat.sh, ...)
# are intentionally not listed here.

info "Installing delta packages..."

packages=(
    # Terminal (Omarchy ships alacritty config but no kitty; alacritty is
    # removed by remove-bloat.sh)
    "kitty"

    # Screenshot annotation — Omarchy default, pairs with grim/slurp
    "satty"

    # Cursor theme (Bibata, as in the official dotfiles)
    "bibata-cursor-theme"

    # Browser
    "zen-browser-bin"
)

_installPackages "${packages[@]}"

ok "Delta packages installed."
