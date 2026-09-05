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

    property string currentMode: "agitator_cw"

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
                Text { text: "SELECT AGITATOR ROTATION MODE"; color: "#ffffff"; font.bold: true; font.pixelSize: 15 }
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

                // CW
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: modalRoot.currentMode === "agitator_cw" ? "#164e85" : (cwMouse.containsMouse ? "#124373" : "#0c345a")
                    border.color: modalRoot.currentMode === "agitator_cw" ? "#00d2ff" : (cwMouse.containsMouse ? "#3b82f6" : "#1d5b94")
                    border.width: modalRoot.currentMode === "agitator_cw" ? 2.5 : 1
                    radius: 8

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10
                        ScadaIcon { width: 52; height: 52; iconName: "agitator_cw"; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "Clockwise (CW)\nDown-Pumping"; color: "#ffffff"; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter }
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
                        visible: modalRoot.currentMode === "agitator_cw"
                        Image {
                            anchors.centerIn: parent
                            source: "../../../assets/icons/common/icon_check.svg"
                            width: 12
                            height: 12
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    MouseArea {
                        id: cwMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modalRoot.currentMode = "agitator_cw";
                            modalRoot.modeSelected("agitator_cw");
                            modalRoot.closed();
                        }
                    }
                }

                // CCW
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: modalRoot.currentMode === "agitator_ccw" ? "#164e85" : (ccwMouse.containsMouse ? "#124373" : "#0c345a")
                    border.color: modalRoot.currentMode === "agitator_ccw" ? "#00d2ff" : (ccwMouse.containsMouse ? "#3b82f6" : "#1d5b94")
                    border.width: modalRoot.currentMode === "agitator_ccw" ? 2.5 : 1
                    radius: 8

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10
                        ScadaIcon { iconName: "agitator_ccw"; width: 52; height: 52; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "Counter-CW (CCW)\nUp-Pumping"; color: "#ffffff"; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter }
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
                        visible: modalRoot.currentMode === "agitator_ccw"
                        Image {
                            anchors.centerIn: parent
                            source: "../../../assets/icons/common/icon_check.svg"
                            width: 12
                            height: 12
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    MouseArea {
                        id: ccwMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modalRoot.currentMode = "agitator_ccw";
                            modalRoot.modeSelected("agitator_ccw");
                            modalRoot.closed();
                        }
                    }
                }

                // Reversing
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: modalRoot.currentMode === "agitator_reversing" ? "#164e85" : (revMouse.containsMouse ? "#124373" : "#0c345a")
                    border.color: modalRoot.currentMode === "agitator_reversing" ? "#00d2ff" : (revMouse.containsMouse ? "#3b82f6" : "#1d5b94")
                    border.width: modalRoot.currentMode === "agitator_reversing" ? 2.5 : 1
                    radius: 8

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 10
                        ScadaIcon { iconName: "agitator_reversing"; width: 52; height: 52; Layout.alignment: Qt.AlignHCenter }
                        Text { text: "Reversing Cycle\n(Interval CW/CCW)"; color: "#ffffff"; font.bold: true; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter }
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
                        visible: modalRoot.currentMode === "agitator_reversing"
                        Image {
                            anchors.centerIn: parent
                            source: "../../../assets/icons/common/icon_check.svg"
                            width: 12
                            height: 12
                            fillMode: Image.PreserveAspectFit
                        }
                    }

                    MouseArea {
                        id: revMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            modalRoot.currentMode = "agitator_reversing";
                            modalRoot.modeSelected("agitator_reversing");
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
