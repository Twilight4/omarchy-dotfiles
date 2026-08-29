#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
#
# Offers to run the official dotfiles post-install workflow (15-step
# interactive checklist) from the clone fetched by fetch-official-dotfiles.sh.
# It is the SAME script the Garuda install uses — Garuda-specific steps in it
# are guarded and degrade to no-ops on Omarchy.

OFFICIAL_DIR="${OFFICIAL_DIR:-$HOME/desktop/workspace/dotfiles}"
POST_INSTALL="$OFFICIAL_DIR/.config/.install/post-install.sh"

if [[ ! -f $POST_INSTALL ]]; then
    warn "Official post-install.sh not found at $POST_INSTALL — skipping."
    return 0
fi

echo ""
info "The official post-install workflow walks the remaining bootstrap steps"
info "(hyprpm plugins, cloud sync, app theming, AI tooling, docker MCP, ...)."
info "NOTE: it is tailored to Twilight4's personal apps — skip steps that"
info "don't apply to this machine."
read -rp "Run it now? (y/n) " run_now
if [[ $run_now == "y" ]]; then
    bash "$POST_INSTALL"
else
    info "Run it later with:  bash $POST_INSTALL"
fi
