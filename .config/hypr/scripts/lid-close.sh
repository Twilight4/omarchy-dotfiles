#!/usr/bin/env bash
# Lid-close handler (rebinds Omarchy's stock switch:on:Lid Switch).
# Stock omarchy-system-lid-close LOCKS the session the moment the lid closes
# (lock-before-suspend head start). During clean mode the logind lid inhibitor
# keeps the machine running — but the lock still fired, so reopening showed a
# locked screen. Clean mode wants NO lock and NO suspend: skip only the lock,
# keep the clamshell monitor reconciliation.
exec 9>"${XDG_RUNTIME_DIR:-/tmp}/lid-close.lock"
flock -n 9 || exit 0   # Hyprland can emit switch events in bursts

if [[ ! -f $HOME/.local/state/omarchy/toggles/taeryn-clean-mode ]]; then
  omarchy-system-lid-close
  exit 0
fi

# Clean mode: reconcile monitors without locking.
exec omarchy-hyprland-monitor-clamshell
