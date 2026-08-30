pragma ComponentBehavior: Bound
/*
This is a UI file (.ui.qml) for Screen 2: Phase-Wise Ingredient Formulation Builder.
Strictly declarative for Qt Design Studio. Reference: image_cf2be0.jpg
*/

import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: ingBuilderRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#08213b"

    property string recipeTitle: "Body Lotion Formulation"
    property string productName: "Cosmetic Intensive Body Lotion"
    property string qtyType: "Fixed"
    property int ingredientCount: 13
    property string totalWeightFormatted: "100.0 kg"
    property bool hasSelection: false

    property alias backBtn: prevBtn
    property alias nextBtn: forwardBtn
    property alias addTriggerRow: addRowRect
    property alias editSelectedBtn: editBtn
    property alias duplicateSelectedBtn: dupBtn
    property alias deleteSelectedBtn: delBtn
    property alias ingredientsListView: ingList

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        // 1. Top Header & Recipe Context Summary
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

                ScadaIcon {
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    iconName: "docs_report"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    RowLayout {
                        spacing: 8
                        Text {
                            text: "FORMULATION SPECIFICATION SHEET: " + ingBuilderRoot.recipeTitle
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 13
                        }
                        Rectangle {
                            Layout.preferredHeight: 18
                            Layout.preferredWidth: qTxt.implicitWidth + 8
                            radius: 3
                            color: ingBuilderRoot.qtyType === "Fixed" ? "#0369a1" : "#6b21a8"
                            border.color: ingBuilderRoot.qtyType === "Fixed" ? "#38bdf8" : "#c084fc"
                            border.width: 1
                            Text {
                                id: qTxt
                                anchors.centerIn: parent
                                text: ingBuilderRoot.qtyType + " Mode"
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: 9
                            }
                        }
                    }
                    Text {
                        text: "Phased Batch Bill of Materials (BOM) & Charging Rules | Ref: SOP-VPU50-FORMULATION"
                        color: "#94a3b8"
                        font.pixelSize: 10
                    }
                }

                // Batch Summary Badges
                RowLayout {
                    spacing: 10
                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: 140
                        radius: 4
                        color: "#081d33"
                        border.color: "#1d5b94"
                        border.width: 1
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "Items:"; color: "#94a3b8"; font.pixelSize: 10 }
                            Text { text: ingBuilderRoot.ingredientCount + " Raw Materials"; color: "#38bdf8"; font.bold: true; font.pixelSize: 10 }
                        }
                    }

                    Rectangle {
                        Layout.preferredHeight: 28
                        Layout.preferredWidth: 140
                        radius: 4
                        color: "#081d33"
                        border.color: "#1d5b94"
                        border.width: 1
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 4
                            Text { text: "Batch Total:"; color: "#94a3b8"; font.pixelSize: 10 }
                            Text { text: ingBuilderRoot.totalWeightFormatted; color: "#34d399"; font.bold: true; font.pixelSize: 10 }
                        }
                    }
                }
            }
        }

        // 2. Table Column Headers
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 32
            color: "#0d365e"
            border.color: "#1d5b94"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                Text {
                    Layout.preferredWidth: 50
                    text: "SR. NO."
                    color: "#38bdf8"
                    font.bold: true
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 20; color: "#1d5b94" }

                Text {
                    Layout.preferredWidth: 260
                    text: "INGREDIENTS (RAW MATERIAL NAME)"
                    color: "#38bdf8"
                    font.bold: true
                    font.pixelSize: 11
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 20; color: "#1d5b94" }

                Text {
                    Layout.preferredWidth: 80
                    text: "PHASE"
                    color: "#38bdf8"
                    font.bold: true
                    font.pixelSize: 11
                    horizontalAlignment: Text.AlignHCenter
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 20; color: "#1d5b94" }

                Text {
                    Layout.preferredWidth: 110
                    text: "QTY / RATIO"
                    color: "#38bdf8"
                    font.bold: true
                    font.pixelSize: 11
                }

                Rectangle { Layout.preferredWidth: 1; Layout.preferredHeight: 20; color: "#1d5b94" }

                Text {
                    Layout.fillWidth: true
                    text: "ISA PROCESS PARAMETERS & CHARGING INSTRUCTIONS"
                    color: "#38bdf8"
                    font.bold: true
                    font.pixelSize: 11
                }
            }
        }

        // 3. Scrollable Table Body with Permanent Bottom Inline Add Trigger
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#092442"
            border.color: "#1d5b94"
            border.width: 1
            radius: 4
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 4

                ListView {
                    id: ingList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 4
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                }

                // Permanent "+ Add Ingredient" Inline Bottom Trigger Row
                Rectangle {
                    id: addRowRect
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#0c2f54"
                    border.color: "#38bdf8"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "✚"
                            color: "#38bdf8"
                            font.bold: true
                            font.pixelSize: 14
                        }

                        Text {
                            text: "+ Add New Ingredient to Formulation"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        // 4. Bottom Action Bar: Selection Actions & Stepper Navigation
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

                // Back to Screen 1 Button
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
                        Text {
                            text: "←"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 14
                        }
                        Text {
                            text: "Metadata Dashboard"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 11
                        }
                    }
                }

                // Row Selection Action Buttons (Revealed when row is selected)
                Rectangle {
                    id: editBtn
                    visible: ingBuilderRoot.hasSelection
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#0f3a69"
                    border.color: "#38bdf8"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "✎ Edit Item"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    id: dupBtn
                    visible: ingBuilderRoot.hasSelection
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#78350f"
                    border.color: "#f59e0b"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "⎘ Duplicate"
                        color: "#fef3c7"
                        font.bold: true
                        font.pixelSize: 11
                    }
                }

                Rectangle {
                    id: delBtn
                    visible: ingBuilderRoot.hasSelection
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#450a0a"
                    border.color: "#ef4444"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "🗑 Delete"
                        color: "#fca5a5"
                        font.bold: true
                        font.pixelSize: 11
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Stage 2 of 3: Formulation Structured"
                    color: "#94a3b8"
                    font.pixelSize: 11
                    font.bold: true
                }

                // Save & Next Button to proceed to Screen 3 (The Timeline Designer)
                Rectangle {
                    id: forwardBtn
                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#0284c7"
                    border.color: "#38bdf8"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "Save & Next (Timeline)"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 12
                        }
                        Text {
                            text: "→"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 15
                        }
                    }
                }
            }
        }
    }
}
