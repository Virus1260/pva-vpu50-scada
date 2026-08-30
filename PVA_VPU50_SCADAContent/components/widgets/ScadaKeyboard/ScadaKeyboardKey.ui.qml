/*
This is a UI file (.ui.qml) for SCADA Virtual Keyboard Realistic Tactile Key.
Strictly declarative for Qt Design Studio 2D visual editor.
*/

import QtQuick
import QtQuick.Layouts

Item {
    id: keyRoot
    property string text: ""
    property bool isOk: false
    property bool isAction: false
    property bool isActive: false
    property bool isPhysicalPressed: false
    property alias mouseArea: btnMouse

    readonly property bool isDepressed: btnMouse.pressed || keyRoot.isPhysicalPressed

    Layout.fillWidth: true
    Layout.fillHeight: true
    implicitHeight: 46
    implicitWidth: 44

    // 1. Key Base / 3D Socket Depth Lip (Creates physical mechanical extrusion)
    Rectangle {
        id: keyShadowBase
        anchors.fill: parent
        radius: 6
        color: keyRoot.isOk
               ? (keyRoot.isDepressed ? "#4b8710" : "#579c13")
               : (keyRoot.isActive
                  ? "#024a73"
                  : (keyRoot.isAction ? "#87a7c4" : "#94a9bf"))
    }

    // 2. Physical Depressing Keycap Body
    Rectangle {
        id: keycapFace
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: keyRoot.isDepressed ? 3 : 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: keyRoot.isDepressed ? 0 : 3
        radius: 5

        // Smooth animations for realistic feel
        Behavior on anchors.topMargin {
            NumberAnimation { duration: 60; easing.type: Easing.OutQuad }
        }
        Behavior on anchors.bottomMargin {
            NumberAnimation { duration: 60; easing.type: Easing.OutQuad }
        }
        Behavior on color {
            ColorAnimation { duration: 70 }
        }
        Behavior on border.color {
            ColorAnimation { duration: 70 }
        }

        color: keyRoot.isOk
               ? (keyRoot.isDepressed ? "#65b81b" : (btnMouse.containsMouse ? "#9ef53b" : "#8ee62c"))
               : (keyRoot.isActive
                  ? (keyRoot.isDepressed ? "#0284c7" : (btnMouse.containsMouse ? "#0ea5e9" : "#0284c7"))
                  : (keyRoot.isAction
                     ? (keyRoot.isDepressed ? "#a3c5e3" : (btnMouse.containsMouse ? "#e5f0fa" : "#d8e6f3"))
                     : (keyRoot.isDepressed ? "#cbd5e1" : (btnMouse.containsMouse ? "#f8fafc" : "#ffffff"))))

        border.color: keyRoot.isOk
                      ? (btnMouse.containsMouse ? "#ffffff" : "#72cc1e")
                      : (keyRoot.isActive
                         ? "#38bdf8"
                         : (btnMouse.containsMouse ? "#38bdf8" : (keyRoot.isAction ? "#9bbddc" : "#b0cce6")))
        border.width: (keyRoot.isActive || btnMouse.containsMouse || (keyRoot.isOk && btnMouse.containsMouse)) ? 2 : 1

        // Top Subtle Bevel Highlight (Gloss edge reflection)
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 2
            radius: 4
            color: keyRoot.isOk ? "#c6f98f" : (keyRoot.isActive ? "#7dd3fc" : "#ffffff")
            opacity: keyRoot.isDepressed ? 0.2 : (keyRoot.isAction ? 0.6 : 0.85)
        }

        // Active Tap Ripple Glow Overlay
        Rectangle {
            anchors.fill: parent
            radius: 4
            color: keyRoot.isOk ? "#ffffff" : "#38bdf8"
            opacity: keyRoot.isDepressed ? 0.35 : (btnMouse.containsMouse ? 0.08 : 0.0)
            Behavior on opacity {
                NumberAnimation { duration: 90 }
            }
        }

        // Center Key Symbol / Text
        Text {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: keyRoot.isDepressed ? 1 : 0
            text: keyRoot.text
            color: (keyRoot.isActive) ? "#ffffff" : "#08213b"
            font.bold: true
            font.pixelSize: keyRoot.isOk ? 16 : (keyRoot.isAction ? 12 : 16)
            font.family: "Segoe UI"
            Behavior on anchors.verticalCenterOffset {
                NumberAnimation { duration: 60 }
            }
        }
    }

    MouseArea {
        id: btnMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
