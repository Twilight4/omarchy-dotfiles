#!/usr/bin/env bash
# Sourced by install.sh — runs FIRST after confirm-start: NOPASSWD up front
# means the remaining modules never stop for a password prompt (install.sh
# already primed the cache with sudo -v). The yes/no answer was pre-asked by
# confirm-start.sh (preflight) into ADD_SUDOER.
#
# Omarchy variant vs the official sudoers-hooks.sh:
# - The NOPASSWD rule goes into a DROP-IN (/etc/sudoers.d/99-<user>-nopasswd)
#   instead of being appended to /etc/sudoers. sudoers.d is included at the
#   END of the policy and sudoers is last-match-wins, so the drop-in can't be
#   shadowed by the stock %wheel rule — the failure mode of an appended line.
#   /etc/sudoers itself is never touched; deleting the drop-in fully reverts.
# - The snap-pac section is dropped: Omarchy has no snap-pac alpm hooks (its
#   snapshot flow is limine-snapper-sync, which needs no hook handling).

if [[ ${ADD_SUDOER:-0} == 1 ]]; then
    dropin="/etc/sudoers.d/99-$USER-nopasswd"
    sudoers_line="$USER ALL=(ALL:ALL) NOPASSWD: ALL"

    if sudo grep -qF "$sudoers_line" "$dropin" 2>/dev/null; then
        info "sudoers drop-in already present."
    elif [[ -e $dropin ]]; then
        warn "$dropin exists with different content — leaving it untouched."
        warn "Expected exactly: $sudoers_line"
    else
        # Validate the drop-in with visudo BEFORE installing, then install
        # root:root 0440 (sudo silently ignores writable/group-owned drop-ins).
        # A bad sudoers file bricks sudo — never write one unvalidated.
        payload=$(mktemp)
        printf '%s\n' "$sudoers_line" > "$payload"
        if ! visudo -cf "$payload" >/dev/null 2>&1; then
            err "Drop-in failed visudo validation — not installing."
            rm -f "$payload"
            return 1
        fi
        if sudo install -m 0440 -o root -g root "$payload" "$dropin"; then
            ok "sudoers drop-in installed: NOPASSWD for $USER"
            info "Revert with: sudo rm $dropin"
        else
            err "Failed to install $dropin."
            rm -f "$payload"
            return 1
        fi
        rm -f "$payload"
    fi
fi
