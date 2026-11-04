import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 32
    color: "#1a1b26"

    Text {
        anchors.centerIn: parent
        text: "Quickshell Active"
        color: "#a9b1d6"
        font.pixelSize: 14
    }
}
