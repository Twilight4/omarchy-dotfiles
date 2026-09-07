import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  // Services are keyed by exact plugin id; the enabled notifications service
  // is the taeryn clone, with stock omarchy.notifications as fallback.
  readonly property var notificationService: bar?.shell
    ? (bar.shell.firstPartyServiceFor("taeryn.notifications") || bar.shell.firstPartyServiceFor("omarchy.notifications"))
    : null
  readonly property bool dnd: notificationService ? notificationService.doNotDisturb : false

  active: dnd
  activeText: "󰂛"
  inactiveText: "󰂛"
  activeTooltipText: "Allow Notifications"
  inactiveTooltipText: "Silence Notifications"

  // Same path as SUPER+CTRL+D: the wrapper toggles DND, refreshes this
  // drawer's icons and toasts (omarchy-action bypasses DND).
  onPressed: function() {
    if (root.bar)
      root.bar.run(Quickshell.env("HOME") + "/.config/hypr/scripts/notification-silencing-toggle")
  }
}
