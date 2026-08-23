/*
This is a UI file (.ui.qml) for Screen 6: 21 CFR Part 11 Audit Trail.
Strictly declarative for Qt Design Studio.
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: auditViewRoot
    width: 1184
    height: 626
    color: "#08213b"

    property alias exportLogBtn: exportButton

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // =====================================================================
        // 1. TOP HEADER & INTEGRITY VERIFICATION BADGE
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            radius: 5
            color: "#0d2b4a"
            border.color: "#184d7e"
            border.width: 1.2

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 12

                Rectangle {
                    width: 34
                    height: 34
                    radius: 4
                    color: "#0284c7"
                    Image {
                        source: "../assets/icons/nav/docs_report.svg"
                        width: 18
                        height: 18
                        sourceSize: Qt.size(18, 18)
                        fillMode: Image.PreserveAspectFit
                        anchors.centerIn: parent
                    }
                }

                ColumnLayout {
                    spacing: 2
                    Text { text: "21 CFR PART 11 ELECTRONIC AUDIT TRAIL & EBR"; color: "#ffffff"; font.bold: true; font.pixelSize: 15 }
                    Text { text: "Tamper-Evident Append-Only Cryptographic Event Log"; color: "#94a3b8"; font.pixelSize: 11 }
                }

                Item { Layout.fillWidth: true }

                // Cryptographic Chain Verification Badge
                Rectangle {
                    Layout.preferredWidth: 230
                    Layout.preferredHeight: 34
                    radius: 4
                    color: "#052e16"
                    border.color: "#22c55e"
                    border.width: 1.2

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Rectangle { width: 8; height: 8; radius: 4; color: "#22c55e" }
                        Text { text: "SHA-256 HMAC: VERIFIED"; color: "#4ade80"; font.bold: true; font.pixelSize: 11 }
                    }
                }

                // Export Button
                Rectangle {
                    id: exportButton
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 34
                    radius: 4
                    color: "#0f2b48"
                    border.color: "#0284c7"

                    Text {
                        anchors.centerIn: parent
                        text: "Export Log"
                        color: "#38bdf8"
                        font.bold: true
                        font.pixelSize: 12
                    }
                }
            }
        }

        // =====================================================================
        // 2. AUDIT LOG TABLE HEADER
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            color: "#0d2b4a"
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text { text: "SEQ #"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 60 }
                Text { text: "TIMESTAMP (UTC)"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 140 }
                Text { text: "USER ID"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 90 }
                Text { text: "ACTION"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 130 }
                Text { text: "TARGET / TAG"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 130 }
                Text { text: "REASON FOR CHANGE (21 CFR 11)"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.fillWidth: true }
                Text { text: "VALUE CHANGE"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 140 }
                Text { text: "RECORD HASH"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 110 }
            }
        }

        // =====================================================================
        // 3. AUDIT LOG EVENT LIST
        // =====================================================================
        ListView {
            id: auditEventsListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4

            model: ListModel {
                ListElement { seq: "001"; time: "2026-08-17 09:10:02"; actor: "operator"; action: "USER_LOGIN"; target: "SESSION"; reason: "Operator shift login"; before: "--"; after: "operator"; hash: "a4f81c9b2e..." }
                ListElement { seq: "002"; time: "2026-08-17 09:12:15"; actor: "supervisor"; action: "SETPOINT_CHANGE"; target: "vpu.main.temperature"; reason: "Product heating setpoint adjusted"; before: "25.0 °C"; after: "75.0 °C"; hash: "7c12f0e4b8..." }
                ListElement { seq: "003"; time: "2026-08-17 09:15:30"; actor: "operator"; action: "BATCH_START"; target: "B-20260817-001"; reason: "Recipe Body Lotion initiated"; before: "IDLE"; after: "RUNNING"; hash: "99e1a4d2c7..." }
                ListElement { seq: "004"; time: "2026-08-17 09:25:40"; actor: "operator"; action: "MANUAL_CONFIRM"; target: "STEP_4_PHASE_B"; reason: "Confirmed Phase B oils addition"; before: "WAITING"; after: "DONE"; hash: "3b8a19c5d1..." }
                ListElement { seq: "005"; time: "2026-08-17 09:42:15"; actor: "SYSTEM"; action: "ALARM_TRIGGER"; target: "PIC161001"; reason: "Vacuum pressure low deviation"; before: "NORMAL"; after: "ALARM"; hash: "d83c21a9f0..." }
                ListElement { seq: "006"; time: "2026-08-17 09:43:00"; actor: "operator"; action: "ALARM_ACK"; target: "PIC161001"; reason: "Lid seal inspected and verified"; before: "UNACK"; after: "ACK"; hash: "5f90e2b4a3..." }
            }

            delegate: Rectangle {
                width: auditEventsListView ? auditEventsListView.width : 0
                height: 46
                radius: 4
                color: index % 2 === 0 ? "#071c33" : "#092440"
                border.color: "#1e3a8a"
                border.width: 1.0

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 10

                    Text { text: model.seq; color: "#94a3b8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 60 }
                    Text { text: model.time; color: "#ffffff"; font.pixelSize: 11; Layout.preferredWidth: 140 }
                    Text { text: model.actor; color: "#38bdf8"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 90 }
                    Text { text: model.action; color: "#4ade80"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 130 }
                    Text { text: model.target; color: "#facc15"; font.pixelSize: 11; Layout.preferredWidth: 130 }
                    Text { text: model.reason; color: "#e2e8f0"; font.pixelSize: 11; Layout.fillWidth: true }
                    Text { text: model.before + " -> " + model.after; color: "#cbd5e1"; font.pixelSize: 11; Layout.preferredWidth: 140 }
                    Text { text: model.hash; color: "#94a3b8"; font.pixelSize: 10; font.family: "Monospace"; Layout.preferredWidth: 110 }
                }
            }
        }
    }
}
