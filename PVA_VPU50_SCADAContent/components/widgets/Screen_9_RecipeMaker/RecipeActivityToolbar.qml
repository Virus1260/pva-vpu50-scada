import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ".."

// Activity types on a task: timer, manual, media, loop, schedule, hold, equipment, checklist.
// Optimized for touchscreen human finger touch operation (36px x 36px touch targets).
Item {
    id: toolbarRoot
    implicitWidth: 320
    implicitHeight: 38
    Layout.fillWidth: true
    Layout.preferredHeight: 38

    property bool hasTimer: false
    property bool hasManual: false
    property bool hasMedia: false
    property bool hasLoop: false
    property bool hasSchedule: false
    property bool hasHold: false
    property bool hasEquip: false
    property bool hasCheck: false

    signal typeToggled(string typeKey)

    Row {
        spacing: 6
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: [
                { key: "timer", icon: "act_timer", tip: "Timer / duration", on: toolbarRoot.hasTimer },
                { key: "manual", icon: "act_manual", tip: "Manual operator action", on: toolbarRoot.hasManual },
                { key: "media", icon: "act_media", tip: "Instruction media", on: toolbarRoot.hasMedia },
                { key: "loop", icon: "act_loop", tip: "Repeat / loop", on: toolbarRoot.hasLoop },
                { key: "schedule", icon: "act_schedule", tip: "NLT / max time window", on: toolbarRoot.hasSchedule },
                { key: "hold", icon: "act_hold", tip: "Stop interlock / e-sign hold", on: toolbarRoot.hasHold },
                { key: "equip", icon: "act_equip", tip: "P&ID equipment operation", on: toolbarRoot.hasEquip },
                { key: "check", icon: "act_check", tip: "Checklist / verification", on: toolbarRoot.hasCheck }
            ]
            delegate: Rectangle {
                id: actBtn
                width: 36
                height: 36
                radius: 6
                color: modelData.on ? "#0e4370" : (actMouse.containsMouse ? "#11385f" : "#09223a")
                border.color: modelData.on ? "#00d2ff" : (actMouse.containsMouse ? "#38bdf8" : "#1d5b94")
                border.width: modelData.on ? 2.0 : 1.0

                scale: actMouse.pressed ? 0.90 : (actMouse.containsMouse ? 1.08 : 1.0)
                Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutQuad } }

                // Top Specular Highlight on Active
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 2
                    height: 3
                    radius: 2
                    color: "#ffffff"
                    opacity: modelData.on ? 0.4 : 0.0
                }

                ScadaIcon {
                    anchors.centerIn: parent
                    width: 22
                    height: 22
                    iconName: modelData.icon
                    iconColor: modelData.on ? "#00d2ff" : "#94a3b8"
                }

                MouseArea {
                    id: actMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toolbarRoot.typeToggled(modelData.key)
                    ToolTip.visible: containsMouse
                    ToolTip.text: modelData.tip
                    ToolTip.delay: 200
                }
            }
        }
    }
}
