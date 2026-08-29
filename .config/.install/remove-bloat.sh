#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
#
# Removes bloat: unused Omarchy preinstalls + conflicting duplicates of this
# rice + the pre-v4 stack that Omarchy 4 replaced with the quickshell shell.
# Everything here is guarded: only installed packages are touched, so re-runs
# and partial states are safe no-ops.
#
# Omarchy itself has no general "remove preinstalls" script — its only
# upstream removals are a Kvantum migration and the v3->v4 transition that
# stopped shipping the packages below (machines upgraded from v3 keep them
# installed). This list mirrors that: on a clean v4 install those entries are
# no-ops.
#
# Keep list (Omarchy defaults that stay): quickshell, aether, plymouth,
# hyprpicker, imv, evince, ufw, power-profiles-daemon, swaybg, fcitx5,
# cups stack, docker, mise, lazygit/lazydocker, bluetui, wiremix,
# neovim/omarchy-nvim, nautilus.

info "Removing bloat..."

bloat=(
    # Pre-v4 stack replaced by the quickshell shell (bar/launcher/
    # notifications/OSD/idle+lock). No-ops on clean Omarchy 4 installs.
    "waybar"
    "mako"
    "omarchy-walker"
    "swayosd"
    "hypridle"
    "hyprlock"
    "dunst"

    # Removed by Omarchy's own migrations (fights its Qt/theming)
    "kvantum-qt5"

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
