import QtQuick

Rectangle {
    id: navbarRoot
    implicitWidth: 110
    width: 110
    implicitHeight: 600
    color: "#08213b"

    property int activeIndex: 0
    property int unackAlarmsCount: 0
    property string userRole: "incharge"
    property int userLevel: 2 // Level 1: Operator, Level 2: Incharge, Level 3: Admin
    property bool showAllScreens: true // Allows full navigation in design/engineering mode

    // Master list of SCADA navigation items
    readonly property var navItems: [
        { id: 0, name: "Control", icon: "status_stack", label: "Control", minLevel: 1 },
        { id: 1, name: "P&ID", icon: "pid_vessel", label: "P&ID", minLevel: 1 },
        { id: 2, name: "Trends", icon: "trends_chart", label: "Trends", minLevel: 1 },
        { id: 3, name: "Alarms", icon: "alarms_bell", label: "Alarms", minLevel: 1 },
        { id: 4, name: "Recipes", icon: "recipes_checklist", label: "Recipes (Run)", minLevel: 1 },
        { id: 5, name: "RecipeMaker", icon: "recipe_maker", label: "Recipe Maker", minLevel: 1 },
        { id: 6, name: "AuditLog", icon: "logs_order", label: "Audit Log", minLevel: 1 },
        { id: 7, name: "Diagnostics", icon: "tools_maintenance", label: "Diagnostics", minLevel: 1 }
    ]

    // Top Scroll Hint / Scroll-Up Trigger
    Rectangle {
        id: topScrollIndicator
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 16
        z: 20
        color: "#06182c"
        opacity: scrollArea.contentY > 5 ? 0.95 : 0.0
        visible: opacity > 0.0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text: "▲"
            color: "#38bdf8"
            font.pixelSize: 9
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                var targetY = Math.max(0, scrollArea.contentY - 102);
                scrollAnim.to = targetY;
                scrollAnim.start();
            }
        }
    }

    // Main Vertical Scrollable Container
    Flickable {
        id: scrollArea
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        clip: true
        interactive: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        contentWidth: width
        contentHeight: itemsColumn.implicitHeight

        NumberAnimation {
            id: scrollAnim
            target: scrollArea
            property: "contentY"
            duration: 180
            easing.type: Easing.OutCubic
        }

        Column {
            id: itemsColumn
            width: scrollArea.width
            spacing: 6

            Repeater {
                model: navbarRoot.navItems

                delegate: Item {
                    width: itemsColumn.width
                    height: 96

                    ScadaNavbarItem {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 96
                        height: 96
                        itemId: modelData.id
                        itemIcon: modelData.icon
                        itemLabel: modelData.label
                        isActive: navbarRoot.activeIndex === modelData.id
                        badgeCount: modelData.id === 3 ? navbarRoot.unackAlarmsCount : 0
                        visible: navbarRoot.showAllScreens || modelData.minLevel <= navbarRoot.userLevel

                        mouseArea.onClicked: {
                            navbarRoot.activeIndex = modelData.id;
                        }
                    }
                }
            }
        }

        // Mouse Wheel Scroll Handler
        WheelHandler {
            target: scrollArea
            onWheel: (event) => {
                var step = 102;
                var delta = event.angleDelta.y > 0 ? -step : step;
                var newY = Math.max(0, Math.min(scrollArea.contentHeight - scrollArea.height, scrollArea.contentY + delta));
                scrollArea.contentY = newY;
            }
        }
    }

    // Bottom Scroll Hint / Scroll-Down Trigger
    Rectangle {
        id: bottomScrollIndicator
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 16
        z: 20
        color: "#06182c"
        opacity: (scrollArea.contentHeight > scrollArea.height && scrollArea.contentY < (scrollArea.contentHeight - scrollArea.height - 5)) ? 0.95 : 0.0
        visible: opacity > 0.0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            text: "▼"
            color: "#38bdf8"
            font.pixelSize: 9
            font.bold: true
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                var maxY = scrollArea.contentHeight - scrollArea.height;
                var targetY = Math.min(maxY, scrollArea.contentY + 102);
                scrollAnim.to = targetY;
                scrollAnim.start();
            }
        }
    }

    // Sleek Cyan Vertical Scrollbar Track & Thumb
    Rectangle {
        id: scrollbarThumb
        anchors.right: parent.right
        anchors.rightMargin: 1
        width: 3
        radius: 1.5
        color: "#38bdf8"
        opacity: scrollArea.contentHeight > scrollArea.height ? (scrollArea.moving ? 0.9 : 0.4) : 0.0
        visible: scrollArea.contentHeight > scrollArea.height
        y: scrollArea.height > 0 ? (scrollArea.contentY / scrollArea.contentHeight) * scrollArea.height : 0
        height: scrollArea.height > 0 ? Math.max(20, (scrollArea.height / scrollArea.contentHeight) * scrollArea.height) : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
    }
}
