/*
This is a UI file (.ui.qml) for Trends Interactive Graph Widget.
Strictly declarative for Qt Design Studio.
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: graphWidgetRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#06182c"
    border.color: "#184d7e"
    border.width: 1.2
    radius: 6
    clip: true

    property alias trendCanvasItem: graphCanvas
    property alias dragBoxOverlay: dragSelectionRect
    property alias inspectCardItem: inspectionCard
    property alias inspectRepeaterItem: inspectRepeater
    property alias panStartBtn: timelineStartBtn
    property alias panLiveBtn: timelineLiveBtn
    property alias timeSliderItem: historyTimeSlider

    property string yAxisTitle: "Temperature (°C)"
    property string xAxisTitle: "Time (UTC)"
    property string inspectionTime: "08:34:11 UTC"
    property string startTimeLabel: "19:00:00 UTC"
    property string endTimeLabel: "19:15:00 UTC"
    property bool isLiveStreaming: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 6

        // 1. Graph Title Bar with Dynamic Units
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            spacing: 8

            Text {
                text: "Y-AXIS: " + graphWidgetRoot.yAxisTitle
                color: "#38bdf8"
                font.bold: true
                font.pixelSize: 12
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "X-AXIS: " + graphWidgetRoot.xAxisTitle
                color: "#94a3b8"
                font.bold: true
                font.pixelSize: 11
            }
            Text {
                text: "| Free Drag Box to Zoom | Pan Bottom Bar when Paused"
                color: "#64748b"
                font.pixelSize: 10
            }
        }

        // 2. Canvas Graph Area with Visual Dragging Box Overlay
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Canvas {
                id: graphCanvas
                anchors.fill: parent
            }

            // Dynamic Visual Drag-to-Zoom Free-Size Selection Box
            Rectangle {
                id: dragSelectionRect
                visible: false
                color: "#380284c7"
                border.color: "#38bdf8"
                border.width: 1.5
                z: 5

                Rectangle {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.topMargin: 4
                    height: 20
                    width: 96
                    radius: 3
                    color: "#0284c7"
                    Text {
                        anchors.centerIn: parent
                        text: "Zoom Window"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 10
                    }
                }
            }

            // Dynamic Floating Inspection Tooltip with Live Channel Values
            Rectangle {
                id: inspectionCard
                visible: false
                width: 260
                height: 160
                radius: 6
                color: "#081d33"
                border.color: "#38bdf8"
                border.width: 1.5
                opacity: 0.96
                z: 10

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 5

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: graphWidgetRoot.inspectionTime; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                        Item { Layout.fillWidth: true }
                        Text { text: "LIVE TELEMETRY"; color: "#38bdf8"; font.bold: true; font.pixelSize: 10 }
                    }

                    Rectangle { Layout.fillWidth: true; height: 1; color: "#1e3a8a" }

                    // Dynamic List of Active Sensor Values at Hovered Timestamp
                    ListView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 3
                        interactive: false

                        model: ListModel { id: inspectRepeater }

                        delegate: RowLayout {
                            width: parent ? parent.width : 0
                            spacing: 8

                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: model.color ? model.color : "#38bdf8"
                            }

                            Text {
                                text: model.tag
                                color: "#e2e8f0"
                                font.bold: true
                                font.pixelSize: 11
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: model.val
                                color: model.color ? model.color : "#ffffff"
                                font.bold: true
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }
        }

        // 3. Bottom Sleek Interactive Timeline History Panning & Range Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            radius: 6
            color: "#0a223a"
            border.color: "#184d7e"
            border.width: 1.0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                anchors.topMargin: 4
                anchors.bottomMargin: 4
                spacing: 12

                // Jump to Oldest Button
                Rectangle {
                    id: timelineStartBtn
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 34
                    radius: 4
                    color: "#1e3a8a"
                    border.color: "#3b82f6"
                    border.width: 1.0

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "<<"; color: "#93c5fd"; font.bold: true; font.pixelSize: 10; anchors.verticalCenter: parent.verticalCenter }
                        Text { text: "Oldest"; color: "#ffffff"; font.bold: true; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                    }
                }

                // Range Start Time Badge (Time Only)
                Rectangle {
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: 85
                    radius: 4
                    color: "#06182c"
                    border.color: "#1e3a8a"
                    border.width: 1.0

                    Text {
                        anchors.centerIn: parent
                        text: graphWidgetRoot.startTimeLabel
                        color: "#94a3b8"
                        font.bold: true
                        font.pixelSize: 11
                    }
                }

                // Interactive Timeline Slider with High-Visibility Touch Bar
                Slider {
                    id: historyTimeSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    value: 100
                }

                // Range Live Time Badge (Time Only)
                Rectangle {
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: 85
                    radius: 4
                    color: "#06182c"
                    border.color: graphWidgetRoot.isLiveStreaming ? "#15803d" : "#1e3a8a"
                    border.width: 1.0

                    Text {
                        anchors.centerIn: parent
                        text: graphWidgetRoot.endTimeLabel
                        color: graphWidgetRoot.isLiveStreaming ? "#4ade80" : "#94a3b8"
                        font.bold: true
                        font.pixelSize: 11
                    }
                }

                // Jump to Live Button
                Rectangle {
                    id: timelineLiveBtn
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 34
                    radius: 4
                    color: graphWidgetRoot.isLiveStreaming ? "#15803d" : "#0284c7"
                    border.color: graphWidgetRoot.isLiveStreaming ? "#22c55e" : "#38bdf8"
                    border.width: 1.2

                    Row {
                        anchors.centerIn: parent
                        spacing: 6
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: graphWidgetRoot.isLiveStreaming ? "#4ade80" : "#ffffff"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: graphWidgetRoot.isLiveStreaming ? "LIVE" : "Go Live"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 11
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
