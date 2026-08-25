pragma ComponentBehavior: Bound
/*
This is a UI file (.ui.qml) for Screen 3: 3-Pane Video-Editor Style Recipe Timeline Designer.
Strictly declarative for Qt Design Studio. References: image_daa6f1.png, image_cf2bc7.jpg
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../../components/widgets"

Rectangle {
    id: timelineDesignerViewRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#08213b"

    property string recipeTitle: "Body Lotion Formulation"
    property string estDurationFormatted: "45 min (2700s)"
    property int totalOperationsCount: 10
    property int totalHoldsCount: 2

    // Playback & Scrubber properties
    property bool isPlaying: false
    property int currentPlayheadSec: 0
    property int totalDurationSec: 2700
    property string playheadTimecode: "00:00:00"
    property string totalTimecode: "00:45:00"
    property string currentPhaseName: "Phase A"
    property string currentStageId: "1.1"

    property alias backToIngredientsBtn: prevBtn
    property alias exportNodeRedBtn: exportBtn
    property alias submitForApprovalBtn: submitBtn
    property alias saveRecipeBtn: saveBtn

    property alias mediaBin: leftMediaBin
    property alias pidSimulator: pidPlayer

    property alias playBtn: playPauseBtn
    property alias stepPrevBtn: prevStepBtn
    property alias stepNextBtn: nextStepBtn
    property alias resetPlayheadBtn: stopBtn
    property alias timelineScrubber: scrubSlider

    property alias agitatorTrack: trackAgitator
    property alias homoTrack: trackHomo
    property alias vacuumTrack: trackVacuum
    property alias thermalTrack: trackThermal
    property alias valveTrack: trackValve
    property alias manualTrack: trackManual

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 6
        spacing: 6

        // 1. Top Header Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 46
            color: "#0b2e52"
            border.color: "#1d5b94"
            border.width: 1
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                spacing: 10

                ScadaIcon {
                    Layout.preferredWidth: 20
                    Layout.preferredHeight: 20
                    iconName: "act_schedule"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Text {
                        text: "RECIPE DESIGNER & P&ID SIMULATION STUDIO: " + timelineDesignerViewRoot.recipeTitle.toUpperCase()
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 12
                    }
                    Text {
                        text: "3-Pane Non-Linear SCADA Sequence Authoring & Dynamic Machine Verification (iPad NLE Paradigm)"
                        color: "#94a3b8"
                        font.pixelSize: 9
                    }
                }

                // Batch Timecode & Stats Display
                Rectangle {
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: 150
                    radius: 4
                    color: "#081d33"
                    border.color: "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "⏱ Duration:"; color: "#94a3b8"; font.pixelSize: 9 }
                        Text { text: timelineDesignerViewRoot.estDurationFormatted; color: "#38bdf8"; font.bold: true; font.pixelSize: 10 }
                    }
                }

                Rectangle {
                    Layout.preferredHeight: 28
                    Layout.preferredWidth: 120
                    radius: 4
                    color: "#081d33"
                    border.color: "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text { text: "✋ Holds:"; color: "#94a3b8"; font.pixelSize: 9 }
                        Text { text: timelineDesignerViewRoot.totalHoldsCount + " Gates"; color: "#facc15"; font.bold: true; font.pixelSize: 10 }
                    }
                }
            }
        }

        // 2. 3-PANE SPLITVIEW MAIN WORKSPACE
        SplitView {
            id: verticalSplitView
            Layout.fillWidth: true
            Layout.fillHeight: true
            orientation: Qt.Vertical

            // -------------------------------------------------------------
            // TOP SECTION: HORIZONTAL SPLIT (RESOURCE BIN + P&ID SIMULATOR)
            // -------------------------------------------------------------
            SplitView {
                id: topHorizontalSplitView
                SplitView.preferredHeight: 280
                SplitView.minimumHeight: 180
                SplitView.fillWidth: true
                orientation: Qt.Horizontal

                // Pane 1 (Top-Left): Draggable Resource Media Bin
                RecipeMediaBin {
                    id: leftMediaBin
                    SplitView.preferredWidth: 280
                    SplitView.minimumWidth: 220
                    SplitView.maximumWidth: 380
                    SplitView.fillHeight: true
                }

                // Pane 2 (Top-Right): Live Animated P&ID Simulation Player
                RecipePIDSimulator {
                    id: pidPlayer
                    SplitView.fillWidth: true
                    SplitView.fillHeight: true
                }
            }

            // -------------------------------------------------------------
            // BOTTOM SECTION: MULTI-TRACK PHASE TIMELINE & TRANSPORT
            // -------------------------------------------------------------
            Rectangle {
                id: bottomTimelinePane
                SplitView.fillWidth: true
                SplitView.fillHeight: true
                SplitView.minimumHeight: 220
                color: "#092442"
                border.color: "#1d5b94"
                border.width: 1
                radius: 6
                clip: true

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 4

                    // Transport Control Bar (Video Player Scrubbing)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 38
                        radius: 4
                        color: "#0c2f54"
                        border.color: "#1d5b94"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            spacing: 8

                            // Step Previous Phase
                            Rectangle {
                                id: prevStepBtn
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 26
                                radius: 3
                                color: "#081d33"
                                border.color: "#1d5b94"
                                border.width: 1
                                Text { anchors.centerIn: parent; text: "⏮"; color: "#ffffff"; font.pixelSize: 11 }
                            }

                            // Play / Pause Toggle
                            Rectangle {
                                id: playPauseBtn
                                Layout.preferredWidth: 80
                                Layout.preferredHeight: 26
                                radius: 3
                                color: timelineDesignerViewRoot.isPlaying ? "#0284c7" : "#059669"
                                border.color: timelineDesignerViewRoot.isPlaying ? "#38bdf8" : "#34d399"
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Text { text: timelineDesignerViewRoot.isPlaying ? "⏸ PAUSE" : "▶ PLAY"; color: "#ffffff"; font.bold: true; font.pixelSize: 10 }
                                }
                            }

                            // Step Next Phase
                            Rectangle {
                                id: nextStepBtn
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 26
                                radius: 3
                                color: "#081d33"
                                border.color: "#1d5b94"
                                border.width: 1
                                Text { anchors.centerIn: parent; text: "⏭"; color: "#ffffff"; font.pixelSize: 11 }
                            }

                            // Reset Playhead
                            Rectangle {
                                id: stopBtn
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 26
                                radius: 3
                                color: "#081d33"
                                border.color: "#1d5b94"
                                border.width: 1
                                Text { anchors.centerIn: parent; text: "⏹"; color: "#ffffff"; font.pixelSize: 11 }
                            }

                            // Timecode Display
                            Rectangle {
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 26
                                radius: 3
                                color: "#051324"
                                border.color: "#38bdf8"
                                border.width: 1

                                RowLayout {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Text {
                                        text: timelineDesignerViewRoot.playheadTimecode + " / " + timelineDesignerViewRoot.totalTimecode
                                        color: "#38bdf8"
                                        font.bold: true
                                        font.pixelSize: 10
                                    }
                                }
                            }

                            // Interactive Timeline Scrubber Slider
                            Slider {
                                id: scrubSlider
                                Layout.fillWidth: true
                                from: 0
                                to: timelineDesignerViewRoot.totalDurationSec
                                value: timelineDesignerViewRoot.currentPlayheadSec
                            }

                            // Active Phase Pill
                            Rectangle {
                                Layout.preferredWidth: 100
                                Layout.preferredHeight: 26
                                radius: 3
                                color: "#1e1b4b"
                                border.color: "#818cf8"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: timelineDesignerViewRoot.currentPhaseName
                                    color: "#c7d2fe"
                                    font.bold: true
                                    font.pixelSize: 10
                                }
                            }
                        }
                    }

                    // Phase Timecode Ruler Header (Columns: Phase A, B, C, D, E)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 28
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
                                    text: "TRACK / ASSET"
                                    color: "#38bdf8"
                                    font.bold: true
                                    font.pixelSize: 9
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

                    // Multi-Track Timeline Rows (Scrollable)
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

                            // Track 5: Valves & Dosing Pumps (1K1001)
                            RecipeTimelineTrack {
                                id: trackValve
                                trackId: "track_valve"
                                trackTitle: "1K1001 Material Dosing"
                                trackType: "fillValve"
                                trackIcon: "valve_solenoid"
                            }

                            // Track 6: Manual Sequence Interlocks & Physical Gates
                            RecipeTimelineTrack {
                                id: trackManual
                                trackId: "track_manual"
                                trackTitle: "✋ Manual Interlocks"
                                trackType: "manualActivity"
                                trackIcon: "act_manual"
                            }
                        }
                    }
                }
            }
        }

        // 3. Bottom Action Bar: Navigation & Node-RED Export & 21 CFR Part 11 Sign-off
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
                spacing: 12

                // Back to Stage 2
                Rectangle {
                    id: prevBtn
                    Layout.preferredWidth: 190
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#1e293b"
                    border.color: "#475569"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "← Formulation Builder"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                    }
                }

                Item { Layout.fillWidth: true }

                // Export Node-RED JSON
                Rectangle {
                    id: exportBtn
                    Layout.preferredWidth: 170
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#075985"
                    border.color: "#38bdf8"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "⚡ Node-RED PLC Export"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                    }
                }

                // Save Draft
                Rectangle {
                    id: saveBtn
                    Layout.preferredWidth: 130
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#1e293b"
                    border.color: "#475569"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "Save Draft"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                    }
                }

                // Submit for 21 CFR Part 11 Approval
                Rectangle {
                    id: submitBtn
                    Layout.preferredWidth: 200
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#059669"
                    border.color: "#34d399"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "Submit for Approval ✓"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                    }
                }
            }
        }
    }
}
