/*
This is a UI file (.ui.qml) for Alarms Historical Event Log Table.
Strictly declarative for Qt Design Studio.
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: historyTableRoot
    width: 1160
    height: 560
    implicitWidth: 1160
    implicitHeight: 560
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#06182c"
    border.color: "#184d7e"
    border.width: 1.2
    radius: 5
    clip: true

    property alias historyList: historyListView

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        // Event Log Table Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            color: "#0d2b4a"
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                Text { text: "TIMESTAMP (UTC)"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 120 }
                Text { text: "EVENT TYPE"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 100 }
                Text { text: "TAG / OBJECT"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 110 }
                Text { text: "EVENT DESCRIPTION & OPERATOR CONTEXT"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.fillWidth: true }
                Text { text: "USER / ROLE"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 130; horizontalAlignment: Text.AlignRight }
                Text { text: "STATUS"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 90; horizontalAlignment: Text.AlignHCenter }
            }
        }

        // Event Log List View
        ListView {
            id: historyListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4

            model: ListModel {
                ListElement { time: "09:44:10 UTC"; type: "ALARM_TRIP"; tag: "system.estop"; desc: "Emergency Stop Pushbutton Engaged - Plant Safety Loop Opened"; user: "HARDWARE (E-Stop)"; status: "ACTIVE" }
                ListElement { time: "09:42:15 UTC"; type: "ALARM_TRIP"; tag: "PIC161001"; desc: "Vacuum Seal Differential Pressure Loss triggered (Value: -209.8 mbar, SP: -450.0 mbar)"; user: "SYSTEM (PLC)"; status: "ACTIVE" }
                ListElement { time: "09:40:02 UTC"; type: "ALARM_TRIP"; tag: "TIC162001"; desc: "Jacket Thermal Overheat Warning triggered (Value: 88.9 °C, SP: 80.0 °C)"; user: "SYSTEM (PLC)"; status: "ACTIVE" }
                ListElement { time: "09:38:40 UTC"; type: "ALARM_TRIP"; tag: "1P163001"; desc: "Mechanical Seal Barrier Pot Low Pressure (Value: 0.8 bar, SP: 2.5 bar)"; user: "SYSTEM (PLC)"; status: "ACTIVE" }
                ListElement { time: "09:35:18 UTC"; type: "ALARM_ACK"; tag: "SCR182001"; desc: "Agitator Drive Ready Status Feedback acknowledged: Motor VFD verified"; user: "supervisor (Level 2)"; status: "ACKED" }
                ListElement { time: "09:32:10 UTC"; type: "ALARM_ACK"; tag: "system.comm"; desc: "Delta AS332T-A PLC Link Latency acknowledged: Switch checked"; user: "operator (Level 1)"; status: "ACKED" }
                ListElement { time: "09:30:00 UTC"; type: "INFO_LOG"; tag: "1M2003"; desc: "Homogenizer Seal Cooling Fluid Flow Normal telemetry verified"; user: "operator (Level 1)"; status: "CLEARED" }
            }

            delegate: Rectangle {
                width: historyListView ? historyListView.width : 0
                height: 48
                radius: 4
                color: index % 2 === 0 ? "#071c33" : "#092440"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Text { text: model.time; color: "#cbd5e1"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 120 }
                    Text { text: model.type; color: model.type === "ALARM_TRIP" ? "#ef4444" : "#38bdf8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 100 }
                    Text { text: model.tag; color: "#f59e0b"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 110 }
                    Text { text: model.desc; color: "#ffffff"; font.pixelSize: 11; Layout.fillWidth: true; elide: Text.ElideRight }
                    Text { text: model.user; color: "#94a3b8"; font.pixelSize: 11; Layout.preferredWidth: 130; horizontalAlignment: Text.AlignRight }
                    Rectangle {
                        Layout.preferredWidth: 90
                        Layout.preferredHeight: 24
                        radius: 3
                        color: model.status === "ACTIVE" ? "#7f1d1d" : "#064e3b"
                        Text { anchors.centerIn: parent; text: model.status; color: model.status === "ACTIVE" ? "#fca5a5" : "#6ee7b7"; font.bold: true; font.pixelSize: 10 }
                    }
                }
            }
        }
    }
}
