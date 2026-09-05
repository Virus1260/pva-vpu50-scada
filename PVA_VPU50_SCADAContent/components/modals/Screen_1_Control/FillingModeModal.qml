import QtQuick
import QtQuick.Layouts
import "../../common"

Rectangle {
    id: fillModalRoot
    implicitWidth: 1024
    implicitHeight: 600
    width: 1024
    height: 600
    color: "#bb000000"
    z: 999

    property string selectedMode: "Suction Liquids"

    signal modeApplied(string modeKey, string modeTitle)
    signal closed()

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Rectangle {
        id: modalBox
        anchors.centerIn: parent
        width: 680
        height: 440
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
                    text: "Select Suction / Filling Mode"
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
                        onClicked: fillModalRoot.closed()
                    }
                }
            }

            // 3 Mode Columns
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 24
                Layout.alignment: Qt.AlignHCenter

                // Option 1: Suction Liquids
                ColumnLayout {
                    Layout.preferredWidth: 150
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Text {
                        text: "Suction Liquids"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 140
                        color: fillModalRoot.selectedMode === "Suction Liquids" ? "#164e85" : (s1Mouse.containsMouse ? "#124373" : "#0c345a")
                        border.color: fillModalRoot.selectedMode === "Suction Liquids" ? "#00d2ff" : (s1Mouse.containsMouse ? "#3b82f6" : "#1d5b94")
                        border.width: fillModalRoot.selectedMode === "Suction Liquids" ? 2.5 : 1
                        radius: 12

                        ScadaIcon {
                            anchors.centerIn: parent
                            iconName: "suction_liquids"
                            width: 96
                            height: 96
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
                            visible: fillModalRoot.selectedMode === "Suction Liquids"
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
                            id: s1Mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: fillModalRoot.selectedMode = "Suction Liquids"
                        }
                    }

                    Text {
                        text: "Liquid Port Charging"
                        color: "#94a3b8"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                // Option 2: Suction Solids
                ColumnLayout {
                    Layout.preferredWidth: 150
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Text {
                        text: "Suction Solids"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 140
                        color: fillModalRoot.selectedMode === "Suction Solids" ? "#164e85" : (s2Mouse.containsMouse ? "#124373" : "#0c345a")
                        border.color: fillModalRoot.selectedMode === "Suction Solids" ? "#00d2ff" : (s2Mouse.containsMouse ? "#3b82f6" : "#1d5b94")
                        border.width: fillModalRoot.selectedMode === "Suction Solids" ? 2.5 : 1
                        radius: 12

                        ScadaIcon {
                            anchors.centerIn: parent
                            iconName: "suction_solids"
                            width: 96
                            height: 96
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
                            visible: fillModalRoot.selectedMode === "Suction Solids"
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
                            id: s2Mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: fillModalRoot.selectedMode = "Suction Solids"
                        }
                    }

                    Text {
                        text: "Powder / Solids Funnel"
                        color: "#94a3b8"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                // Option 3: Suction Bottom
                ColumnLayout {
                    Layout.preferredWidth: 150
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Text {
                        text: "Suction Bottom"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.preferredWidth: 140
                        Layout.preferredHeight: 140
                        color: fillModalRoot.selectedMode === "Suction Bottom" ? "#164e85" : (s3Mouse.containsMouse ? "#124373" : "#0c345a")
                        border.color: fillModalRoot.selectedMode === "Suction Bottom" ? "#00d2ff" : (s3Mouse.containsMouse ? "#3b82f6" : "#1d5b94")
                        border.width: fillModalRoot.selectedMode === "Suction Bottom" ? 2.5 : 1
                        radius: 12

                        ScadaIcon {
                            anchors.centerIn: parent
                            iconName: "suction_bottom"
                            width: 96
                            height: 96
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
                            visible: fillModalRoot.selectedMode === "Suction Bottom"
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
                            id: s3Mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: fillModalRoot.selectedMode = "Suction Bottom"
                        }
                    }

                    Text {
                        text: "Bottom Port Valve"
                        color: "#94a3b8"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
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
                        onClicked: fillModalRoot.closed()
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
                            var iconKey = "suction_liquids";
                            if (fillModalRoot.selectedMode === "Suction Solids") iconKey = "suction_solids";
                            else if (fillModalRoot.selectedMode === "Suction Bottom") iconKey = "suction_bottom";

                            fillModalRoot.modeApplied(iconKey, fillModalRoot.selectedMode);
                            fillModalRoot.closed();
                        }
                    }
                }
            }
        }
    }
}
