pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import "../../../theme"
import "../../common"

Item {
    id: fieldRoot
    implicitWidth: 320
    implicitHeight: labelText !== "" ? (labelRow.implicitHeight + Dimensions.spaceXs + boxHeight) : boxHeight
    width: implicitWidth
    height: implicitHeight

    property string labelText: ""
    property bool isRequired: false
    property string placeholderText: ""
    property string unitText: ""
    property string iconName: ""
    property string iconSource: ""
    property bool isCompact: false
    property bool isError: false
    property string errorMessage: ""

    // Virtual Keyboard / Keypad Integration
    property var keyboardTarget: null
    property string keyboardTitle: labelText !== "" ? labelText : "INPUT VALUE"

    // Forwarded TextInput properties
    property alias text: innerInput.text
    property alias displayText: innerInput.displayText
    property alias cursorPosition: innerInput.cursorPosition
    property alias inputMethodHints: innerInput.inputMethodHints
    property alias echoMode: innerInput.echoMode
    property alias readOnly: innerInput.readOnly
    property alias activeFocus: innerInput.activeFocus
    property alias innerTextInput: innerInput
    property alias font: innerInput.font

    signal editingFinished()
    signal accepted()
    signal textEdited()
    signal inputOpened()

    readonly property int boxHeight: isCompact ? Dimensions.boxSizeSm : Dimensions.boxSizeMd

    function forceFocus() {
        innerInput.forceActiveFocus();
    }

    function openKeyboard() {
        innerInput.forceActiveFocus();
        if (keyboardTarget) {
            if (typeof keyboardTarget.openFor === "function") {
                keyboardTarget.openFor(innerInput, keyboardTitle, unitText);
            } else if (typeof keyboardTarget.openForInput === "function") {
                keyboardTarget.openForInput(innerInput, keyboardTitle, unitText);
            }
        }
        fieldRoot.inputOpened();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Dimensions.spaceXs

        // Header Label & Status Indicator Row
        RowLayout {
            id: labelRow
            visible: fieldRoot.labelText !== "" || fieldRoot.isError
            Layout.fillWidth: true
            spacing: Dimensions.spaceSm

            Text {
                visible: fieldRoot.labelText !== ""
                text: fieldRoot.labelText
                color: innerInput.activeFocus ? Theme.accentCyan : "#cbd5e1"
                font.pixelSize: Typography.sizeBadge
                font.bold: true
                font.family: Typography.fontDisplay
            }

            Text {
                visible: fieldRoot.isRequired
                text: "*"
                color: Theme.statusDanger
                font.pixelSize: Typography.sizeBadge
                font.bold: true
            }

            Item { Layout.fillWidth: true }

            Text {
                visible: fieldRoot.isError && fieldRoot.errorMessage !== ""
                text: fieldRoot.errorMessage
                color: Theme.statusDanger
                font.pixelSize: Typography.sizeMicro
                font.bold: true
                font.family: Typography.fontDisplay
            }
        }

        // Tactile Input Box Container
        Rectangle {
            id: inputBox
            Layout.fillWidth: true
            Layout.preferredHeight: fieldRoot.boxHeight
            radius: Dimensions.radiusSm
            color: innerInput.activeFocus ? "#0b2644" : "#081d33"
            border.color: fieldRoot.isError ? Theme.statusDanger : (innerInput.activeFocus ? Theme.borderActive : Theme.borderBright)
            border.width: innerInput.activeFocus ? Dimensions.borderWidthThick : Dimensions.borderWidthThin

            Behavior on color { ColorAnimation { duration: 120 } }
            Behavior on border.color { ColorAnimation { duration: 120 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Dimensions.spaceSm + 2
                anchors.rightMargin: Dimensions.spaceSm + 2
                spacing: Dimensions.spaceSm

                // Prefix Icon Slot
                ScadaIcon {
                    visible: fieldRoot.iconName !== "" || fieldRoot.iconSource !== ""
                    width: 16
                    height: 16
                    iconName: fieldRoot.iconName
                    iconSource: fieldRoot.iconSource
                    iconColor: innerInput.activeFocus ? Theme.accentCyan : "#94a3b8"
                }

                // Core TextInput with Placeholder
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Text {
                        id: placeholder
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        visible: innerInput.text === "" && !innerInput.activeFocus
                        text: fieldRoot.placeholderText
                        color: "#64748b"
                        font.family: Typography.fontDisplay
                        font.pixelSize: Typography.sizeBody
                        font.bold: false
                    }

                    TextInput {
                        id: innerInput
                        anchors.fill: parent
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.textPrimary
                        selectionColor: Theme.selectionHighlight
                        selectedTextColor: "#ffffff"
                        selectByMouse: false // Custom touch ergonomics with magnifying loupe
                        font.family: Typography.fontDisplay
                        font.pixelSize: Typography.sizeBody
                        font.bold: true
                        clip: true

                        onEditingFinished: fieldRoot.editingFinished()
                        onAccepted: fieldRoot.accepted()
                        onTextEdited: fieldRoot.textEdited()

                        Keys.onEscapePressed: function(event) {
                            innerInput.focus = false;
                            event.accepted = true;
                        }
                    }
                }

                // Suffix Unit Badge
                Text {
                    visible: fieldRoot.unitText !== ""
                    text: fieldRoot.unitText
                    color: innerInput.activeFocus ? Theme.accentCyan : "#94a3b8"
                    font.family: Typography.fontDisplay
                    font.pixelSize: Typography.sizeBadge
                    font.bold: true
                }
            }

            // Touch Area Handling Loupe Drag & Context Menu
            MouseArea {
                id: touchMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.IBeamCursor

                property bool isDraggingLoupe: false
                property real pressStartX: 0
                property real pressStartY: 0

                Timer {
                    id: longPressTimer
                    interval: 220
                    repeat: false
                    onTriggered: {
                        touchMouseArea.isDraggingLoupe = true;
                        loupeInstance.active = true;
                        loupeInstance.fingerX = touchMouseArea.pressStartX;
                        loupeInstance.fingerY = touchMouseArea.pressStartY;
                    }
                }

                onPressed: function(mouse) {
                    pressStartX = mouse.x;
                    pressStartY = mouse.y;
                    longPressTimer.restart();

                    var pos = innerInput.positionAt(mouse.x);
                    innerInput.cursorPosition = pos;
                    innerInput.forceActiveFocus();
                    fieldRoot.openKeyboard();
                }

                onPositionChanged: function(mouse) {
                    var dx = Math.abs(mouse.x - pressStartX);
                    var dy = Math.abs(mouse.y - pressStartY);
                    if (dx > 6 || dy > 6) {
                        isDraggingLoupe = true;
                        loupeInstance.active = true;
                    }

                    if (isDraggingLoupe) {
                        var pos = innerInput.positionAt(mouse.x);
                        innerInput.cursorPosition = pos;
                        loupeInstance.fingerX = mouse.x;
                        loupeInstance.fingerY = mouse.y;
                    }
                }

                onReleased: function(mouse) {
                    longPressTimer.stop();
                    isDraggingLoupe = false;
                    loupeInstance.active = false;
                }

                onCanceled: function() {
                    longPressTimer.stop();
                    isDraggingLoupe = false;
                    loupeInstance.active = false;
                }

                onDoubleClicked: function(mouse) {
                    longPressTimer.stop();
                    isDraggingLoupe = false;
                    loupeInstance.active = false;
                    innerInput.selectWord();
                    contextMenuInstance.openFor(innerInput, mouse.x, mouse.y);
                }
            }
        }
    }

    // Touch Magnifying Loupe Instance
    ScadaTouchLoupe {
        id: loupeInstance
        targetInput: innerInput
        Component.onCompleted: {
            if (fieldRoot.Window && fieldRoot.Window.contentItem) {
                parent = fieldRoot.Window.contentItem;
            }
        }
    }

    // Floating Context Menu Instance (Cut / Copy / Paste / Select All)
    ScadaTextContextMenu {
        id: contextMenuInstance
        targetInput: innerInput
        Component.onCompleted: {
            if (fieldRoot.Window && fieldRoot.Window.contentItem) {
                parent = fieldRoot.Window.contentItem;
            }
        }
    }
}
