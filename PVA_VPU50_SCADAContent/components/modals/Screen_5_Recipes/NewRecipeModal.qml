import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../widgets/ScadaKeyboard"

Rectangle {
    id: modalRoot
    implicitWidth: 1024
    implicitHeight: 600
    width: 1024
    height: 600
    color: "#bb000000"
    z: 999

    signal recipeCreated(string recipeName, string productName, string batchSize)
    signal cancelled()

    MouseArea {
        anchors.fill: parent
    }

    Rectangle {
        anchors.centerIn: parent
        width: 440
        height: 280
        color: "#08213b"
        border.color: "#00d2ff"
        border.width: 1.5
        radius: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Header
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Create New Formulation Recipe"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 15
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
                    color: "#0d365e"
                    Text { anchors.centerIn: parent; text: "✕"; color: "#ffffff"; font.pixelSize: 12 }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modalRoot.visible = false;
                            modalRoot.cancelled();
                        }
                    }
                }
            }

            // Recipe Name Field
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Text { text: "Recipe Name:"; color: "#94a3b8"; font.pixelSize: 11 }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    color: "#06182c"
                    border.color: nameInput.activeFocus ? "#00d2ff" : "#1e40af"
                    border.width: 1
                    radius: 4
                    TextInput {
                        id: nameInput
                        anchors.fill: parent
                        anchors.margins: 8
                        color: "#ffffff"
                        font.pixelSize: 12
                        text: "New Lotion Formulation"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor
                        onClicked: {
                            nameInput.forceActiveFocus();
                            textKeyboard.openFor(nameInput, "RECIPE NAME");
                        }
                    }
                }
            }

            // Product Name Field
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                Text { text: "Target Product:"; color: "#94a3b8"; font.pixelSize: 11 }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 34
                    color: "#06182c"
                    border.color: prodInput.activeFocus ? "#00d2ff" : "#1e40af"
                    border.width: 1
                    radius: 4
                    TextInput {
                        id: prodInput
                        anchors.fill: parent
                        anchors.margins: 8
                        color: "#ffffff"
                        font.pixelSize: 12
                        text: "Ointment / Emulsion Base"
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.IBeamCursor
                        onClicked: {
                            prodInput.forceActiveFocus();
                            textKeyboard.openFor(prodInput, "TARGET PRODUCT");
                        }
                    }
                }
            }

            // Action Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 10
                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 90
                    Layout.preferredHeight: 32
                    radius: 4
                    color: "#0d2847"
                    border.color: "#1e40af"
                    border.width: 1
                    Text { anchors.centerIn: parent; text: "Cancel"; color: "#94a3b8"; font.pixelSize: 12 }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modalRoot.visible = false;
                            modalRoot.cancelled();
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 32
                    radius: 4
                    color: "#16a34a"
                    border.color: "#4ade80"
                    border.width: 1
                    Text { anchors.centerIn: parent; text: "Create Recipe"; color: "#ffffff"; font.bold: true; font.pixelSize: 12 }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (nameInput.text.trim().length > 0) {
                                modalRoot.recipeCreated(nameInput.text.trim(), prodInput.text.trim(), "500 L");
                                modalRoot.visible = false;
                            }
                        }
                    }
                }
            }
        }
    }

    ScadaTextKeyboard {
        id: textKeyboard
        anchors.fill: parent
        z: 9999
        visible: false
    }
}
