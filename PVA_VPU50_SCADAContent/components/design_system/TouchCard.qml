import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: root
    property bool isElevated: true
    property bool isHovered: cardMouse.containsMouse
    property color cardColor: isHovered ? Theme.bgCardHover : Theme.bgCard

    color: cardColor
    radius: Dimensions.cornerRadiusMd
    border.color: isHovered ? Theme.borderBright : Theme.borderDim
    border.width: Dimensions.borderWidthThin

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    MouseArea {
        id: cardMouse
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton // Passthrough by default
    }
}
