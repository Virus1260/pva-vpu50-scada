import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: selectorModalRoot
    implicitWidth: 1024
    implicitHeight: 600
    color: "#95000000"
    z: 9999

    property string title: "SELECT RUN MODE"
    property var modeList: []
    property string selectedModeId: ""

    signal modeSelected(string modeId)
    signal closed()

    // Consume background clicks
    MouseArea {
        anchors.fill: parent
        onClicked: selectorModalRoot.closed()
    }

    Rectangle {
        id: dialogBox
        anchors.centerIn: parent
        width: Math.max(460, Math.min(parent.width * 0.55, 620))
        height: Math.max(300, Math.min(parent.height * 0.55, 380))
        color: "#08213b"
        border.color: "#184d7e"
        border.width: 2
        radius: 8

        // Prevent clicking inside from closing dialog
        MouseArea {
            anchors.fill: parent
            onClicked: function(mouse) { mouse.accepted = true; }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // Dialog Header
            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: selectorModalRoot.title
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 14
                    font.family: "Segoe UI"
                }

                Item { Layout.fillWidth: true }

                Rectangle {
                    width: 28
                    height: 28
                    radius: 4
                    color: closeMouse.containsMouse ? "#1e40af" : "#0d365e"
                    border.color: "#1d5b94"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: closeMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: selectorModalRoot.closed()
                    }
                }
            }

            // Cards Grid / Row
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                Repeater {
                    model: selectorModalRoot.modeList

                    delegate: Rectangle {
                        id: cardDelegate
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        property bool isSelected: (selectorModalRoot.selectedModeId === modelData.id || selectorModalRoot.selectedModeId === modelData.code)

                        color: isSelected ? "#164e85" : (cardMouse.containsMouse ? "#124373" : "#0c345a")
                        border.color: isSelected ? "#00d2ff" : (cardMouse.containsMouse ? "#38bdf8" : "#1d5b94")
                        border.width: isSelected ? 2.5 : 1
                        radius: 8

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            ScadaIcon {
                                iconName: cardDelegate.modelData.icon || "stirrer_agitator"
                                width: 48
                                height: 48
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: cardDelegate.modelData.title
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: 12
                                font.family: "Segoe UI"
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                            }

                            Text {
                                text: cardDelegate.modelData.subtitle
                                color: "#8cb5dc"
                                font.pixelSize: 10
                                font.family: "Segoe UI"
                                horizontalAlignment: Text.AlignHCenter
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        // Selected Check Badge
                        Rectangle {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 6
                            width: 20
                            height: 20
                            radius: 10
                            color: "#00d2ff"
                            visible: cardDelegate.isSelected

                            Text {
                                anchors.centerIn: parent
                                text: "✓"
                                color: "#08213b"
                                font.bold: true
                                font.pixelSize: 12
                            }
                        }

                        MouseArea {
                            id: cardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                var chosenId = cardDelegate.modelData.id || cardDelegate.modelData.code;
                                selectorModalRoot.selectedModeId = chosenId;
                                selectorModalRoot.modeSelected(chosenId);
                                selectorModalRoot.closed();
                            }
                        }
                    }
                }
            }

            // Cancel Button
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: 4
                color: cancelMouse.containsMouse ? "#1e3a5f" : "#0d365e"
                border.color: "#1d5b94"
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    color: "#8cb5dc"
                    font.bold: true
                    font.pixelSize: 12
                    font.family: "Segoe UI"
                }

                MouseArea {
                    id: cancelMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: selectorModalRoot.closed()
                }
            }
        }
    }
}
