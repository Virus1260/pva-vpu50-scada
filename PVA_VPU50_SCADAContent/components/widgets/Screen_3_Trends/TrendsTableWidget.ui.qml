/*
This is a UI file (.ui.qml) for Trends Multi-Column Tabular Historian Grid.
Strictly declarative for Qt Design Studio. Uses SVG vector icon for web/WASM compatibility.
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: tableWidgetRoot
    width: 800
    height: 560
    implicitWidth: 800
    implicitHeight: 560
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#06182c"
    border.color: "#184d7e"
    border.width: 1.2
    radius: 5
    clip: true

    property alias tableHeaderModelItem: headerSensorsListModel
    property alias telemetryList: tableListView
    property string activeTimePreset: "5min"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 4

        // Table Top Summary Bar with SVG Icon
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 26
            spacing: 8

            Image {
                source: "../../../assets/icons/nav/docs_report.svg"
                width: 14
                height: 14
                sourceSize: Qt.size(14, 14)
                Layout.preferredWidth: 14
                Layout.preferredHeight: 14
                fillMode: Image.PreserveAspectFit
            }
            Text { text: "PROCESS TELEMETRY HISTORIAN LOG"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
            Item { Layout.fillWidth: true }
            Text { text: "TIME SCALE: " + tableWidgetRoot.activeTimePreset.toUpperCase(); color: "#f59e0b"; font.bold: true; font.pixelSize: 11 }
        }

        // Horizontally & Vertically Scrollable Multi-Column Grid
        ScrollView {
            id: tableScrollViewContainer
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ColumnLayout {
                spacing: 2
                width: Math.max(tableScrollViewContainer.width, 140 + headerSensorsListModel.count * 150 + 80)

                // Multi-Column Dynamic Header Row
                Rectangle {
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: 40
                    color: "#0d2b4a"
                    radius: 3

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 24
                        spacing: 10

                        Text {
                            text: "TIMESTAMP (UTC)"
                            color: "#94a3b8"
                            font.bold: true
                            font.pixelSize: 11
                            Layout.preferredWidth: 120
                        }

                        Repeater {
                            model: ListModel { id: headerSensorsListModel }
                            delegate: Rectangle {
                                Layout.preferredWidth: 140
                                Layout.fillHeight: true
                                color: "transparent"

                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    spacing: 1

                                    Text {
                                        text: model.tag
                                        color: model.color ? model.color : "#38bdf8"
                                        font.bold: true
                                        font.pixelSize: 11
                                        horizontalAlignment: Text.AlignRight
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                    Text {
                                        text: model.desc + " (" + model.unit + ")"
                                        color: "#94a3b8"
                                        font.pixelSize: 9
                                        horizontalAlignment: Text.AlignRight
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                        }

                        // Right End Safe Buffer Padding
                        Item { Layout.preferredWidth: 50 }
                    }
                }

                // Data Rows ListView
                ListView {
                    id: tableListView
                    Layout.preferredWidth: parent.width
                    Layout.preferredHeight: 450
                    clip: true
                    spacing: 2
                    interactive: false

                    delegate: Rectangle {
                        width: parent ? parent.width : 0
                        height: 32
                        radius: 2
                        color: index % 2 === 0 ? "#071c33" : "#092440"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 24
                            spacing: 10

                            Text {
                                text: modelData.time ? modelData.time : ""
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: 11
                                Layout.preferredWidth: 120
                            }

                            Repeater {
                                model: modelData.sensorCols ? modelData.sensorCols : []
                                delegate: Text {
                                    text: modelData.val
                                    color: modelData.color ? modelData.color : "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 11
                                    horizontalAlignment: Text.AlignRight
                                    Layout.preferredWidth: 140
                                }
                            }

                            // Right End Safe Buffer Padding
                            Item { Layout.preferredWidth: 50 }
                        }
                    }
                }
            }
        }
    }
}
