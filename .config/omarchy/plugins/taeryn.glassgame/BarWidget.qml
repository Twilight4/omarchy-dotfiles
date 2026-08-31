import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui

// Glass / Gamemode bar toggles. Wide fixed-height buttons (easier touchpad
// targets than the hover-reveal indicators), state read live from the
// ~/.cache state files the scripts write.

BarWidget {
  id: root
  moduleName: "taeryn.glassgame"

  property string glassState: "normal"
  property bool gameOn: false

  implicitWidth: row.implicitWidth
  implicitHeight: row.implicitHeight

  Row {
    id: row
    anchors.fill: parent

    WidgetButton {
      bar: root.bar
      text: "\uF043"  // nf droplet
      active: root.glassState !== "off"
      dimmed: root.glassState === "off"
      horizontalMargin: 11
      fixedHeight: parent.height
      onPressed: root.bar && root.bar.run(
        Quickshell.env("HOME") + "/.config/hypr/scripts/glassmorphism-toggle")
    }

    WidgetButton {
      bar: root.bar
      text: "\uF11B"  // nf gamepad
      active: root.gameOn
      horizontalMargin: 11
      fixedHeight: parent.height
      onPressed: root.bar && root.bar.run(
        Quickshell.env("HOME") + "/.config/hypr/scripts/gamemode")
    }
  }

  FileView {
    path: Quickshell.env("HOME") + "/.cache/omarchy-glass-state"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: root.glassState = String(text()).trim()
  }

  FileView {
    path: Quickshell.env("HOME") + "/.cache/omarchy-gamemode-state"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: root.gameOn = String(text()).trim() === "on"
  }
}
