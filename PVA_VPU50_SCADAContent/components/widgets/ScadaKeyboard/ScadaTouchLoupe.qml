pragma ComponentBehavior: Bound
// @disable-check M203  -- JavaScript functions are required QML runtime logic; DS visual editor advisory only
import QtQuick
import QtQuick.Shapes
import "../../../theme"

Item {
    id: loupeRoot
    width: Dimensions.loupeDiameter
    height: Dimensions.loupeDiameter + 10 // extra height for downward pointer tip
    z: 100000
    enabled: false // Never intercept touch events from dragging finger
    visible: active || opacity > 0.001
    opacity: active ? 1.0 : 0.0
    x: 0
    y: 0

    Behavior on opacity {
        NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
    }

    property var targetInput: null
    property var anchorItem: null
    readonly property var activeAnchor: anchorItem ? anchorItem : targetInput
    property real fingerX: 0
    property real fingerY: 0
    property int cursorPosition: targetInput ? targetInput.cursorPosition : 0
    property bool active: false

    // Calculated text metrics for magnification
    readonly property string currentText: targetInput ? targetInput.text : ""
    readonly property font targetFont: (anchorItem && anchorItem.font) ? anchorItem.font : (targetInput ? targetInput.font : Qt.font({ family: Typography.fontDisplay, pixelSize: 12 }))
    readonly property real zoomScale: Dimensions.loupeZoomScale

    // Synchronize position to float directly above operator finger/pointer
    function updatePosition() {
        if (!activeAnchor) return;
        if (!parent || parent.width <= 0) return;

        // fingerX is a local-space offset within activeAnchor (e.g. cursorMetrics.width)
        // Use mapToItem to convert to parent coordinate space
        var fx = (isNaN(fingerX) || fingerX < 0) ? 0 : fingerX;
        var fy = (isNaN(fingerY) || fingerY < 0) ? (activeAnchor.height / 2) : fingerY;
        var globalPos = activeAnchor.mapToItem(parent, fx, fy);
        if (!globalPos || isNaN(globalPos.x) || isNaN(globalPos.y)) return;

        var targetX = globalPos.x - (width / 2);
        // Float cleanly above the finger/pointer (clears full loupe height + 12px margin)
        var targetY = globalPos.y - height - 12;

        // If too close to top edge, flip to show below the input row instead
        if (targetY < 8) {
            targetY = globalPos.y + (activeAnchor.height > 0 ? activeAnchor.height : 32) + 12;
        }

        // Boundary safety clamps inside parent view
        loupeRoot.x = Math.max(8, Math.min(parent.width - width - 8, targetX));
        loupeRoot.y = Math.max(8, Math.min(parent.height - height - 8, targetY));
        if (active) autoDismissTimer.restart();
    }

    // Auto-dismiss after 0.5 sec (500ms) of stationary inactivity
    Timer {
        id: autoDismissTimer
        interval: 500
        repeat: false
        onTriggered: loupeRoot.active = false
    }

    onFingerXChanged: {
        updatePosition();
        if (active) autoDismissTimer.restart();
    }
    onFingerYChanged: {
        updatePosition();
        if (active) autoDismissTimer.restart();
    }
    onActiveChanged: {
        if (active) {
            updatePosition();
            autoDismissTimer.restart();
        } else {
            autoDismissTimer.stop();
        }
    }
    onCursorPositionChanged: if (active) updatePosition()
    onTargetInputChanged: {
        if (!targetInput) active = false;
        if (active) updatePosition();
    }
    onAnchorItemChanged: if (active) updatePosition()

    // Circular Magnifying Glass Frame
    Rectangle {
        id: loupeCircle
        width: Dimensions.loupeDiameter
        height: Dimensions.loupeDiameter
        radius: Dimensions.loupeRadius
        color: Theme.loupeBg
        border.color: Theme.loupeBorder
        border.width: Dimensions.borderWidthThick
        clip: true

        // Inner Ambient Glow
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            border.color: "#2238bdf8"
            border.width: 4
        }

        // Magnified Text Display Canvas
        Item {
            id: magnifiedCanvas
            anchors.fill: parent

            // Exact text measurement for pixel-perfect cursor centering
            TextMetrics {
                id: cursorMetrics
                font.family: loupeRoot.targetFont.family
                font.pixelSize: Math.round(loupeRoot.targetFont.pixelSize * loupeRoot.zoomScale)
                font.bold: true
                text: loupeRoot.currentText.substring(0, Math.max(0, Math.min(loupeRoot.cursorPosition, loupeRoot.currentText.length)))
            }

            // Magnified text preview string
            Text {
                id: magnifiedText
                anchors.verticalCenter: parent.verticalCenter
                font.family: loupeRoot.targetFont.family
                font.pixelSize: Math.round(loupeRoot.targetFont.pixelSize * loupeRoot.zoomScale)
                font.bold: true
                color: "#ffffff"
                text: loupeRoot.currentText

                // Centered exactly at insertion point
                x: (loupeCircle.width / 2) - cursorMetrics.width
            }

            // High-Visibility Vertical Amber Cursor Line
            Rectangle {
                anchors.centerIn: parent
                width: 2
                height: 32
                color: Theme.loupeCursor
                radius: 1
            }

            // Subtle Horizontal Alignment Baseline
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 14
                width: 44
                height: 1
                color: "#3338bdf8"
            }
        }
    }

    // Downward Pointer Notch (Anchoring loupe to touch point)
    Shape {
        id: pointerNotch
        anchors.top: loupeCircle.bottom
        anchors.topMargin: -2
        anchors.horizontalCenter: loupeCircle.horizontalCenter
        width: 14
        height: 8

        ShapePath {
            strokeColor: Theme.loupeBorder
            strokeWidth: 2
            fillColor: Theme.loupeBg
            startX: 0
            startY: 0
            PathLine { x: 7; y: 8 }
            PathLine { x: 14; y: 0 }
            PathLine { x: 0; y: 0 }
        }
    }
}
