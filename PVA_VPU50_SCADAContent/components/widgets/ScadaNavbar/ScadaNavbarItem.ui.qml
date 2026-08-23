import QtQuick
import QtQuick.Layouts
import ".."

// Perfect Square Navigation Tile (96px x 96px)
Rectangle {
    id: navBtn
    implicitWidth: 96
    implicitHeight: 96
    width: 96
    height: 96
    radius: 6

    property int itemId: 0
    property string itemIcon: "status_stack"
    property string itemLabel: "Control"
    property bool isActive: false
    property int badgeCount: 0
    property bool isHovered: navMouse.containsMouse
    property bool isPressed: navMouse.pressed

    property alias mouseArea: navMouse

    color: navBtn.isActive ? "#155590" : (navBtn.isPressed ? "#07203a" : (navBtn.isHovered ? "#103f6d" : "#0d365e"))
    border.color: navBtn.isActive ? "#00d2ff" : (navBtn.isHovered ? "#38bdf8" : "#1a5286")
    border.width: navBtn.isActive ? 2.0 : 1.0

    // Active Left Neon Indicator Strip
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 4
        width: 4
        radius: 2
        color: "#00d2ff"
        visible: navBtn.isActive
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 4

        Item {
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            Layout.alignment: Qt.AlignHCenter

            ScadaIcon {
                anchors.centerIn: parent
                width: 36
                height: 36
                iconName: (navBtn.itemIcon === "alarms_bell" && navBtn.badgeCount === 0) ? "alarms_bell_green" : navBtn.itemIcon
                iconColor: "#ffffff"
            }
        }

        Text {
            Layout.preferredWidth: 84
            Layout.alignment: Qt.AlignHCenter
            text: navBtn.itemLabel
            color: navBtn.isActive ? "#ffffff" : (navBtn.isHovered ? "#e0f2fe" : "#94a3b8")
            font.bold: true
            font.pixelSize: 10
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
