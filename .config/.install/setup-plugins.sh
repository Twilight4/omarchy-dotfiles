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

# omaga-sync — MEGA two-way sync widget + systemd services (bismawy/omaga-sync).
# Unlike the shell plugins above, it also ships CLI binaries (~/.local/bin/
# omaga-*) and two systemd user units, installed by its own ./install.sh;
# requires the megacmd package (install-packages.sh).
OMAGA_ID="bisma.omaga-sync"
OMAGA_URL="https://github.com/bismawy/omaga-sync.git"
if [[ -d "$HOME/.config/omarchy/plugins/$OMAGA_ID" && -x "$HOME/.local/bin/omaga-sync" ]]; then
    info "Plugin already present: $OMAGA_ID"
else
    omaga_tmp="$(mktemp -d)"
    if git clone --depth 1 "$OMAGA_URL" "$omaga_tmp/omaga-sync" \
        && (cd "$omaga_tmp/omaga-sync" && ./install.sh) \
        && omarchy plugin add "$OMAGA_URL" --enable; then
        ok "Plugin installed: $OMAGA_ID"
    else
        warn "Plugin install failed: $OMAGA_ID ($OMAGA_URL)"
    fi
    rm -rf "$omaga_tmp"
fi

# taeryn.* shell-plugin clones are tracked in this repo and deployed by
# deploy-configs.sh (deployed before this module runs). Their enablement
# lives only in ~/.config/omarchy/shell.json, which omarchy updates can
# reset — re-assert it so the installer self-heals (enable is idempotent).
for p in taeryn.clipboard taeryn.image-picker taeryn.notifications taeryn.menu; do
    omarchy plugin enable "$p" &>/dev/null \
        || warn "Plugin enable failed: $p (deployed to ~/.config/omarchy/plugins?)"
done
for p in omarchy.clipboard omarchy.image-picker omarchy.notifications omarchy.menu; do
    omarchy plugin disable "$p" &>/dev/null \
        || warn "Plugin disable failed: $p"
done
ok "taeryn plugin clones enabled (stock counterparts disabled)"
