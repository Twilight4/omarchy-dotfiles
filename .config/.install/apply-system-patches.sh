#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`. Also runnable directly:
#   bash ~/desktop/workspace/omarchy-dotfiles/.config/.install/apply-system-patches.sh
# (the post-update hook points at this exact command when drift is detected).
#
# Applies the tracked /usr/bin patches from .config/omarchy-patches/ on top
# of the stock omarchy package files (omarchy updates overwrite them; this
# repo keeps .orig + .patched copies and reinstalls the patched versions).
# Then restarts the Omarchy shell stack: a RUNNING omarchy-launch-shell
# supervisor keeps the pre-patch script parsed in memory, so without the
# kill+restart the old behaviour (e.g. un-scaled bar) silently survives.

# Standalone invocation: derive REPO_DIR + load the logging helpers.
if [[ -z ${REPO_DIR:-} ]]; then
    REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
    # shellcheck source=library.sh
    source "$REPO_DIR/.config/.install/library.sh"
fi

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

# Shell/plugin QML patches: share/<relpath>.patched -> /usr/share/<relpath>.
# Same .orig/.patched drift handling as the /usr/bin loop above.
if [[ -d $patch_dir/share ]]; then
    while IFS= read -r -d '' p; do
        rel="${p#"$patch_dir/share/"}"; rel="${rel%.patched}"
        target="/usr/share/$rel"
        [[ -e $target ]] || { warn "Patch target missing, skipping: $target"; continue; }
        if cmp -s "$p" "$target"; then
            ok "Already patched: $target"
            continue
        fi
        orig="${p%.patched}.orig"
        if [[ ! -e $orig ]] || ! cmp -s "$target" "$orig"; then
            sudo cp "$target" "$target.pre-omarchy-patches" \
                && warn "Upstream changed: saved $target.pre-omarchy-patches"
        fi
        if sudo cp "$p" "$target"; then
            ok "Patched: $target"
        else
            warn "Failed to patch: $target"
        fi
    done < <(find "$patch_dir/share" -name '*.patched' -print0)
fi

# .localbin wrappers install to /usr/local/bin (user-owned, precedes
# /usr/bin in PATH, untouched by package updates).
if [[ -d $patch_dir ]]; then
    for w in "$patch_dir"/*.localbin; do
        [[ -e $w ]] || continue
        target="/usr/local/bin/$(basename "$w" .localbin)"
        if cmp -s "$w" "$target" 2>/dev/null; then
            ok "Already installed: $target"
            continue
        fi
        if sudo cp "$w" "$target" && sudo chmod 755 "$target"; then
            ok "Installed wrapper: $target"
        else
            warn "Failed to install wrapper: $target"
        fi
    done
fi

# uinput for xremap: udev rule (root:input 0660) + boot-time module load.
# Without these xremap exits with "Failed to prepare an output device
# (Permission denied)". Load the module first so the trigger has a sysfs
# node to apply the rule to.
sudo modprobe uinput &>/dev/null || true
uinput_rule="/etc/udev/rules.d/99-uinput.rules"
if ! cmp -s "$REPO_DIR/.config/.install/system/99-uinput.rules" "$uinput_rule" 2>/dev/null; then
    sudo cp "$REPO_DIR/.config/.install/system/99-uinput.rules" "$uinput_rule" \
        && sudo udevadm control --reload \
        && sudo udevadm trigger --sysname-match=uinput \
        && ok "Installed: $uinput_rule" \
        || warn "Failed to install $uinput_rule"
fi
if ! grep -qx uinput /etc/modules-load.d/uinput.conf 2>/dev/null; then
    sudo cp "$REPO_DIR/.config/.install/system/uinput.conf" /etc/modules-load.d/uinput.conf \
        && ok "Installed: /etc/modules-load.d/uinput.conf" \
        || warn "Failed to install modules-load uinput.conf"
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
