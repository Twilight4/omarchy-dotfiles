import QtQuick
import Quickshell
import qs.Ui

// Front-webcam pop button: toggles the ffplay popup launched by webcam2.sh.
// Running already -> kill it; not running -> launch. Same wide touch shape
// as taeryn.webapps.

BarWidget {
  id: root
  moduleName: "taeryn.webcam"

  implicitWidth: btn.implicitWidth
  implicitHeight: btn.implicitHeight

  WidgetButton {
    id: btn
    bar: root.bar
    text: "\uf03d"  // nf-fa-video-camera
    horizontalMargin: 5.5
    // pgrep -x (exact process name), not -f: an -f pattern would match the
    // bash -lc wrapper's own command line and the toggle would kill itself.
    onPressed: root.bar && root.bar.run(
      "pgrep -x ffplay >/dev/null && pkill -x ffplay || exec ~/.local/bin/webcam2.sh"
    )
  }
}
