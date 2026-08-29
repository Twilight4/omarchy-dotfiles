#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.

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

while true; do
    read -rp "START THE INSTALLATION? (y/n): " yn
    case $yn in
        [Yy]*) ok "Installation started."; break ;;
        [Nn]*) warn "Installation canceled."; return 1 ;;
        *)     warn "Please answer yes or no." ;;
    esac
done
echo ""
