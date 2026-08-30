/*
This is a UI file (.ui.qml) for SCADA Numeric-Only Keypad (Value Putter).
Strictly declarative for Qt Design Studio 2D visual editor.
*/

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: numpadViewRoot
    implicitWidth: 360
    implicitHeight: 480
    width: implicitWidth
    height: implicitHeight
    color: "#0b2e52"
    border.color: "#38bdf8"
    border.width: 2
    radius: 8
    clip: true

    property string titleText: "Numeric Value Input"
    property string displayText: "0"
    property string unitText: ""

    property alias headerDragArea: dragArea
    property alias dockBtn: dockBMouse
    property alias closeBtn: closeVkMouse

    property alias btn7: k7
    property alias btn8: k8
    property alias btn9: k9
    property alias btnDel: kDel

    property alias btn4: k4
    property alias btn5: k5
    property alias btn6: k6
    property alias btnEsc: kEsc

    property alias btn1: k1
    property alias btn2: k2
    property alias btn3: k3
    property alias btnClear: kClear

    property alias btn0: k0
    property alias btnDot: kDot
    property alias btnMinus: kMinus
    property alias btnOk: kOk

    // Prevent background click-through
    MouseArea {
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // =====================================================================
        // 1. DRAGGABLE TOP HEADER BAR WITH CRISP VECTOR ICONS
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            color: "#08213b"
            radius: 5
            border.color: dragArea.containsMouse ? "#38bdf8" : "#1d5b94"
            border.width: 1

            MouseArea {
                id: dragArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.SizeAllCursor
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 6
                spacing: 8

                // Crisp 6-Dot Tactile Grip Handle
                Row {
                    spacing: 3
                    Column {
                        spacing: 3
                        Rectangle { width: 3; height: 3; radius: 1.5; color: dragArea.containsMouse ? "#38bdf8" : "#7dd3fc" }
                        Rectangle { width: 3; height: 3; radius: 1.5; color: dragArea.containsMouse ? "#38bdf8" : "#7dd3fc" }
                        Rectangle { width: 3; height: 3; radius: 1.5; color: dragArea.containsMouse ? "#38bdf8" : "#7dd3fc" }
                    }
                    Column {
                        spacing: 3
                        Rectangle { width: 3; height: 3; radius: 1.5; color: dragArea.containsMouse ? "#38bdf8" : "#7dd3fc" }
                        Rectangle { width: 3; height: 3; radius: 1.5; color: dragArea.containsMouse ? "#38bdf8" : "#7dd3fc" }
                        Rectangle { width: 3; height: 3; radius: 1.5; color: dragArea.containsMouse ? "#38bdf8" : "#7dd3fc" }
                    }
                }

                Text {
                    text: numpadViewRoot.titleText + "  •  DRAG TO MOVE"
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 12
                    font.family: "Segoe UI"
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                // Interactive Dock Down Button
                Rectangle {
                    z: 10
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 26
                    radius: 4
                    color: dockBMouse.pressed ? "#0284c7" : (dockBMouse.containsMouse ? "#0f4273" : "#0d365e")
                    border.color: dockBMouse.containsMouse ? "#38bdf8" : "#1d5b94"
                    border.width: 1

                    Column {
                        anchors.centerIn: parent
                        spacing: 2
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "▼"
                            color: dockBMouse.containsMouse ? "#38bdf8" : "#94a3b8"
                            font.pixelSize: 9
                        }
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            width: 10
                            height: 2
                            radius: 1
                            color: dockBMouse.containsMouse ? "#38bdf8" : "#94a3b8"
                        }
                    }

                    MouseArea {
                        id: dockBMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }

                // Interactive Close Button
                Rectangle {
                    z: 10
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 26
                    radius: 4
                    color: closeVkMouse.pressed ? "#dc2626" : (closeVkMouse.containsMouse ? "#ef4444" : "#0d365e")
                    border.color: closeVkMouse.containsMouse ? "#fca5a5" : "#1d5b94"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: closeVkMouse.containsMouse ? "#ffffff" : "#94a3b8"
                        font.bold: true
                        font.pixelSize: 13
                        font.family: "Segoe UI"
                    }

                    MouseArea {
                        id: closeVkMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }
        }

        // =====================================================================
        // 2. VALUE DISPLAY BOX (#e6f2fa)
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            color: "#e6f2fa"
            border.color: "#286aa8"
            border.width: 2
            radius: 5

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 6

                Text {
                    text: numpadViewRoot.displayText + "▎"
                    color: "#08213b"
                    font.bold: true
                    font.pixelSize: 26
                    font.family: "Segoe UI"
                    Layout.fillWidth: true
                    elide: Text.ElideLeft
                }

                Text {
                    visible: numpadViewRoot.unitText !== ""
                    text: numpadViewRoot.unitText
                    color: "#4a749b"
                    font.bold: true
                    font.pixelSize: 15
                    font.family: "Segoe UI"
                }
            }
        }

        // =====================================================================
        // 3. 4x4 GRID LAYOUT WITH TACTILE BEVEL KEYS
        // =====================================================================
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 4
            rowSpacing: 6
            columnSpacing: 6

            // Row 1
            ScadaKeyboardKey { id: k7; text: "7" }
            ScadaKeyboardKey { id: k8; text: "8" }
            ScadaKeyboardKey { id: k9; text: "9" }
            ScadaKeyboardKey { id: kDel; text: "Del"; isAction: true }

            // Row 2
            ScadaKeyboardKey { id: k4; text: "4" }
            ScadaKeyboardKey { id: k5; text: "5" }
            ScadaKeyboardKey { id: k6; text: "6" }
            ScadaKeyboardKey { id: kEsc; text: "Esc"; isAction: true }

            // Row 3
            ScadaKeyboardKey { id: k1; text: "1" }
            ScadaKeyboardKey { id: k2; text: "2" }
            ScadaKeyboardKey { id: k3; text: "3" }
            ScadaKeyboardKey { id: kClear; text: "Clear"; isAction: true }

            // Row 4
            ScadaKeyboardKey { id: k0; text: "0" }
            ScadaKeyboardKey { id: kDot; text: "." }
            ScadaKeyboardKey { id: kMinus; text: "−"; isAction: true }
            ScadaKeyboardKey { id: kOk; text: "OK"; isOk: true }
        }
    }
}
