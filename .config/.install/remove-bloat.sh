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
#      Pre-answered by the confirm-start.sh preflight (REMOVE_PREINSTALLS);
#      its own gum confirm is stripped before running.
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

if [[ ${REMOVE_PREINSTALLS:-0} == 1 ]]; then
    if [[ -x $PREINSTALL_REMOVER ]]; then
        info "Removing Omarchy preinstalls (confirmed in preflight)..."
        # The remover's own `gum confirm` is pre-answered by the preflight —
        # rewrite it to `true` and run the body. If upstream rewrites the
        # script, the sed no-ops and its gum confirm simply asks again.
        sed 's/^if gum confirm .*; then/if true; then/' "$PREINSTALL_REMOVER" | bash \
            || warn "Preinstall remover partially failed."
    else
        warn "omarchy-remove-preinstalls not found — skipping (not an Omarchy 4 install?)."
    fi
else
    info "Preinstall remover declined in preflight — skipping."
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
    "brave-browser"

    # Unused pre-installed apps (not covered by the preinstall remover)
    "1password-beta"
    "1password-cli"
    "signal-desktop"
    "spotify"
    "typora"
)

_uninstallPackages "${bloat[@]}"

ok "Bloat removal finished."
