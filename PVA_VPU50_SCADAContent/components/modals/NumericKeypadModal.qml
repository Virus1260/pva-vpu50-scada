pragma ComponentBehavior: Bound
// @disable-check M203  -- JavaScript functions are required runtime logic; DS visual editor advisory only
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: keypadRoot
    implicitWidth: 1024
    implicitHeight: 600
    color: "#95000000"
    visible: false
    z: 9999

    property string title: "Parameter Setpoint"
    property string targetTag: "1M1501 Stirrer"
    property string unit: "rpm"
    property var minVal: null
    property var maxVal: null
    property bool hasRange: (minVal !== null && minVal !== undefined && maxVal !== null && maxVal !== undefined)
    property string currentInput: "25.0"
    property bool isInputValid: true
    property var targetInput: null
    property bool isDocked: false
    property string physicalPressedKey: ""
    property int maxDigits: 14
    property int selectionStart: 0
    property int selectionEnd: 0
    readonly property bool hasSelection: selectionEnd > selectionStart
    property string securityToastMessage: ""
    property bool securityToastVisible: false

    signal accepted(double value)
    signal rejected
    signal closed

    focus: true

    Timer {
        id: numSecurityTimer
        interval: 2600
        repeat: false
        onTriggered: keypadRoot.securityToastVisible = false
    }

    function showSecurityToast(msg) {
        keypadRoot.securityToastMessage = msg;
        keypadRoot.securityToastVisible = true;
        numSecurityTimer.restart();
    }

    Timer {
        id: keyReleaseTimer
        interval: 130
        repeat: false
        onTriggered: keypadRoot.physicalPressedKey = ""
    }

    function flashKey(k) {
        physicalPressedKey = k;
        keyReleaseTimer.restart();
    }

    onVisibleChanged: {
        if (visible) {
            keypadRoot.forceActiveFocus();
        }
    }

    Keys.onPressed: function(event) {
        if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_V) {
            keypadRoot.flashKey("PASTE");
            keypadRoot.handlePaste();
            event.accepted = true;
            return;
        }
        if (event.key >= Qt.Key_0 && event.key <= Qt.Key_9) {
            var digit = (event.key - Qt.Key_0).toString();
            keypadRoot.flashKey(digit);
            keypadRoot.appendDigit(digit);
            event.accepted = true;
        } else if (event.key === Qt.Key_Period) {
            keypadRoot.flashKey(".");
            keypadRoot.appendDot();
            event.accepted = true;
        } else if (event.key === Qt.Key_Minus) {
            keypadRoot.flashKey("−");
            keypadRoot.toggleMinus();
            event.accepted = true;
        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            keypadRoot.flashKey("OK");
            keypadRoot.submitValue();
            event.accepted = true;
        } else if (event.key === Qt.Key_Backspace) {
            keypadRoot.flashKey("Del");
            keypadRoot.backspace();
            event.accepted = true;
        } else if (event.key === Qt.Key_Escape) {
            keypadRoot.flashKey("Esc");
            keypadRoot.dismiss();
            event.accepted = true;
        } else if (event.key === Qt.Key_Delete) {
            keypadRoot.flashKey("Clear");
            keypadRoot.clear();
            event.accepted = true;
        }
    }

    Keys.onReleased: function(event) {
        keypadRoot.physicalPressedKey = "";
    }

    // Modal Background Click Dismiss
    MouseArea {
        anchors.fill: parent
        onClicked: keypadRoot.dismiss()
    }

    // Modal Card Container (Draggable & Dockable Value Putter)
    Rectangle {
        id: modalBox
        width: 360
        height: keypadRoot.hasRange ? 480 : 440
        x: (keypadRoot.width - width) / 2
        y: (keypadRoot.height - height) / 2
        color: "#0b2e52"
        border.color: "#38bdf8"
        border.width: 2
        radius: 8

        // Prevent click-through from modal box to overlay background
        MouseArea {
            anchors.fill: parent
            onPressed: function(mouse) { mouse.accepted = true; }
        }

        // Security Interlock Warning Toast Banner (Buffer overflow & DoS attack mitigation)
        Rectangle {
            id: numSecurityBanner
            z: 9999
            anchors.top: parent.top
            anchors.topMargin: keypadRoot.securityToastVisible ? 8 : -50
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width - 24, secNumRow.implicitWidth + 24)
            height: 32
            radius: 6
            color: "#2a0a0a"
            border.color: "#ef4444"
            border.width: 1.5
            visible: opacity > 0.01
            opacity: keypadRoot.securityToastVisible ? 1.0 : 0.0

            Behavior on anchors.topMargin { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
            Behavior on opacity { NumberAnimation { duration: 200 } }

            RowLayout {
                id: secNumRow
                anchors.centerIn: parent
                spacing: 6

                Rectangle {
                    width: 14
                    height: 14
                    radius: 7
                    color: "#dc2626"

                    Text {
                        anchors.centerIn: parent
                        text: "!"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 10
                        font.family: "Segoe UI"
                    }
                }

                Text {
                    text: keypadRoot.securityToastMessage
                    color: "#fca5a5"
                    font.bold: true
                    font.pixelSize: 11
                    font.family: "Segoe UI"
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            // =================================================================
            // 1. DRAGGABLE TOP TITLE BAR WITH CRISP VECTOR ICONS
            // =================================================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                color: "#08213b"
                radius: 5
                border.color: headerDragArea.containsMouse ? "#38bdf8" : "#1d5b94"
                border.width: 1

                MouseArea {
                    id: headerDragArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.SizeAllCursor
                    drag.target: modalBox
                    drag.axis: Drag.XAndYAxis
                    drag.minimumX: 0
                    drag.minimumY: 0
                    drag.maximumX: keypadRoot.width - modalBox.width
                    drag.maximumY: keypadRoot.height - modalBox.height
                    onPressed: keypadRoot.isDocked = false
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 6
                    spacing: 8

                    // Crisp 6-Dot Grip Handle
                    Row {
                        spacing: 3
                        Column {
                            spacing: 3
                            Rectangle { width: 3; height: 3; radius: 1.5; color: headerDragArea.containsMouse ? "#38bdf8" : "#7dd3fc" }
                            Rectangle { width: 3; height: 3; radius: 1.5; color: headerDragArea.containsMouse ? "#38bdf8" : "#7dd3fc" }
                            Rectangle { width: 3; height: 3; radius: 1.5; color: headerDragArea.containsMouse ? "#38bdf8" : "#7dd3fc" }
                        }
                        Column {
                            spacing: 3
                            Rectangle { width: 3; height: 3; radius: 1.5; color: headerDragArea.containsMouse ? "#38bdf8" : "#7dd3fc" }
                            Rectangle { width: 3; height: 3; radius: 1.5; color: headerDragArea.containsMouse ? "#38bdf8" : "#7dd3fc" }
                            Rectangle { width: 3; height: 3; radius: 1.5; color: headerDragArea.containsMouse ? "#38bdf8" : "#7dd3fc" }
                        }
                    }

                    Text {
                        text: (keypadRoot.targetTag + (keypadRoot.title !== "" ? (" " + keypadRoot.title) : "")) + "  •  DRAG TO MOVE"
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
                            onClicked: keypadRoot.dockBottom()
                        }
                    }

                    // Interactive Close Button
                    Rectangle {
                        z: 10
                        Layout.preferredWidth: 28
                        Layout.preferredHeight: 26
                        radius: 4
                        color: closeMouse.pressed ? "#dc2626" : (closeMouse.containsMouse ? "#ef4444" : "#0d365e")
                        border.color: closeMouse.containsMouse ? "#fca5a5" : "#1d5b94"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "X"
                            color: closeMouse.containsMouse ? "#ffffff" : "#94a3b8"
                            font.bold: true
                            font.pixelSize: 13
                            font.family: "Segoe UI"
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: keypadRoot.dismiss()
                        }
                    }
                }
            }

            // =================================================================
            // 2. INPUT DISPLAY BOX (#e6f2fa) WITH SELECTION & DIRECT PASTE
            // =================================================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                color: "#e6f2fa"
                border.color: keypadRoot.hasSelection ? "#0284c7" : (keypadRoot.isInputValid ? "#286aa8" : "#ff4444")
                border.width: keypadRoot.hasSelection ? 2 : 1.5
                radius: 5

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 6

                    Item {
                        id: numDisplayContainer
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        // Normal Non-Selection Row with Blinking Numpad Cursor
                        Row {
                            visible: !keypadRoot.hasSelection
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 3

                            Text {
                                text: keypadRoot.currentInput === "" ? "0" : keypadRoot.currentInput
                                color: "#08213b"
                                font.bold: true
                                font.pixelSize: 26
                                font.family: "Segoe UI"
                            }

                            // Living Blinking Numpad Cursor
                            Rectangle {
                                width: 3
                                height: 26
                                color: "#0284c7"
                                radius: 1.5
                                opacity: 1.0

                                SequentialAnimation on opacity {
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.0; duration: 450; easing.type: Easing.InOutQuad }
                                    NumberAnimation { to: 1.0; duration: 450; easing.type: Easing.InOutQuad }
                                }
                            }
                        }

                        // Selection Active Row with Dual Teardrop Pin Handles
                        Row {
                            visible: keypadRoot.hasSelection
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 0

                            Text {
                                text: keypadRoot.currentInput.substring(0, keypadRoot.selectionStart)
                                color: "#08213b"
                                font.bold: true
                                font.pixelSize: 26
                                font.family: "Segoe UI"
                            }

                            Rectangle {
                                id: numHighlightBox
                                height: 32
                                color: "#0284c7"
                                border.color: "#38bdf8"
                                border.width: 1
                                radius: 2
                                width: numSelTxt.implicitWidth
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    id: numSelTxt
                                    anchors.centerIn: parent
                                    text: keypadRoot.currentInput.substring(keypadRoot.selectionStart, keypadRoot.selectionEnd)
                                    color: "#ffffff"
                                    font.bold: true
                                    font.pixelSize: 26
                                    font.family: "Segoe UI"
                                }

                                // Left Selection Handle (Pin & grab bead)
                                Rectangle {
                                    width: 14
                                    height: 32
                                    color: "transparent"
                                    x: -7
                                    y: -2
                                    z: 30

                                    Rectangle {
                                        width: 2
                                        height: 22
                                        color: "#38bdf8"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.top: parent.top
                                    }
                                    Rectangle {
                                        width: 10
                                        height: 10
                                        radius: 5
                                        color: numLeftHandleMouse.pressed ? "#38bdf8" : "#0284c7"
                                        border.color: "#ffffff"
                                        border.width: 1.5
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottom: parent.bottom
                                    }

                                    MouseArea {
                                        id: numLeftHandleMouse
                                        anchors.fill: parent
                                        anchors.margins: -6
                                        hoverEnabled: true
                                        cursorShape: Qt.SizeHorCursor
                                        onPositionChanged: function(mouse) {
                                            if (!pressed) return;
                                            var newStart = Math.max(0, Math.min(keypadRoot.selectionEnd - 1, Math.floor((x + mouse.x) / 16)));
                                            keypadRoot.selectionStart = newStart;
                                        }
                                    }
                                }

                                // Right Selection Handle (Pin & grab bead)
                                Rectangle {
                                    width: 14
                                    height: 32
                                    color: "transparent"
                                    x: parent.width - 7
                                    y: -2
                                    z: 30

                                    Rectangle {
                                        width: 2
                                        height: 22
                                        color: "#38bdf8"
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.top: parent.top
                                    }
                                    Rectangle {
                                        width: 10
                                        height: 10
                                        radius: 5
                                        color: numRightHandleMouse.pressed ? "#38bdf8" : "#0284c7"
                                        border.color: "#ffffff"
                                        border.width: 1.5
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottom: parent.bottom
                                    }

                                    MouseArea {
                                        id: numRightHandleMouse
                                        anchors.fill: parent
                                        anchors.margins: -6
                                        hoverEnabled: true
                                        cursorShape: Qt.SizeHorCursor
                                        onPositionChanged: function(mouse) {
                                            if (!pressed) return;
                                            var newEnd = Math.min(keypadRoot.currentInput.length, Math.max(keypadRoot.selectionStart + 1, Math.ceil((parent.width + mouse.x) / 16)));
                                            keypadRoot.selectionEnd = newEnd;
                                        }
                                    }
                                }
                            }

                            Text {
                                text: keypadRoot.currentInput.substring(keypadRoot.selectionEnd)
                                color: "#08213b"
                                font.bold: true
                                font.pixelSize: 26
                                font.family: "Segoe UI"
                            }
                        }

                        // Double-tap on display box selects whole number; single-tap clears selection
                        MouseArea {
                            anchors.fill: parent
                            z: 5
                            onDoubleClicked: {
                                keypadRoot.selectionStart = 0;
                                keypadRoot.selectionEnd = keypadRoot.currentInput.length;
                            }
                            onClicked: {
                                if (keypadRoot.hasSelection) {
                                    keypadRoot.selectionStart = 0;
                                    keypadRoot.selectionEnd = 0;
                                }
                            }
                        }
                    }

                    // Direct Paste Pill Button (Allows paste without replacing or selecting)
                    Rectangle {
                        Layout.preferredHeight: 26
                        Layout.preferredWidth: 54
                        radius: 4
                        color: numPasteMouse.pressed ? "#0284c7" : (numPasteMouse.containsMouse ? "#0f4273" : "#0d365e")
                        border.color: numPasteMouse.containsMouse ? "#38bdf8" : "#1d5b94"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "PASTE"
                            color: numPasteMouse.containsMouse ? "#38bdf8" : "#94a3b8"
                            font.bold: true
                            font.pixelSize: 10
                            font.family: "Segoe UI"
                        }

                        MouseArea {
                            id: numPasteMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: keypadRoot.handlePaste()
                        }
                    }

                    Text {
                        visible: keypadRoot.unit !== ""
                        text: keypadRoot.unit
                        color: "#4a749b"
                        font.bold: true
                        font.pixelSize: 15
                        font.family: "Segoe UI"
                    }
                }
            }

            // =================================================================
            // 3. DYNAMIC RANGE LIMITS BAR (Only shown when min/max provided)
            // =================================================================
            RowLayout {
                visible: keypadRoot.hasRange
                Layout.fillWidth: true
                Text {
                    text: keypadRoot.hasRange ? Number(keypadRoot.minVal).toFixed(1) : ""
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
                    text: keypadRoot.hasRange ? Number(keypadRoot.maxVal).toFixed(1) : ""
                    color: "#8cb5dc"
                    font.bold: true
                    font.pixelSize: 12
                }
            }

            // =================================================================
            // 4. AUTHENTIC 4x4 KEYPAD GRID WITH TACTILE 3D BEVEL KEYS
            // =================================================================
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
                    onClicked: keypadRoot.dismiss()
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

    function openFor(inputItem, tagTitle, unitName, minLimit, maxLimit) {
        openForInput(inputItem, tagTitle, unitName, minLimit, maxLimit);
    }

    function openForInput(inputItem, tagTitle, unitName, minLimit, maxLimit) {
        targetInput = inputItem;
        targetTag = tagTitle ? tagTitle : "";
        title = "";
        unit = unitName ? unitName : "";
        minVal = (minLimit !== undefined && minLimit !== null) ? minLimit : null;
        maxVal = (maxLimit !== undefined && maxLimit !== null) ? maxLimit : null;
        currentInput = (inputItem && inputItem.text) ? inputItem.text : "0";
        validateInput();
        visible = true;
        // Keep focus on targetInput — don't steal focus to modal root
        // (prevents cursor from disappearing in the input field)
        if (inputItem) inputItem.forceActiveFocus();
        if (modalBox && !isDocked) {
            // Responsive centering: use actual runtime dimensions
            var pW = keypadRoot.width > 0 ? keypadRoot.width : 1024;
            var pH = keypadRoot.height > 0 ? keypadRoot.height : 600;
            var mW = modalBox.width > 0 ? modalBox.width : 400;
            var mH = modalBox.height > 0 ? modalBox.height : 280;
            modalBox.x = Math.max(8, (pW - mW) / 2);
            modalBox.y = Math.max(8, (pH - mH) / 2);
        }
    }

    function dismiss() {
        rejected();
        closed();
        visible = false;
    }

    function dockBottom() {
        isDocked = true;
        var pW = keypadRoot.width > 0 ? keypadRoot.width : 1024;
        var pH = keypadRoot.height > 0 ? keypadRoot.height : 600;
        var mW = modalBox.width > 0 ? modalBox.width : 400;
        var mH = modalBox.height > 0 ? modalBox.height : 280;
        modalBox.x = Math.max(0, (pW - mW) / 2);
        modalBox.y = Math.max(0, pH - mH - 12);
    }

    function handlePaste(clipboardStr) {
        var str = clipboardStr;
        if (str === undefined || str === null) {
            if (targetInput && targetInput.paste) {
                targetInput.forceActiveFocus();
                targetInput.paste();
                str = targetInput.text;
            }
        }
        if (!str || str.length === 0) return;

        // Security check 1: Reject strings containing letters or malicious injection characters
        var cleaned = str.trim();
        if (!/^-?[0-9]*\.?[0-9]+$/.test(cleaned)) {
            showSecurityToast("SECURITY: Non-numeric input rejected.");
            return;
        }

        // Security check 2: Buffer limit (maxDigits)
        if (cleaned.length > maxDigits) {
            cleaned = cleaned.substring(0, maxDigits);
            showSecurityToast("SECURITY: Input clamped to " + maxDigits + " digits.");
        }

        // Security check 3: Safe Operating Range Validation
        var val = parseFloat(cleaned);
        if (isNaN(val)) {
            showSecurityToast("SECURITY: Invalid number format.");
            return;
        }

        if (hasRange) {
            if (val < minVal || val > maxVal) {
                showSecurityToast("SECURITY: Value outside range [" + minVal + " – " + maxVal + " " + unit + "]");
                val = Math.max(minVal, Math.min(maxVal, val));
                cleaned = val.toString();
            }
        }

        currentInput = cleaned;
        selectionStart = 0;
        selectionEnd = 0;
        validateInput();
    }

    function appendDigit(digit) {
        if (currentInput.length >= maxDigits) {
            showSecurityToast("SECURITY: Max " + maxDigits + " digits limit reached.");
            return;
        }
        if (hasSelection) {
            var before = currentInput.substring(0, selectionStart);
            var after = currentInput.substring(selectionEnd);
            currentInput = before + digit + after;
            selectionStart = 0;
            selectionEnd = 0;
        } else if (currentInput === "0" || currentInput === "") {
            currentInput = digit;
        } else {
            currentInput += digit;
        }
        validateInput();
    }

    function appendDot() {
        if (hasSelection) {
            currentInput = "0.";
            selectionStart = 0;
            selectionEnd = 0;
        } else if (currentInput.indexOf(".") === -1) {
            currentInput = (currentInput === "" ? "0." : currentInput + ".");
        }
        validateInput();
    }

    function backspace() {
        if (hasSelection) {
            var before = currentInput.substring(0, selectionStart);
            var after = currentInput.substring(selectionEnd);
            currentInput = (before + after === "") ? "0" : (before + after);
            selectionStart = 0;
            selectionEnd = 0;
        } else if (currentInput.length > 0) {
            currentInput = currentInput.substring(0, currentInput.length - 1);
            if (currentInput === "" || currentInput === "-") currentInput = "0";
        }
        validateInput();
    }

    function clear() {
        currentInput = "0";
        selectionStart = 0;
        selectionEnd = 0;
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
        if (!hasRange) {
            isInputValid = true;
            return;
        }
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
            dismiss();
            return;
        }
        if (hasRange) {
            val = Math.max(minVal, Math.min(maxVal, val));
        }
        if (targetInput) {
            targetInput.text = currentInput;
            if (targetInput.editingFinished) targetInput.editingFinished();
        }
        accepted(val);
        closed();
        visible = false;
    }

    // Authentic Keypad Button Component with Realistic 3D Mechanical Depressing Tactile Action
    component KeypadButton: Item {
        id: kBtn
        property string text: ""
        property bool isOk: false
        property bool isAction: false
        signal clicked

        readonly property bool isPressedState: btnMouse.pressed || (keypadRoot.physicalPressedKey === kBtn.text)

        Layout.fillWidth: true
        Layout.fillHeight: true
        implicitWidth: 64
        implicitHeight: 52

        // 1. Key Base / 3D Socket Depth Lip
        Rectangle {
            anchors.fill: parent
            radius: 6
            color: kBtn.isOk
                   ? (kBtn.isPressedState ? "#4b8710" : "#579c13")
                   : (kBtn.isAction ? "#87a7c4" : "#94a9bf")
        }

        // 2. Physical Depressing Keycap Body
        Rectangle {
            id: keycapFace
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: kBtn.isPressedState ? 3 : 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: kBtn.isPressedState ? 0 : 3
            radius: 5

            Behavior on anchors.topMargin { NumberAnimation { duration: 60; easing.type: Easing.OutQuad } }
            Behavior on anchors.bottomMargin { NumberAnimation { duration: 60; easing.type: Easing.OutQuad } }
            Behavior on color { ColorAnimation { duration: 70 } }
            Behavior on border.color { ColorAnimation { duration: 70 } }

            color: kBtn.isOk
                   ? (kBtn.isPressedState ? "#65b81b" : (btnMouse.containsMouse ? "#9ef53b" : "#8ee62c"))
                   : (kBtn.isAction
                      ? (kBtn.isPressedState ? "#a3c5e3" : (btnMouse.containsMouse ? "#e5f0fa" : "#d8e6f3"))
                      : (kBtn.isPressedState ? "#cbd5e1" : (btnMouse.containsMouse ? "#f8fafc" : "#ffffff")))

            border.color: kBtn.isOk
                          ? (btnMouse.containsMouse ? "#ffffff" : "#72cc1e")
                          : (btnMouse.containsMouse ? "#38bdf8" : (kBtn.isAction ? "#9bbddc" : "#b0cce6"))
            border.width: (btnMouse.containsMouse || (kBtn.isOk && btnMouse.containsMouse)) ? 2 : 1

            // Top Bevel Reflection
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 1
                height: 2
                radius: 4
                color: kBtn.isOk ? "#c6f98f" : "#ffffff"
                opacity: kBtn.isPressedState ? 0.2 : (kBtn.isAction ? 0.6 : 0.85)
            }

            // Active Tap Glow
            Rectangle {
                anchors.fill: parent
                radius: 4
                color: kBtn.isOk ? "#ffffff" : "#38bdf8"
                opacity: kBtn.isPressedState ? 0.35 : (btnMouse.containsMouse ? 0.08 : 0.0)
                Behavior on opacity { NumberAnimation { duration: 90 } }
            }

            Text {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: kBtn.isPressedState ? 1 : 0
                text: kBtn.text
                color: "#08213b"
                font.bold: true
                font.pixelSize: kBtn.isOk ? 16 : (kBtn.isAction ? 13 : 20)
                font.family: "Segoe UI"
                Behavior on anchors.verticalCenterOffset { NumberAnimation { duration: 60 } }
            }
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
