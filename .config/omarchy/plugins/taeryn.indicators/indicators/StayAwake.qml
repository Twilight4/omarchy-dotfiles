import QtQuick
import qs.Ui

BarIndicator {
  id: root

  readonly property var idleService: bar?.shell?.firstPartyServiceFor("omarchy.idle")

  active: idleService ? idleService.stayAwake : false
  activeText: "󰅶"
  inactiveText: "󰅶"
  activeTooltipText: "Allow Idle Lock & Screensaver"
  inactiveTooltipText: "Stay Awake"

  function toggle() {
    if (root.idleService) root.idleService.setIdleEnabled(root.active)
  }

  onPressed: function() {
    if (!root.idleService) return
    var staying = !root.active
    root.toggle()
    // Toast mirrors the DND wrapper's feedback; omarchy-action bypasses DND.
    if (root.bar) {
      root.bar.run("omarchy-notification-send -g 󰅶 -r 9003 \""
        + (staying ? "Staying awake" : "Idle lock & screensaver allowed") + "\"")
    }
  }
}
