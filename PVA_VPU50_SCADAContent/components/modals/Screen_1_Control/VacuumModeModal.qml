import QtQuick
import QtQuick.Layouts

Rectangle {
    id: vacModalRoot
    implicitWidth: 1024
    implicitHeight: 600
    width: 1024
    height: 600
    color: "#bb000000"
    z: 999

    property string selectedMode: "Vacuum"
    property real vacuumPreset: -400.0
    property real materialLoadingPreset: -850.0

    signal modeApplied(string modeKey, string modeTitle, double presetVal)
    signal closed()

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Rectangle {
        id: modalBox
        anchors.centerIn: parent
        width: 580
        height: 380
        color: "#08213b"
        border.color: "#184d7e"
        border.width: 2
        radius: 12
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // Header Bar
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Select Vacuum Operational Mode"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 17
                    Layout.fillWidth: true
                }
                Rectangle {
                    width: 30
                    height: 30
                    color: closeMouse.containsMouse ? "#c82333" : "#103358"
                    border.color: "#215c9b"
                    border.width: 1
                    radius: 4
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
                        onClicked: vacModalRoot.closed()
                    }
                }
            }

            // 2 Mode Cards
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 20
                Layout.alignment: Qt.AlignHCenter

                // Option 1: Vacuum
                Rectangle {
                    Layout.preferredWidth: 240
                    Layout.preferredHeight: 160
                    color: vacModalRoot.selectedMode === "Vacuum" ? "#164e85" : (v1Mouse.containsMouse ? "#124373" : "#0c345a")
                    border.color: vacModalRoot.selectedMode === "Vacuum" ? "#00d2ff" : (v1Mouse.containsMouse ? "#3b82f6" : "#1d5b94")
                    border.width: vacModalRoot.selectedMode === "Vacuum" ? 2.5 : 1
                    radius: 10

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 6
                        Layout.alignment: Qt.AlignHCenter

                        Text {
                            text: "Vacuum"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 18
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: "Preset: -400.0 mbar"
                            color: "#7dd3fc"
                            font.bold: true
                            font.pixelSize: 13
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: "Main Vessel Vacuum Control"
                            color: "#94a3b8"
                            font.pixelSize: 11
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Active Selection Badge
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 6
                        width: 20
                        height: 20
                        radius: 10
                        color: "#00d2ff"
                        visible: vacModalRoot.selectedMode === "Vacuum"
                        Image {
                            anchors.centerIn: parent
                            source: "../../../assets/icons/common/icon_check.svg"
                            width: 12
                            height: 12
                            sourceSize: Qt.size(12, 12)
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    MouseArea {
                        id: v1Mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: vacModalRoot.selectedMode = "Vacuum"
                    }
                }

                // Option 2: Material Loading
                Rectangle {
                    Layout.preferredWidth: 240
                    Layout.preferredHeight: 160
                    color: vacModalRoot.selectedMode === "Material Loading" ? "#164e85" : (v2Mouse.containsMouse ? "#124373" : "#0c345a")
                    border.color: vacModalRoot.selectedMode === "Material Loading" ? "#00d2ff" : (v2Mouse.containsMouse ? "#3b82f6" : "#1d5b94")
                    border.width: vacModalRoot.selectedMode === "Material Loading" ? 2.5 : 1
                    radius: 10

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 6
                        Layout.alignment: Qt.AlignHCenter

                        Text {
                            text: "Material Loading"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 18
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: "Preset: -850.0 mbar"
                            color: "#7dd3fc"
                            font.bold: true
                            font.pixelSize: 13
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: "High Vacuum Material Charging"
                            color: "#94a3b8"
                            font.pixelSize: 11
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // Active Selection Badge
                    Rectangle {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 6
                        width: 20
                        height: 20
                        radius: 10
                        color: "#00d2ff"
                        visible: vacModalRoot.selectedMode === "Material Loading"
                        Image {
                            anchors.centerIn: parent
                            source: "../../../assets/icons/common/icon_check.svg"
                            width: 12
                            height: 12
                            sourceSize: Qt.size(12, 12)
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    MouseArea {
                        id: v2Mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: vacModalRoot.selectedMode = "Material Loading"
                    }
                }
            }

            // Action Buttons Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Rectangle {
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 46
                    color: cancelMouse.pressed ? "#0f3258" : "#184c82"
                    border.color: "#276cb4"
                    border.width: 1
                    radius: 6
                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 14
                    }
                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: vacModalRoot.closed()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    color: applyMouse.pressed ? "#5cb818" : "#78dc20"
                    radius: 6
                    Text {
                        anchors.centerIn: parent
                        text: "APPLY MODE"
                        color: "#0b1d33"
                        font.bold: true
                        font.pixelSize: 14
                    }
                    MouseArea {
                        id: applyMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var preset = vacModalRoot.selectedMode === "Vacuum" ? -400.0 : -850.0;
                            vacModalRoot.modeApplied("vacuum_gauge", vacModalRoot.selectedMode, preset);
                            vacModalRoot.closed();
                        }
                    }
                }
            }
        }
    }
}
