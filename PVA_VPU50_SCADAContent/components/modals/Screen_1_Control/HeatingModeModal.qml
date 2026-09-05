import QtQuick
import QtQuick.Layouts
import "../../common"

Rectangle {
    id: heatModalRoot
    implicitWidth: 1024
    implicitHeight: 600
    width: 1024
    height: 600
    color: "#bb000000"
    z: 999

    property string targetSelector: "mode" // "mode", "regulation", "temp_src"
    property string selectedValue: "Heating"

    signal optionSelected(string selector, string val, string iconKey)
    signal closed()

    MouseArea {
        anchors.fill: parent
        onClicked: {}
    }

    Rectangle {
        id: modalBox
        anchors.centerIn: parent
        width: 560
        height: 400
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
                    text: heatModalRoot.targetSelector === "mode" ? "Select Heating / Cooling Mode" :
                          heatModalRoot.targetSelector === "regulation" ? "Select Temperature Regulation Target" : "Select Temperature Indicator Source"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 16
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
                        onClicked: heatModalRoot.closed()
                    }
                }
            }

            // Selection Options Row
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 40
                Layout.alignment: Qt.AlignHCenter

                // Option 1
                ColumnLayout {
                    Layout.preferredWidth: 120
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Text {
                        text: heatModalRoot.targetSelector === "mode" ? "Heating" :
                              heatModalRoot.targetSelector === "regulation" ? "Product" : "Baffle"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.preferredWidth: 110
                        Layout.preferredHeight: 110
                        color: (heatModalRoot.selectedValue === "Heating" || heatModalRoot.selectedValue === "Product" || heatModalRoot.selectedValue === "Baffle") ?
                               (heatModalRoot.targetSelector === "mode" ? "#7f1d1d" : "#164e85") : (h1Mouse.containsMouse ? "#124373" : "#0b2545")
                        border.color: (heatModalRoot.selectedValue === "Heating" || heatModalRoot.selectedValue === "Product" || heatModalRoot.selectedValue === "Baffle") ?
                                      "#00d2ff" : (h1Mouse.containsMouse ? "#3b82f6" : "#1e40af")
                        border.width: (heatModalRoot.selectedValue === "Heating" || heatModalRoot.selectedValue === "Product" || heatModalRoot.selectedValue === "Baffle") ? 2.5 : 1.5
                        radius: 12

                        ScadaIcon {
                            anchors.centerIn: parent
                            iconName: heatModalRoot.targetSelector === "mode" ? "heat_mode_heating" :
                                      heatModalRoot.targetSelector === "regulation" ? "heat_reg_product" : "heat_src_baffle"
                            width: 84
                            height: 84
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
                            visible: (heatModalRoot.selectedValue === "Heating" || heatModalRoot.selectedValue === "Product" || heatModalRoot.selectedValue === "Baffle")
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
                            id: h1Mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (heatModalRoot.targetSelector === "mode") heatModalRoot.selectedValue = "Heating";
                                else if (heatModalRoot.targetSelector === "regulation") heatModalRoot.selectedValue = "Product";
                                else if (heatModalRoot.targetSelector === "temp_src") heatModalRoot.selectedValue = "Baffle";
                            }
                        }
                    }

                    Text {
                        text: heatModalRoot.targetSelector === "mode" ? "Thermal Coil Heating" :
                              heatModalRoot.targetSelector === "regulation" ? "Product Batch RTD" : "Vertical Probe"
                        color: "#94a3b8"
                        font.pixelSize: 11
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                // Option 2
                ColumnLayout {
                    Layout.preferredWidth: 120
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Text {
                        text: heatModalRoot.targetSelector === "mode" ? "Cooling" :
                              heatModalRoot.targetSelector === "regulation" ? "Jacket" : "Homogenizer"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 13
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.preferredWidth: 110
                        Layout.preferredHeight: 110
                        color: (heatModalRoot.selectedValue === "Cooling" || heatModalRoot.selectedValue === "Jacket" || heatModalRoot.selectedValue === "Homogenizer") ?
                               (heatModalRoot.targetSelector === "mode" ? "#0e7490" : "#164e85") : (h2Mouse.containsMouse ? "#124373" : "#0b2545")
                        border.color: (heatModalRoot.selectedValue === "Cooling" || heatModalRoot.selectedValue === "Jacket" || heatModalRoot.selectedValue === "Homogenizer") ?
                                      "#00d2ff" : (h2Mouse.containsMouse ? "#3b82f6" : "#1e40af")
                        border.width: (heatModalRoot.selectedValue === "Cooling" || heatModalRoot.selectedValue === "Jacket" || heatModalRoot.selectedValue === "Homogenizer") ? 2.5 : 1.5
                        radius: 12

                        ScadaIcon {
                            anchors.centerIn: parent
                            iconName: heatModalRoot.targetSelector === "mode" ? "heat_mode_cooling" :
                                      heatModalRoot.targetSelector === "regulation" ? "heat_reg_jacket" : "heat_src_homo"
                            width: 84
                            height: 84
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
                            visible: (heatModalRoot.selectedValue === "Cooling" || heatModalRoot.selectedValue === "Jacket" || heatModalRoot.selectedValue === "Homogenizer")
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
                            id: h2Mouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (heatModalRoot.targetSelector === "mode") heatModalRoot.selectedValue = "Cooling";
                                else if (heatModalRoot.targetSelector === "regulation") heatModalRoot.selectedValue = "Jacket";
                                else if (heatModalRoot.targetSelector === "temp_src") heatModalRoot.selectedValue = "Homogenizer";
                            }
                        }
                    }

                    Text {
                        text: heatModalRoot.targetSelector === "mode" ? "External Chiller Inlet" :
                              heatModalRoot.targetSelector === "regulation" ? "Double Jacket RTD" : "In-Line Sensor"
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
                        onClicked: heatModalRoot.closed()
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 46
                    color: applyMouse.pressed ? "#5cb818" : "#78dc20"
                    radius: 6
                    Text {
                        anchors.centerIn: parent
                        text: "APPLY SELECTION"
                        color: "#0b1d33"
                        font.bold: true
                        font.pixelSize: 14
                    }
                    MouseArea {
                        id: applyMouse
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var iconKey = "";
                            if (heatModalRoot.targetSelector === "mode") {
                                iconKey = heatModalRoot.selectedValue === "Heating" ? "heat_mode_heating" : "heat_mode_cooling";
                            } else if (heatModalRoot.targetSelector === "regulation") {
                                iconKey = heatModalRoot.selectedValue === "Product" ? "heat_reg_product" : "heat_reg_jacket";
                            } else if (heatModalRoot.targetSelector === "temp_src") {
                                iconKey = heatModalRoot.selectedValue === "Baffle" ? "heat_src_baffle" : "heat_src_homo";
                            }

                            heatModalRoot.optionSelected(heatModalRoot.targetSelector, heatModalRoot.selectedValue, iconKey);
                            heatModalRoot.closed();
                        }
                    }
                }
            }
        }
    }
}
