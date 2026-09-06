pragma ComponentBehavior: Bound
// @disable-check M203  -- JavaScript functions are required QML runtime logic; DS visual editor advisory only
import QtQuick

Rectangle {
    id: textKeyboardController
    implicitWidth: 1024
    implicitHeight: 600
    color: hasScrim ? "#95000000" : "transparent"
    z: 9999
    visible: false
    focus: true

    property bool hasScrim: true
    property var targetInput: null
    property alias titleText: ui.titleText
    property int shiftMode: 0 // 0 = lowercase, 1 = single-character shift, 2 = CAPS LOCK
    property real lastShiftTapTime: 0
    property bool isDocked: false
    property string physicalActiveKey: ""

    property real posX: 20
    property real posY: 20
    property int maxCharacters: 64

    Timer {
        id: securityToastTimer
        interval: 2600
        repeat: false
        onTriggered: ui.securityToastVisible = false
    }

    function showSecurityToast(msg) {
        if (headerContextMenu) headerContextMenu.closeMenu();
        ui.securityToastMessage = msg;
        ui.securityToastVisible = true;
        securityToastTimer.restart();
    }

    signal closed
    signal submitted(string value)

    Timer {
        id: keyReleaseTimer
        interval: 130
        repeat: false
        onTriggered: textKeyboardController.physicalActiveKey = ""
    }

    function flashKey(k) {
        physicalActiveKey = k.toUpperCase();
        keyReleaseTimer.restart();
    }

    onVisibleChanged: {
        if (visible) {
            // Keep focus on targetInput so the cursor stays visible and blinking
            // Physical keyboard events are forwarded via Keys.forwardTo below
            if (targetInput) {
                targetInput.forceActiveFocus();
                // Ensure cursor is visible at end of current text
                if (targetInput.cursorPosition !== undefined) {
                    targetInput.cursorPosition = targetInput.text ? targetInput.text.length : 0;
                }
            }
        }
    }

    // Forward physical keyboard to targetInput so cursor blinks in the actual field
    Keys.forwardTo: targetInput ? [targetInput] : []

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            textKeyboardController.flashKey("ENTER");
            textKeyboardController.submitAndClose();
            event.accepted = true;
        } else if (event.key === Qt.Key_Backspace) {
            textKeyboardController.flashKey("BACKSPACE");
            event.accepted = false; // Let forwardTo handle it so cursor moves correctly
        } else if (event.key === Qt.Key_Escape) {
            textKeyboardController.flashKey("ESCAPE");
            textKeyboardController.visible = false;
            textKeyboardController.shiftMode = 0;
            textKeyboardController.closed();
            event.accepted = true;
        } else if (event.key === Qt.Key_Delete) {
            textKeyboardController.flashKey("DELETE");
            textKeyboardController.clearAll();
            event.accepted = true;
        } else if (event.key === Qt.Key_Space) {
            textKeyboardController.flashKey("SPACE");
            event.accepted = false; // Let forwardTo insert space naturally
        } else if (event.key === Qt.Key_Shift) {
            textKeyboardController.flashKey("SHIFT");
            event.accepted = true;
        } else if (event.text && event.text.length > 0) {
            var ch = event.text;
            textKeyboardController.flashKey(ch);
            event.accepted = false; // Let forwardTo insert char naturally into targetInput
        }
    }

    Keys.onReleased: function(event) {
        textKeyboardController.physicalActiveKey = "";
    }

    // Modal Background Click Dismiss (Protective Scrim Layer)
    MouseArea {
        anchors.fill: parent
        onClicked: textKeyboardController.submitAndClose()
    }

    // Modal Card Container (Draggable & Dockable QWERTY Card)
    Item {
        id: keyboardCard
        width: ui.implicitWidth
        height: ui.implicitHeight
        x: textKeyboardController.posX
        y: textKeyboardController.posY

        // Prevent click-through from keyboard card to protective backdrop
        MouseArea {
            anchors.fill: parent
            onPressed: function(mouse) { mouse.accepted = true; }
        }

        ScadaTextKeyboardView {
            id: ui
            anchors.fill: parent
            displayText: textKeyboardController.targetInput ? textKeyboardController.targetInput.text : ""
            cursorPosition: textKeyboardController.targetInput ? textKeyboardController.targetInput.cursorPosition : 0
            selectionStart: textKeyboardController.targetInput ? (textKeyboardController.targetInput.selectionStart !== undefined ? textKeyboardController.targetInput.selectionStart : 0) : 0
            selectionEnd: textKeyboardController.targetInput ? (textKeyboardController.targetInput.selectionEnd !== undefined ? textKeyboardController.targetInput.selectionEnd : 0) : 0
            selectedText: textKeyboardController.targetInput ? (textKeyboardController.targetInput.selectedText || "") : ""
            isShift: textKeyboardController.shiftMode > 0
            isShiftActive: textKeyboardController.shiftMode > 0
            isCapsLock: textKeyboardController.shiftMode === 2
            shiftLabel: textKeyboardController.shiftMode === 2 ? "CAPS" : (textKeyboardController.shiftMode === 1 ? "▲ SHIFT" : "▲ Shift")
            physicalActiveKey: textKeyboardController.physicalActiveKey
        }

        // =====================================================================
        // HEADER PREVIEW STRIP INTERACTIVE TOUCH ERGONOMICS
        // =====================================================================
        TextMetrics {
            id: headerMetrics
            font.family: "Segoe UI"
            font.pixelSize: 14
            font.bold: true
        }

        MouseArea {
            id: previewTouchArea
            parent: ui.previewStrip
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.IBeamCursor
            z: 20

            property real pressX: 0
            property real pressY: 0
            property bool isDraggingHeader: false
            property bool isHeldHeader: false

            Timer {
                id: headerHoldTimer
                interval: 320
                repeat: false
                onTriggered: {
                    if (!previewTouchArea.isDraggingHeader && textKeyboardController.targetInput) {
                        previewTouchArea.isHeldHeader = true;
                        headerLoupe.active = false;
                        if (typeof textKeyboardController.targetInput.selectWord === "function") {
                            textKeyboardController.targetInput.selectWord();
                        }
                        if (headerContextMenu) {
                            headerContextMenu.openFor(textKeyboardController.targetInput, previewTouchArea.pressX, previewTouchArea.pressY, ui.previewStrip);
                        }
                    }
                }
            }

            function getCharIndexAt(headerX) {
                if (!textKeyboardController.targetInput || !textKeyboardController.targetInput.text) return 0;
                var str = textKeyboardController.targetInput.text;
                var bestIdx = str.length;
                var minDiff = 999999;
                for (var i = 0; i <= str.length; i++) {
                    headerMetrics.text = str.substring(0, i);
                    var diff = Math.abs(headerMetrics.width - headerX);
                    if (diff < minDiff) {
                        minDiff = diff;
                        bestIdx = i;
                    }
                }
                return bestIdx;
            }

            onPressed: function(mouse) {
                pressX = mouse.x;
                pressY = mouse.y;
                isDraggingHeader = false;
                isHeldHeader = false;
                headerLoupe.active = false;
                if (headerContextMenu) headerContextMenu.closeMenu();
                if (textKeyboardController.targetInput) {
                    textKeyboardController.targetInput.forceActiveFocus();
                    if (textKeyboardController.targetInput.deselect) {
                        textKeyboardController.targetInput.deselect();
                    }
                    textKeyboardController.targetInput.cursorPosition = getCharIndexAt(mouse.x - 10);
                }
                headerHoldTimer.restart();
            }

            onPositionChanged: function(mouse) {
                // CRITICAL FIX: Only process dragging when actively pressed!
                if (!previewTouchArea.pressed) return;

                var dx = Math.abs(mouse.x - pressX);
                var dy = Math.abs(mouse.y - pressY);
                if (dx > 4 || dy > 4) {
                    headerHoldTimer.stop();
                    isDraggingHeader = true;
                    isHeldHeader = false;
                    if (headerContextMenu) headerContextMenu.closeMenu();
                }

                if (isDraggingHeader && textKeyboardController.targetInput) {
                    var idx = getCharIndexAt(mouse.x - 10);
                    textKeyboardController.targetInput.cursorPosition = idx;
                    headerLoupe.targetInput = textKeyboardController.targetInput;
                    headerLoupe.anchorItem = ui.previewStrip;
                    headerMetrics.text = textKeyboardController.targetInput.text.substring(0, idx);
                    headerLoupe.fingerX = headerMetrics.width + 10;
                    headerLoupe.fingerY = ui.previewStrip.height / 2;
                    headerLoupe.active = true;
                    headerLoupe.updatePosition();
                }
            }

            onReleased: function(mouse) {
                headerHoldTimer.stop();
                headerLoupe.active = false; // Always dismiss loupe on release!

                if (isHeldHeader) {
                    isHeldHeader = false;
                    return;
                }

                if (isDraggingHeader) {
                    isDraggingHeader = false;
                    if (headerContextMenu && textKeyboardController.targetInput) {
                        headerContextMenu.openFor(textKeyboardController.targetInput, mouse.x, mouse.y, ui.previewStrip);
                    }
                    return;
                }
            }

            onCanceled: {
                headerHoldTimer.stop();
                isDraggingHeader = false;
                isHeldHeader = false;
                headerLoupe.active = false;
            }

            onDoubleClicked: function(mouse) {
                headerHoldTimer.stop();
                isDraggingHeader = false;
                isHeldHeader = false;
                headerLoupe.active = false;
                if (textKeyboardController.targetInput) {
                    textKeyboardController.targetInput.selectWord();
                    headerContextMenu.openFor(textKeyboardController.targetInput, mouse.x, mouse.y, ui.previewStrip);
                }
            }
        }
    }

    // Touch Ergonomics: Header Preview Loupe & Selection Context Menu
    ScadaTouchLoupe {
        id: headerLoupe
        anchorItem: ui.previewStrip
        z: 100000
    }

    ScadaTextContextMenu {
        id: headerContextMenu
        showKeyboardAction: false
        z: 100000
    }

    // Connections to Header Controls
    Connections {
        target: ui.headerDragArea
        function onPressed() {
            textKeyboardController.isDocked = false;
        }
        function onReleased() {
            textKeyboardController.posX = keyboardCard.x;
            textKeyboardController.posY = keyboardCard.y;
        }
    }

    Connections {
        target: ui.dockBtn
        function onClicked() {
            textKeyboardController.dockBottom();
        }
    }

    Connections {
        target: ui.closeBtn
        function onClicked() {
            textKeyboardController.visible = false;
            textKeyboardController.shiftMode = 0;
            textKeyboardController.closed();
        }
    }

    // Quick Paste Connection (Pastes directly at cursor without replacing/selecting)
    Connections {
        target: ui.quickPasteMouse
        function onClicked() {
            textKeyboardController.pasteAtCursor();
        }
    }

    // Left Selection Handle (Start pin drag to expand/shrink range)
    Connections {
        target: ui.leftHandleArea
        function onPositionChanged(mouse) {
            if (!ui.leftHandleArea.pressed || !textKeyboardController.targetInput) return;
            var mapped = ui.leftHandleArea.mapToItem(ui.previewStrip, mouse.x, mouse.y);
            var newIdx = previewTouchArea.getCharIndexAt(mapped.x - 10);
            var curEnd = (textKeyboardController.targetInput.selectionEnd !== undefined && textKeyboardController.targetInput.selectionEnd > 0)
                         ? textKeyboardController.targetInput.selectionEnd
                         : textKeyboardController.targetInput.cursorPosition;
            if (newIdx < curEnd) {
                textKeyboardController.targetInput.select(newIdx, curEnd);
            }
        }
    }

    // Right Selection Handle (End pin drag to expand/shrink range)
    Connections {
        target: ui.rightHandleArea
        function onPositionChanged(mouse) {
            if (!ui.rightHandleArea.pressed || !textKeyboardController.targetInput) return;
            var mapped = ui.rightHandleArea.mapToItem(ui.previewStrip, mouse.x, mouse.y);
            var newIdx = previewTouchArea.getCharIndexAt(mapped.x - 10);
            var curStart = (textKeyboardController.targetInput.selectionStart !== undefined)
                           ? textKeyboardController.targetInput.selectionStart : 0;
            if (newIdx > curStart) {
                textKeyboardController.targetInput.select(curStart, newIdx);
            }
        }
    }

    // Shift Key with Mobile Double-Tap Caps Lock Logic
    Connections {
        target: ui.kShift.mouseArea
        function onClicked() {
            var now = Date.now();
            if (now - textKeyboardController.lastShiftTapTime < 350 && textKeyboardController.shiftMode === 1) {
                // Double-tap detected -> engage CAPS LOCK
                textKeyboardController.shiftMode = 2;
            } else if (textKeyboardController.shiftMode === 0) {
                // Single tap -> single char shift
                textKeyboardController.shiftMode = 1;
            } else {
                // Turn off shift / caps lock
                textKeyboardController.shiftMode = 0;
            }
            textKeyboardController.lastShiftTapTime = now;
        }
    }

    // Row 1 Connections (Numbers & Signs & Del)
    Connections { target: ui.k1.mouseArea; function onClicked() { textKeyboardController.insertText("1"); } }
    Connections { target: ui.k2.mouseArea; function onClicked() { textKeyboardController.insertText("2"); } }
    Connections { target: ui.k3.mouseArea; function onClicked() { textKeyboardController.insertText("3"); } }
    Connections { target: ui.k4.mouseArea; function onClicked() { textKeyboardController.insertText("4"); } }
    Connections { target: ui.k5.mouseArea; function onClicked() { textKeyboardController.insertText("5"); } }
    Connections { target: ui.k6.mouseArea; function onClicked() { textKeyboardController.insertText("6"); } }
    Connections { target: ui.k7.mouseArea; function onClicked() { textKeyboardController.insertText("7"); } }
    Connections { target: ui.k8.mouseArea; function onClicked() { textKeyboardController.insertText("8"); } }
    Connections { target: ui.k9.mouseArea; function onClicked() { textKeyboardController.insertText("9"); } }
    Connections { target: ui.k0.mouseArea; function onClicked() { textKeyboardController.insertText("0"); } }
    Connections { target: ui.kMinus.mouseArea; function onClicked() { textKeyboardController.insertText("-"); } }
    Connections { target: ui.kPlus.mouseArea; function onClicked() { textKeyboardController.insertText("+"); } }
    Connections { target: ui.kDel.mouseArea; function onClicked() { textKeyboardController.backspace(); } }

    // Row 2 Connections (Q W E R T Y U I O P ( ) Clear)
    Connections { target: ui.kQ.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kQ.text); } }
    Connections { target: ui.kW.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kW.text); } }
    Connections { target: ui.kE.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kE.text); } }
    Connections { target: ui.kR.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kR.text); } }
    Connections { target: ui.kT.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kT.text); } }
    Connections { target: ui.kY.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kY.text); } }
    Connections { target: ui.kU.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kU.text); } }
    Connections { target: ui.kI.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kI.text); } }
    Connections { target: ui.kO.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kO.text); } }
    Connections { target: ui.kP.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kP.text); } }
    Connections { target: ui.kOpenParen.mouseArea; function onClicked() { textKeyboardController.insertText("("); } }
    Connections { target: ui.kCloseParen.mouseArea; function onClicked() { textKeyboardController.insertText(")"); } }
    Connections { target: ui.kClear.mouseArea; function onClicked() { textKeyboardController.clearAll(); } }

    // Row 3 Connections (A S D F G H J K L : / % Esc)
    Connections { target: ui.kA.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kA.text); } }
    Connections { target: ui.kS.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kS.text); } }
    Connections { target: ui.kD.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kD.text); } }
    Connections { target: ui.kF.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kF.text); } }
    Connections { target: ui.kG.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kG.text); } }
    Connections { target: ui.kH.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kH.text); } }
    Connections { target: ui.kJ.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kJ.text); } }
    Connections { target: ui.kK.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kK.text); } }
    Connections { target: ui.kL.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kL.text); } }
    Connections { target: ui.kColon.mouseArea; function onClicked() { textKeyboardController.insertText(":"); } }
    Connections { target: ui.kSlash.mouseArea; function onClicked() { textKeyboardController.insertText("/"); } }
    Connections { target: ui.kPercent.mouseArea; function onClicked() { textKeyboardController.insertText("%"); } }
    Connections {
        target: ui.kEsc.mouseArea
        function onClicked() {
            textKeyboardController.visible = false;
            textKeyboardController.shiftMode = 0;
            textKeyboardController.closed();
        }
    }

    // Row 4 Connections (Z X C V B N M , . ? !)
    Connections { target: ui.kZ.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kZ.text); } }
    Connections { target: ui.kX.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kX.text); } }
    Connections { target: ui.kC.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kC.text); } }
    Connections { target: ui.kV.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kV.text); } }
    Connections { target: ui.kB.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kB.text); } }
    Connections { target: ui.kN.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kN.text); } }
    Connections { target: ui.kM.mouseArea; function onClicked() { textKeyboardController.insertCharacter(ui.kM.text); } }
    Connections { target: ui.kComma.mouseArea; function onClicked() { textKeyboardController.insertText(","); } }
    Connections { target: ui.kDot.mouseArea; function onClicked() { textKeyboardController.insertText("."); } }
    Connections { target: ui.kQuestion.mouseArea; function onClicked() { textKeyboardController.insertText("?"); } }
    Connections { target: ui.kExclamation.mouseArea; function onClicked() { textKeyboardController.insertText("!"); } }

    // Row 5 Connections (@ _ " Space & # = Single OK)
    Connections { target: ui.kAt.mouseArea; function onClicked() { textKeyboardController.insertText("@"); } }
    Connections { target: ui.kUnderscore.mouseArea; function onClicked() { textKeyboardController.insertText("_"); } }
    Connections { target: ui.kQuote.mouseArea; function onClicked() { textKeyboardController.insertText("\""); } }
    Connections { target: ui.kSpace.mouseArea; function onClicked() { textKeyboardController.insertText(" "); } }
    Connections { target: ui.kAmp.mouseArea; function onClicked() { textKeyboardController.insertText("&"); } }
    Connections { target: ui.kHash.mouseArea; function onClicked() { textKeyboardController.insertText("#"); } }
    Connections { target: ui.kEquals.mouseArea; function onClicked() { textKeyboardController.insertText("="); } }
    Connections { target: ui.kOk.mouseArea; function onClicked() { textKeyboardController.submitAndClose(); } }

    Component.onCompleted: {
        ui.headerDragArea.drag.target = keyboardCard;
        ui.headerDragArea.drag.axis = Drag.XAndYAxis;
        ui.headerDragArea.drag.minimumX = 0;
        ui.headerDragArea.drag.minimumY = 0;
        ui.headerDragArea.drag.maximumX = Qt.binding(function() { return Math.max(0, textKeyboardController.width - keyboardCard.width); });
        ui.headerDragArea.drag.maximumY = Qt.binding(function() { return Math.max(0, textKeyboardController.height - keyboardCard.height); });
    }

    onWidthChanged: {
        ui.headerDragArea.drag.maximumX = Qt.binding(function() { return Math.max(0, textKeyboardController.width - keyboardCard.width); });
    }

    onHeightChanged: {
        ui.headerDragArea.drag.maximumY = Qt.binding(function() { return Math.max(0, textKeyboardController.height - keyboardCard.height); });
    }

    function openFor(inputItem, title) {
        targetInput = inputItem;
        ui.titleText = title ? title : "Text Input Keyboard";
        shiftMode = 0;
        visible = true;
        headerLoupe.active = false;
        if (headerContextMenu) headerContextMenu.closeMenu();

        // Keep cursor blinking in the actual input field
        if (targetInput) {
            targetInput.forceActiveFocus();
            if (targetInput.cursorPosition !== undefined) {
                targetInput.cursorPosition = targetInput.text ? targetInput.text.length : 0;
            }
        }

        if (!isDocked) {
            // Responsive centering: use parent dimensions, fall back gracefully
            var pW = textKeyboardController.width > 0 ? textKeyboardController.width : 1024;
            var pH = textKeyboardController.height > 0 ? textKeyboardController.height : 600;
            var cW = keyboardCard.width > 0 ? keyboardCard.width : (ui.implicitWidth > 0 ? ui.implicitWidth : 720);
            var cH = keyboardCard.height > 0 ? keyboardCard.height : (ui.implicitHeight > 0 ? ui.implicitHeight : 260);
            // Centre horizontally, dock near bottom with 16px clearance
            posX = Math.max(8, (pW - cW) / 2);
            posY = Math.max(8, pH - cH - 16);
            keyboardCard.x = posX;
            keyboardCard.y = posY;
        }
    }

    // Handles letter insertion with mobile keyboard shift behavior
    function insertCharacter(ch) {
        insertText(ch);
        if (shiftMode === 1) {
            // Single shift used -> automatically un-shift to lowercase
            shiftMode = 0;
        }
    }

    function insertText(str) {
        if (!targetInput) return;
        var t = targetInput.text ? targetInput.text : "";
        var curPos = (targetInput.cursorPosition !== undefined) ? targetInput.cursorPosition : t.length;
        var selStart = (targetInput.selectionStart !== undefined) ? targetInput.selectionStart : curPos;
        var selEnd = (targetInput.selectionEnd !== undefined) ? targetInput.selectionEnd : curPos;

        // If range is selected, replace the selected range
        var sMin = Math.min(selStart, selEnd);
        var sMax = Math.max(selStart, selEnd);
        var before = t.slice(0, sMin);
        var after = t.slice(sMax);

        // Security Interlock: Character Limit & Buffer Overflow / DoS Protection
        var remainingAllowed = Math.max(0, maxCharacters - (before.length + after.length));
        if (str.length > remainingAllowed) {
            str = str.slice(0, remainingAllowed);
            showSecurityToast("SECURITY: Exceeds " + maxCharacters + " chars limit (clamped).");
        }
        if (str.length === 0 && remainingAllowed === 0) {
            showSecurityToast("SECURITY: Maximum buffer limit reached (" + maxCharacters + " chars).");
            return;
        }

        targetInput.text = before + str + after;
        if (targetInput.deselect) targetInput.deselect();
        if (targetInput.cursorPosition !== undefined) {
            targetInput.cursorPosition = before.length + str.length;
        }
    }

    function pasteAtCursor() {
        if (!targetInput) return;
        targetInput.forceActiveFocus();
        if (targetInput.paste) {
            targetInput.paste();
            // Clamp if pasted buffer exceeded maxCharacters
            if (targetInput.text && targetInput.text.length > maxCharacters) {
                targetInput.text = targetInput.text.slice(0, maxCharacters);
                showSecurityToast("SECURITY: Pasted input clamped to " + maxCharacters + " chars.");
            }
        }
    }

    function backspace() {
        if (!targetInput) return;
        var curPos = (targetInput.cursorPosition !== undefined) ? targetInput.cursorPosition : targetInput.text.length;
        if (curPos > 0) {
            var t = targetInput.text ? targetInput.text : "";
            targetInput.text = t.slice(0, curPos - 1) + t.slice(curPos);
            if (targetInput.cursorPosition !== undefined) {
                targetInput.cursorPosition = curPos - 1;
            }
        }
    }

    function clearAll() {
        if (!targetInput) return;
        targetInput.text = "";
        if (targetInput.cursorPosition !== undefined) {
            targetInput.cursorPosition = 0;
        }
    }

    function submitAndClose() {
        if (targetInput) {
            submitted(targetInput.text);
            if (targetInput.editingFinished) targetInput.editingFinished();
        }
        visible = false;
        shiftMode = 0;
        closed();
    }

    function dockBottom() {
        isDocked = true;
        var pW = textKeyboardController.width > 0 ? textKeyboardController.width : 1024;
        var pH = textKeyboardController.height > 0 ? textKeyboardController.height : 600;
        var cW = keyboardCard.width > 0 ? keyboardCard.width : (ui.implicitWidth > 0 ? ui.implicitWidth : 720);
        var cH = keyboardCard.height > 0 ? keyboardCard.height : (ui.implicitHeight > 0 ? ui.implicitHeight : 260);
        posX = Math.max(0, (pW - cW) / 2);
        posY = Math.max(0, pH - cH - 10);
        keyboardCard.x = posX;
        keyboardCard.y = posY;
        if (targetInput) targetInput.forceActiveFocus();
    }
}
