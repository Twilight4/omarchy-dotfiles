#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
#
# Re-installs the quickshell shell plugins from their git remotes. Plugin
# code is NOT tracked in this repo (~/.config/omarchy/plugins/ is 29M of
# cloned upstream repos); shell.json's layout references them by id, so they
# must exist before the shell renders those widgets.

info "Restoring omarchy shell plugins..."

if ! command -v omarchy &>/dev/null; then
    warn "omarchy CLI not found — skipping plugin restore."
    return 0
fi

# id|git-url pairs, captured from ~/.config/omarchy/plugins/*/.git
plugins=(
    "akitaonrails.ai-usagebar|https://github.com/akitaonrails/ai-usagebar.git"
    "crmne.hyprmoncfg|https://github.com/crmne/omarchy-hyprmoncfg.git"
    "io.github.sirjul1337.lock-explorer|https://github.com/SirJul1337/omarchy-lock-explorer.git"
)

for entry in "${plugins[@]}"; do
    id="${entry%%|*}"
    url="${entry##*|}"
    if [[ -d "$HOME/.config/omarchy/plugins/$id" ]]; then
        info "Plugin already present: $id"
        continue
    fi
    if omarchy plugin add "$url" --yes; then
        ok "Plugin installed: $id"
    else
        warn "Plugin install failed: $id ($url)"
    fi
done
