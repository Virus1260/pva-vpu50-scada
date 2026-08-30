/*
This is a UI file (.ui.qml) for Screen 1: Recipe Dashboard & Catalog Engine.
Strictly declarative for Qt Design Studio.
*/

import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: dashboardRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    color: "#08213b"

    property string searchQuery: ""
    property string statusFilter: "ALL"
    property int selectedIndex: 0
    property int totalRecipesCount: 3

    property alias newRecipeBtn: newBtn
    property alias editRecipeBtn: editBtn
    property alias duplicateRecipeBtn: dupBtn
    property alias deleteRecipeBtn: delBtn
    property alias nextStageBtn: nextBtn
    property alias recipeListView: listView

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 10

        // 1. Top Control Bar: Search, Filters, and [NEW RECIPE] Button
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

                ScadaIcon {
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    iconName: "recipes_checklist"
                }

                Text {
                    text: "MASTER RECIPE CATALOG (" + dashboardRoot.totalRecipesCount + ")"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 13
                }

                Item { Layout.fillWidth: true }

                // Search Input Field
                Rectangle {
                    Layout.preferredWidth: 220
                    Layout.preferredHeight: 34
                    color: "#081d33"
                    border.color: "#1d5b94"
                    border.width: 1
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 6

                        Text {
                            text: "🔍"
                            color: "#64748b"
                            font.pixelSize: 11
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            color: "#ffffff"
                            font.pixelSize: 11
                            selectByMouse: true
                            clip: true

                            Text {
                                anchors.fill: parent
                                text: "Search recipes or products..."
                                color: "#64748b"
                                font.pixelSize: 11
                                visible: !searchInput.text && !searchInput.activeFocus
                            }
                        }
                    }
                }

                // NEW RECIPE Trigger Button
                Rectangle {
                    id: newBtn
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#059669"
                    border.color: "#34d399"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "+"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 16
                        }
                        Text {
                            text: "NEW RECIPE"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        // 2. Main Recipe Cards List
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#092442"
            border.color: "#1d5b94"
            border.width: 1
            radius: 6
            clip: true

            ListView {
                id: listView
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                clip: true
                boundsBehavior: Flickable.StopAtBounds
            }
        }

        // 3. Bottom Action Bar: Edit, Duplicate, Delete & [Save & Next ->]
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

                // Edit Button
                Rectangle {
                    id: editBtn
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#0f3a69"
                    border.color: "#38bdf8"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "✎ Edit Info"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 11
                    }
                }

                // Duplicate Button
                Rectangle {
                    id: dupBtn
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 36
                    radius: 4
                    color: "#0f3a69"
                    border.color: "#38bdf8"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "⎘ Duplicate"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 11
                    }
                }

                // Delete Button
                Rectangle {
                    id: delBtn
                    Layout.preferredWidth: 100
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
                    text: "Stage 1 of 3: Metadata Configured"
                    color: "#94a3b8"
                    font.pixelSize: 11
                    font.bold: true
                }

                // Proceed to Screen 2 Button
                Rectangle {
                    id: nextBtn
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
                            text: "Ingredient Builder"
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
