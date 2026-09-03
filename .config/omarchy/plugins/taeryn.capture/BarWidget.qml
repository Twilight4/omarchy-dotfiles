import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

// Screenshot bar button with a touch-native picker overlay. The stock flow
// (slurp over a hyprpicker freeze) is pointer-only, so finger input never
// reaches it on the tablet. Drag draws a selection; a bare tap captures the
// whole screen; Esc or right-click cancels. The geometry goes to
// ~/.config/.local/bin/taeryn-capture-rect, which mirrors the stock post-processing
// (save to Pictures, wl-copy, editable notification).

BarWidget {
  id: root
  moduleName: "taeryn.capture"

  property bool picking: false

  readonly property string captureScript: Quickshell.env("HOME") + "/.config/.local/bin/taeryn-capture-rect"

  implicitWidth: btn.implicitWidth
  implicitHeight: btn.implicitHeight

  IpcHandler {
    target: "taeryn.capture"

    function open(): void {
      root.startPick()
    }
  }

  function startPick() {
    picking = true
  }

  function stopPick() {
    picking = false
  }

  function runCapture(args) {
    captureProc.command = [captureScript].concat(args)
    captureProc.running = true
  }

  Process {
    id: captureProc
  }

  WidgetButton {
    id: btn
    bar: root.bar
    text: "\uf125"  // nf-fa-crop (reads as "select a region" — the screenshot glyph)
    horizontalMargin: 5.5
    onPressed: root.startPick()
  }

  Variants {
    model: Quickshell.screens

    delegate: Component {
      PanelWindow {
        id: picker
        required property var modelData

        screen: modelData
        visible: root.picking
        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        WlrLayershell.namespace: "taeryn-capture"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: root.picking ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        exclusionMode: ExclusionMode.Ignore
        onVisibleChanged: if (visible) keyScope.forceActiveFocus()

        property real pressX: 0
        property real pressY: 0
        property real selX: 0
        property real selY: 0
        property real selW: 0
        property real selH: 0
        property bool dragging: false

        function reset() {
          dragging = false
          selW = 0
          selH = 0
        }

        Rectangle {
          anchors.fill: parent
          color: Util.alpha("#000000", 0.45)
        }

        Item {
          id: keyScope
          anchors.fill: parent
          focus: true
          Keys.onEscapePressed: root.stopPick()
        }

        Rectangle {
          visible: picker.dragging && picker.selW > 2 && picker.selH > 2
          x: picker.selX
          y: picker.selY
          width: picker.selW
          height: picker.selH
          color: Util.alpha(Color.accent, 0.12)
          border.color: Color.accent
          border.width: 2
        }

        Text {
          anchors.top: parent.top
          anchors.topMargin: 64
          anchors.horizontalCenter: parent.horizontalCenter
          text: "Drag to select \u00b7 Tap for full screen \u00b7 Esc cancels"
          color: "#ffffff"
          font.pixelSize: Style.font.body
          style: Text.Outline
          styleColor: "#aa000000"
        }

        MouseArea {
          anchors.fill: parent
          acceptedButtons: Qt.LeftButton | Qt.RightButton

          onPressed: function(mouse) {
            if (mouse.button === Qt.RightButton) {
              root.stopPick()
              return
            }
            picker.pressX = mouse.x
            picker.pressY = mouse.y
            picker.dragging = true
          }

          onPositionChanged: function(mouse) {
            if (!picker.dragging) return
            picker.selX = Math.min(picker.pressX, mouse.x)
            picker.selY = Math.min(picker.pressY, mouse.y)
            picker.selW = Math.abs(mouse.x - picker.pressX)
            picker.selH = Math.abs(mouse.y - picker.pressY)
          }

          onReleased: function(mouse) {
            if (mouse.button === Qt.RightButton) return
            // ponytail: 20px tap threshold; a wobble filter would eat slow drags.
            var tap = picker.selW < 20 || picker.selH < 20
            var args = tap
              ? [picker.modelData.name, "full"]
              : [picker.modelData.name, String(Math.round(picker.selX)), String(Math.round(picker.selY)), String(Math.round(picker.selW)), String(Math.round(picker.selH))]
            picker.reset()
            root.stopPick()
            root.runCapture(args)
          }
        }
      }
    }
  }
}
