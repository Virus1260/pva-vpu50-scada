/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML.
*/
import QtQuick
import QtQuick.Shapes

Item {
    id: pumpRoot
    width: 64
    height: 52

    property string tag: "P 168 001"
    property string pressTag: "PI 168 001"
    property real pressureBar: 1.2
    property bool isRunning: false
    property bool showTags: true

    property alias mouseArea: pumpMouseArea

    signal clicked()

    // 1. REAR MOTOR DRIVE HOUSING (Left Box)
    Rectangle {
        id: motorBox
        anchors.left: parent.left
        anchors.verticalCenter: voluteCasing.verticalCenter
        width: 18
        height: 28
        radius: 3
        color: "#081f38"
        border.color: pumpRoot.isRunning ? "#4ade80" : "#38bdf8"
        border.width: 1.2

        // Motor Terminal Box on top
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: -4
            anchors.horizontalCenter: parent.horizontalCenter
            width: 8
            height: 5
            radius: 1
            color: "#1e293b"
            border.color: "#38bdf8"
            border.width: 0.8
        }

        // Motor Cooling Ribs
        Column {
            anchors.centerIn: parent
            spacing: 3
            Rectangle { width: 12; height: 1.5; color: "#334155" }
            Rectangle { width: 12; height: 1.5; color: "#334155" }
            Rectangle { width: 12; height: 1.5; color: "#334155" }
            Rectangle { width: 12; height: 1.5; color: "#334155" }
        }
    }

    // 2. CENTRIFUGAL VOLUTE CASING (Circular Pump Head)
    Rectangle {
        id: voluteCasing
        anchors.left: motorBox.right
        anchors.leftMargin: -2
        anchors.top: parent.top
        anchors.topMargin: 8
        width: 36
        height: 36
        radius: 18
        color: pumpRoot.isRunning ? "#052e16" : "#092440"
        border.color: pumpRoot.isRunning ? "#22c55e" : "#38bdf8"
        border.width: 2.0

        // Tangential Discharge Nozzle pointing UP
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: -8
            width: 8
            height: 10
            color: "#334155"
            border.color: "#64748b"
            border.width: 0.8
        }
        Rectangle {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: -10
            width: 14
            height: 3
            radius: 0.5
            color: "#64748b"
            border.color: "#94a3b8"
            border.width: 0.8
        }

        // Impeller Center Hub
        Rectangle {
            anchors.centerIn: parent
            width: 10
            height: 10
            radius: 5
            color: pumpRoot.isRunning ? "#22c55e" : "#38bdf8"
        }

        // Impeller Vanes (Vector Cross)
        Shape {
            anchors.fill: parent
            layer.enabled: true
            layer.smooth: true

            ShapePath {
                strokeColor: pumpRoot.isRunning ? "#4ade80" : "#64748b"
                strokeWidth: 1.8
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                startX: 18; startY: 8
                PathLine { x: 18; y: 28 }
            }
            ShapePath {
                strokeColor: pumpRoot.isRunning ? "#4ade80" : "#64748b"
                strokeWidth: 1.8
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap

                startX: 8; startY: 18
                PathLine { x: 28; y: 18 }
            }
        }
    }

    // 3. TAG LABEL
    Text {
        visible: pumpRoot.showTags
        anchors.left: voluteCasing.right
        anchors.leftMargin: 8
        anchors.verticalCenter: voluteCasing.verticalCenter
        text: pumpRoot.tag
        color: pumpRoot.isRunning ? "#4ade80" : "#94a3b8"
        font.pixelSize: 10
        font.bold: true
    }

    MouseArea {
        id: pumpMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
