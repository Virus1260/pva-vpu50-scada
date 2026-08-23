/*
This is a UI file (.ui.qml) for the Master Recipe Maker (Authoring & Configuration).
Strictly declarative for Qt Design Studio.
Accessible exclusively to Incharge / Supervisor (Level 2) and Administrator (Level 3).
Compliant with GAMP-5 and 21 CFR Part 11.
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../components/widgets"
import "../components/widgets/Screen_5_Recipes"

Rectangle {
    id: recipeMakerRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#08213b"

    property string selectedRecipeName: "Industrial Shampoo Formulation"
    property string selectedRecipeId: "REC-VPU50-001"
    property string recipeStatus: "APPROVED" // "DRAFT", "APPROVED", "DEPRECATED"
    property int recipeVersion: 1
    property string recipeAuthor: "Dr. E. Vance (Process Eng)"
    property string approvalDate: "2026-02-20 10:00:00"

    // Property Aliases for Interactive Binding
    property alias recipeSelectorBox: recipeCombo
    property alias newRecipeBtn: btnNew
    property alias saveDraftBtn: btnSave
    property alias approveBtn: btnApprove
    property alias deleteBtn: btnDelete
    property alias addStepBtn: btnAddStep

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 8

        // =====================================================================
        // 1. TOP AUTHORING TOOLBAR & RECIPE MASTER CONTROL
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            color: "#06182c"
            border.color: "#184d7e"
            border.width: 1
            radius: 6

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                // Screen Title Badge
                Rectangle {
                    Layout.preferredWidth: 150
                    Layout.preferredHeight: 34
                    radius: 4
                    color: "#0d2b4a"
                    border.color: "#00d2ff"
                    border.width: 1.2
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text { text: "✎ RECIPE MAKER"; color: "#00d2ff"; font.bold: true; font.pixelSize: 12 }
                    }
                }

                // Recipe Master Dropdown
                RowLayout {
                    spacing: 6
                    Text { text: "Master Recipe:"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11 }
                    ComboBox {
                        id: recipeCombo
                        Layout.preferredWidth: 260
                        Layout.preferredHeight: 34
                        model: [
                            "REC-VPU50-001 | Industrial Shampoo Formulation",
                            "REC-VPU50-002 | Intensive Body Lotion Cream",
                            "REC-VPU50-003 | High-Shear Cosmetic Gel (Carbomer)"
                        ]
                    }
                }

                // Version & Status Badges
                Rectangle {
                    Layout.preferredWidth: 60
                    Layout.preferredHeight: 24
                    radius: 3
                    color: "#0f2d4d"
                    border.color: "#1d5b94"
                    Text { anchors.centerIn: parent; text: "v" + recipeMakerRoot.recipeVersion + ".0"; color: "#38bdf8"; font.bold: true; font.pixelSize: 11 }
                }

                Rectangle {
                    Layout.preferredWidth: 85
                    Layout.preferredHeight: 24
                    radius: 3
                    color: recipeMakerRoot.recipeStatus === "APPROVED" ? "#064e3b" : (recipeMakerRoot.recipeStatus === "DRAFT" ? "#78350f" : "#450a0a")
                    border.color: recipeMakerRoot.recipeStatus === "APPROVED" ? "#22c55e" : (recipeMakerRoot.recipeStatus === "DRAFT" ? "#f59e0b" : "#ef4444")
                    Text {
                        anchors.centerIn: parent
                        text: recipeMakerRoot.recipeStatus
                        color: recipeMakerRoot.recipeStatus === "APPROVED" ? "#86efac" : (recipeMakerRoot.recipeStatus === "DRAFT" ? "#fde68a" : "#fca5a5")
                        font.bold: true
                        font.pixelSize: 10
                    }
                }

                Item { Layout.fillWidth: true }

                // Authoring Action Buttons
                Button {
                    id: btnNew
                    text: "+ New"
                    Layout.preferredHeight: 34
                    Layout.preferredWidth: 80
                }

                Button {
                    id: btnSave
                    text: "Save Draft"
                    Layout.preferredHeight: 34
                    Layout.preferredWidth: 95
                }

                Button {
                    id: btnApprove
                    text: "✓ Approve"
                    Layout.preferredHeight: 34
                    Layout.preferredWidth: 95
                }

                Button {
                    id: btnDelete
                    text: "✕ Delete"
                    Layout.preferredHeight: 34
                    Layout.preferredWidth: 80
                }
            }
        }

        // =====================================================================
        // 2. MAIN SPLIT: STEP MATRIX (LEFT) + BILL OF MATERIALS & 21 CFR (RIGHT)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            // -----------------------------------------------------------------
            // LEFT PANEL: STEP-BY-STEP PROCESS MATRIX
            // -----------------------------------------------------------------
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#06182c"
                border.color: "#184d7e"
                border.width: 1
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 6

                    // Table Header Bar
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        radius: 4
                        color: "#0a243f"
                        border.color: "#184d7e"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8

                            Text { text: "#"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 32 }
                            Text { text: "Step Name"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 190 }
                            Text { text: "SOP Description"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 11; Layout.fillWidth: true }
                            Text { text: "P&ID Tag / Setpoint"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 160 }
                            Text { text: "Hold"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 40 }
                            Text { text: "Reorder / Delete"; color: "#6b8fbb"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 110; horizontalAlignment: Text.AlignRight }
                        }
                    }

                    // Step Matrix Rows
                    ListView {
                        id: stepsList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        model: [
                            { id: 1, name: "Phase A: Initial Water Charge", desc: "Charge DI Water to 55% level via CIP valve", tag: "1K1001 | Level 55%", isHold: false },
                            { id: 2, name: "Phase A: Pre-Heating & Gentle Agitation", desc: "Heat aqueous phase to 45.0°C under slow anchor stirring", tag: "1M1501 (25rpm) | 1E6001 (45°C)", isHold: false },
                            { id: 3, name: "Phase A: Dissolve EDTA & Citric Acid", desc: "Manual addition of chelating agents via top hatch", tag: "1M1501 (45rpm) | Hatch", isHold: true },
                            { id: 4, name: "Phase B: SLES 28% Surfactant Addition", desc: "Charge primary surfactant through bottom suction port", tag: "1M1501 (20rpm) | 1M5001 (-300mbar)", isHold: true },
                            { id: 5, name: "Phase C: Heating for Pearlizer Melt", desc: "Raise batch temperature to 70.0°C for wax dissolution", tag: "1E6001 (70°C) | 1M1501 (35rpm)", isHold: false },
                            { id: 6, name: "Phase C: High-Shear Emulsification", desc: "Homogenizer ramping to 3600 RPM under deep vacuum", tag: "1X1001 (3600rpm) | 1M5001 (-450mbar)", isHold: false },
                            { id: 7, name: "Phase D: Cool-Down to 45.0°C", desc: "Jacket cooling under moderate agitation", tag: "1E6001_COOL (45°C) | 1M1501 (30rpm)", isHold: false },
                            { id: 8, name: "Phase E: Preservative & Scent Dosing", desc: "Add heat-sensitive actives at 45.0°C", tag: "1M1501 (30rpm) | Hatch", isHold: true },
                            { id: 9, name: "Phase F: Viscosity Adjustment (Salt Trim)", desc: "Electrolyte viscosity trim and final vacuum deaeration", tag: "1M1501 (40rpm) | 1M5001 (-300mbar)", isHold: true }
                        ]

                        delegate: Rectangle {
                            width: stepsList.width
                            height: 44
                            radius: 4
                            color: index % 2 === 0 ? "#092440" : "#071b30"
                            border.color: "#122d52"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                // Step Number Pill
                                Rectangle {
                                    Layout.preferredWidth: 26
                                    Layout.preferredHeight: 26
                                    radius: 13
                                    color: "#0f2d4d"
                                    border.color: "#1d5b94"
                                    Text { anchors.centerIn: parent; text: modelData.id; color: "#ffffff"; font.bold: true; font.pixelSize: 11 }
                                }

                                // Step Name
                                Text { text: modelData.name; color: "#ffffff"; font.bold: true; font.pixelSize: 11; Layout.preferredWidth: 190; elide: Text.ElideRight }

                                // SOP Description
                                Text { text: modelData.desc; color: "#94a3b8"; font.pixelSize: 10; Layout.fillWidth: true; elide: Text.ElideRight }

                                // P&ID Tag / Setpoint
                                Text { text: modelData.tag; color: "#38bdf8"; font.bold: true; font.pixelSize: 10; Layout.preferredWidth: 160; elide: Text.ElideRight }

                                // Hold Point Chip
                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 18
                                    radius: 3
                                    color: modelData.isHold ? "#78350f" : "#1e293b"
                                    border.color: modelData.isHold ? "#f59e0b" : "#475569"
                                    Text { anchors.centerIn: parent; text: modelData.isHold ? "21CFR" : "AUTO"; color: modelData.isHold ? "#fde68a" : "#64748b"; font.bold: true; font.pixelSize: 8 }
                                }

                                // Actions: Move Up / Down / Delete
                                RowLayout {
                                    Layout.preferredWidth: 110
                                    spacing: 4

                                    Rectangle {
                                        width: 24; height: 24; radius: 3; color: "#0d2847"; border.color: "#1e40af"
                                        Text { anchors.centerIn: parent; text: "↑"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11 }
                                    }
                                    Rectangle {
                                        width: 24; height: 24; radius: 3; color: "#0d2847"; border.color: "#1e40af"
                                        Text { anchors.centerIn: parent; text: "↓"; color: "#94a3b8"; font.bold: true; font.pixelSize: 11 }
                                    }
                                    Rectangle {
                                        width: 24; height: 24; radius: 3; color: "#450a0a"; border.color: "#ef4444"
                                        Text { anchors.centerIn: parent; text: "✕"; color: "#f87171"; font.bold: true; font.pixelSize: 10 }
                                    }
                                }
                            }
                        }
                    }

                    // + Add Step Button
                    Button {
                        id: btnAddStep
                        text: "+ Add Sequence Step"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                    }
                }
            }

            // -----------------------------------------------------------------
            // RIGHT PANEL: BILL OF MATERIALS (BOM) & 21 CFR SIGN-OFF RECORD
            // -----------------------------------------------------------------
            Rectangle {
                Layout.preferredWidth: 360
                Layout.fillHeight: true
                color: "#06182c"
                border.color: "#184d7e"
                border.width: 1
                radius: 6

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8

                    Text { text: "BILL OF MATERIALS (BOM PHASES)"; color: "#38bdf8"; font.bold: true; font.pixelSize: 11 }

                    // BOM Table
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#071b30"
                        border.color: "#122d52"
                        radius: 4

                        ListView {
                            id: bomList
                            anchors.fill: parent
                            anchors.margins: 6
                            clip: true
                            spacing: 3
                            model: [
                                { sr: 1, name: "Deionized Water", phase: "A", qty: "45.0 kg" },
                                { sr: 2, name: "EDTA Disodium", phase: "A", qty: "0.1 kg" },
                                { sr: 3, name: "Citric Acid (50% Sol)", phase: "A", qty: "0.3 kg" },
                                { sr: 4, name: "SLES 28% Surfactant", phase: "B", qty: "18.0 kg" },
                                { sr: 5, name: "CAPB Foam Booster", phase: "B", qty: "4.0 kg" },
                                { sr: 6, name: "Cocamide DEA", phase: "B", qty: "2.0 kg" },
                                { sr: 7, name: "Glycol Distearate", phase: "C", qty: "3.0 kg" },
                                { sr: 8, name: "Cetyl Alcohol", phase: "C", qty: "1.5 kg" },
                                { sr: 9, name: "Dimethicone Fluid", phase: "C", qty: "1.0 kg" },
                                { sr: 10, name: "Polyquaternium-7", phase: "D", qty: "1.5 kg" },
                                { sr: 11, name: "Panthenol (Pro-Vit B5)", phase: "D", qty: "0.5 kg" },
                                { sr: 12, name: "Fragrance Oil", phase: "E", qty: "0.8 kg" },
                                { sr: 13, name: "Preservative Blend", phase: "E", qty: "0.15 kg" },
                                { sr: 14, name: "Sodium Chloride (NaCl)", phase: "F", qty: "2.5 kg" },
                                { sr: 15, name: "Color D&C Yellow", phase: "F", qty: "0.02 kg" }
                            ]

                            delegate: Rectangle {
                                width: bomList.width
                                height: 26
                                radius: 3
                                color: index % 2 === 0 ? "#092440" : "#071b30"

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.leftMargin: 6
                                    anchors.rightMargin: 6
                                    spacing: 6

                                    Rectangle {
                                        width: 18; height: 18; radius: 3
                                        color: modelData.phase === "A" ? "#1e3a8a" : (modelData.phase === "B" ? "#14532d" : (modelData.phase === "C" ? "#7c2d12" : "#581c87"))
                                        Text { anchors.centerIn: parent; text: modelData.phase; color: "#ffffff"; font.bold: true; font.pixelSize: 9 }
                                    }

                                    Text { text: modelData.name; color: "#ffffff"; font.pixelSize: 10; Layout.fillWidth: true; elide: Text.ElideRight }
                                    Text { text: modelData.qty; color: "#4ade80"; font.bold: true; font.pixelSize: 10; font.family: "Monospace" }
                                }
                            }
                        }
                    }

                    // 21 CFR Master Approval Metadata Box
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 70
                        radius: 4
                        color: "#0a243f"
                        border.color: "#1e40af"

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 2
                            Text { text: "21 CFR PART 11 MASTER APPROVAL"; color: "#38bdf8"; font.bold: true; font.pixelSize: 9 }
                            Text { text: "Authored By: " + recipeMakerRoot.recipeAuthor; color: "#cbd5e1"; font.pixelSize: 9 }
                            Text { text: "Approved By: Dr. E. Vance (Process Eng)"; color: "#86efac"; font.bold: true; font.pixelSize: 9 }
                            Text { text: "Signed At: " + recipeMakerRoot.approvalDate; color: "#94a3b8"; font.pixelSize: 9 }
                        }
                    }
                }
            }
        }
    }
}
