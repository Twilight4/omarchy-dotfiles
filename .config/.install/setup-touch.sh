#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
#
# Touch stack bring-up for the 2-in-1 panel (wvkbd OSK + hyprgrass gestures +
# accelerometer auto-rotation). Packages come from install-packages.sh
# (wvkbd, iio-sensor-proxy), configs from this repo (hypr bindings/input/
# autostart + the fcitx5 override under systemd/).

info "Setting up the touch stack..."

#---------------------------------------------- hyprgrass plugin (hyprpm)
# The gesture binding in bindings.lua is guarded (`hl.plugin.hyprgrass ~= nil`
# style) — without the plugin it is a no-op, so a failed/skipped install here
# never breaks the compositor. Needs a RUNNING Hyprland session; the official
# post-install.sh step 1 does the same plus hyprexpo when run interactively.
if [[ -n ${HYPRLAND_INSTANCE_SIGNATURE:-} ]] && command -v hyprpm &>/dev/null; then
    hyprpm update || warn "hyprpm update failed."
    # Pin: last commit compatible with Hyprland 0.56.x stable — main tracks
    # the 0.57-dev keybinds reorg and the v0.8.2 tag needs the older Log.hpp
    # layout. Bump when Hyprland stable moves past 0.56.
    HYPRGRASS_REV=56473e9e0b2da34bb3b871e90f40b3fc3d41ba9b
    hyprpm add https://github.com/horriblename/hyprgrass "$HYPRGRASS_REV" 2>/dev/null \
        || info "hyprgrass repo already added."
    hyprpm enable hyprgrass || warn "hyprpm enable hyprgrass failed."
    hyprpm reload || warn "hyprpm reload failed."
    ok "hyprgrass installed/enabled."
    hyprpm add https://github.com/sandwichfarm/hyprexpo 2>/dev/null \
        || info "hyprexpo repo already added."
    hyprpm enable hyprexpo || warn "hyprpm enable hyprexpo failed."
    hyprpm reload || warn "hyprpm reload failed."
    ok "hyprexpo installed/enabled."
    # Note: hyprpm add/enable need /var/cache/hyprpm to be user-writable.
    # If a sudo'd hyprpm run left it root-owned ("failed to create cache
    # dir" / "Failed to write plugin state"): sudo chown -R $USER:$USER
    # /var/cache/hyprpm
else
    warn "No running Hyprland session (or no hyprpm) — hyprgrass not loaded."
    info "Re-run this module inside Hyprland, or use the official post-install step 1."
fi

#------------------------------------------- iio-sensor-proxy (rotation)
if pacman -Qq iio-sensor-proxy &>/dev/null; then
    sudo systemctl enable --now iio-sensor-proxy \
        && ok "iio-sensor-proxy enabled." \
        || warn "iio-sensor-proxy enable failed."
else
    warn "iio-sensor-proxy not installed — auto-rotate stays inert."
fi

#----------------------------- fcitx5 override (free input-method-v2 slot)
# wvkbd needs the seat's input-method-v2 slot; fcitx5's waylandim grabs it
# exclusively. The override (deployed from .config/systemd/user/) restarts
# fcitx5 without waylandim. XCompose in XWayland clients keeps working.
OVERRIDE="$HOME/.config/systemd/user/omarchy-fcitx5.service.d/override.conf"
if [[ -f $OVERRIDE ]]; then
    systemctl --user daemon-reload
    systemctl --user restart omarchy-fcitx5 \
        && ok "fcitx5 restarted without waylandim (wvkbd can take the IM slot)." \
        || warn "omarchy-fcitx5 restart failed — reboot applies the override."
else
    warn "fcitx5 override not deployed ($OVERRIDE) — wvkbd may not surface."
fi
