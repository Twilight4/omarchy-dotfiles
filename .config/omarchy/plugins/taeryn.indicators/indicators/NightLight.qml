import QtQuick
import Quickshell
import qs.Ui

BarIndicator {
  id: root

  readonly property var nightlightService: bar?.shell?.firstPartyServiceFor("omarchy.nightlight")

  active: nightlightService ? nightlightService.enabled : false
  activeText: "󰔎"
  inactiveText: "󰔎"
  activeTooltipText: "Day Light"
  inactiveTooltipText: "Night Light"

  // Same path as SUPER+backslash: nightlight.sh toggles AND notifies; the
  // stock omarchy-toggle-nightlight it calls refreshes this icon.
  onPressed: function() {
    if (root.bar)
      root.bar.run(Quickshell.env("HOME") + "/.config/hypr/scripts/nightlight.sh toggle")
  }
}
