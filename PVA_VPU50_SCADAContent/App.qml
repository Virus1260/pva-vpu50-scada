import QtQuick
import QtQuick.VirtualKeyboard
import PVA_VPU50_SCADA

Window {
    id: appWindow
    width: 1280
    height: 720
    visible: true
    title: "PVA Systems - VPU 50 Industrial SCADA Control System"
    color: "#08213b"

    Main_frame_screen {
        id: mainScreen
        anchors.fill: parent
    }

    InputPanel {
        id: inputPanel
        z: 99999
        y: inputPanel.active ? (appWindow.height - inputPanel.height) : appWindow.height
        anchors.left: parent.left
        anchors.right: parent.right
        visible: inputPanel.active
    }
}
