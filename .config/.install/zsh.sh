#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
# Modified copy of the official dotfiles zsh.sh (same logic, trimmed banner).

read -rp "This will set the default shell to Zsh. Press any key to continue or Ctrl+C to exit..." -n 1 -s
echo

zsh_path=$(command -v zsh) || { err "zsh not found in PATH."; return 1; }

# Zsh as default shell
default_shell=$(getent passwd "$(whoami)" | cut -d: -f7)
if [[ $default_shell != "$zsh_path" ]]; then
    # Idempotent: tee (overwrite), not append, so re-runs never duplicate.
    echo "export ZDOTDIR=\"$HOME/.config/zsh\"" | sudo tee /etc/zsh/zshenv >/dev/null
    if sudo chsh -s "$zsh_path" "$(whoami)"; then
        ok "Zsh set as default shell."
    else
        err "Failed to set Zsh as default shell (sudo privileges required)."
        return 1
    fi
else
    echo
    info "Zsh is already the default shell."
fi
