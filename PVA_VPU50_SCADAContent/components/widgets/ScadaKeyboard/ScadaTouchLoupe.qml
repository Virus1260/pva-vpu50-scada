import QtQuick
import QtQuick.Shapes
import "../../../theme"

Item {
    id: loupeRoot
    width: Dimensions.loupeDiameter
    height: Dimensions.loupeDiameter + 10 // extra height for downward pointer tip
    z: 99999
    visible: active && opacity > 0.01
    opacity: active ? 1.0 : 0.0

    Behavior on opacity {
        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
    }

    property var targetInput: null
    property real fingerX: 0
    property real fingerY: 0
    property int cursorPosition: targetInput ? targetInput.cursorPosition : 0
    property bool active: false

    // Calculated text metrics for magnification
    readonly property string currentText: targetInput ? targetInput.text : ""
    readonly property font targetFont: targetInput ? targetInput.font : Qt.font({ family: Typography.fontDisplay, pixelSize: 12 })
    readonly property real zoomScale: Dimensions.loupeZoomScale

    // Synchronize position to float directly above operator finger
    function updatePosition() {
        if (!targetInput || !parent) return;
        var globalPos = targetInput.mapToItem(parent, fingerX, fingerY);
        var targetX = globalPos.x - (width / 2);
        var targetY = globalPos.y + Dimensions.loupeOffsetY;

        // Boundary safety clamps inside parent view
        loupeRoot.x = Math.max(8, Math.min(parent.width - width - 8, targetX));
        loupeRoot.y = Math.max(8, Math.min(parent.height - height - 8, targetY));
    }

    onFingerXChanged: updatePosition()
    onFingerYChanged: updatePosition()
    onActiveChanged: if (active) updatePosition()

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

            // Magnified text preview string
            Text {
                id: magnifiedText
                anchors.verticalCenter: parent.verticalCenter
                font.family: loupeRoot.targetFont.family
                font.pixelSize: Math.round(loupeRoot.targetFont.pixelSize * loupeRoot.zoomScale)
                font.bold: true
                color: "#ffffff"
                text: loupeRoot.currentText

                // Calculate horizontal shift so cursor position is centered exactly in the loupe
                x: {
                    var curPos = Math.max(0, Math.min(loupeRoot.cursorPosition, loupeRoot.currentText.length));
                    var textBefore = loupeRoot.currentText.substring(0, curPos);
                    var textMetricsWidth = curPos > 0 ? (curPos * (font.pixelSize * 0.58)) : 0;
                    return (loupeCircle.width / 2) - textMetricsWidth;
                }
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
