import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland

// Standalone rofi-style app-grid launcher: dark blurred backdrop, search on
// top, 6-column icon grid (palette mirrors .config/rofi/themes/nova-dark).
// Summoned/toggled by hypr/scripts/app-launcher.sh; completely separate from
// the omarchy system menu, which stays stock.

ShellRoot {
  PanelWindow {
    id: panel
    visible: true
    anchors { top: true; left: true; right: true; bottom: true }
    color: "transparent"

    WlrLayershell.exclusiveZone: -1

    WlrLayershell.namespace: "qs-applauncher"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // ---- palette (rofi nova-dark twin) --------------------------------
    readonly property color backdrop: Qt.rgba(0, 0, 0, 0.5)
    readonly property color fg: "#cdd6f4"
    readonly property color fgDim: "#6c7086"
    readonly property color accent: "#89b4fa"
    readonly property color selectedBg: Qt.rgba(0.537, 0.706, 0.980, 0.25)

    // ---- app model ----------------------------------------------------
    property var allApps: []
    property string query: ""

    function refreshApps() {
      var list = []
      var values = DesktopEntries.applications.values || []
      for (var i = 0; i < values.length; i++) {
        var e = values[i]
        if (e.noDisplay) continue
        list.push({ id: String(e.id), name: String(e.name || e.id), icon: e.icon })
      }
      list.sort(function(a, b) {
        return a.name.toLowerCase() < b.name.toLowerCase() ? -1 : 1
      })
      panel.allApps = list
    }

    function iconSource(icon) {
      var v = String(icon || "")
      if (v.indexOf("file://") === 0 || v.indexOf("image://") === 0) return v
      return Quickshell.iconPath(v.length > 0 ? v : "application-x-executable", true)
    }

    function launch(id) {
      Quickshell.execDetached(["uwsm-app", "--", "gtk-launch", id + ".desktop"])
      Qt.quit()
    }

    Component.onCompleted: refreshApps()
    Connections {
      target: DesktopEntries.applications
      function onValuesChanged() { panel.refreshApps() }
    }

    Rectangle {
      anchors.fill: parent
      color: panel.backdrop

      Column {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // ---- search ----------------------------------------------------
        TextField {
          id: search
          width: Math.min(560, parent.width)
          anchors.horizontalCenter: parent.horizontalCenter
          height: 44
          placeholderText: "Search apps…"
          color: panel.fg
          selectionColor: panel.accent
          selectedTextColor: "#11111b"
          font.family: "monospace"  // same fontconfig alias the omarchy menu uses
          font.pointSize: 12
          background: Rectangle {
            color: Qt.rgba(0.067, 0.067, 0.106, 0.9)  // #11111b
            radius: 12
            border.width: 1
            border.color: search.activeFocus ? panel.accent : "transparent"
          }
          onTextChanged: {
            panel.query = text.toLowerCase()
            grid.model = panel.filtered()
            grid.currentIndex = 0
          }
          Keys.onPressed: event => {
            var ctrl = event.modifiers & Qt.ControlModifier
            if (event.key === Qt.Key_Escape) Qt.quit()
            // rofi bindings from the Garuda config.rasi: C-j/k move, C-m/RET
            // accept, C-h/l cursor, C-w del word, C-y primary paste.
            else if (ctrl && event.key === Qt.Key_J) { grid.incrementCurrentIndex(); event.accepted = true }
            else if (ctrl && event.key === Qt.Key_K) { grid.decrementCurrentIndex(); event.accepted = true }
            else if (event.key === Qt.Key_Down) { grid.incrementCurrentIndex(); event.accepted = true }
            else if (event.key === Qt.Key_Up) { grid.decrementCurrentIndex(); event.accepted = true }
            else if ((ctrl && event.key === Qt.Key_M) || event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
              if (grid.model.length > 0) panel.launch(grid.model[grid.currentIndex].id)
              event.accepted = true
            }
            else if (ctrl && event.key === Qt.Key_Y) {  // primary paste (rofi kb-primary-paste)
              if (typeof Quickshell.primarySelection === "function") {
                search.insert(search.cursorPosition, Quickshell.primarySelection() || "")
              }
              event.accepted = true
            }
            else if (ctrl && event.key === Qt.Key_H) { search.cursorPosition--; event.accepted = true }  // rofi C-h
            else if (ctrl && event.key === Qt.Key_L) { search.cursorPosition++; event.accepted = true }  // rofi C-l
            else if (ctrl && event.key === Qt.Key_W) {  // delete word back
              var p = search.text.slice(0, search.cursorPosition)
              var s = search.cursorPosition
              p = p.replace(/\S+\s*$/, "")
              search.text = p + search.text.slice(s)
              search.cursorPosition = p.length
              event.accepted = true
            }
          }
          Component.onCompleted: forceActiveFocus()
        }

        // ---- grid ------------------------------------------------------
        GridView {
          id: grid
          width: parent.width
          height: parent.height - search.height - 16
          anchors.horizontalCenter: parent.horizontalCenter
          clip: true
          cellWidth: Math.floor(width / 6)
          cellHeight: 208
          model: panel.filtered()
          boundsBehavior: Flickable.StopAtBounds
          highlight: Rectangle {
            color: panel.selectedBg
            radius: 14
            width: grid.cellWidth - 12
            height: grid.cellHeight - 12
            x: grid.currentItem ? grid.currentItem.x - 6 : 0
            y: grid.currentItem ? grid.currentItem.y - 6 : 0
          }
          highlightMoveDuration: 0

          delegate: Item {
            width: grid.cellWidth
            height: grid.cellHeight

            Column {
              anchors.centerIn: parent
              spacing: 8

              Image {
                source: panel.iconSource(modelData.icon)
                width: 96
                height: 96
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                smooth: true
                asynchronous: true
              }
              Text {
                text: modelData.name
                color: panel.fg
                font.family: "monospace"
                font.pointSize: 9
                anchors.horizontalCenter: parent.horizontalCenter
                elide: Text.ElideRight
                width: grid.cellWidth - 24
                horizontalAlignment: Text.AlignHCenter
              }
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: false
              onClicked: panel.launch(modelData.id)
            }
          }
        }
      }
    }

    function filtered() {
      var out = []
      var q = panel.query
      for (var i = 0; i < panel.allApps.length; i++) {
        var a = panel.allApps[i]
        if (q.length === 0 || a.name.toLowerCase().indexOf(q) >= 0) out.push(a)
      }
      return out
    }
  }
}
