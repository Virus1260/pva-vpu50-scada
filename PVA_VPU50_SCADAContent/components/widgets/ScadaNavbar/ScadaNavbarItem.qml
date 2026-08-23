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

    signal clicked()

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

    // Unacknowledged Alarms / Notification Badge
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 4
        anchors.rightMargin: 4
        width: 18
        height: 18
        radius: 9
        color: "#ef4444"
        border.color: "#ffffff"
        border.width: 1
        visible: navBtn.badgeCount > 0

        Text {
            anchors.centerIn: parent
            text: navBtn.badgeCount > 99 ? "99+" : navBtn.badgeCount
            color: "#ffffff"
            font.pixelSize: 9
            font.bold: true
        }
    }

    MouseArea {
        id: navMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: navBtn.clicked()
    }
}
