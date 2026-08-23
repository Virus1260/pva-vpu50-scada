import QtQuick
import QtQuick.Layouts
import "../../widgets"

Rectangle {
    id: extModalRoot
    implicitWidth: 1024
    implicitHeight: 600
    width: 1024
    height: 600
    color: "#bb000000"
    z: 999

    property string selectedMode: "Discharge Circulation"
    signal modeApplied(string modeKey, string modeTitle)
    signal closed()

    MouseArea {
        anchors.fill: parent
        onClicked: {} // Block clicks from passing to underlying screen
    }

    Rectangle {
        id: modalBox
        anchors.centerIn: parent
        width: 780
        height: 480
        color: "#08213b"
        border.color: "#184d7e"
        border.width: 2
        radius: 12
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            // Header Bar
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Select External Line Recirculation Mode"
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
                        onClicked: extModalRoot.closed()
                    }
                }
            }

            // Category Containers Row
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 16

                // =============================================================
                // CATEGORY 1: PRODUCT OPERATIONS (Blue Theme - 2 Cards)
                // =============================================================
                Rectangle {
                    Layout.preferredWidth: 290
                    Layout.fillHeight: true
                    color: "#071d36"
                    border.color: "#1d4ed8"
                    border.width: 1.5
                    radius: 10

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        // Category Header Badge
                        Rectangle {
                            Layout.fillWidth: true
                            height: 28
                            color: "#1e3a8a"
                            radius: 6
                            Text {
                                anchors.centerIn: parent
                                text: "PRODUCT OPERATIONS"
                                color: "#60a5fa"
                                font.bold: true
                                font.pixelSize: 11
                            }
                        }

                        // 2 Columns of Selection Cards
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 12
                            Layout.alignment: Qt.AlignHCenter

                            // Option 1: Discharge Product
                            ColumnLayout {
                                Layout.preferredWidth: 110
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 6

                                Text {
                                    text: "Discharge\nProduct"
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 12
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Rectangle {
                                    Layout.preferredWidth: 110
                                    Layout.preferredHeight: 110
                                    color: extModalRoot.selectedMode === "Discharge Product" ? "#164e85" : (p1Mouse.containsMouse ? "#124373" : "#0b2545")
                                    border.color: extModalRoot.selectedMode === "Discharge Product" ? "#00d2ff" : (p1Mouse.containsMouse ? "#3b82f6" : "#1e40af")
                                    border.width: extModalRoot.selectedMode === "Discharge Product" ? 2.5 : 1.5
                                    radius: 10

                                    ScadaIcon {
                                        anchors.centerIn: parent
                                        iconName: "ext_discharge_product"
                                        width: 80
                                        height: 80
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
                                        visible: extModalRoot.selectedMode === "Discharge Product"
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
                                        id: p1Mouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: extModalRoot.selectedMode = "Discharge Product"
                                    }
                                }

                                Text {
                                    text: "Product Discharge"
                                    color: "#94a3b8"
                                    font.pixelSize: 10
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }

                            // Option 2: Discharge Circulation
                            ColumnLayout {
                                Layout.preferredWidth: 110
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 6

                                Text {
                                    text: "Discharge\nCirculation"
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 12
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Rectangle {
                                    Layout.preferredWidth: 110
                                    Layout.preferredHeight: 110
                                    color: extModalRoot.selectedMode === "Discharge Circulation" ? "#164e85" : (p2Mouse.containsMouse ? "#124373" : "#0b2545")
                                    border.color: extModalRoot.selectedMode === "Discharge Circulation" ? "#00d2ff" : (p2Mouse.containsMouse ? "#3b82f6" : "#1e40af")
                                    border.width: extModalRoot.selectedMode === "Discharge Circulation" ? 2.5 : 1.5
                                    radius: 10

                                    ScadaIcon {
                                        anchors.centerIn: parent
                                        iconName: "ext_discharge_circulation"
                                        width: 80
                                        height: 80
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
                                        visible: extModalRoot.selectedMode === "Discharge Circulation"
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
                                        id: p2Mouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: extModalRoot.selectedMode = "Discharge Circulation"
                                    }
                                }

                                Text {
                                    text: "Recirculation Loop"
                                    color: "#94a3b8"
                                    font.pixelSize: 10
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }
                }

                // =============================================================
                // CATEGORY 2: CIP OPERATIONS (Teal Theme - 3 Cards)
                // =============================================================
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: "#042330"
                    border.color: "#0e7490"
                    border.width: 1.5
                    radius: 10

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 10

                        // Category Header Badge
                        Rectangle {
                            Layout.fillWidth: true
                            height: 28
                            color: "#155e75"
                            radius: 6
                            Text {
                                anchors.centerIn: parent
                                text: "CIP OPERATIONS"
                                color: "#22d3ee"
                                font.bold: true
                                font.pixelSize: 11
                            }
                        }

                        // 3 Columns of Selection Cards
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            spacing: 12
                            Layout.alignment: Qt.AlignHCenter

                            // Option 3: CIP Rinse
                            ColumnLayout {
                                Layout.preferredWidth: 110
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 6

                                Text {
                                    text: "CIP\nRinse"
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 12
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Rectangle {
                                    Layout.preferredWidth: 110
                                    Layout.preferredHeight: 110
                                    color: extModalRoot.selectedMode === "CIP Rinse" ? "#0891b2" : (c1Mouse.containsMouse ? "#0c4a5e" : "#072a38")
                                    border.color: extModalRoot.selectedMode === "CIP Rinse" ? "#00d2ff" : (c1Mouse.containsMouse ? "#22d3ee" : "#164e63")
                                    border.width: extModalRoot.selectedMode === "CIP Rinse" ? 2.5 : 1.5
                                    radius: 10

                                    ScadaIcon {
                                        anchors.centerIn: parent
                                        iconName: "ext_cip_rinse"
                                        width: 80
                                        height: 80
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
                                        visible: extModalRoot.selectedMode === "CIP Rinse"
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
                                        id: c1Mouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: extModalRoot.selectedMode = "CIP Rinse"
                                    }
                                }

                                Text {
                                    text: "Water Flush"
                                    color: "#94a3b8"
                                    font.pixelSize: 10
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }

                            // Option 4: CIP Discharge
                            ColumnLayout {
                                Layout.preferredWidth: 110
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 6

                                Text {
                                    text: "CIP\nDischarge"
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 12
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Rectangle {
                                    Layout.preferredWidth: 110
                                    Layout.preferredHeight: 110
                                    color: extModalRoot.selectedMode === "CIP Discharge" ? "#0891b2" : (c2Mouse.containsMouse ? "#0c4a5e" : "#072a38")
                                    border.color: extModalRoot.selectedMode === "CIP Discharge" ? "#00d2ff" : (c2Mouse.containsMouse ? "#22d3ee" : "#164e63")
                                    border.width: extModalRoot.selectedMode === "CIP Discharge" ? 2.5 : 1.5
                                    radius: 10

                                    ScadaIcon {
                                        anchors.centerIn: parent
                                        iconName: "ext_cip_discharge"
                                        width: 80
                                        height: 80
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
                                        visible: extModalRoot.selectedMode === "CIP Discharge"
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
                                        id: c2Mouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: extModalRoot.selectedMode = "CIP Discharge"
                                    }
                                }

                                Text {
                                    text: "Drain Discharge"
                                    color: "#94a3b8"
                                    font.pixelSize: 10
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }

                            // Option 5: CIP Drying
                            ColumnLayout {
                                Layout.preferredWidth: 110
                                Layout.alignment: Qt.AlignHCenter
                                spacing: 6

                                Text {
                                    text: "CIP\nDrying"
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 12
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.alignment: Qt.AlignHCenter
                                }

                                Rectangle {
                                    Layout.preferredWidth: 110
                                    Layout.preferredHeight: 110
                                    color: extModalRoot.selectedMode === "CIP Drying" ? "#0891b2" : (c3Mouse.containsMouse ? "#0c4a5e" : "#072a38")
                                    border.color: extModalRoot.selectedMode === "CIP Drying" ? "#00d2ff" : (c3Mouse.containsMouse ? "#22d3ee" : "#164e63")
                                    border.width: extModalRoot.selectedMode === "CIP Drying" ? 2.5 : 1.5
                                    radius: 10

                                    ScadaIcon {
                                        anchors.centerIn: parent
                                        iconName: "ext_cip_drying"
                                        width: 80
                                        height: 80
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
                                        visible: extModalRoot.selectedMode === "CIP Drying"
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
                                        id: c3Mouse
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: extModalRoot.selectedMode = "CIP Drying"
                                    }
                                }

                                Text {
                                    text: "Air Drying"
                                    color: "#94a3b8"
                                    font.pixelSize: 10
                                    horizontalAlignment: Text.AlignHCenter
                                    Layout.alignment: Qt.AlignHCenter
                                }
                            }
                        }
                    }
                }
            }

            // Action Buttons Row
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Rectangle {
                    Layout.preferredWidth: 180
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
                        onClicked: extModalRoot.closed()
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
                            var iconKey = "external_circulation";
                            if (extModalRoot.selectedMode === "Discharge Product") iconKey = "ext_discharge_product";
                            else if (extModalRoot.selectedMode === "Discharge Circulation") iconKey = "ext_discharge_circulation";
                            else if (extModalRoot.selectedMode === "CIP Rinse") iconKey = "ext_cip_rinse";
                            else if (extModalRoot.selectedMode === "CIP Discharge") iconKey = "ext_cip_discharge";
                            else if (extModalRoot.selectedMode === "CIP Drying") iconKey = "ext_cip_drying";

                            extModalRoot.modeApplied(iconKey, extModalRoot.selectedMode);
                            extModalRoot.closed();
                        }
                    }
                }
            }
        }
    }
}
