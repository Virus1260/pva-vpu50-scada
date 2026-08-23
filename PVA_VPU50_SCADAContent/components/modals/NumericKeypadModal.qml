import QtQuick
import QtQuick.Layouts

Rectangle {
    id: keypadRoot
    implicitWidth: 1024
    implicitHeight: 600
    width: 1024
    height: 600
    color: "#95000000"

    property string title: "Parameter Setpoint"
    property string targetTag: "1M1501 Stirrer"
    property string unit: "rpm"
    property real minVal: 25.0
    property real maxVal: 120.0
    property string currentInput: "25.0"
    property bool isInputValid: true

    signal accepted(double value)
    signal rejected
    signal closed

    focus: true

    onVisibleChanged: {
        if (visible) {
            keypadRoot.forceActiveFocus();
        }
    }
    Component.onCompleted: {
        if (visible) {
            keypadRoot.forceActiveFocus();
        }
    }

    Keys.onPressed: function(event) {
        if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
            keypadRoot.appendDigit((event.key - Qt.Key_0).toString());
            event.accepted = true;
        } else if (event.key === Qt.Key_Period) {
            keypadRoot.appendDot();
            event.accepted = true;
        } else if (event.key === Qt.Key_Minus) {
            keypadRoot.toggleMinus();
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            keypadRoot.submitValue();
            event.accepted = true;
        } else if (event.key === Qt.Key_Backspace) {
            keypadRoot.backspace();
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape) {
            keypadRoot.rejected();
            keypadRoot.closed();
            event.accepted = true;
        } else if (event.key === Qt.Key_Delete) {
            keypadRoot.clear();
            event.accepted = true;
        }
    }

    MouseArea {
        anchors.fill: parent
    }

    // Modal Card Container (Scalable for Full-Screen)
    Rectangle {
        id: modalBox
        anchors.centerIn: parent
        width: 360
        height: 480
        color: "#0b2e52"
        border.color: "#1d5b94"
        border.width: 2
        radius: 6

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 8

            // 1. Top Title Bar & Close
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: keypadRoot.targetTag + " " + keypadRoot.title
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 13
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Rectangle {
                    Layout.preferredWidth: 26
                    Layout.preferredHeight: 26
                    radius: 3
                    color: "#0d365e"
                    border.color: "#1d5b94"
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: "#8cb5dc"
                        font.bold: true
                        font.pixelSize: 12
                    }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            keypadRoot.rejected();
                            keypadRoot.closed();
                        }
                    }
                }
            }

            // 2. Authentic EKATO Light-Blue / White Input Display (Image 3)
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                color: "#e6f2fa"
                border.color: keypadRoot.isInputValid ? "#286aa8" : "#ff4444"
                border.width: 2
                radius: 4

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 4

                    Text {
                        text: keypadRoot.currentInput === "" ? "0" : keypadRoot.currentInput
                        color: "#08213b"
                        font.bold: true
                        font.pixelSize: 26
                        Layout.fillWidth: true
                    }

                    Text {
                        text: keypadRoot.unit
                        color: "#4a749b"
                        font.bold: true
                        font.pixelSize: 15
                    }
                }
            }

            // 3. Range Limits Bar (Image 3: Min on Left, Max on Right)
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: keypadRoot.minVal.toFixed(1)
                    color: "#8cb5dc"
                    font.bold: true
                    font.pixelSize: 12
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    text: keypadRoot.isInputValid ? "" : "OUT OF RANGE"
                    color: "#ff5555"
                    font.bold: true
                    font.pixelSize: 10
                }
                Item {
                    Layout.fillWidth: true
                }
                Text {
                    text: keypadRoot.maxVal.toFixed(1)
                    color: "#8cb5dc"
                    font.bold: true
                    font.pixelSize: 12
                }
            }

            // 4. Authentic 4x4 Keypad Grid (Image 3 with Clear at Row 3)
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 4
                rowSpacing: 6
                columnSpacing: 6

                // Row 1: 7, 8, 9, Del
                KeypadButton {
                    text: "7"
                    onClicked: keypadRoot.appendDigit("7")
                }
                KeypadButton {
                    text: "8"
                    onClicked: keypadRoot.appendDigit("8")
                }
                KeypadButton {
                    text: "9"
                    onClicked: keypadRoot.appendDigit("9")
                }
                KeypadButton {
                    text: "Del"
                    isAction: true
                    onClicked: keypadRoot.backspace()
                }

                // Row 2: 4, 5, 6, Esc
                KeypadButton {
                    text: "4"
                    onClicked: keypadRoot.appendDigit("4")
                }
                KeypadButton {
                    text: "5"
                    onClicked: keypadRoot.appendDigit("5")
                }
                KeypadButton {
                    text: "6"
                    onClicked: keypadRoot.appendDigit("6")
                }
                KeypadButton {
                    text: "Esc"
                    isAction: true
                    onClicked: {
                        keypadRoot.rejected();
                        keypadRoot.closed();
                    }
                }

                // Row 3: 1, 2, 3, Clear
                KeypadButton {
                    text: "1"
                    onClicked: keypadRoot.appendDigit("1")
                }
                KeypadButton {
                    text: "2"
                    onClicked: keypadRoot.appendDigit("2")
                }
                KeypadButton {
                    text: "3"
                    onClicked: keypadRoot.appendDigit("3")
                }
                KeypadButton {
                    text: "Clear"
                    isAction: true
                    onClicked: keypadRoot.clear()
                }

                // Row 4: 0, ., −, OK
                KeypadButton {
                    text: "0"
                    onClicked: keypadRoot.appendDigit("0")
                }
                KeypadButton {
                    text: "."
                    onClicked: keypadRoot.appendDot()
                }
                KeypadButton {
                    text: "−"
                    isAction: true
                    onClicked: keypadRoot.toggleMinus()
                }
                KeypadButton {
                    text: "OK"
                    isOk: true
                    onClicked: keypadRoot.submitValue()
                }
            }
        }
    }

    // Helper Functions for Keypad Logic & Validation
    function appendDigit(digit) {
        if (currentInput === "0" || currentInput === "") {
            currentInput = digit;
        } else {
            currentInput += digit;
        }
        validateInput();
    }

    function appendDot() {
        if (currentInput.indexOf(".") === -1) {
            currentInput = (currentInput === "" ? "0." : currentInput + ".");
        }
        validateInput();
    }

    function backspace() {
        if (currentInput.length > 0) {
            currentInput = currentInput.substring(0, currentInput.length - 1);
        }
        validateInput();
    }

    function clear() {
        currentInput = "0";
        validateInput();
    }

    function toggleMinus() {
        if (currentInput.startsWith("-")) {
            currentInput = currentInput.substring(1);
        } else {
            currentInput = "-" + currentInput;
        }
        validateInput();
    }

    function validateInput() {
        var num = parseFloat(currentInput);
        if (isNaN(num)) {
            isInputValid = true;
            return;
        }
        isInputValid = (num >= minVal && num <= maxVal);
    }

    function submitValue() {
        var val = parseFloat(currentInput);
        if (isNaN(val)) {
            rejected();
            closed();
            return;
        }
        // Strict industrial boundary clamping
        val = Math.max(minVal, Math.min(maxVal, val));
        accepted(val);
        closed();
    }

    // Internal Custom Keypad Button Component
    component KeypadButton: Rectangle {
        id: kBtn
        property string text: ""
        property bool isOk: false
        property bool isAction: false
        signal clicked

        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitWidth: 64
        implicitHeight: 52
        radius: 4

        color: kBtn.isOk ? "#8ee62c" : (btnMouse.pressed ? "#d0e2f2" : "#ffffff")
        border.color: kBtn.isOk ? "#ffffff" : (btnMouse.containsMouse ? "#3892e6" : "#b0cce6")
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: kBtn.text
            color: "#08213b"
            font.bold: true
            font.pixelSize: kBtn.isOk ? 16 : (kBtn.isAction ? 13 : 20)
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: kBtn.clicked()
        }
    }
}
