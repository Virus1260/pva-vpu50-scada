pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: textKeyboardController
    implicitWidth: ui.implicitWidth
    implicitHeight: ui.implicitHeight
    width: implicitWidth
    height: implicitHeight
    z: 9999
    visible: false
    focus: true

    property var targetInput: null
    property alias titleText: ui.titleText
    property int shiftMode: 0 // 0 = lowercase, 1 = single-character shift, 2 = CAPS LOCK
    property real lastShiftTapTime: 0
    property bool isDocked: false
    property string physicalActiveKey: ""

    property real posX: 20
    property real posY: 20
    x: posX
    y: posY

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
            textKeyboardController.forceActiveFocus();
        }
    }

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
            textKeyboardController.flashKey("ENTER");
            textKeyboardController.submitAndClose();
            event.accepted = true;
        } else if (event.key === Qt.Key_Backspace) {
            textKeyboardController.flashKey("BACKSPACE");
            textKeyboardController.backspace();
            event.accepted = true;
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
            textKeyboardController.insertText(" ");
            event.accepted = true;
        } else if (event.key === Qt.Key_Shift) {
            textKeyboardController.flashKey("SHIFT");
            event.accepted = true;
        } else if (event.text && event.text.length > 0) {
            var ch = event.text;
            textKeyboardController.flashKey(ch);
            textKeyboardController.insertCharacter(ch);
            event.accepted = true;
        }
    }

    Keys.onReleased: function(event) {
        textKeyboardController.physicalActiveKey = "";
    }

    ScadaTextKeyboardView {
        id: ui
        anchors.fill: parent
        displayText: textKeyboardController.targetInput ? textKeyboardController.targetInput.text : ""
        isShift: textKeyboardController.shiftMode > 0
        isShiftActive: textKeyboardController.shiftMode > 0
        isCapsLock: textKeyboardController.shiftMode === 2
        shiftLabel: textKeyboardController.shiftMode === 2 ? "CAPS" : (textKeyboardController.shiftMode === 1 ? "▲ SHIFT" : "▲ Shift")
        physicalActiveKey: textKeyboardController.physicalActiveKey
    }

    // Connections to Header Controls
    Connections {
        target: ui.headerDragArea
        function onPressed() {
            textKeyboardController.isDocked = false;
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
        ui.headerDragArea.drag.target = textKeyboardController;
        ui.headerDragArea.drag.axis = Drag.XAndYAxis;
        ui.headerDragArea.drag.minimumX = 0;
        ui.headerDragArea.drag.minimumY = 0;
    }

    onParentChanged: {
        if (parent) {
            ui.headerDragArea.drag.maximumX = Qt.binding(function() { return Math.max(0, parent.width - textKeyboardController.width); });
            ui.headerDragArea.drag.maximumY = Qt.binding(function() { return Math.max(0, parent.height - textKeyboardController.height); });
        }
    }

    function openFor(inputItem, title) {
        targetInput = inputItem;
        ui.titleText = title ? title : "Text Input Keyboard";
        shiftMode = 0;
        visible = true;
        textKeyboardController.forceActiveFocus();

        if (parent && !isDocked) {
            var pW = parent.width;
            var pH = parent.height;
            posX = Math.max(10, Math.min(pW - width - 10, (pW - width) / 2));
            posY = Math.max(10, Math.min(pH - height - 10, pH - height - 15));
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
        var curPos = (targetInput.cursorPosition !== undefined) ? targetInput.cursorPosition : targetInput.text.length;
        var t = targetInput.text ? targetInput.text : "";
        targetInput.text = t.slice(0, curPos) + str + t.slice(curPos);
        if (targetInput.cursorPosition !== undefined) {
            targetInput.cursorPosition = curPos + str.length;
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
        if (parent) {
            isDocked = true;
            posX = (parent.width - width) / 2;
            posY = parent.height - height - 10;
        }
    }
}
