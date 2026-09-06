pragma ComponentBehavior: Bound
// @disable-check M203  -- JavaScript functions are required QML runtime logic; DS visual editor advisory only
import QtQuick
import QtQuick.Layouts
import "../../../theme"

Item {
    id: handlerRoot
    anchors.fill: parent
    z: 20

    property var targetInput: null
    property var keyboard: null
    property var numpad: null
    property var loupe: null
    property var contextMenu: null
    property string title: ""
    property string unit: ""
    property bool isNumeric: false

    property bool isDragging: false
    property bool isHeld: false
    property real pressX: 0
    property real pressY: 0
    property bool wasAlreadyFocused: false

    // Measure cursor horizontal position in pixels
    TextMetrics {
        id: cursorMetrics
        font: targetInput ? targetInput.font : Qt.font({ family: "Segoe UI", pixelSize: 12 })
        text: (targetInput && targetInput.text) ? targetInput.text.substring(0, Math.max(0, Math.min(targetInput.cursorPosition, targetInput.text.length))) : ""
    }

    // Cursor pixel X mapped into handlerRoot coordinate space — works even inside nested RowLayouts
    readonly property real cursorPixelX: {
        if (!targetInput) return 10;
        var mapped = targetInput.mapToItem(handlerRoot, cursorMetrics.width, 0);
        return mapped ? mapped.x : cursorMetrics.width;
    }

    // Connect context menu keyboardTriggered signal (only for the active matching input)
    Connections {
        target: handlerRoot.contextMenu
        function onKeyboardTriggered() {
            if (handlerRoot.contextMenu && handlerRoot.contextMenu.targetInput === handlerRoot.targetInput) {
                if (handlerRoot.isNumeric && handlerRoot.numpad) {
                    handlerRoot.numpad.openForInput(handlerRoot.targetInput, handlerRoot.title, handlerRoot.unit, null, null);
                } else if (handlerRoot.keyboard) {
                    handlerRoot.keyboard.openFor(handlerRoot.targetInput, handlerRoot.title);
                }
            }
        }
    }

    // Long press timer for context menu (stationary hold ~320ms)
    Timer {
        id: holdTimer
        interval: 320
        repeat: false
        onTriggered: {
            if (!handlerRoot.isDragging && handlerRoot.targetInput) {
                handlerRoot.isHeld = true;
                if (handlerRoot.loupe) handlerRoot.loupe.active = false;
                if (typeof handlerRoot.targetInput.selectWord === "function") {
                    handlerRoot.targetInput.selectWord();
                }
                if (handlerRoot.contextMenu) {
                    var pt = handlerRoot.mapToItem(handlerRoot.targetInput, handlerRoot.pressX, handlerRoot.pressY);
                    handlerRoot.contextMenu.openFor(handlerRoot.targetInput, pt.x, pt.y);
                }
            }
        }
    }

    function updateCursorAt(localX, localY) {
        if (!targetInput) return null;
        var pt = handlerRoot.mapToItem(targetInput, localX, localY);
        if (typeof targetInput.positionAt === "function") {
            var pos = (targetInput.wrapMode !== undefined) ? 
                      targetInput.positionAt(pt.x, pt.y) : 
                      targetInput.positionAt(pt.x);
            targetInput.cursorPosition = Math.max(0, Math.min(pos, (targetInput.text ? targetInput.text.length : 0)));
        }
        return pt;
    }

    // =========================================================================
    // 1. TOUCH & DRAG AREA OVER ENTIRE INPUT FIELD
    // =========================================================================
    MouseArea {
        id: fieldArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.IBeamCursor

        onPressed: function(mouse) {
            handlerRoot.pressX = mouse.x;
            handlerRoot.pressY = mouse.y;
            handlerRoot.isDragging = false;
            handlerRoot.isHeld = false;
            handlerRoot.wasAlreadyFocused = targetInput ? targetInput.activeFocus : false;

            if (contextMenu) contextMenu.closeMenu();
            if (targetInput) targetInput.forceActiveFocus();

            updateCursorAt(mouse.x, mouse.y);
            holdTimer.restart();
        }

        onPositionChanged: function(mouse) {
            if (!fieldArea.pressed) return;
            var dx = Math.abs(mouse.x - handlerRoot.pressX);
            var dy = Math.abs(mouse.y - handlerRoot.pressY);

            // Drag / slide threshold: 4 pixels
            if (dx > 4 || dy > 4) {
                holdTimer.stop();
                handlerRoot.isDragging = true;
                handlerRoot.isHeld = false;
                if (contextMenu) contextMenu.closeMenu();

                var pt = updateCursorAt(mouse.x, mouse.y);

                if (loupe && targetInput && pt) {
                    loupe.targetInput = targetInput;
                    loupe.fingerX = cursorMetrics.width;
                    loupe.fingerY = targetInput.height / 2;
                    loupe.active = true;
                    loupe.updatePosition();
                }
            }
        }

        onReleased: function(mouse) {
            holdTimer.stop();
            if (loupe) loupe.active = false;

            if (handlerRoot.isHeld) {
                // Operator completed a touch-and-hold: context menu is already open!
                // Keep context menu open, DO NOT open keyboard!
                handlerRoot.isHeld = false;
                return;
            }

            if (handlerRoot.isDragging) {
                // Operator completed sliding/scrubbing cursor with loupe
                handlerRoot.isDragging = false;
                if (loupe) loupe.active = false;
                if (contextMenu && targetInput) {
                    var pt = handlerRoot.mapToItem(targetInput, mouse.x, mouse.y);
                    contextMenu.openFor(targetInput, pt.x, pt.y);
                }
                return;
            }

            // Quick tap: focus and open keyboard/numpad immediately
            if (targetInput) {
                targetInput.forceActiveFocus();
                if (isNumeric && numpad) {
                    numpad.openForInput(targetInput, handlerRoot.title, handlerRoot.unit, null, null);
                } else if (keyboard) {
                    keyboard.openFor(targetInput, handlerRoot.title);
                }
            }
        }

        onCanceled: {
            holdTimer.stop();
            handlerRoot.isDragging = false;
            handlerRoot.isHeld = false;
            if (loupe) loupe.active = false;
        }

        onDoubleClicked: function(mouse) {
            holdTimer.stop();
            handlerRoot.isDragging = false;
            handlerRoot.isHeld = false;
            if (loupe) loupe.active = false;
            if (targetInput) {
                if (typeof targetInput.selectWord === "function") {
                    targetInput.selectWord();
                }
                if (contextMenu) {
                    var pt = handlerRoot.mapToItem(targetInput, mouse.x, mouse.y);
                    contextMenu.openFor(targetInput, pt.x, pt.y);
                }
            }
        }
    }

    // =========================================================================
    // 2. TACTILE CURSOR MOVER HANDLE (SLIDER PIN & TOUCH GRIP)
    // =========================================================================
    Item {
        id: cursorMover
        // Show only when the TextInput has focus and contains text — or is empty but focused
        visible: targetInput !== null && targetInput.activeFocus
        width: 32
        height: 28
        z: 99
        // Use mapToItem for correct coordinate translation across nested RowLayouts / anchored children
        x: Math.max(0, Math.min(handlerRoot.width - width, handlerRoot.cursorPixelX - (width / 2)))
        y: Math.max(0, handlerRoot.height - 20)

        // Vertical Cyan Needle pointing straight up to cursor baseline
        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: 2
            height: 6
            color: moverMouse.pressed ? "#f59e0b" : "#38bdf8"
        }

        // Tactile Pill Handle with Ambient Glow
        Rectangle {
            id: handlePill
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 5
            width: 26
            height: 17
            radius: 8.5
            color: moverMouse.pressed ? "#f59e0b" : "#0284c7"
            border.color: moverMouse.pressed ? "#fbbf24" : "#38bdf8"
            border.width: 1.5

            // Outer ambient glow ring
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 6
                height: parent.height + 6
                radius: 11
                color: "transparent"
                border.color: moverMouse.pressed ? "#44f59e0b" : "#4438bdf8"
                border.width: 1.5
            }

            // Dual Arrows ◀ ▶ & Grip Dot
            Row {
                anchors.centerIn: parent
                spacing: 2
                Text {
                    text: "<"
                    color: "#ffffff"
                    font.pixelSize: 8
                    font.bold: true
                    font.family: "Segoe UI"
                }
                Rectangle {
                    width: 3
                    height: 3
                    radius: 1.5
                    color: "#ffffff"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: ">"
                    color: "#ffffff"
                    font.pixelSize: 8
                    font.bold: true
                    font.family: "Segoe UI"
                }
            }
        }

        // Dedicated Touchpad / Finger Grab Area for Cursor Mover
        MouseArea {
            id: moverMouse
            anchors.fill: parent
            anchors.margins: -10 // Generous 52x48px grab target
            cursorShape: Qt.SizeHorCursor
            hoverEnabled: true

            onPressed: function(mouse) {
                if (contextMenu) contextMenu.closeMenu();
                if (targetInput) targetInput.forceActiveFocus();
                handlerRoot.isHeld = false;

                // Immediately show loupe when grab handle is pressed
                if (loupe && targetInput) {
                    loupe.targetInput = targetInput;
                    loupe.fingerX = cursorMetrics.width;
                    loupe.fingerY = targetInput.height / 2;
                    loupe.active = true;
                    loupe.updatePosition();
                }
                holdTimer.restart();
            }

            onPositionChanged: function(mouse) {
                if (!pressed || !targetInput) return;
                holdTimer.stop();
                handlerRoot.isHeld = false;

                // Map mouse position in handlerRoot stationary space to avoid jitter
                var rootPt = handlerRoot.mapFromItem(moverMouse, mouse.x, mouse.y);
                var targetPt = handlerRoot.mapToItem(targetInput, rootPt.x, targetInput.height / 2);
                var pos = (targetInput.wrapMode !== undefined) ? 
                          targetInput.positionAt(targetPt.x, targetPt.y) : 
                          targetInput.positionAt(targetPt.x);
                targetInput.cursorPosition = Math.max(0, Math.min(pos, (targetInput.text ? targetInput.text.length : 0)));

                if (loupe) {
                    loupe.fingerX = cursorMetrics.width;
                    loupe.fingerY = targetInput.height / 2;
                    loupe.active = true;
                    loupe.updatePosition();
                }
            }

            onReleased: function(mouse) {
                holdTimer.stop();
                if (loupe) loupe.active = false;
                if (handlerRoot.isHeld) {
                    handlerRoot.isHeld = false;
                    return;
                }
                if (contextMenu && targetInput) {
                    var rootPt = handlerRoot.mapFromItem(moverMouse, mouse.x, mouse.y);
                    var pt = handlerRoot.mapToItem(targetInput, rootPt.x, targetInput.height / 2);
                    contextMenu.openFor(targetInput, pt.x, pt.y);
                }
            }

            onCanceled: {
                holdTimer.stop();
                handlerRoot.isHeld = false;
                if (loupe) loupe.active = false;
            }

            onDoubleClicked: function() {
                if (isNumeric && numpad) {
                    numpad.openForInput(targetInput, handlerRoot.title, handlerRoot.unit, null, null);
                } else if (keyboard) {
                    keyboard.openFor(targetInput, handlerRoot.title);
                }
            }
        }
    }

    // =========================================================================
    // 3. QUICK KEYBOARD ICON BUTTON (RIGHT EDGE OF INPUT BOX)
    // =========================================================================
    Rectangle {
        id: kbToggleBtn
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.verticalCenter: parent.verticalCenter
        width: 22
        height: 20
        radius: 3
        z: 30
        color: kbToggleMouse.pressed ? "#0284c7" : (kbToggleMouse.containsMouse ? "#1d5b94" : "#0d365e")
        border.color: kbToggleMouse.containsMouse ? "#38bdf8" : "#1e40af"
        border.width: 1

        Text {
            anchors.centerIn: parent
            text: handlerRoot.isNumeric ? "123" : "ABC"
            color: kbToggleMouse.containsMouse ? "#ffffff" : "#94a3b8"
            font.pixelSize: 8
            font.bold: true
            font.family: "Segoe UI"
        }

        MouseArea {
            id: kbToggleMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (targetInput) targetInput.forceActiveFocus();
                if (handlerRoot.isNumeric && handlerRoot.numpad) {
                    handlerRoot.numpad.openForInput(handlerRoot.targetInput, handlerRoot.title, handlerRoot.unit, null, null);
                } else if (handlerRoot.keyboard) {
                    handlerRoot.keyboard.openFor(handlerRoot.targetInput, handlerRoot.title);
                }
            }
        }
    }
}
