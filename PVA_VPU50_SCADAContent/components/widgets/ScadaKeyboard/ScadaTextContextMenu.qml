pragma ComponentBehavior: Bound
// @disable-check M203  -- JavaScript functions are required QML runtime logic; DS visual editor advisory only
import QtQuick
import QtQuick.Layouts
import "../../../theme"

Item {
    id: menuRoot
    anchors.fill: parent
    z: 99999
    visible: active || opacity > 0.001
    opacity: active ? 1.0 : 0.0
    enabled: active

    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
    }

    property var targetInput: null
    property var currentVisualAnchor: null
    property real lastAnchorX: 0
    property real lastAnchorY: 0
    property bool showKeyboardAction: true
    property bool active: false
    property real pillX: 100
    property real pillY: 100

    readonly property bool hasSelection: targetInput && targetInput.selectedText && targetInput.selectedText.length > 0
    readonly property bool hasText: targetInput && targetInput.text && targetInput.text.length > 0
    readonly property bool isAllSelected: targetInput && hasSelection && targetInput.selectionStart === 0 && targetInput.selectionEnd === targetInput.text.length
    readonly property bool isReadOnly: targetInput ? targetInput.readOnly : false

    signal cutTriggered()
    signal copyTriggered()
    signal pasteTriggered()
    signal selectAllTriggered()
    signal keyboardTriggered()

    function openFor(inputItem, anchorX, anchorY, visualAnchor) {
        targetInput = inputItem;
        active = true;
        if (!parent) return;

        if (visualAnchor) currentVisualAnchor = visualAnchor;
        var anchor = currentVisualAnchor ? currentVisualAnchor : inputItem;
        if (!anchor) return;

        var ax = (anchorX !== undefined && !isNaN(anchorX)) ? anchorX : (lastAnchorX > 0 ? lastAnchorX : (anchor.width / 2));
        var ay = (anchorY !== undefined && !isNaN(anchorY)) ? anchorY : (lastAnchorY > 0 ? lastAnchorY : 0);
        lastAnchorX = ax;
        lastAnchorY = ay;

        var globalPos = anchor.mapToItem(parent, ax, ay);
        if (!globalPos || isNaN(globalPos.x) || isNaN(globalPos.y)) return;

        var targetX = globalPos.x - (menuPill.width / 2);
        var targetY = globalPos.y - menuPill.height - 8;

        if (targetY < 8) {
            targetY = globalPos.y + (anchor.height ? anchor.height : 32) + 8;
        }

        pillX = Math.max(8, Math.min(parent.width - menuPill.width - 8, targetX));
        pillY = Math.max(8, Math.min(parent.height - menuPill.height - 8, targetY));
    }

    function closeMenu() {
        active = false;
    }

    // Dismiss Backdrop (Tap outside closes the floating context menu)
    MouseArea {
        anchors.fill: parent
        enabled: menuRoot.active
        onClicked: menuRoot.closeMenu()
    }

    Rectangle {
        id: menuPill
        x: menuRoot.pillX
        y: menuRoot.pillY
        height: Dimensions.contextMenuHeight
        implicitHeight: Dimensions.contextMenuHeight
        implicitWidth: actionRow.implicitWidth + 12
        width: implicitWidth
        radius: Dimensions.radiusMd
        color: Theme.contextMenuBg
        border.color: Theme.contextMenuBorder
        border.width: Dimensions.borderWidthThin

        // Prevent click-through from menu pill to dismiss backdrop
        MouseArea {
            anchors.fill: parent
            onPressed: function(mouse) { mouse.accepted = true; }
        }

        RowLayout {
            id: actionRow
            anchors.centerIn: parent
            spacing: 2

            // Cut Action
            Rectangle {
                visible: menuRoot.hasSelection && !menuRoot.isReadOnly
                implicitWidth: 50
                implicitHeight: 30
                radius: Dimensions.radiusSm
                color: cutMouse.pressed ? Theme.contextMenuPressed : (cutMouse.containsMouse ? Theme.contextMenuHover : "transparent")

                Text {
                    anchors.centerIn: parent
                    text: "Cut"
                    color: Theme.textPrimary
                    font.family: Typography.fontDisplay
                    font.pixelSize: Typography.sizeBadge
                    font.bold: true
                }

                MouseArea {
                    id: cutMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (menuRoot.targetInput && menuRoot.targetInput.cut) {
                            menuRoot.targetInput.cut();
                        }
                        menuRoot.cutTriggered();
                        menuRoot.closeMenu();
                    }
                }
            }

            // Divider
            Rectangle {
                visible: menuRoot.hasSelection && !menuRoot.isReadOnly
                width: 1
                height: 18
                color: Theme.borderDark
            }

            // Copy Action
            Rectangle {
                visible: menuRoot.hasSelection
                implicitWidth: 54
                implicitHeight: 30
                radius: Dimensions.radiusSm
                color: copyMouse.pressed ? Theme.contextMenuPressed : (copyMouse.containsMouse ? Theme.contextMenuHover : "transparent")

                Text {
                    anchors.centerIn: parent
                    text: "Copy"
                    color: Theme.textPrimary
                    font.family: Typography.fontDisplay
                    font.pixelSize: Typography.sizeBadge
                    font.bold: true
                }

                MouseArea {
                    id: copyMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (menuRoot.targetInput && menuRoot.targetInput.copy) {
                            menuRoot.targetInput.copy();
                        }
                        menuRoot.copyTriggered();
                        menuRoot.closeMenu();
                    }
                }
            }

            // Divider
            Rectangle {
                visible: menuRoot.hasSelection && !menuRoot.isReadOnly
                width: 1
                height: 18
                color: Theme.borderDark
            }

            // Paste Action
            Rectangle {
                visible: !menuRoot.isReadOnly
                implicitWidth: 54
                implicitHeight: 30
                radius: Dimensions.radiusSm
                color: pasteMouse.pressed ? Theme.contextMenuPressed : (pasteMouse.containsMouse ? Theme.contextMenuHover : "transparent")

                Text {
                    anchors.centerIn: parent
                    text: "Paste"
                    color: Theme.textPrimary
                    font.family: Typography.fontDisplay
                    font.pixelSize: Typography.sizeBadge
                    font.bold: true
                }

                MouseArea {
                    id: pasteMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (menuRoot.targetInput && menuRoot.targetInput.paste) {
                            menuRoot.targetInput.paste();
                        }
                        menuRoot.pasteTriggered();
                        menuRoot.closeMenu();
                    }
                }
            }

            // Divider
            Rectangle {
                visible: menuRoot.hasText
                width: 1
                height: 18
                color: Theme.borderDark
            }

            // Select All Action
            Rectangle {
                visible: menuRoot.hasText && !menuRoot.isAllSelected
                implicitWidth: 68
                implicitHeight: 30
                radius: Dimensions.radiusSm
                color: selectAllMouse.pressed ? Theme.contextMenuPressed : (selectAllMouse.containsMouse ? Theme.contextMenuHover : "transparent")

                Text {
                    anchors.centerIn: parent
                    text: "Select All"
                    color: Theme.accentCyan
                    font.family: Typography.fontDisplay
                    font.pixelSize: Typography.sizeBadge
                    font.bold: true
                }

                MouseArea {
                    id: selectAllMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (menuRoot.targetInput && menuRoot.targetInput.selectAll) {
                            menuRoot.targetInput.selectAll();
                        }
                        menuRoot.selectAllTriggered();
                        if (menuRoot.targetInput) {
                            menuRoot.openFor(menuRoot.targetInput, menuRoot.lastAnchorX, menuRoot.lastAnchorY, menuRoot.currentVisualAnchor);
                        }
                    }
                }
            }

            // Deselect Action (shown when everything is selected so operator can clear selection)
            Rectangle {
                visible: menuRoot.isAllSelected
                implicitWidth: 68
                implicitHeight: 30
                radius: Dimensions.radiusSm
                color: deselectMouse.pressed ? Theme.contextMenuPressed : (deselectMouse.containsMouse ? Theme.contextMenuHover : "transparent")

                Text {
                    anchors.centerIn: parent
                    text: "Deselect"
                    color: Theme.accentCyan
                    font.family: Typography.fontDisplay
                    font.pixelSize: Typography.sizeBadge
                    font.bold: true
                }

                MouseArea {
                    id: deselectMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (menuRoot.targetInput && menuRoot.targetInput.deselect) {
                            menuRoot.targetInput.deselect();
                        }
                        if (menuRoot.targetInput) {
                            menuRoot.openFor(menuRoot.targetInput, menuRoot.lastAnchorX, menuRoot.lastAnchorY, menuRoot.currentVisualAnchor);
                        }
                    }
                }
            }

            // Divider
            Rectangle {
                visible: menuRoot.showKeyboardAction
                width: 1
                height: 18
                color: Theme.borderDark
            }

            // Keyboard Trigger Action
            Rectangle {
                visible: menuRoot.showKeyboardAction
                implicitWidth: 62
                implicitHeight: 30
                radius: Dimensions.radiusSm
                color: kbMouse.pressed ? Theme.contextMenuPressed : (kbMouse.containsMouse ? Theme.contextMenuHover : "transparent")

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: "KB"
                        color: Theme.accentAmber
                        font.pixelSize: 10
                        font.bold: true
                        font.family: Typography.fontDisplay
                    }
                    Text {
                        text: "Keys"
                        color: Theme.textPrimary
                        font.family: Typography.fontDisplay
                        font.pixelSize: Typography.sizeBadge
                        font.bold: true
                    }
                }

                MouseArea {
                    id: kbMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        menuRoot.keyboardTriggered();
                        menuRoot.closeMenu();
                    }
                }
            }
        }
    }
}
