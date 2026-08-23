/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML.
*/
import QtQuick
import QtQuick.Shapes

Item {
    id: heaterRoot
    width: 44
    height: 72

    property string tag: "W 168 001"
    property bool isHeating: false
    property bool showTags: true

    property alias mouseArea: heaterMouseArea

    signal clicked

    // 1. TOP OUTLET NOZZLE & FLANGE
    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: heaterBody.horizontalCenter
        width: 10
        height: 10
        color: "#334155"
        border.color: "#64748b"
        border.width: 1
    }
    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: heaterBody.horizontalCenter
        width: 18
        height: 4
        radius: 1
        color: "#64748b"
        border.color: "#94a3b8"
        border.width: 0.8
    }

    // 2. MAIN CYLINDRICAL HEATER HOUSING (W 168 001)
    Rectangle {
        id: heaterBody
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 8
        width: 32
        height: 54
        radius: 4
        color: "#0a2642"
        border.color: heaterRoot.isHeating ? "#f97316" : "#38bdf8"
        border.width: 1.6

        // Left Terminal Power Junction Box
        Rectangle {
            anchors.left: parent.left
            anchors.leftMargin: -6
            anchors.verticalCenter: parent.verticalCenter
            width: 7
            height: 16
            radius: 1.5
            color: "#0f172a"
            border.color: "#38bdf8"
            border.width: 1
        }

        // Internal Electric Heating Coil (Vector Zigzag)
        Shape {
            anchors.fill: parent
            anchors.margins: 4
            layer.enabled: true
            layer.smooth: true

            ShapePath {
                strokeColor: heaterRoot.isHeating ? "#f97316" : "#475569"
                strokeWidth: 2.2
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                startX: 12
                startY: 4
                PathLine { x: 12; y: 9 }
                PathLine { x: 5; y: 14 }
                PathLine { x: 19; y: 19 }
                PathLine { x: 5; y: 24 }
                PathLine { x: 19; y: 29 }
                PathLine { x: 5; y: 34 }
                PathLine { x: 19; y: 39 }
                PathLine { x: 12; y: 44 }
            }
        }
    }

    // 3. BOTTOM INLET NOZZLE & FLANGE
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: heaterBody.horizontalCenter
        width: 10
        height: 10
        color: "#334155"
        border.color: "#64748b"
        border.width: 1
    }
    Rectangle {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: heaterBody.horizontalCenter
        width: 18
        height: 4
        radius: 1
        color: "#64748b"
        border.color: "#94a3b8"
        border.width: 0.8
    }

    // 4. TAG LABEL
    Text {
        visible: heaterRoot.showTags
        anchors.left: heaterBody.right
        anchors.leftMargin: 8
        anchors.verticalCenter: heaterBody.verticalCenter
        text: heaterRoot.tag
        color: heaterRoot.isHeating ? "#fb923c" : "#94a3b8"
        font.pixelSize: 10
        font.bold: true
    }

    MouseArea {
        id: heaterMouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
