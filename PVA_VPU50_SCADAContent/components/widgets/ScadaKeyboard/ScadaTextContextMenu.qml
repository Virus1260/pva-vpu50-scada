pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../../theme"

Rectangle {
    id: menuRoot
    height: Dimensions.contextMenuHeight
    implicitHeight: Dimensions.contextMenuHeight
    implicitWidth: actionRow.implicitWidth + 12
    width: implicitWidth
    radius: Dimensions.radiusMd
    color: Theme.contextMenuBg
    border.color: Theme.contextMenuBorder
    border.width: Dimensions.borderWidthThin
    z: 99999
    visible: active && opacity > 0.01
    opacity: active ? 1.0 : 0.0

    Behavior on opacity {
        NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
    }

    property var targetInput: null
    property bool active: false

    readonly property bool hasSelection: targetInput && targetInput.selectedText && targetInput.selectedText.length > 0
    readonly property bool hasText: targetInput && targetInput.text && targetInput.text.length > 0
    readonly property bool isReadOnly: targetInput ? targetInput.readOnly : false

    signal cutTriggered()
    signal copyTriggered()
    signal pasteTriggered()
    signal selectAllTriggered()

    function openFor(inputItem, anchorX, anchorY) {
        targetInput = inputItem;
        active = true;
        if (!parent) return;

        var globalPos = inputItem.mapToItem(parent, anchorX !== undefined ? anchorX : (inputItem.width / 2), anchorY !== undefined ? anchorY : 0);
        var targetX = globalPos.x - (width / 2);
        var targetY = globalPos.y - height - 8;

        if (targetY < 8) {
            targetY = globalPos.y + (inputItem.height ? inputItem.height : 32) + 8;
        }

        menuRoot.x = Math.max(8, Math.min(parent.width - width - 8, targetX));
        menuRoot.y = Math.max(8, Math.min(parent.height - height - 8, targetY));
    }

    function closeMenu() {
        active = false;
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
            visible: menuRoot.hasText
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
                    menuRoot.closeMenu();
                }
            }
        }
    }
}
