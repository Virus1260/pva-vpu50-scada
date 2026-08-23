import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Activity types on a task: timer, manual, media, loop, schedule, hold, equipment, checklist.
Item {
    id: toolbarRoot
    implicitWidth: 220
    implicitHeight: 26
    Layout.fillWidth: true
    Layout.preferredHeight: 26

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
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter

        Repeater {
            model: [
                { key: "timer", glyph: "⏱", tip: "Timer / duration", on: toolbarRoot.hasTimer },
                { key: "manual", glyph: "✋", tip: "Manual operator action", on: toolbarRoot.hasManual },
                { key: "media", glyph: "▣", tip: "Instruction media", on: toolbarRoot.hasMedia },
                { key: "loop", glyph: "↻", tip: "Repeat / loop", on: toolbarRoot.hasLoop },
                { key: "schedule", glyph: "◷", tip: "NLT / max time window", on: toolbarRoot.hasSchedule },
                { key: "hold", glyph: "🔒", tip: "Stop interlock / e-sign hold", on: toolbarRoot.hasHold },
                { key: "equip", glyph: "⚙", tip: "P&ID equipment operation", on: toolbarRoot.hasEquip },
                { key: "check", glyph: "☑", tip: "Checklist / verification", on: toolbarRoot.hasCheck }
            ]
            delegate: Rectangle {
                width: 22
                height: 22
                radius: 3
                color: modelData.on ? "#0d3a62" : "#0a243f"
                border.color: modelData.on ? "#00d2ff" : "#1d5b94"
                border.width: modelData.on ? 1.5 : 1

                Text {
                    anchors.centerIn: parent
                    text: modelData.glyph
                    color: modelData.on ? "#00d2ff" : "#94a3b8"
                    font.pixelSize: 11
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: toolbarRoot.typeToggled(modelData.key)
                    ToolTip.visible: containsMouse
                    ToolTip.text: modelData.tip
                    ToolTip.delay: 250
                }
            }
        }
    }
}
