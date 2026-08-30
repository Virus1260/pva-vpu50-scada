pragma ComponentBehavior: Bound
import QtQuick

Item {
    id: numpadController
    implicitWidth: ui.implicitWidth
    implicitHeight: ui.implicitHeight
    width: implicitWidth
    height: implicitHeight
    z: 9999
    visible: false

    property var targetInput: null
    property alias titleText: ui.titleText
    property alias unitText: ui.unitText
    property bool isDocked: false

    property real posX: 20
    property real posY: 20
    x: posX
    y: posY

    signal closed
    signal submitted(string value)

    ScadaNumericKeypadView {
        id: ui
        anchors.fill: parent
        displayText: numpadController.targetInput ? (numpadController.targetInput.text === "" ? "0" : numpadController.targetInput.text) : "0"
    }

    // Connections to UI elements
    Connections {
        target: ui.headerDragArea
        function onPressed() {
            numpadController.isDocked = false;
        }
    }

    Connections {
        target: ui.dockBtn
        function onClicked() {
            numpadController.dockBottom();
        }
    }

    Connections {
        target: ui.closeBtn
        function onClicked() {
            numpadController.visible = false;
            numpadController.closed();
        }
    }

    // Connect numeric buttons
    Connections {
        target: ui.btn7.mouseArea
        function onClicked() { numpadController.insertText("7"); }
    }
    Connections {
        target: ui.btn8.mouseArea
        function onClicked() { numpadController.insertText("8"); }
    }
    Connections {
        target: ui.btn9.mouseArea
        function onClicked() { numpadController.insertText("9"); }
    }
    Connections {
        target: ui.btnDel.mouseArea
        function onClicked() { numpadController.backspace(); }
    }

    Connections {
        target: ui.btn4.mouseArea
        function onClicked() { numpadController.insertText("4"); }
    }
    Connections {
        target: ui.btn5.mouseArea
        function onClicked() { numpadController.insertText("5"); }
    }
    Connections {
        target: ui.btn6.mouseArea
        function onClicked() { numpadController.insertText("6"); }
    }
    Connections {
        target: ui.btnEsc.mouseArea
        function onClicked() {
            numpadController.visible = false;
            numpadController.closed();
        }
    }

    Connections {
        target: ui.btn1.mouseArea
        function onClicked() { numpadController.insertText("1"); }
    }
    Connections {
        target: ui.btn2.mouseArea
        function onClicked() { numpadController.insertText("2"); }
    }
    Connections {
        target: ui.btn3.mouseArea
        function onClicked() { numpadController.insertText("3"); }
    }
    Connections {
        target: ui.btnClear.mouseArea
        function onClicked() { numpadController.clearAll(); }
    }

    Connections {
        target: ui.btn0.mouseArea
        function onClicked() { numpadController.insertText("0"); }
    }
    Connections {
        target: ui.btnDot.mouseArea
        function onClicked() { numpadController.appendDot(); }
    }
    Connections {
        target: ui.btnMinus.mouseArea
        function onClicked() { numpadController.toggleMinus(); }
    }
    Connections {
        target: ui.btnOk.mouseArea
        function onClicked() { numpadController.submitAndClose(); }
    }

    Component.onCompleted: {
        ui.headerDragArea.drag.target = numpadController;
        ui.headerDragArea.drag.axis = Drag.XAndYAxis;
        ui.headerDragArea.drag.minimumX = 0;
        ui.headerDragArea.drag.minimumY = 0;
    }

    onParentChanged: {
        if (parent) {
            ui.headerDragArea.drag.maximumX = Qt.binding(function() { return Math.max(0, parent.width - numpadController.width); });
            ui.headerDragArea.drag.maximumY = Qt.binding(function() { return Math.max(0, parent.height - numpadController.height); });
        }
    }

    function openFor(inputItem, title, unit) {
        targetInput = inputItem;
        ui.titleText = title ? title : "Numeric Value Input";
        ui.unitText = unit ? unit : "";
        visible = true;

        if (parent && !isDocked) {
            var globalPt = inputItem.mapToItem(parent, 0, 0);
            var calcY = globalPt.y + inputItem.height + 8;
            if (calcY + height > parent.height) {
                calcY = Math.max(10, globalPt.y - height - 8);
            }
            var calcX = Math.min(Math.max(10, globalPt.x - (width / 4)), parent.width - width - 10);
            posX = Math.max(10, calcX);
            posY = Math.max(10, calcY);
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

    function appendDot() {
        if (!targetInput) return;
        var t = targetInput.text ? targetInput.text : "";
        if (t.indexOf(".") === -1) {
            insertText(".");
        }
    }

    function toggleMinus() {
        if (!targetInput) return;
        var t = targetInput.text ? targetInput.text : "";
        if (t.indexOf("-") === 0) {
            targetInput.text = t.slice(1);
        } else {
            targetInput.text = "-" + t;
        }
    }

    function submitAndClose() {
        if (targetInput) {
            submitted(targetInput.text);
            if (targetInput.editingFinished) targetInput.editingFinished();
        }
        visible = false;
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
