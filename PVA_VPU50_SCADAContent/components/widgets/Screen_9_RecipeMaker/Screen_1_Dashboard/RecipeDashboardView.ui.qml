pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../"

Item {
    id: dashboardRoot
    implicitWidth: 1166
    implicitHeight: 600

    property int totalRecipesCount: 3
    property int selectedIndex: 0
    property string searchQuery: ""

    property alias recipeListView: listView
    property alias createNewRecipeBtn: newBtn
    property alias createNewRecipeMouse: newMouse
    property alias searchInputField: searchInput
    property alias editRecipeBtn: editBtn
    property alias editRecipeMouse: editMouse
    property alias duplicateRecipeBtn: dupBtn
    property alias duplicateRecipeMouse: dupMouse
    property alias deleteRecipeBtn: delBtn
    property alias deleteRecipeMouse: delMouse
    property alias proceedToIngredientsBtn: nextBtn
    property alias proceedToIngredientsMouse: nextMouse

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 10

        // 1. Header Toolbar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
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
                    iconName: "recipes_checklist"
                }

                Text {
                    text: "MASTER RECIPE CATALOG (" + dashboardRoot.totalRecipesCount + ")"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 13
                    font.family: "Segoe UI"
                }

                Item { Layout.fillWidth: true }

                // Search Input Field
                Rectangle {
                    Layout.preferredWidth: 230
                    Layout.preferredHeight: 34
                    color: "#081d33"
                    border.color: searchInput.activeFocus ? "#38bdf8" : "#1d5b94"
                    border.width: 1
                    radius: 4

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 8

                        // Clean vector magnifying glass search icon (cross-platform safe)
                        Item {
                            Layout.preferredWidth: 16
                            Layout.preferredHeight: 16
                            Rectangle {
                                x: 1
                                y: 1
                                width: 9
                                height: 9
                                radius: 4.5
                                color: "transparent"
                                border.color: searchInput.activeFocus ? "#38bdf8" : "#64748b"
                                border.width: 2
                            }
                            Rectangle {
                                x: 8
                                y: 8
                                width: 5
                                height: 2
                                rotation: 45
                                color: searchInput.activeFocus ? "#38bdf8" : "#64748b"
                            }
                        }

                        TextInput {
                            id: searchInput
                            Layout.fillWidth: true
                            color: "#ffffff"
                            font.pixelSize: 11
                            font.family: "Segoe UI"
                            selectByMouse: true
                            clip: true

                            Text {
                                anchors.fill: parent
                                text: "Search recipes or products..."
                                color: "#64748b"
                                font.pixelSize: 11
                                font.family: "Segoe UI"
                                verticalAlignment: Text.AlignVCenter
                                visible: !searchInput.text && !searchInput.activeFocus
                            }
                        }
                    }
                }

                // NEW RECIPE Trigger Button
                Rectangle {
                    id: newBtn
                    Layout.preferredWidth: 140
                    Layout.preferredHeight: 34
                    radius: 4
                    color: newMouse.containsMouse ? "#047857" : "#059669"
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
                            font.family: "Segoe UI"
                        }
                        Text {
                            text: "NEW RECIPE"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 12
                            font.family: "Segoe UI"
                        }
                    }

                    MouseArea {
                        id: newMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
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
                    color: editMouse.containsMouse ? "#1e40af" : "#0f3a69"
                    border.color: "#38bdf8"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Edit Info"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 11
                        font.family: "Segoe UI"
                    }

                    MouseArea {
                        id: editMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                // Duplicate Button
                Rectangle {
                    id: dupBtn
                    Layout.preferredWidth: 110
                    Layout.preferredHeight: 36
                    radius: 4
                    color: dupMouse.containsMouse ? "#1e40af" : "#0f3a69"
                    border.color: "#38bdf8"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Duplicate"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 11
                        font.family: "Segoe UI"
                    }

                    MouseArea {
                        id: dupMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                // Delete Button
                Rectangle {
                    id: delBtn
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    radius: 4
                    color: delMouse.containsMouse ? "#7f1d1d" : "#450a0a"
                    border.color: "#ef4444"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Delete"
                        color: "#fca5a5"
                        font.bold: true
                        font.pixelSize: 11
                        font.family: "Segoe UI"
                    }

                    MouseArea {
                        id: delMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "Stage 1 of 3: Metadata Configured"
                    color: "#94a3b8"
                    font.pixelSize: 11
                    font.bold: true
                    font.family: "Segoe UI"
                }

                // Proceed to Screen 2 Button
                Rectangle {
                    id: nextBtn
                    Layout.preferredWidth: 180
                    Layout.preferredHeight: 36
                    radius: 4
                    color: nextMouse.containsMouse ? "#0369a1" : "#0284c7"
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
                            font.family: "Segoe UI"
                        }
                        Text {
                            text: "→"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 15
                            font.family: "Segoe UI"
                        }
                    }

                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }
    }
}
