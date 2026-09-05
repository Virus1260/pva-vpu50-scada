import QtQuick
import QtQuick.Layouts
import "../../theme"

Rectangle {
    id: modeBtnRoot
    implicitWidth: 320
    implicitHeight: Dimensions.minTouchTarget
    Layout.fillWidth: true
    Layout.preferredHeight: Dimensions.minTouchTarget

    property string iconName: "homo_permanent"
    property string title: "Permanent"
    property string subtitle: "Continuous Run"
    property bool readOnly: false

    signal clicked()

    color: mouseArea.pressed ? Theme.bgCardHover : (mouseArea.containsMouse ? Theme.bgCardHover : Theme.bgSurface)
    border.color: mouseArea.containsMouse ? Theme.primaryGlow : Theme.borderDim
    border.width: Dimensions.borderWidthThin
    radius: Dimensions.cornerRadiusSm

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Dimensions.spaceSm
        anchors.rightMargin: Dimensions.spaceSm
        spacing: Dimensions.spaceSm

        // Subsystem Mode Icon
        Rectangle {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            radius: Dimensions.cornerRadiusSm
            color: Theme.bgInput
            border.color: Theme.borderDim
            border.width: Dimensions.borderWidthThin

            ScadaIcon {
                anchors.centerIn: parent
                iconName: modeBtnRoot.iconName
                width: 24
                height: 24
            }
        }

        // Title and Subtitle Column (Stacked cleanly with vertical space)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: modeBtnRoot.title
                color: Theme.textPrimary
                font.bold: true
                font.pointSize: Typography.sizeBody
                font.family: Typography.fontDisplay
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: modeBtnRoot.subtitle
                color: Theme.textSecondary
                font.pointSize: Typography.sizeBadge
                font.family: Typography.fontDisplay
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        // Action Pill Button [ CHANGE ] (Tactile 52px target)
        Rectangle {
            Layout.preferredWidth: 76
            Layout.preferredHeight: 32
            radius: Dimensions.cornerRadiusSm
            color: mouseArea.containsMouse ? Theme.accentHover : Theme.bgCard
            border.color: mouseArea.containsMouse ? Theme.textPrimary : Theme.borderBright
            border.width: Dimensions.borderWidthThin
            visible: !modeBtnRoot.readOnly

            Text {
                anchors.centerIn: parent
                text: "CHANGE"
                color: mouseArea.containsMouse ? Theme.textPrimary : Theme.textHighlight
                font.bold: true
                font.pointSize: Typography.sizeBadge
                font.family: Typography.fontDisplay
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: !modeBtnRoot.readOnly
        enabled: !modeBtnRoot.readOnly
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: modeBtnRoot.clicked()
    }
}
