/*
This is a UI file (.ui.qml) for Trends Top Control Bar.
Strictly declarative for Qt Design Studio. Uses SVG icons for web/WASM compatibility.
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: topBarRoot
    width: 1160
    height: 50
    implicitWidth: 1160
    implicitHeight: 50
    Layout.fillWidth: true
    Layout.preferredHeight: 50
    radius: 6
    color: "#0a223a"
    border.color: "#184d7e"
    border.width: 1.2

    property alias t1MinBtn: time1MinBtn
    property alias t5MinBtn: time5MinBtn
    property alias t15MinBtn: time15MinBtn
    property alias t1HourBtn: time1HourBtn
    property alias t8HourBtn: time8HourBtn
    property alias t24HourBtn: time24HourBtn
    property alias liveStreamBtn: liveStreamToggleBtn
    property alias resetZoomBtn: resetZoomButton
    property alias chartModeBtn: chartViewButton
    property alias tableModeBtn: tableViewButton

    property string activeTimePreset: "5min"
    property bool isLiveStreaming: true
    property bool isZoomed: false
    property string activeMode: "chart"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        spacing: 10

        // 1. Process Batch & Recipe Telemetry Indicator Pill
        Rectangle {
            Layout.preferredWidth: 240
            Layout.preferredHeight: 38
            radius: 5
            color: "#06182c"
            border.color: "#0284c7"
            border.width: 1.2

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 8

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: "#22c55e"
                }

                Text {
                    text: "BATCH [B1] • 50L VESSEL LIVE"
                    color: "#38bdf8"
                    font.bold: true
                    font.pixelSize: 11
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }
        }

        // 2. High-Visibility Time Window Preset Selector (1m, 5m, 15m, 1h, 8h, 24h)
        Rectangle {
            Layout.preferredWidth: 330
            Layout.preferredHeight: 38
            radius: 5
            color: "#06182c"
            border.color: "#184d7e"
            border.width: 1.2

            RowLayout {
                anchors.fill: parent
                spacing: 2
                anchors.margins: 2

                Rectangle {
                    id: time1MinBtn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 4
                    color: topBarRoot.activeTimePreset === "1min" ? "#0284c7" : "transparent"
                    border.color: topBarRoot.activeTimePreset === "1min" ? "#38bdf8" : "transparent"
                    border.width: topBarRoot.activeTimePreset === "1min" ? 1.5 : 0
                    Text { anchors.centerIn: parent; text: "1m"; color: topBarRoot.activeTimePreset === "1min" ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 12 }
                }
                Rectangle {
                    id: time5MinBtn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 4
                    color: topBarRoot.activeTimePreset === "5min" ? "#0284c7" : "transparent"
                    border.color: topBarRoot.activeTimePreset === "5min" ? "#38bdf8" : "transparent"
                    border.width: topBarRoot.activeTimePreset === "5min" ? 1.5 : 0
                    Text { anchors.centerIn: parent; text: "5m"; color: topBarRoot.activeTimePreset === "5min" ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 12 }
                }
                Rectangle {
                    id: time15MinBtn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 4
                    color: topBarRoot.activeTimePreset === "15min" ? "#0284c7" : "transparent"
                    border.color: topBarRoot.activeTimePreset === "15min" ? "#38bdf8" : "transparent"
                    border.width: topBarRoot.activeTimePreset === "15min" ? 1.5 : 0
                    Text { anchors.centerIn: parent; text: "15m"; color: topBarRoot.activeTimePreset === "15min" ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 12 }
                }
                Rectangle {
                    id: time1HourBtn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 4
                    color: topBarRoot.activeTimePreset === "1h" ? "#0284c7" : "transparent"
                    border.color: topBarRoot.activeTimePreset === "1h" ? "#38bdf8" : "transparent"
                    border.width: topBarRoot.activeTimePreset === "1h" ? 1.5 : 0
                    Text { anchors.centerIn: parent; text: "1h"; color: topBarRoot.activeTimePreset === "1h" ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 12 }
                }
                Rectangle {
                    id: time8HourBtn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 4
                    color: topBarRoot.activeTimePreset === "8h" ? "#0284c7" : "transparent"
                    border.color: topBarRoot.activeTimePreset === "8h" ? "#38bdf8" : "transparent"
                    border.width: topBarRoot.activeTimePreset === "8h" ? 1.5 : 0
                    Text { anchors.centerIn: parent; text: "8h"; color: topBarRoot.activeTimePreset === "8h" ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 12 }
                }
                Rectangle {
                    id: time24HourBtn
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 4
                    color: topBarRoot.activeTimePreset === "24h" ? "#0284c7" : "transparent"
                    border.color: topBarRoot.activeTimePreset === "24h" ? "#38bdf8" : "transparent"
                    border.width: topBarRoot.activeTimePreset === "24h" ? 1.5 : 0
                    Text { anchors.centerIn: parent; text: "24h"; color: topBarRoot.activeTimePreset === "24h" ? "#ffffff" : "#94a3b8"; font.bold: true; font.pixelSize: 12 }
                }
            }
        }

        // 3. Live Streaming Scroll Toggle Button
        Rectangle {
            id: liveStreamToggleBtn
            Layout.preferredWidth: 140
            Layout.preferredHeight: 38
            radius: 5
            color: topBarRoot.isLiveStreaming ? "#052e16" : "#451a03"
            border.color: topBarRoot.isLiveStreaming ? "#22c55e" : "#f59e0b"
            border.width: 1.5

            Row {
                anchors.centerIn: parent
                spacing: 8
                Rectangle {
                    width: 10
                    height: 10
                    radius: 5
                    color: topBarRoot.isLiveStreaming ? "#22c55e" : "#f59e0b"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: topBarRoot.isLiveStreaming ? "LIVE SCROLL" : "PAUSED (SEEK)"
                    color: topBarRoot.isLiveStreaming ? "#4ade80" : "#fde68a"
                    font.bold: true
                    font.pixelSize: 11
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Item { Layout.fillWidth: true }

        // 4. Reset Zoom Button (Visible when zoomed)
        Rectangle {
            id: resetZoomButton
            Layout.preferredWidth: 110
            Layout.preferredHeight: 38
            radius: 5
            visible: topBarRoot.isZoomed
            color: "#1e3a8a"
            border.color: "#60a5fa"
            border.width: 1.5
            Text { anchors.centerIn: parent; text: "Reset Zoom"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
        }

        // 5. High-Contrast Prominent Graph / Table View Switcher
        Rectangle {
            Layout.preferredWidth: 190
            Layout.preferredHeight: 38
            radius: 5
            color: "#06182c"
            border.color: "#0284c7"
            border.width: 1.5

            RowLayout {
                anchors.fill: parent
                spacing: 2
                anchors.margins: 2

                Rectangle {
                    id: chartViewButton
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 4
                    color: topBarRoot.activeMode === "chart" ? "#0284c7" : "transparent"
                    border.color: topBarRoot.activeMode === "chart" ? "#38bdf8" : "transparent"
                    border.width: topBarRoot.activeMode === "chart" ? 1.5 : 0

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Image {
                            source: "../../../assets/icons/nav/trends_chart.svg"
                            width: 16
                            height: 16
                            sourceSize: Qt.size(16, 16)
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Graph"
                            color: topBarRoot.activeMode === "chart" ? "#ffffff" : "#94a3b8"
                            font.bold: true
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Rectangle {
                    id: tableViewButton
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 4
                    color: topBarRoot.activeMode === "table" ? "#0284c7" : "transparent"
                    border.color: topBarRoot.activeMode === "table" ? "#38bdf8" : "transparent"
                    border.width: topBarRoot.activeMode === "table" ? 1.5 : 0

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Image {
                            source: "../../../assets/icons/nav/docs_report.svg"
                            width: 16
                            height: 16
                            sourceSize: Qt.size(16, 16)
                            fillMode: Image.PreserveAspectFit
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Table"
                            color: topBarRoot.activeMode === "table" ? "#ffffff" : "#94a3b8"
                            font.bold: true
                            font.pixelSize: 12
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
