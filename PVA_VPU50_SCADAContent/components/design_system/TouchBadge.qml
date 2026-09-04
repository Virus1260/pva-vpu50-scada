import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: root
    property alias text: label.text
    property color badgeColor: Theme.primary
    property bool isMonospace: true

    property int horizontalPadding: Dimensions.spaceSm

    implicitWidth: label.implicitWidth + (horizontalPadding * 2)
    implicitHeight: 28
    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    radius: Dimensions.cornerRadiusSm
    color: Qt.rgba(badgeColor.r, badgeColor.g, badgeColor.b, 0.15)
    border.color: badgeColor
    border.width: Dimensions.borderWidthThin
    clip: true

    Text {
        id: label
        anchors.centerIn: parent
        anchors.leftMargin: Dimensions.spaceSm
        anchors.rightMargin: Dimensions.spaceSm
        font.family: root.isMonospace ? Typography.fontMono : Typography.fontDisplay
        font.pointSize: Typography.sizeBadge
        font.weight: Typography.weightBold
        color: root.badgeColor
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
}
