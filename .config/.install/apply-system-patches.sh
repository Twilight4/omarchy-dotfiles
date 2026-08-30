#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
#
# Applies the tracked /usr/bin patches from .config/omarchy-patches/ on top
# of the stock omarchy package files (omarchy updates overwrite them; this
# repo keeps .orig + .patched copies and reinstalls the patched versions).
# Then restarts the Omarchy shell stack: a RUNNING omarchy-launch-shell
# supervisor keeps the pre-patch script parsed in memory, so without the
# kill+restart the old behaviour (e.g. un-scaled bar) silently survives.

patch_dir="$REPO_DIR/.config/omarchy-patches"

if [[ -d $patch_dir ]]; then
    for p in "$patch_dir"/*.patched; do
        [[ -e $p ]] || continue
        target="/usr/bin/$(basename "$p" .patched)"
        [[ -e $target ]] || { warn "Patch target missing, skipping: $target"; continue; }

        if cmp -s "$p" "$target"; then
            ok "Already patched: $target"
            continue
        fi

        # If the live file matches neither our .orig nor our .patched, an
        # omarchy update rewrote it — back it up before overwriting.
        orig="$patch_dir/$(basename "$p" .patched).orig"
        if [[ ! -e $orig ]] || ! cmp -s "$target" "$orig"; then
            sudo cp "$target" "$target.pre-omarchy-patches" \
                && warn "Upstream changed: saved $target.pre-omarchy-patches"
        fi

        if sudo cp "$p" "$target" && sudo chmod 755 "$target"; then
            ok "Patched: $target"
        else
            warn "Failed to patch: $target"
        fi
    done
fi

# Restart the shell stack so the patched launcher actually takes effect.
# Kill supervisor + quickshell, then reload — the default autostart re-execs
# omarchy-launch-shell, which now reads the patched file. If the reload
# doesn't bring the shell back, launch it directly.
if pgrep -f 'quickshell -n' &>/dev/null; then
    info "Restarting the Omarchy shell (pick up patched launcher) ..."
    pkill -f 'omarchy-launch-shell' || true
    pkill -f 'quickshell -n' || true
    sleep 1
    hyprctl reload &>/dev/null || true
    sleep 3
    if ! pgrep -f 'quickshell -n' &>/dev/null; then
        setsid uwsm app -d "Omarchy shell" -- /usr/bin/omarchy-launch-shell \
            </dev/null >/dev/null 2>&1 &
        sleep 3
    fi
    pgrep -f 'quickshell -n' &>/dev/null \
        && ok "Omarchy shell restarted." \
        || warn "Shell did not come back; run: omarchy-launch-shell"
fi
