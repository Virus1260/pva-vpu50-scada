import QtQuick
import QtQuick.Controls
import "../../theme"

Flickable {
    id: root
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    flickableDirection: Flickable.VerticalFlick

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
        width: 8
        contentItem: Rectangle {
            implicitWidth: 6
            radius: 3
            color: parent.pressed ? Theme.primaryGlow : (parent.hovered ? Theme.primary : Theme.borderDim)
        }
    }
}
