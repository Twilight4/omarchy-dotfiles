#!/usr/bin/env bash
# Sourced by install.sh — use `return`, not `exit`.
# Modified copy of the official dotfiles prompt-reboot.sh.
#
# Omarchy-specific changes vs the original:
# - no repo cleanup: BOTH repos are persistent working copies
#   (~/desktop/workspace/omarchy-dotfiles + ~/desktop/workspace/dotfiles);
#   nothing in ~/.config points back into them after the copy-based deploy.
# - TTY session entry is Omarchy's (hyprland-uwsm.desktop, not
#   garuda-hyprland-uwsm.desktop).
# - post-install pointer targets the official repo's copy.

echo ""
echo "Installation Finished."
echo "To complete the setup, reboot and log in via SDDM."
echo ""
echo "To start Hyprland from a TTY instead, use the uwsm-managed entry:"
echo "  uwsm start hyprland-uwsm.desktop"
echo ""
echo "Once inside the desktop session, you can run the post-install workflow:"
echo "  bash ~/desktop/workspace/dotfiles/.config/.install/post-install.sh"
echo ""
echo "Reboot now? (y/n)"
read -rp "> " answer
[[ $answer == "y" ]] && sudo reboot
