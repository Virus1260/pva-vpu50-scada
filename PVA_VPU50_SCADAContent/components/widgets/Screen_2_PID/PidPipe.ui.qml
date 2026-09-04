/*
This is a UI file (.ui.qml) that is intended to be edited in Qt Design Studio only.
It is supposed to be strictly declarative and only uses a subset of QML.
*/
import QtQuick

Item {
    id: pipeRoot
    implicitWidth: 200
    implicitHeight: 100

    // =========================================================================
    // 1. GEOMETRY & COORDINATES (Pixel-Perfect Orthogonal Routing)
    // =========================================================================
    property real startX: 0
    property real startY: 0
    property real endX: 0
    property real endY: 0
    property real pipeWidth: 5.0
    property real wallThickness: 1.0
    property string section: ""

    // =========================================================================
    // 2. INDUSTRIAL PIPE WALL & FLUID CORE COLORS
    // =========================================================================
    property color wallColor: "#0f2338"       // Dark metallic pipe wall casing
    property color wallBorderColor: "#1e3a5f" // Outer pipe wall highlight contour
    property color baseColor: "#0284c7"       // Inner fluid core color (idle)
    property color flowColor: "#38ef7d"       // Active fluid flow color
    property bool isActive: false
    property string flowDirection: "forward"  // "forward", "reverse", "none"
    property bool reverseFlow: (flowDirection === "reverse")
    property real flowSpeed: 800

    // Coordinate Normalization
    readonly property bool isHorizontal: (Math.abs(endY - startY) <= 1.0)
    readonly property real minX: Math.min(startX, endX)
    readonly property real maxX: Math.max(startX, endX)
    readonly property real minY: Math.min(startY, endY)
    readonly property real maxY: Math.max(startY, endY)

    x: isHorizontal ? minX : (minX - pipeWidth / 2)
    y: isHorizontal ? (minY - pipeWidth / 2) : minY
    width: isHorizontal ? Math.max(2, maxX - minX) : pipeWidth
    height: isHorizontal ? pipeWidth : Math.max(2, maxY - minY)

    // =========================================================================
    // 3. OUTER METALLIC PIPE WALL CASING (Thick Industrial Shell)
    // =========================================================================
    Rectangle {
        id: outerPipeWall
        anchors.fill: parent
        color: pipeRoot.wallColor
        border.color: pipeRoot.wallBorderColor
        border.width: 1
        radius: 0
    }

    // =========================================================================
    // 4. INNER FLUID CHANNEL (Visible Process Medium Flow Core)
    // =========================================================================
    Rectangle {
        id: innerFluidCore
        anchors.fill: parent
        anchors.topMargin: pipeRoot.isHorizontal ? pipeRoot.wallThickness : 0
        anchors.bottomMargin: pipeRoot.isHorizontal ? pipeRoot.wallThickness : 0
        anchors.leftMargin: pipeRoot.isHorizontal ? 0 : pipeRoot.wallThickness
        anchors.rightMargin: pipeRoot.isHorizontal ? 0 : pipeRoot.wallThickness
        color: pipeRoot.isActive ? Qt.darker(pipeRoot.flowColor, 1.8) : pipeRoot.baseColor
        radius: 0
    }

    // =========================================================================
    // 5. ANIMATED ACTIVE FLOW STREAM (Dynamic Moving Flow Core)
    // =========================================================================
    Item {
        id: flowOverlay
        anchors.fill: innerFluidCore
        visible: pipeRoot.isActive && pipeRoot.flowDirection !== "none"
        clip: true

        Rectangle {
            id: flowPulse
            color: pipeRoot.flowColor
            opacity: 0.9

            x: pipeRoot.isHorizontal ? (pipeRoot.reverseFlow ? (parent.width - width) : 0) : 0
            y: pipeRoot.isHorizontal ? 0 : (pipeRoot.reverseFlow ? (parent.height - height) : 0)
            width: pipeRoot.isHorizontal ? Math.min(parent.width, 36) : parent.width
            height: pipeRoot.isHorizontal ? parent.height : Math.min(parent.height, 36)

            NumberAnimation on x {
                running: pipeRoot.isActive && pipeRoot.isHorizontal
                from: pipeRoot.reverseFlow ? (pipeRoot.width) : -36
                to: pipeRoot.reverseFlow ? -36 : (pipeRoot.width)
                duration: pipeRoot.flowSpeed
                loops: Animation.Infinite
            }

            NumberAnimation on y {
                running: pipeRoot.isActive && !pipeRoot.isHorizontal
                from: pipeRoot.reverseFlow ? (pipeRoot.height) : -36
                to: pipeRoot.reverseFlow ? -36 : (pipeRoot.height)
                duration: pipeRoot.flowSpeed
                loops: Animation.Infinite
            }
        }
    }
}
