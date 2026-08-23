/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML.
*/
import QtQuick
import QtQuick.Shapes

Item {
    id: valveRoot
    width: 32
    height: 32

    property string tag: "V101"
    property string subLabel: ""
    property bool isOpen: false
    property bool isVertical: false
    property string valveType: "diaphragm" // Options: "diaphragm" or "butterfly"
    property bool isButterfly: (valveType === "butterfly")
    property bool showTags: true

    property alias mouseArea: valveMouseArea

    signal clicked

    Item {
        id: valveSymbolContainer
        anchors.centerIn: parent
        width: 28
        height: 28
        rotation: valveRoot.isVertical ? 90 : 0

        // 1. TOP ACTUATOR (Mushroom Dome & Stem for Diaphragm, Disc Handle for Butterfly)
        Rectangle {
            visible: !valveRoot.isButterfly
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 2
            width: 14
            height: 7
            radius: 4
            color: valveRoot.isOpen ? "#15803d" : "#1e293b"
            border.color: valveRoot.isOpen ? "#4ade80" : "#94a3b8"
            border.width: 1
        }
        Rectangle {
            visible: !valveRoot.isButterfly
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 8
            width: 2.5
            height: 6
            color: valveRoot.isOpen ? "#4ade80" : "#94a3b8"
        }

        // 2. BASE VALVE SYMBOL: TWO OPPOSING TRIANGLES
        Shape {
            anchors.fill: parent
            anchors.topMargin: 10
            layer.enabled: true
            layer.smooth: true

            // Left Inward Triangle
            ShapePath {
                strokeColor: "#ffffff"
                strokeWidth: 1.0
                fillColor: valveRoot.isOpen ? "#22c55e" : "#ef4444"
                joinStyle: ShapePath.MiterJoin

                startX: 2; startY: 1
                PathLine { x: 14; y: 8 }
                PathLine { x: 2; y: 15 }
                PathLine { x: 2; y: 1 }
            }

            // Right Inward Triangle
            ShapePath {
                strokeColor: "#ffffff"
                strokeWidth: 1.0
                fillColor: valveRoot.isOpen ? "#22c55e" : "#ef4444"
                joinStyle: ShapePath.MiterJoin

                startX: 26; startY: 1
                PathLine { x: 14; y: 8 }
                PathLine { x: 26; y: 15 }
                PathLine { x: 26; y: 1 }
            }
        }
    }

    // 3. TAG LABEL
    Text {
        visible: valveRoot.showTags
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.top
        anchors.bottomMargin: 2
        text: valveRoot.tag
        color: valveRoot.isOpen ? "#4ade80" : "#cbd5e1"
        font.pixelSize: 9
        font.bold: valveRoot.isOpen
    }

    // 4. SUB-LABEL
    Text {
        visible: valveRoot.showTags && valveRoot.subLabel.length > 0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 2
        text: valveRoot.subLabel
        color: "#94a3b8"
        font.pixelSize: 8
    }

    MouseArea {
        id: valveMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
