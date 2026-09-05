import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../common"

Rectangle {
    id: modalRoot
    implicitWidth: 1024
    implicitHeight: 600
    width: 1024
    height: 600
    color: "#95000000"

    property string currentMode: "homo_permanent"

    signal modeSelected(string mode)
    signal closed()

    MouseArea { anchors.fill: parent }

    Rectangle {
        id: modalBox
        anchors.centerIn: parent
        width: Math.max(440, Math.min(parent.width * 0.50, 580))
        height: Math.max(300, Math.min(parent.height * 0.55, 380))
        color: "#08213b"
        border.color: "#184d7e"
        border.width: 2
        radius: 8

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                Text { text: "SELECT HOMOGENIZER RUN MODE"; color: "#ffffff"; font.bold: true; font.pixelSize: 15 }
                Item { Layout.fillWidth: true }
                Rectangle {
                    width: 28
                    height: 28
                    radius: 4
                    color: "#0d365e"
                    border.color: "#1d5b94"
                    border.width: 1
                    Text { anchors.centerIn: parent; text: "✕"; color: "#ffffff"; font.bold: true; font.pixelSize: 14 }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: modalRoot.closed()
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 14

                // Permanent
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: modalRoot.currentMode === "homo_permanent" ? "#164e85" : (permMouse.containsMouse ? "#124373" : "#0c345a")
                    border.color: modalRoot.currentMode === "homo_permanent" ? "#00d2ff" : (permMouse.containsMouse ? "#3b82f6" : "#1d5b94")
                    border.width: modalRoot.currentMode === "homo_permanent" ? 2.5 : 1
                    radius: 8

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10
                        ScadaIcon { iconName: "homo_permanent"; width: 52; height: 52; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "Permanent\nContinuous Run"; color: "#ffffff"; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter }
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
                        visible: modalRoot.currentMode === "homo_permanent"
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
                        id: permMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modalRoot.currentMode = "homo_permanent";
                            modalRoot.modeSelected("homo_permanent");
                            modalRoot.closed();
                        }
                    }
                }

                // Interval
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: modalRoot.currentMode === "homo_interval" ? "#164e85" : (intMouse.containsMouse ? "#124373" : "#0c345a")
                    border.color: modalRoot.currentMode === "homo_interval" ? "#00d2ff" : (intMouse.containsMouse ? "#3b82f6" : "#1d5b94")
                    border.width: modalRoot.currentMode === "homo_interval" ? 2.5 : 1
                    radius: 8

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10
                        ScadaIcon { iconName: "homo_interval"; width: 52; height: 52; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "Interval Pulse\n(Timer ON/OFF)"; color: "#ffffff"; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter }
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
                        visible: modalRoot.currentMode === "homo_interval"
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
                        id: intMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modalRoot.currentMode = "homo_interval";
                            modalRoot.modeSelected("homo_interval");
                            modalRoot.closed();
                        }
                    }
                }

                // Internal Loop
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: modalRoot.currentMode === "homogenizer" ? "#164e85" : (loopMouse.containsMouse ? "#124373" : "#0c345a")
                    border.color: modalRoot.currentMode === "homogenizer" ? "#00d2ff" : (loopMouse.containsMouse ? "#3b82f6" : "#1d5b94")
                    border.width: modalRoot.currentMode === "homogenizer" ? 2.5 : 1
                    radius: 8

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10
                        ScadaIcon { iconName: "homogenizer"; width: 52; height: 52; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "Internal Vessel\nRecirculation"; color: "#ffffff"; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter }
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
                        visible: modalRoot.currentMode === "homogenizer"
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
                        id: loopMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modalRoot.currentMode = "homogenizer";
                            modalRoot.modeSelected("homogenizer");
                            modalRoot.closed();
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                radius: 4
                color: "#0d365e"
                border.color: "#1d5b94"
                border.width: 1
                Text { anchors.centerIn: parent; text: "Cancel"; color: "#8cb5dc"; font.bold: true; font.pixelSize: 12 }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modalRoot.closed()
                }
            }
        }
    }
}
