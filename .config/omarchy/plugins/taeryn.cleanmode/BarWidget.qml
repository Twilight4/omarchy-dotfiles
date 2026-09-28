import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// Clean mode shade: while the flag file exists (scripts/clean-mode.sh), map
// a fullscreen opaque layer over every screen that swallows ALL touch input
// — apps receive nothing. The enter/exit gesture is NOT here: hyprgrass sees
// raw touch regardless of layers, so the SAME 4-finger-down swipe toggles
// clean-mode.sh both ways (its hyprgrass bind is exempt from the clean-mode
// gating in bindings.lua; every other hyprgrass action no-ops while flagged
// so wiping the glass can't fire gestures underneath). Esc is a keyboard
// exit; SUPER+ALT+Y and the touchpad mirror also run the script.

BarWidget {
  id: root

  moduleName: "taeryn.cleanmode"

  property bool clean: false

  readonly property string cleanScript: Quickshell.env("HOME") + "/.config/hypr/scripts/clean-mode.sh"

  // No bar button: the gesture is the interface (widget exists to host the
  // shade + flag watch).
  implicitWidth: 0
  implicitHeight: 0

  FileView {
    path: Quickshell.env("HOME") + "/.local/state/omarchy/toggles/taeryn-clean-mode"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: root.clean = true
    onLoadFailed: root.clean = false
  }

  Process {
    id: cleanProc
    command: [root.cleanScript]
  }

  function exitClean() {
    if (clean) cleanProc.running = true
  }

  Variants {
    model: Quickshell.screens

    delegate: Component {
      PanelWindow {
        id: shade

        required property var modelData

        screen: modelData
        visible: root.clean
        anchors { top: true; bottom: true; left: true; right: true }
        color: "#000000"
        WlrLayershell.namespace: "taeryn-cleanmode"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.clean ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore
        onVisibleChanged: if (visible) keyScope.forceActiveFocus()

        Item {
          id: keyScope
          anchors.fill: parent
          focus: true
          Keys.onEscapePressed: root.exitClean()
        }

        // Touch/pointer consumers: no handlers on purpose — the areas exist
        // only so every touch and click ends HERE instead of in an app.
        MultiPointTouchArea {
          anchors.fill: parent
          minimumTouchPoints: 1
          maximumTouchPoints: 10
        }

        MouseArea {
          anchors.fill: parent
        }
      }
    }
  }
}
