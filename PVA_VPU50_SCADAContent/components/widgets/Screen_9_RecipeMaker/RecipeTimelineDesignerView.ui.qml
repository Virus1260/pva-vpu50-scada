/*
This is a UI file (.ui.qml) for Screen 3: Video-Editor Style Recipe Timeline Designer.
Strictly declarative for Qt Design Studio. References: image_cf2bc7.jpg, image_cf2f65.png
*/

import QtQuick
import QtQuick.Layouts
import "../../../components/widgets"

Rectangle {
    id: timelineDesignerViewRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#08213b"

    property string recipeTitle: "Body Lotion Formulation"
    property string estDurationFormatted: "45 min (2700s)"
    property int totalOperationsCount: 8
    property int totalHoldsCount: 2

    property alias backToIngredientsBtn: prevBtn
    property alias exportNodeRedBtn: exportBtn
    property alias submitForApprovalBtn: submitBtn
    property alias saveRecipeBtn: saveBtn
    property alias mediaBin: leftMediaBin

    property alias agitatorTrack: trackAgitator
    property alias homoTrack: trackHomo
    property alias vacuumTrack: trackVacuum
    property alias thermalTrack: trackThermal
    property alias valveTrack: trackValve

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // 1. Top Transport & Phase Header Bar (Video Editor Timeline Paradigm)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            color: "#0b2e52"
            border.color: "#1d5b94"
            border.width: 1
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                ScadaIcon {
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    iconName: "act_schedule"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "QML MULTI-TRACK TIMELINE DESIGNER: " + timelineDesignerViewRoot.recipeTitle.toUpperCase()
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 13
                    }
                    Text {
                        text: "Non-Linear Drag-and-Drop Batch Sequence Authoring (Node-RED PLC Compatible)"
                        color: "#94a3b8"
                        font.pixelSize: 10
                    }
                }

                // Batch Timecode & Stats Display
                Rectangle {
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 160
                    radius: 4
                    color: "#081d33"
                    border.color: "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "⏱ Est Time:"; color: "#94a3b8"; font.pixelSize: 10 }
                        Text { text: timelineDesignerViewRoot.estDurationFormatted; color: "#38bdf8"; font.bold: true; font.pixelSize: 11 }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: 32
                    Layout.preferredWidth: 130
                    radius: 4
                    color: "#081d33"
                    border.color: "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "⚠ Holds:"; color: "#94a3b8"; font.pixelSize: 10 }
                        Text { text: timelineDesignerViewRoot.totalHoldsCount + " Sign-offs"; color: "#facc15"; font.bold: true; font.pixelSize: 11 }
                    }
                }
            }
        }

        // 2. Main Work Area: Left Media Bin + Right Timeline Tracks
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            // Left Accordion Resource Bin
            RecipeMediaBin {
                id: leftMediaBin
                Layout.preferredWidth: 250
                Layout.fillHeight: true
            }

            // Right Timeline Canvas
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#092442"
                border.color: "#1d5b94"
                border.width: 1
                radius: 6
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 4

                    // Phase Timecode Ruler Header (Columns: Phase A, B, C, D, E)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        color: "#0d365e"
                        border.color: "#1d5b94"
                        border.width: 1
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            spacing: 0

                            Rectangle {
                                Layout.preferredWidth: 150
                                Layout.fillHeight: true
                                color: "#081d33"
                                Text {
                                    anchors.centerIn: parent
                                    text: "TRACK / RESOURCE"
                                    color: "#38bdf8"
                                    font.bold: true
                                    font.pixelSize: 10
                                }
                            }

                            Repeater {
                                model: [
                                    { title: "PHASE A: Aqueous Charge", time: "00:00 - 08:00" },
                                    { title: "PHASE B: Oil Emulsification", time: "08:00 - 20:00" },
                                    { title: "PHASE C: Surfactant Induction", time: "20:00 - 30:00" },
                                    { title: "PHASE D: Neutralization Trim", time: "30:00 - 38:00" },
                                    { title: "PHASE E: Actives & Cooling", time: "38:00 - 45:00" }
                                ]
                                delegate: Rectangle {
                                    id: phHeader
                                    required property var modelData
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    color: "#0c2f54"
                                    border.color: "#1d5b94"
                                    border.width: 1

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 1
                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: phHeader.modelData.title
                                            color: "#ffffff"
                                            font.bold: true
                                            font.pixelSize: 9
                                        }
                                        Text {
                                            Layout.alignment: Qt.AlignHCenter
                                            text: phHeader.modelData.time
                                            color: "#94a3b8"
                                            font.pixelSize: 8
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Multi-Track Timeline Rows
                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        contentWidth: width
                        contentHeight: tracksCol.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds

                        ColumnLayout {
                            id: tracksCol
                            width: parent.width
                            spacing: 4

                            // Track 1: Agitator Stirrer (1M1501)
                            RecipeTimelineTrack {
                                id: trackAgitator
                                trackId: "track_agitator"
                                trackTitle: "1M1501 Agitator"
                                trackType: "agitator"
                                trackIcon: "stirrer_anchor"
                            }

                            // Track 2: Homogenizer High-Shear Rotor (1X1001)
                            RecipeTimelineTrack {
                                id: trackHomo
                                trackId: "track_homo"
                                trackTitle: "1X1001 Homogenizer"
                                trackType: "homogenizer"
                                trackIcon: "homogenizer_rotor"
                            }

                            // Track 3: Vacuum Pump (1M5001)
                            RecipeTimelineTrack {
                                id: trackVacuum
                                trackId: "track_vacuum"
                                trackTitle: "1M5001 Vacuum"
                                trackType: "vacuum"
                                trackIcon: "vacuum_gauge"
                            }

                            // Track 4: Heating & Cooling Jacket (1E6001)
                            RecipeTimelineTrack {
                                id: trackThermal
                                trackId: "track_thermal"
                                trackTitle: "1E6001 Thermal Jacket"
                                trackType: "heater"
                                trackIcon: "heating_thermometer"
                            }

                            // Track 5: Charging & Discharge Valves (1K1001 / 1M2001)
                            RecipeTimelineTrack {
                                id: trackValve
                                trackId: "track_valve"
                                trackTitle: "1K1001 Charge Valve"
                                trackType: "fillValve"
                                trackIcon: "suction_funnel"
                            }
                        }
                    }
                }
            }
        }

        // 3. Bottom Action Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            color: "#0b2e52"
            border.color: "#1d5b94"
            border.width: 1
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                // Back to Screen 2
                Rectangle {
                    id: prevBtn
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#1e293b"
                    border.color: "#475569"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "←"; color: "#ffffff"; font.bold: true; font.pixelSize: 14 }
                        Text { text: "Ingredient Builder"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                    }
                }

                Item { Layout.fillWidth: true }

                // Export Node-RED JSON Button
                Rectangle {
                    id: exportBtn
                    Layout.preferredWidth: 170
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#0369a1"
                    border.color: "#38bdf8"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "⚡"; color: "#facc15"; font.pixelSize: 13 }
                        Text { text: "Export Node-RED JSON"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                    }
                }

                // Submit for Review / Approval Button (21 CFR Part 11)
                Rectangle {
                    id: submitBtn
                    Layout.preferredWidth: 170
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#854d0e"
                    border.color: "#facc15"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "✍"; color: "#ffffff"; font.pixelSize: 13 }
                        Text { text: "Submit for QA Approval"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                    }
                }

                // Save Master Recipe
                Rectangle {
                    id: saveBtn
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#059669"
                    border.color: "#34d399"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "💾"; color: "#ffffff"; font.pixelSize: 13 }
                        Text { text: "Save Master Recipe"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                    }
                }
            }
        }
    }
}
