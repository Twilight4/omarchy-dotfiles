#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
#
# Bloat removal, in two stages:
#
#   1. Omarchy's own "Remove > Preinstalls" action (the SUPER+SPACE menu
#      script) — drops all preinstalled webapps, TUI wrappers, mise stubs,
#      and its preinstall package list (aether, cliamp, libreoffice,
#      obsidian, obs-studio, kdenlive, moonlight-qt, lazydocker, omacut,
#      omacalc, omawrite, xournalpp, pinta, ...). It runs FIRST so anything
#      it removes that this rice still wants (e.g. cliamp) is cleanly
#      reinstalled afterwards by install-packages.sh from the official
#      variants (cliamp-bin, gnome-calculator instead of omacalc).
#      Interactive: it asks via gum confirm — declining skips it.
#
#   2. This rice's own removal list — only what Omarchy's remover does NOT
#      cover: the pre-v4 stack, migration removals, and desktop-app picks.
#      Guarded: only installed packages are touched, so re-runs and partial
#      states are safe no-ops.
#
# Keep list (Omarchy defaults that stay): quickshell, plymouth, hyprpicker,
# imv, gpu-screen-recorder, ufw, power-profiles-daemon, swaybg, fcitx5,
# cups stack, docker, mise, lazygit, bluetui, wiremix, neovim/omarchy-nvim,
# nautilus.

info "Removing bloat..."

#----------------------------------------------------- omarchy preinstalls
PREINSTALL_REMOVER="$(command -v omarchy-remove-preinstalls || true)"
[[ -n $PREINSTALL_REMOVER ]] || PREINSTALL_REMOVER=/usr/share/omarchy/bin/omarchy-remove-preinstalls

if [[ -x $PREINSTALL_REMOVER ]]; then
    info "Launching Omarchy's preinstall remover (interactive gum confirm)..."
    # Declining (non-zero exit from gum confirm) is a valid choice, not a
    # failure — treat it as "skipped", not an abort.
    "$PREINSTALL_REMOVER" || warn "Preinstall remover skipped or partially failed."
else
    warn "omarchy-remove-preinstalls not found — skipping (not an Omarchy 4 install?)."
fi

#------------------------------------------------------- this rice's drops
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

    # Document viewer — zathura replaces it (sushi depends on evince,
    # so both must go in one transaction)
    "evince"
    "sushi"

    # Shell/CLI conflicts with the official-dotfiles setup
    # (zsh + p10k, lsd, no multiplexer)
    "tmux"
    "starship"
    "eza"

    # Browser — zen-browser-bin replaces it
    "chromium"

    # Unused pre-installed apps (not covered by the preinstall remover)
    "1password-beta"
    "1password-cli"
    "signal-desktop"
    "spotify"
    "localsend"
    "typora"
)

_uninstallPackages "${bloat[@]}"

ok "Bloat removal finished."
