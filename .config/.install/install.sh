#!/usr/bin/env bash
# Orchestrator: sources every install module in order. Modules run in THIS
# shell, so strict mode here applies everywhere — any failing module command
# aborts the whole install instead of leaving silent partial state.
#
# Scope: this repo layers a customized Omarchy rice on top of a STOCK Omarchy
# install:
#   1. bloat removal (unused preinstalls + pre-v4 stack)
#   2. delta packages (rice picks + official-dotfiles toolset)
#   3. tracked Omarchy user configs (hypr/omarchy/kitty/imv/gtk)
#   4. shared configs from the official dotfiles repo (zsh/emacs/git/...)
#   5. shell + fonts + cursor + plugins + home cleanup
#   6. official post-install workflow + reboot prompt
set -euo pipefail

# Repo root: this script lives at <repo>/.config/.install/install.sh
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
export REPO_DIR

clear
echo "
   ___                                _
  / _ \ _ __ ___   __ _ _ __ ___| |__  _   _
 | | | | '_ \` _ \ / _\` | '__/ __| '_ \| | | |
 | |_| | | | | | | (_| | | | (__| | | | |_| |
  \___/|_| |_| |_|\__,_|_|  \___|_| |_|\__, |
  rice layer for Omarchy               |___/
"

# Fail fast on missing sudo rather than mid-chain with partial state.
sudo -v || { echo "This installation requires sudo privileges. Aborting..."; exit 1; }

# Sanity: this script assumes an Omarchy install.
if ! pacman -Qq omarchy &>/dev/null; then
    echo "WARNING: the 'omarchy' package is not installed."
    echo "This repo layers on top of a stock Omarchy install; continue only if"
    echo "you know what you're doing."
    read -rp "Continue anyway? (y/n) " cont
    [[ $cont == "y" ]] || exit 1
fi

################
# Installation #
################
source "$REPO_DIR/.config/.install/library.sh"
source "$REPO_DIR/.config/.install/confirm-start.sh"
source "$REPO_DIR/.config/.install/remove-bloat.sh"
source "$REPO_DIR/.config/.install/install-packages.sh"
source "$REPO_DIR/.config/.install/install-fonts.sh"
source "$REPO_DIR/.config/.install/deploy-configs.sh"
source "$REPO_DIR/.config/.install/fetch-official-dotfiles.sh"
source "$REPO_DIR/.config/.install/zsh.sh"
source "$REPO_DIR/.config/.install/setup-cursor.sh"
source "$REPO_DIR/.config/.install/setup-plugins.sh"
source "$REPO_DIR/.config/.install/cleanup-homedir.sh"
source "$REPO_DIR/.config/.install/run-post-install.sh"
source "$REPO_DIR/.config/.install/prompt-reboot.sh"
