import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: root
    property string text: "Button"
    property string iconSource: ""
    property color buttonColor: Theme.primary
    property color textColor: Theme.textPrimary
    property bool isPrimary: true
    property bool isSmall: false

    signal clicked()

    implicitWidth: Math.max(isSmall ? Dimensions.buttonHeightMd : Dimensions.minTouchTarget, contentLayout.implicitWidth + (Dimensions.spaceMd * 2))
    implicitHeight: isSmall ? Dimensions.buttonHeightMd : Dimensions.minTouchTarget
    Layout.preferredHeight: isSmall ? Dimensions.buttonHeightMd : Dimensions.minTouchTarget

    radius: Dimensions.cornerRadiusSm
    color: mouseArea.pressed ? Theme.accentHover : (mouseArea.containsMouse ? Qt.lighter(buttonColor, 1.15) : buttonColor)
    border.color: mouseArea.containsMouse ? Theme.primaryGlow : Theme.borderBright
    border.width: Dimensions.borderWidthThin

    Behavior on color { ColorAnimation { duration: 100 } }

    RowLayout {
        id: contentLayout
        anchors.centerIn: parent
        spacing: Dimensions.spaceSm

        Text {
            visible: root.iconSource !== ""
            text: root.iconSource
            color: root.textColor
            font.pixelSize: Typography.sizeH2
        }

        Text {
            text: root.text
            color: root.textColor
            font.pointSize: root.isSmall ? Typography.sizeBadge : Typography.sizeBody
            font.weight: Typography.weightBold
            font.family: Typography.fontDisplay
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
