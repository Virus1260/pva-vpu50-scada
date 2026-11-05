import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: modalRoot
    implicitWidth: 1024
    implicitHeight: 600
    width: 1024
    height: 600
    color: "#95000000"

    property bool isAuto: true
    property string activeMode: "PRODUCTION"

    signal modeSelected(string mode)
    signal autoToggled(bool isAuto)
    signal closed()

    MouseArea {
        anchors.fill: parent
    }

    Rectangle {
        id: modalBox
        anchors.centerIn: parent
        width: Math.max(420, Math.min(parent.width * 0.44, 520))
        height: Math.max(360, Math.min(parent.height * 0.65, 460))
        color: "#08213b"
        border.color: "#184d7e"
        border.width: 2
        radius: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 12

            // Header Bar
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Plantmode"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 18
                }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 28
                    height: 28
                    radius: 4
                    color: "#0d365e"
                    border.color: "#1d5b94"
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 14
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modalRoot.closed()
                    }
                }
            }

            // Subtitle Tag
            Text {
                text: "B1 - VPU 50"
                color: "#8cb5dc"
                font.bold: true
                font.pixelSize: 13
                Layout.alignment: Qt.AlignHCenter
            }

            // 2x2 Grid of Plantmode Options
            GridLayout {
                columns: 2
                rows: 2
                Layout.fillWidth: true
                Layout.fillHeight: true
                columnSpacing: 14
                rowSpacing: 14

                // 1. Automatic / Manual Tile
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: modalRoot.isAuto ? "#0f3a64" : "#2a2412"
                    border.color: modalRoot.isAuto ? "#00d2ff" : "#f5d033"
                    border.width: 2.5
                    radius: 8

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: modalRoot.isAuto ? "Automatic" : "Manual"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 13
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Rectangle {
                            width: 48
                            height: 48
                            radius: 24
                            color: modalRoot.isAuto ? "#78dc20" : "#f5d033"
                            Text {
                                anchors.centerIn: parent
                                text: modalRoot.isAuto ? "(A)" : "(M)"
                                color: "#000000"
                                font.bold: true
                                font.pixelSize: 18
                            }
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
                        Image {
                            anchors.centerIn: parent
                            source: "../../assets/icons/common/icon_check.svg"
                            width: 12
                            height: 12
                            sourceSize: Qt.size(12, 12)
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modalRoot.isAuto = !modalRoot.isAuto;
                            modalRoot.autoToggled(modalRoot.isAuto);
                            modalRoot.closed();
                        }
                    }
                }

                // 2. External Circulation Tile
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: modalRoot.activeMode === "CIRCULATION" ? "#164e85" : (rMouse.containsMouse ? "#124373" : "#082646")
                    border.color: modalRoot.activeMode === "CIRCULATION" ? "#00d2ff" : (rMouse.containsMouse ? "#3b82f6" : "#1d5b94")
                    border.width: modalRoot.activeMode === "CIRCULATION" ? 2.5 : 1
                    radius: 8

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: "Circulation"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 13
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Image {
                            width: 40
                            height: 40
                            source: "../../assets/icons/modes/plant/external_circulation.svg"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
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
                        visible: modalRoot.activeMode === "CIRCULATION"
                        Image {
                            anchors.centerIn: parent
                            source: "../../assets/icons/common/icon_check.svg"
                            width: 12
                            height: 12
                            sourceSize: Qt.size(12, 12)
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    MouseArea {
                        id: rMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modalRoot.activeMode = "CIRCULATION";
                            modalRoot.modeSelected("CIRCULATION");
                            modalRoot.closed();
                        }
                    }
                }

                // 3. CIP Tile (Clean In Place)
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: modalRoot.activeMode === "CIP" ? "#164e85" : (cipMouse.containsMouse ? "#124373" : "#082646")
                    border.color: modalRoot.activeMode === "CIP" ? "#00d2ff" : (cipMouse.containsMouse ? "#3b82f6" : "#1d5b94")
                    border.width: modalRoot.activeMode === "CIP" ? 2.5 : 1
                    radius: 8

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: "CIP"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 13
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Image {
                            width: 40
                            height: 40
                            source: "../../assets/icons/modes/plant/external_circulation.svg"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
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
                        visible: modalRoot.activeMode === "CIP"
                        Image {
                            anchors.centerIn: parent
                            source: "../../assets/icons/common/icon_check.svg"
                            width: 12
                            height: 12
                            sourceSize: Qt.size(12, 12)
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    MouseArea {
                        id: cipMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modalRoot.activeMode = "CIP";
                            modalRoot.modeSelected("CIP");
                            modalRoot.closed();
                        }
                    }
                }

                // 4. Production Tile
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: modalRoot.activeMode === "PRODUCTION" ? "#164e85" : (prodMouse.containsMouse ? "#124373" : "#082646")
                    border.color: modalRoot.activeMode === "PRODUCTION" ? "#00d2ff" : (prodMouse.containsMouse ? "#3b82f6" : "#1d5b94")
                    border.width: modalRoot.activeMode === "PRODUCTION" ? 2.5 : 1
                    radius: 8

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        Text {
                            text: "Production"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 13
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Image {
                            width: 40
                            height: 40
                            source: "../../assets/icons/nav/tools_maintenance.svg"
                            fillMode: Image.PreserveAspectFit
                            mipmap: true
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
                        visible: modalRoot.activeMode === "PRODUCTION"
                        Image {
                            anchors.centerIn: parent
                            source: "../../assets/icons/common/icon_check.svg"
                            width: 12
                            height: 12
                            sourceSize: Qt.size(12, 12)
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    MouseArea {
                        id: prodMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modalRoot.activeMode = "PRODUCTION";
                            modalRoot.modeSelected("PRODUCTION");
                            modalRoot.closed();
                        }
                    }
                }
            }
        }
    }
}
