/*
This is a UI file (.ui.qml) for SCADA Full-Size QWERTY Text Keyboard.
Strictly declarative for Qt Design Studio 2D visual editor.
*/

import QtQuick
import QtQuick.Layouts

Rectangle {
    id: textKeyboardViewRoot
    implicitWidth: 800
    implicitHeight: 380
    width: implicitWidth
    height: implicitHeight
    color: "#0b2e52"
    border.color: "#38bdf8"
    border.width: 2
    radius: 8
    clip: true

    property string titleText: "Text Input Keyboard"
    property string displayText: ""
    property bool isShift: false
    property string shiftLabel: "▲ Shift"
    property bool isShiftActive: false
    property bool isCapsLock: false
    property string physicalActiveKey: ""

    property alias headerDragArea: dragArea
    property alias dockBtn: dockBMouse
    property alias closeBtn: closeVkMouse

    // Key aliases
    property alias k1: key1; property alias k2: key2; property alias k3: key3; property alias k4: key4
    property alias k5: key5; property alias k6: key6; property alias k7: key7; property alias k8: key8
    property alias k9: key9; property alias k0: key0; property alias kMinus: keyMinus; property alias kPlus: keyPlus; property alias kDel: keyDel

    property alias kQ: keyQ; property alias kW: keyW; property alias kE: keyE; property alias kR: keyR
    property alias kT: keyT; property alias kY: keyY; property alias kU: keyU; property alias kI: keyI
    property alias kO: keyO; property alias kP: keyP; property alias kOpenParen: keyOpenParen; property alias kCloseParen: keyCloseParen; property alias kClear: keyClear

    property alias kA: keyA; property alias kS: keyS; property alias kD: keyD; property alias kF: keyF
    property alias kG: keyG; property alias kH: keyH; property alias kJ: keyJ; property alias kK: keyK
    property alias kL: keyL; property alias kColon: keyColon; property alias kSlash: keySlash; property alias kPercent: keyPercent; property alias kEsc: keyEsc

    property alias kShift: keyShift
    property alias kZ: keyZ; property alias kX: keyX; property alias kC: keyC; property alias kV: keyV
    property alias kB: keyB; property alias kN: keyN; property alias kM: keyM; property alias kComma: keyComma; property alias kDot: keyDot
    property alias kQuestion: keyQuestion; property alias kExclamation: keyExclamation

    property alias kAt: keyAt; property alias kUnderscore: keyUnderscore; property alias kQuote: keyQuote
    property alias kSpace: keySpace; property alias kAmp: keyAmp; property alias kHash: keyHash; property alias kEquals: keyEquals
    property alias kOk: keyOk

    // Prevent background click-through
    MouseArea {
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 6

        // =====================================================================
        // 1. DRAGGABLE TITLE BAR WITH CRISP VECTOR ICONS
        // =====================================================================
        Rectangle {
            id: headerBar
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

                // Crisp 6-Dot Matrix Handle
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
                    text: textKeyboardViewRoot.titleText + "  •  DRAG TO MOVE"
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
        // 2. LIVE TEXT PREVIEW STRIP (#e6f2fa)
        // =====================================================================
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            color: "#e6f2fa"
            border.color: "#286aa8"
            border.width: 1
            radius: 4

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10

                Text {
                    id: previewTxt
                    text: (textKeyboardViewRoot.displayText === "" ? "Type text here..." : textKeyboardViewRoot.displayText) + "▎"
                    color: textKeyboardViewRoot.displayText === "" ? "#718da6" : "#08213b"
                    font.pixelSize: 14
                    font.bold: true
                    font.family: "Segoe UI"
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }
        }

        // =====================================================================
        // 3. ROW 1: Numbers & Math Signs & Del (13 keys total)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            ScadaKeyboardKey { id: key1; text: "1"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "1" }
            ScadaKeyboardKey { id: key2; text: "2"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "2" }
            ScadaKeyboardKey { id: key3; text: "3"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "3" }
            ScadaKeyboardKey { id: key4; text: "4"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "4" }
            ScadaKeyboardKey { id: key5; text: "5"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "5" }
            ScadaKeyboardKey { id: key6; text: "6"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "6" }
            ScadaKeyboardKey { id: key7; text: "7"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "7" }
            ScadaKeyboardKey { id: key8; text: "8"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "8" }
            ScadaKeyboardKey { id: key9; text: "9"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "9" }
            ScadaKeyboardKey { id: key0; text: "0"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "0" }
            ScadaKeyboardKey { id: keyMinus; text: "-"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "-" }
            ScadaKeyboardKey { id: keyPlus; text: "+"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "+" }
            ScadaKeyboardKey { id: keyDel; text: "Del"; isAction: true; Layout.preferredWidth: 64; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "BACKSPACE" }
        }

        // =====================================================================
        // 4. ROW 2: QWERTY Top Letters & Parentheses & Clear (13 keys total)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            ScadaKeyboardKey { id: keyQ; text: textKeyboardViewRoot.isShift ? "Q" : "q"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "Q" }
            ScadaKeyboardKey { id: keyW; text: textKeyboardViewRoot.isShift ? "W" : "w"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "W" }
            ScadaKeyboardKey { id: keyE; text: textKeyboardViewRoot.isShift ? "E" : "e"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "E" }
            ScadaKeyboardKey { id: keyR; text: textKeyboardViewRoot.isShift ? "R" : "r"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "R" }
            ScadaKeyboardKey { id: keyT; text: textKeyboardViewRoot.isShift ? "T" : "t"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "T" }
            ScadaKeyboardKey { id: keyY; text: textKeyboardViewRoot.isShift ? "Y" : "y"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "Y" }
            ScadaKeyboardKey { id: keyU; text: textKeyboardViewRoot.isShift ? "U" : "u"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "U" }
            ScadaKeyboardKey { id: keyI; text: textKeyboardViewRoot.isShift ? "I" : "i"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "I" }
            ScadaKeyboardKey { id: keyO; text: textKeyboardViewRoot.isShift ? "O" : "o"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "O" }
            ScadaKeyboardKey { id: keyP; text: textKeyboardViewRoot.isShift ? "P" : "p"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "P" }
            ScadaKeyboardKey { id: keyOpenParen; text: "("; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "(" }
            ScadaKeyboardKey { id: keyCloseParen; text: ")"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === ")" }
            ScadaKeyboardKey { id: keyClear; text: "Clear"; isAction: true; Layout.preferredWidth: 64; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "DELETE" }
        }

        // =====================================================================
        // 5. ROW 3: Middle Letters & Punctuation & Esc (13 keys total)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            ScadaKeyboardKey { id: keyA; text: textKeyboardViewRoot.isShift ? "A" : "a"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "A" }
            ScadaKeyboardKey { id: keyS; text: textKeyboardViewRoot.isShift ? "S" : "s"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "S" }
            ScadaKeyboardKey { id: keyD; text: textKeyboardViewRoot.isShift ? "D" : "d"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "D" }
            ScadaKeyboardKey { id: keyF; text: textKeyboardViewRoot.isShift ? "F" : "f"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "F" }
            ScadaKeyboardKey { id: keyG; text: textKeyboardViewRoot.isShift ? "G" : "g"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "G" }
            ScadaKeyboardKey { id: keyH; text: textKeyboardViewRoot.isShift ? "H" : "h"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "H" }
            ScadaKeyboardKey { id: keyJ; text: textKeyboardViewRoot.isShift ? "J" : "j"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "J" }
            ScadaKeyboardKey { id: keyK; text: textKeyboardViewRoot.isShift ? "K" : "k"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "K" }
            ScadaKeyboardKey { id: keyL; text: textKeyboardViewRoot.isShift ? "L" : "l"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "L" }
            ScadaKeyboardKey { id: keyColon; text: ":"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === ":" }
            ScadaKeyboardKey { id: keySlash; text: "/"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "/" }
            ScadaKeyboardKey { id: keyPercent; text: "%"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "%" }
            ScadaKeyboardKey { id: keyEsc; text: "Esc"; isAction: true; Layout.preferredWidth: 64; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "ESCAPE" }
        }

        // =====================================================================
        // 6. ROW 4: Shift & Bottom Letters & Punctuation (12 keys total)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            // Dynamic Shift / Caps Lock Key with 3D Tactile Depression & LED Indicator
            Item {
                id: keyShift
                Layout.preferredWidth: 84
                Layout.fillHeight: true
                implicitHeight: 46
                property alias mouseArea: shiftMouse
                readonly property bool isDepressed: shiftMouse.pressed || (textKeyboardViewRoot.physicalActiveKey === "SHIFT")

                // 1. Socket Base
                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: textKeyboardViewRoot.isShiftActive ? "#024a73" : "#87a7c4"
                }

                // 2. Depressing Keycap
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.topMargin: keyShift.isDepressed ? 3 : 0
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: keyShift.isDepressed ? 0 : 3
                    radius: 5

                    Behavior on anchors.topMargin { NumberAnimation { duration: 60; easing.type: Easing.OutQuad } }
                    Behavior on anchors.bottomMargin { NumberAnimation { duration: 60; easing.type: Easing.OutQuad } }
                    Behavior on color { ColorAnimation { duration: 70 } }
                    Behavior on border.color { ColorAnimation { duration: 70 } }

                    color: textKeyboardViewRoot.isShiftActive
                           ? (keyShift.isDepressed ? "#0369a1" : (shiftMouse.containsMouse ? "#0ea5e9" : "#0284c7"))
                           : (keyShift.isDepressed ? "#a3c5e3" : (shiftMouse.containsMouse ? "#e5f0fa" : "#d8e6f3"))
                    border.color: textKeyboardViewRoot.isShiftActive ? "#38bdf8" : (shiftMouse.containsMouse ? "#38bdf8" : "#9bbddc")
                    border.width: textKeyboardViewRoot.isShiftActive ? 2 : 1

                    // Top Bevel
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 1
                        height: 2
                        radius: 4
                        color: textKeyboardViewRoot.isShiftActive ? "#7dd3fc" : "#ffffff"
                        opacity: keyShift.isDepressed ? 0.2 : 0.6
                    }

                    // Active Tap Glow
                    Rectangle {
                        anchors.fill: parent
                        radius: 4
                        color: "#38bdf8"
                        opacity: keyShift.isDepressed ? 0.35 : (shiftMouse.containsMouse ? 0.08 : 0.0)
                        Behavior on opacity { NumberAnimation { duration: 90 } }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: keyShift.isDepressed ? 1 : 0
                        spacing: 5

                        // Caps Lock Green LED Dot
                        Rectangle {
                            visible: textKeyboardViewRoot.isCapsLock
                            Layout.preferredWidth: 6
                            Layout.preferredHeight: 6
                            radius: 3
                            color: "#22c55e"
                        }
                        Text {
                            text: textKeyboardViewRoot.shiftLabel
                            color: textKeyboardViewRoot.isShiftActive ? "#ffffff" : "#08213b"
                            font.bold: true
                            font.pixelSize: 12
                            font.family: "Segoe UI"
                        }
                        Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 60 } }
                    }
                }

                MouseArea {
                    id: shiftMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }

            ScadaKeyboardKey { id: keyZ; text: textKeyboardViewRoot.isShift ? "Z" : "z"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "Z" }
            ScadaKeyboardKey { id: keyX; text: textKeyboardViewRoot.isShift ? "X" : "x"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "X" }
            ScadaKeyboardKey { id: keyC; text: textKeyboardViewRoot.isShift ? "C" : "c"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "C" }
            ScadaKeyboardKey { id: keyV; text: textKeyboardViewRoot.isShift ? "V" : "v"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "V" }
            ScadaKeyboardKey { id: keyB; text: textKeyboardViewRoot.isShift ? "B" : "b"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "B" }
            ScadaKeyboardKey { id: keyN; text: textKeyboardViewRoot.isShift ? "N" : "n"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "N" }
            ScadaKeyboardKey { id: keyM; text: textKeyboardViewRoot.isShift ? "M" : "m"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "M" }
            ScadaKeyboardKey { id: keyComma; text: ","; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "," }
            ScadaKeyboardKey { id: keyDot; text: "."; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "." }
            ScadaKeyboardKey { id: keyQuestion; text: "?"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "?" }
            ScadaKeyboardKey { id: keyExclamation; text: "!"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "!" }
        }

        // =====================================================================
        // 7. ROW 5: Special Symbols & Spacebar & Single Green OK Button (8 keys total)
        // =====================================================================
        RowLayout {
            Layout.fillWidth: true
            spacing: 5

            ScadaKeyboardKey { id: keyAt; text: "@"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "@" }
            ScadaKeyboardKey { id: keyUnderscore; text: "_"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "_" }
            ScadaKeyboardKey { id: keyQuote; text: "\""; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "\"" }
            ScadaKeyboardKey { id: keySpace; text: "SPACE"; Layout.preferredWidth: 260; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "SPACE" }
            ScadaKeyboardKey { id: keyAmp; text: "&"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "&" }
            ScadaKeyboardKey { id: keyHash; text: "#"; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "#" }
            ScadaKeyboardKey { id: keyEquals; text: "="; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "=" }
            ScadaKeyboardKey { id: keyOk; text: "OK"; isOk: true; Layout.preferredWidth: 100; isPhysicalPressed: textKeyboardViewRoot.physicalActiveKey === "ENTER" }
        }
    }
}
