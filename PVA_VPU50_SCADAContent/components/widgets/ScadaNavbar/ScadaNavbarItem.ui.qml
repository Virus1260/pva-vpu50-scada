import QtQuick
import QtQuick.Layouts
import ".."
import "../../../theme"

// Ergonomic Square Navigation Tile
Rectangle {
    id: navBtn
    implicitWidth: 96
    implicitHeight: 96
    width: 96
    height: 96
    radius: Dimensions.cornerRadiusMd

    property int itemId: 0
    property string itemIcon: "status_stack"
    property string itemLabel: "Control"
    property bool isActive: false
    property int badgeCount: 0
    property bool isHovered: navMouse.containsMouse
    property bool isPressed: navMouse.pressed

    property alias mouseArea: navMouse

    color: navBtn.isActive ? Theme.accentHover : (navBtn.isPressed ? Theme.bgInput : (navBtn.isHovered ? Theme.bgCardHover : Theme.bgCard))
    border.color: navBtn.isActive ? Theme.primaryGlow : (navBtn.isHovered ? Theme.primary : Theme.borderDim)
    border.width: navBtn.isActive ? Dimensions.borderWidthThick : Dimensions.borderWidthThin

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on border.color { ColorAnimation { duration: 120 } }

    // Active Left Neon Indicator Strip
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: Dimensions.spaceXs
        width: 4
        radius: 2
        color: Theme.primaryGlow
        visible: navBtn.isActive
    }

    property int iconBoxSize: navBtn.height < 84 ? 34 : 42

    ColumnLayout {
        anchors.centerIn: parent
        spacing: navBtn.height < 84 ? 2 : Dimensions.spaceXs

        Item {
            Layout.preferredWidth: navBtn.iconBoxSize
            Layout.preferredHeight: navBtn.iconBoxSize
            Layout.alignment: Qt.AlignHCenter

            ScadaIcon {
                anchors.centerIn: parent
                width: navBtn.iconBoxSize - 2
                height: navBtn.iconBoxSize - 2
                iconName: (navBtn.itemIcon === "alarms_bell" && navBtn.badgeCount === 0) ? "alarms_bell_green" : navBtn.itemIcon
                iconColor: navBtn.isActive ? Theme.textPrimary : (navBtn.isHovered ? Theme.textHighlight : Theme.textSecondary)
            }
        }

        Text {
            Layout.preferredWidth: 88
            Layout.alignment: Qt.AlignHCenter
            text: navBtn.itemLabel
            color: navBtn.isActive ? Theme.textPrimary : (navBtn.isHovered ? Theme.textPrimary : Theme.textSecondary)
            font.bold: true
            font.pointSize: Typography.sizeBadge
            font.family: Typography.fontDisplay
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            maximumLineCount: 2
            elide: Text.ElideRight
        }
    }

    // =========================================================================
    // Enhanced High-Visibility Pulsing Alarm Badge (Prominent & Interactive)
    // =========================================================================
    Item {
        id: badgeContainer
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 4
        anchors.rightMargin: 4
        width: Math.max(26, badgeLabel.implicitWidth + 12)
        height: 24
        visible: navBtn.badgeCount > 0
        z: 10

        // Pulsing Soft Glow Halo Ring
        Rectangle {
            id: glowRing
            anchors.centerIn: parent
            width: parent.width + 8
            height: parent.height + 8
            radius: (parent.height + 8) / 2
            color: "transparent"
            border.color: "#ef4444"
            border.width: 2
            opacity: 0.0

            SequentialAnimation on scale {
                running: navBtn.badgeCount > 0
                loops: Animation.Infinite
                NumberAnimation { from: 0.9; to: 1.35; duration: 900; easing.type: Easing.OutQuad }
                NumberAnimation { from: 1.35; to: 0.9; duration: 900; easing.type: Easing.InQuad }
            }

            SequentialAnimation on opacity {
                running: navBtn.badgeCount > 0
                loops: Animation.Infinite
                NumberAnimation { from: 0.8; to: 0.0; duration: 900; easing.type: Easing.OutQuad }
                NumberAnimation { from: 0.0; to: 0.8; duration: 900; easing.type: Easing.InQuad }
            }
        }

        // Main Alarm Badge Pill
        Rectangle {
            id: badgePill
            anchors.fill: parent
            radius: height / 2
            color: navBtn.isHovered ? "#dc2626" : "#ef4444"
            border.color: "#ffffff"
            border.width: 2.0

            scale: navBtn.isHovered ? 1.15 : 1.0
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

            // Inner Highlight Top Gloss
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 2
                height: 4
                radius: 2
                color: "#ffffff"
                opacity: 0.35
            }

            Text {
                id: badgeLabel
                anchors.centerIn: parent
                text: navBtn.badgeCount > 99 ? "99+" : (navBtn.badgeCount + "")
                color: "#ffffff"
                font.pixelSize: 12
                font.bold: true
                font.family: "Segoe UI"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    MouseArea {
        id: navMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
}
