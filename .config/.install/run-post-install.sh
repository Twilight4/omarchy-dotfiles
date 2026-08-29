#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
#
# Final step: run the official dotfiles post-install workflow (15-step
# interactive checklist) from the clone fetched by fetch-official-dotfiles.sh.
# It is the SAME script the Garuda install uses — Garuda-specific steps in it
# are guarded and degrade to no-ops on Omarchy. The install runs from a live
# Hyprland session, so config changes apply live (quickshell watches
# shell.json; hyprctl reload already ran) — no reboot prompt needed.

OFFICIAL_DIR="${OFFICIAL_DIR:-$HOME/desktop/workspace/dotfiles}"
POST_INSTALL="$OFFICIAL_DIR/.config/.install/post-install.sh"

if [[ -f $POST_INSTALL ]]; then
    echo ""
    info "Running the official post-install workflow (Garuda-specific steps"
    info "are no-ops here; skip steps that don't apply to this machine)."
    bash "$POST_INSTALL"
else
    warn "Official post-install.sh not found at $POST_INSTALL — skipping."
    info "Run it later with:  bash $OFFICIAL_DIR/.config/.install/post-install.sh"
fi

echo ""
ok "Omarchy rice installation completed."
