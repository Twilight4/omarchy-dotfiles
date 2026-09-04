import QtQuick
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

  onPressed: function() {
    if (root.notificationService) {
      root.notificationService.setDoNotDisturb(!root.notificationService.doNotDisturb)
    }
  }
}
