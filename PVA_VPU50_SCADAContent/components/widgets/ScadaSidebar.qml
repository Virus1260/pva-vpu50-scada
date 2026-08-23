import QtQuick
import QtQuick.Layouts

Rectangle {
    id: sidebarRoot
    implicitWidth: 110
    width: 110
    implicitHeight: 600
    height: 600
    color: "#08213b"

    property int activeIndex: 0
    property int unackAlarmsCount: 0
    property string userRole: "operator" // "operator", "incharge", "administrator"
    property int userLevel: 1 // 1: Operator, 2: Incharge/Supervisor, 3: Administrator

    // All available screens with role requirements
    property var allNavItems: [
        { id: 0, name: "Control", icon: "status_stack", label: "Control", minLevel: 1 },
        { id: 1, name: "P&ID", icon: "pid_vessel", label: "P&ID", minLevel: 1 },
        { id: 2, name: "Trends", icon: "trends_chart", label: "Trends", minLevel: 1 },
        { id: 3, name: "Alarms", icon: "alarms_bell", label: "Alarms", minLevel: 1 },
        { id: 4, name: "Recipes", icon: "recipes_checklist", label: "Recipes (Run)", minLevel: 1 },
        { id: 5, name: "RecipeMaker", icon: "recipe_maker", label: "Recipe Maker", minLevel: 2 }, // Incharge / Admin only
        { id: 6, name: "AuditLog", icon: "logs_order", label: "Audit Log", minLevel: 1 },
        { id: 7, name: "Diagnostics", icon: "tools_maintenance", label: "Diagnostics", minLevel: 1 }
    ]

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        anchors.topMargin: 6
        anchors.bottomMargin: 6
        spacing: 5

        Repeater {
            model: sidebarRoot.allNavItems

            delegate: Rectangle {
                id: navBtn
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 6
                visible: modelData.minLevel <= sidebarRoot.userLevel

                property bool isActive: sidebarRoot.activeIndex === modelData.id
                property bool isHovered: navMouse.containsMouse
                property bool isPressed: navMouse.pressed

                color: navBtn.isActive ? "#155590" : (navBtn.isPressed ? "#07203a" : (navBtn.isHovered ? "#103f6d" : "#0d365e"))
                border.color: navBtn.isActive ? "#00d2ff" : (navBtn.isHovered ? "#38bdf8" : "#1a5286")
                border.width: navBtn.isActive ? 2.5 : 1

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

                    ScadaIcon {
                        iconName: (modelData.icon === "alarms_bell" && sidebarRoot.unackAlarmsCount === 0) ? "alarms_bell_green" : modelData.icon
                        iconColor: "#ffffff"
                        width: 32
                        height: 32
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: modelData.label
                        color: navBtn.isActive ? "#ffffff" : (navBtn.isHovered ? "#e0f2fe" : "#94a3b8")
                        font.bold: true
                        font.pixelSize: 11
                        Layout.alignment: Qt.AlignHCenter
                        elide: Text.ElideRight
                    }
                }

                MouseArea {
                    id: navMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: sidebarRoot.activeIndex = modelData.id
                }
            }
        }
    }
}
