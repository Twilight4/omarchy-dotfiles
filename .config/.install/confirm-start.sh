#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
#
# Also the PREFLIGHT: every interactive question of the whole install is
# asked here, up front (gum confirm), so the remaining modules run
# unattended. Answers are exported: ADD_SUDOER (sudoers.sh),
# REMOVE_PREINSTALLS (remove-bloat.sh).

# Refuse to run when the repo was cloned into the live config dir: the deploy
# step would then operate on its own target. `mode=dev` bypasses for testing.
SCRIPTPATH=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
if [[ $SCRIPTPATH == "/home/$USER/.config"* && ${mode:-} != "dev" ]]; then
    err "IMPORTANT: You're running the installation script from the installation target directory."
    warn "Please keep the omarchy-dotfiles repository outside ~/.config (e.g. ~/desktop/workspace) and start the script again."
    echo ""
    return 1
fi

echo "This script layers Twilight4's Omarchy rice on top of a stock Omarchy"
echo "install. It will:"
echo "  - remove bloat (unused preinstalls + pre-v4 stack)"
echo "  - install the delta packages (kitty, satty, official-dotfiles toolset)"
echo "  - deploy the tracked Omarchy user configs into ~/.config"
echo "  - fetch the official dotfiles repo for shared configs (zsh, emacs, ...)"
echo "  - set Zsh as the default shell and install terminal fonts"
echo ""

if ! command -v gum >/dev/null; then
    err "gum not found (stock Omarchy ships it) — cannot ask the preflight questions."
    return 1
fi

if ! gum confirm "START THE INSTALLATION?"; then
    warn "Installation canceled."
    return 1
fi
ok "Installation started."

ADD_SUDOER=0
if gum confirm "Add $USER to sudoers with NOPASSWD (drop-in /etc/sudoers.d/99-$USER-nopasswd)?"; then
    ADD_SUDOER=1
fi
export ADD_SUDOER

REMOVE_PREINSTALLS=0
if gum confirm "Remove Omarchy's preinstalled web apps, TUI wrappers and desktop applications?"; then
    REMOVE_PREINSTALLS=1
fi
export REMOVE_PREINSTALLS
echo ""
