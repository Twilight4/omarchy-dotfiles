#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
#
# Removes Omarchy-shipped bloat that conflicts with or duplicates the rice.
# Everything here is guarded: only installed packages are touched, so re-runs
# and partial states are safe no-ops.
#
# Keep list (Omarchy defaults that stay): quickshell, aether, plymouth,
# hyprpicker, imv, ufw, power-profiles-daemon, swaybg, hypridle/hyprlock,
# waybar-free shell, fcitx5, cups stack, docker, mise, lazygit/lazydocker,
# bluetui, wiremix, neovim/omarchy-nvim.

info "Removing bloat..."

bloat=(
    # Terminal — kitty replaces it
    "alacritty"

    # Shell/CLI conflicts with the official-dotfiles setup
    # (zsh + p10k, lsd, no multiplexer)
    "tmux"
    "starship"
    "eza"

    # Browser — zen-browser-bin replaces it
    "chromium"

    # Unused pre-installed apps
    "1password-beta"
    "1password-cli"
    "signal-desktop"
    "spotify"
    "obsidian"
    "libreoffice-fresh"
    "localsend"
    "typora"
    "xournalpp"
    "pinta"
    "kdenlive"
    "obs-studio"
)

_uninstallPackages "${bloat[@]}"

ok "Bloat removal finished."
