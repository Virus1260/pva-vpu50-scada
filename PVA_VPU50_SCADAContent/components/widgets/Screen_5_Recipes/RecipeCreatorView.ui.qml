/*
This is a UI file (.ui.qml) for the Recipe Formulation Studio & 21 CFR Part 11 Recipe Creator.
Strictly declarative for Qt Design Studio.
Compliant with GAMP 5 and FDA 21 CFR Part 11.
Supports Nested Step Schema: Parent Steps containing Multiple Concurrent/Sequential Sub-steps.
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: creatorRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#06182c"
    border.color: "#184d7e"
    border.width: 1.2
    radius: 6
    clip: true

    property string selectedRecipeName: "Industrial Shampoo Formulation"
    property string selectedProduct: "Botanical Conditioning Shampoo (100 kg)"
    property string recipeVersion: "v3.0.0-GAMP5"
    property string validationStatus: "APPROVED & VALIDATED"
    property string approvedBy: "Dr. E. Vance (Process Eng)"
    property int totalStepsCount: 10
    property int totalOpsCount: 22

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // =====================================================================
        // 1. RECIPE METADATA & 21 CFR PART 11 VALIDATION HEADER
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 76
            radius: 6
            color: "#0d2b4a"
            border.color: "#0284c7"
            border.width: 1.4

            RowLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 16

                Rectangle {
                    width: 48
                    height: 48
                    radius: 6
                    color: "#0c345a"
                    border.color: "#38bdf8"
                    Image {
                        source: "../../../assets/icons/nav/recipes_checklist.svg"
                        width: 26
                        height: 26
                        anchors.centerIn: parent
                        fillMode: Image.PreserveAspectFit
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text { text: "MASTER FORMULATION MATRIX (ISA-88)"; color: "#38bdf8"; font.bold: true; font.pixelSize: 10 }
                    Text { text: creatorRoot.selectedRecipeName + " (" + creatorRoot.selectedProduct + ")"; color: "#ffffff"; font.bold: true; font.pixelSize: 14 }
                    Text { text: "Compliance: FDA 21 CFR Part 11 & ISPE GAMP 5 | " + creatorRoot.totalStepsCount + " Steps | " + creatorRoot.totalOpsCount + " Sub-operations"; color: "#94a3b8"; font.pixelSize: 11 }
                }

                // Electronic Approval Stamp
                Rectangle {
                    Layout.preferredWidth: 220
                    Layout.preferredHeight: 48
                    radius: 4
                    color: "#052e16"
                    border.color: "#22c55e"
                    border.width: 1.2

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2
                        RowLayout {
                            spacing: 6
                            Rectangle { width: 8; height: 8; radius: 4; color: "#22c55e" }
                            Text { text: creatorRoot.validationStatus; color: "#86efac"; font.bold: true; font.pixelSize: 10 }
                        }
                        Text { text: "Signed: " + creatorRoot.approvedBy; color: "#cbd5e1"; font.pixelSize: 9 }
                    }
                }
            }
        }

        // =====================================================================
        // 2. TWO-COLUMN SPLIT: NESTED STEP SCHEMA (LEFT) & BOM INGREDIENTS (RIGHT)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // LEFT COLUMN: NESTED PARENT STEPS & SUB-OPERATIONS MATRIX
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 5
                color: "#071c33"
                border.color: "#184d7e"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    RowLayout {
                        Layout.fillWidth: true
                        Text { text: "PARENT PROCESS PHASES & CONCURRENT SUB-OPERATIONS"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11 }
                        Item { Layout.fillWidth: true }
                        Text { text: "ISA-88 Procedure Hierarchy"; color: "#38bdf8"; font.pixelSize: 10 }
                    }

                    // Parent Step 1: Initial Water Charge & Pre-Heat
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68
                        radius: 4
                        color: "#0a243f"
                        border.color: "#1d4ed8"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Rectangle {
                                    width: 20; height: 20; radius: 10; color: "#1e40af"
                                    Text { anchors.centerIn: parent; text: "1"; color: "#ffffff"; font.bold: true; font.pixelSize: 10 }
                                }
                                Text { text: "Phase A: Water Prep & Initial Heating (45.0°C)"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                                Item { Layout.fillWidth: true }
                                Text { text: "Dur: 4 min | Auto-Advance"; color: "#38bdf8"; font.pixelSize: 10 }
                            }

                            // Sub-operations pills row
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Rectangle {
                                    Layout.preferredHeight: 22; Layout.preferredWidth: 150; radius: 3; color: "#0c345a"; border.color: "#0284c7"
                                    RowLayout { anchors.centerIn: parent; spacing: 4; Text { text: "FillValve: ON (SP 55%)"; color: "#93c5fd"; font.pixelSize: 9 } }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 22; Layout.preferredWidth: 150; radius: 3; color: "#0c345a"; border.color: "#22c55e"
                                    RowLayout { anchors.centerIn: parent; spacing: 4; Text { text: "Agitator: ON (25 RPM)"; color: "#86efac"; font.pixelSize: 9 } }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 22; Layout.preferredWidth: 160; radius: 3; color: "#0c345a"; border.color: "#f97316"
                                    RowLayout { anchors.centerIn: parent; spacing: 4; Text { text: "Heater: ON (SP 45.0°C)"; color: "#fdba74"; font.pixelSize: 9 } }
                                }
                            }
                        }
                    }

                    // Parent Step 2: Surfactant Addition & Vacuum Deaeration
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68
                        radius: 4
                        color: "#0a243f"
                        border.color: "#1d4ed8"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Rectangle {
                                    width: 20; height: 20; radius: 10; color: "#1e40af"
                                    Text { anchors.centerIn: parent; text: "2"; color: "#ffffff"; font.bold: true; font.pixelSize: 10 }
                                }
                                Text { text: "Phase B: SLES 28% & CAPB Induction"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                                Item { Layout.fillWidth: true }
                                Text { text: "21 CFR Hold Point Sign-off"; color: "#f59e0b"; font.bold: true; font.pixelSize: 10 }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Rectangle {
                                    Layout.preferredHeight: 22; Layout.preferredWidth: 150; radius: 3; color: "#0c345a"; border.color: "#22c55e"
                                    RowLayout { anchors.centerIn: parent; spacing: 4; Text { text: "Agitator: ON (20 RPM)"; color: "#86efac"; font.pixelSize: 9 } }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 22; Layout.preferredWidth: 160; radius: 3; color: "#0c345a"; border.color: "#8b5cf6"
                                    RowLayout { anchors.centerIn: parent; spacing: 4; Text { text: "Vacuum: ON (-300 mbar)"; color: "#c4b5fd"; font.pixelSize: 9 } }
                                }
                            }
                        }
                    }

                    // Parent Step 3: Pearlizer Melt & High-Shear Emulsification
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68
                        radius: 4
                        color: "#0a243f"
                        border.color: "#1d4ed8"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Rectangle {
                                    width: 20; height: 20; radius: 10; color: "#1e40af"
                                    Text { anchors.centerIn: parent; text: "3"; color: "#ffffff"; font.bold: true; font.pixelSize: 10 }
                                }
                                Text { text: "Phase C: High-Shear Emulsification (70.0°C)"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                                Item { Layout.fillWidth: true }
                                Text { text: "Dur: 8 min | Auto-Advance"; color: "#38bdf8"; font.pixelSize: 10 }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Rectangle {
                                    Layout.preferredHeight: 22; Layout.preferredWidth: 130; radius: 3; color: "#0c345a"; border.color: "#22c55e"
                                    RowLayout { anchors.centerIn: parent; spacing: 4; Text { text: "Agitator: 60 RPM"; color: "#86efac"; font.pixelSize: 9 } }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 22; Layout.preferredWidth: 170; radius: 3; color: "#0c345a"; border.color: "#a855f7"
                                    RowLayout { anchors.centerIn: parent; spacing: 4; Text { text: "Homo: RAMP (600->3600 RPM)"; color: "#d8b4fe"; font.pixelSize: 9 } }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 22; Layout.preferredWidth: 140; radius: 3; color: "#0c345a"; border.color: "#8b5cf6"
                                    RowLayout { anchors.centerIn: parent; spacing: 4; Text { text: "Vacuum: -450 mbar"; color: "#c4b5fd"; font.pixelSize: 9 } }
                                }
                            }
                        }
                    }

                    // Parent Step 4: Cooling & Active Scent Dosing
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 68
                        radius: 4
                        color: "#0a243f"
                        border.color: "#1d4ed8"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Rectangle {
                                    width: 20; height: 20; radius: 10; color: "#1e40af"
                                    Text { anchors.centerIn: parent; text: "4"; color: "#ffffff"; font.bold: true; font.pixelSize: 10 }
                                }
                                Text { text: "Phase D/E: Jacket Cooling (45.0°C) & Preservative Addition"; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                                Item { Layout.fillWidth: true }
                                Text { text: "21 CFR Hold Point Sign-off"; color: "#f59e0b"; font.bold: true; font.pixelSize: 10 }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                Rectangle {
                                    Layout.preferredHeight: 22; Layout.preferredWidth: 140; radius: 3; color: "#0c345a"; border.color: "#06b6d4"
                                    RowLayout { anchors.centerIn: parent; spacing: 4; Text { text: "Cooler: ON (SP 45.0°C)"; color: "#67e8f9"; font.pixelSize: 9 } }
                                }
                                Rectangle {
                                    Layout.preferredHeight: 22; Layout.preferredWidth: 140; radius: 3; color: "#0c345a"; border.color: "#22c55e"
                                    RowLayout { anchors.centerIn: parent; spacing: 4; Text { text: "Agitator: ON (30 RPM)"; color: "#86efac"; font.pixelSize: 9 } }
                                }
                            }
                        }
                    }
                }
            }

            // RIGHT COLUMN: BILL OF MATERIALS (BOM) RAW MATERIALS
            Rectangle {
                Layout.preferredWidth: 380
                Layout.fillHeight: true
                radius: 5
                color: "#071c33"
                border.color: "#184d7e"
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 6

                    Text { text: "BILL OF MATERIALS (15 INGREDIENTS)"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11 }

                    Repeater {
                        model: [
                            { code: "PH-A", name: "Deionized Water (USP Bulk)", qty: "45.0 kg", phase: "Phase A" },
                            { code: "PH-A", name: "EDTA Disodium / Citric Acid", qty: "0.4 kg", phase: "Phase A" },
                            { code: "PH-B", name: "Sodium Laureth Sulfate (SLES 28%)", qty: "18.0 kg", phase: "Phase B" },
                            { code: "PH-B", name: "Cocamidopropyl Betaine (CAPB)", qty: "4.0 kg", phase: "Phase B" },
                            { code: "PH-C", name: "Glycol Distearate (Pearlizer)", qty: "3.0 kg", phase: "Phase C" },
                            { code: "PH-D", name: "Polyquaternium-7 / Panthenol", qty: "2.0 kg", phase: "Phase D" },
                            { code: "PH-E", name: "Fragrance Oil / Preservative MIT", qty: "0.95 kg", phase: "Phase E" },
                            { code: "PH-F", name: "Sodium Chloride (Viscosity Trim)", qty: "2.5 kg", phase: "Phase F" }
                        ]

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 38
                            radius: 4
                            color: "#0a243f"
                            border.color: "#184d7e"

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8

                                Rectangle {
                                    width: 44
                                    height: 18
                                    radius: 3
                                    color: modelData.phase === "Phase A" ? "#1e3a8a" : modelData.phase === "Phase B" ? "#c2410c" : modelData.phase === "Phase C" ? "#7e22ce" : "#0f766e"
                                    Text { anchors.centerIn: parent; text: modelData.code; color: "#ffffff"; font.bold: true; font.pixelSize: 8 }
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    Text { text: modelData.name; color: "#ffffff"; font.bold: true; font.pixelSize: 9; elide: Text.ElideRight }
                                    Text { text: modelData.phase; color: "#64748b"; font.pixelSize: 8 }
                                }

                                Text { text: modelData.qty; color: "#22c55e"; font.bold: true; font.pixelSize: 10; horizontalAlignment: Text.AlignRight }
                            }
                        }
                    }
                }
            }
        }
    }
}
