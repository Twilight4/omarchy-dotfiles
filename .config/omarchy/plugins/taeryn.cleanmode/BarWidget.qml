import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// Clean mode: panel off + this fullscreen opaque layer swallowing ALL touch
// input (apps get nothing while it is up). The touchscreen device stays
// enabled so the MultiPointTouchArea below can recognize the restoring
// 4-finger LEFT swipe — the mode is therefore enterable AND restorable from
// the touchscreen alone. Visibility truth = the flag file that
// scripts/clean-mode.sh toggles (hyprgrass actions are gated on it too).
// Also enterable/exitable via the bar button, SUPER+ALT+Y, or the touchpad
// 4-finger-left mirror in input.lua.

BarWidget {
  id: root

  moduleName: "taeryn.cleanmode"

  property bool clean: false

  readonly property string cleanScript: Quickshell.env("HOME") + "/.config/hypr/scripts/clean-mode.sh"

  implicitWidth: btn.implicitWidth
  implicitHeight: btn.implicitHeight

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

  function toggleClean() {
    cleanProc.running = true
  }

  function exitClean() {
    if (clean) toggleClean()
  }

  WidgetButton {
    id: btn
    bar: root.bar
    text: "\uf186"  // nf-fa-moon_o — screen-off/clean-mode toggle
    horizontalMargin: 5.5
    onPressed: root.toggleClean()
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
          // Esc is the keyboard exit path (binds still fire — compositor
          // binds run before layer key routing, so SUPER+ALT+Y works too).
          Keys.onEscapePressed: root.exitClean()
        }

        Text {
          visible: false  // panel is dpms-off; nothing to read
          text: ""
        }

        MultiPointTouchArea {
          anchors.fill: parent
          minimumTouchPoints: 1
          maximumTouchPoints: 10

          // First-seen X per finger; when 4+ fingers each travel ~160px left,
          // exit clean mode (mirrors the hyprgrass 4-left enter gesture).
          property var startX: ({})

          onTouchUpdated: function(points) {
            if (points.length === 0) {
              startX = ({})
              return
            }
            for (var i = 0; i < points.length; i++) {
              var p = points[i]
              if (startX[p.pointId] === undefined)
                startX[p.pointId] = p.x
            }
            if (points.length >= 4) {
              for (var j = 0; j < points.length; j++) {
                var q = points[j]
                if (q.x - startX[q.pointId] < -160) {
                  startX = ({})
                  root.exitClean()
                  return
                }
              }
            }
          }
        }
      }
    }
  }
}
