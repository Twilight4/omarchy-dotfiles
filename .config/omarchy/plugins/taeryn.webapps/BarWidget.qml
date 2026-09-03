import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

// Web apps bar button: toggles the omarchy-menu "webapps" route (rows are the
// tracked .desktop entries; see ~/.config/omarchy/extensions/omarchy-menu.jsonc).
// Single wide button for touch, same shape as taeryn.glassgame.

BarWidget {
  id: root
  moduleName: "taeryn.webapps"

  implicitWidth: btn.implicitWidth
  implicitHeight: btn.implicitHeight

  WidgetButton {
    id: btn
    bar: root.bar
    text: ""  // nf-fa globe
    activeColor: "#ffffff"
    active: false
    dimmed: false
    horizontalMargin: 5.5
    onPressed: root.bar && root.bar.run("omarchy-menu toggle webapps")
  }
}
