import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// Detail editor for the selected task: device, action, setpoint, stop condition, hold text.
Rectangle {
    id: inspectorRoot
    implicitWidth: 340
    implicitHeight: 460
    color: "#06182c"
    border.color: "#184d7e"
    border.width: 1
    radius: 6

    property string taskLabel: "Select a task"
    property string taskName: ""
    property int deviceIndex: 0
    property int actionIndex: 0
    property string setpoint: ""
    property int stopIndex: 0
    property string durationSec: "0"
    property bool requireConfirm: false
    property string confirmMessage: ""
    property bool emptySelection: true

    readonly property var deviceOptions: [
        "1M1501 Anchor agitator",
        "1X1001 Homogenizer",
        "1M5001 / 1P5001 Vacuum",
        "1E6001 Jacket heat/cool",
        "1K1001 Charge / CIP valve",
        "1M2001 Discharge pump",
        "1M6001 Recirc pump",
        "MANUAL Operator action"
    ]
    readonly property var actionOptions: ["ON", "OFF", "RAMP"]
    readonly property var stopOptions: [
        "timer (duration)",
        "level_below (min level)",
        "level_above (target level)",
        "temp_above (heating target)",
        "temp_below (cooling target)",
        "manual (operator acknowledge)",
        "vessel_empty (drain complete)"
    ]

    signal nameEdited(string value)
    signal deviceChanged(int index)
    signal actionChanged(int index)
    signal setpointEdited(string value)
    signal stopChanged(int index)
    signal durationEdited(string value)
    signal confirmToggled()
    signal confirmMessageEdited(string value)

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // Header Section
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "TASK PROPERTIES"
                color: "#38bdf8"
                font.bold: true
                font.pixelSize: 11
            }
            Item { Layout.fillWidth: true }
            Rectangle {
                Layout.preferredHeight: 18
                Layout.preferredWidth: 64
                radius: 3
                color: inspectorRoot.requireConfirm ? "#78350f" : "#0d365e"
                border.color: inspectorRoot.requireConfirm ? "#f59e0b" : "#1e40af"
                visible: !inspectorRoot.emptySelection
                Text {
                    anchors.centerIn: parent
                    text: inspectorRoot.requireConfirm ? "21 CFR HOLD" : "AUTO EXEC"
                    color: inspectorRoot.requireConfirm ? "#fde68a" : "#93c5fd"
                    font.pixelSize: 8
                    font.bold: true
                }
            }
        }

        Text {
            text: inspectorRoot.emptySelection ? "Select a task on the left to edit parameters, device routing, and stop conditions." : inspectorRoot.taskLabel
            color: "#94a3b8"
            font.pixelSize: 10
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#1e3a5f"
        }

        // Form Fields (Scrollable if compact vertical space)
        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: formCol.implicitHeight
            flickableDirection: Flickable.VerticalFlick

            ColumnLayout {
                id: formCol
                width: parent.width
                spacing: 6
                enabled: !inspectorRoot.emptySelection
                opacity: inspectorRoot.emptySelection ? 0.35 : 1.0

                // Field: Task Name
                Text { text: "TASK DESCRIPTION"; color: "#7dd3fc"; font.pixelSize: 9; font.bold: true }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    radius: 4
                    color: "#0a243f"
                    border.color: nameInput.activeFocus ? "#00d2ff" : "#1d5b94"
                    border.width: 1

                    TextInput {
                        id: nameInput
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: TextInput.AlignVCenter
                        text: inspectorRoot.taskName
                        color: "#ffffff"
                        font.pixelSize: 11
                        selectByMouse: true
                        onEditingFinished: inspectorRoot.nameEdited(text)
                    }
                }

                // Field: P&ID Device
                Text { text: "P&ID EQUIPMENT DEVICE"; color: "#7dd3fc"; font.pixelSize: 9; font.bold: true }
                ComboBox {
                    id: deviceCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    model: inspectorRoot.deviceOptions
                    currentIndex: inspectorRoot.deviceIndex
                    onActivated: inspectorRoot.deviceChanged(index)

                    background: Rectangle {
                        color: "#0a243f"
                        border.color: deviceCombo.activeFocus ? "#00d2ff" : "#1d5b94"
                        border.width: 1
                        radius: 4
                    }
                    contentItem: Text {
                        leftPadding: 8
                        text: deviceCombo.currentText
                        color: "#ffffff"
                        font.pixelSize: 10
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    popup: Popup {
                        y: deviceCombo.height + 2
                        width: deviceCombo.width
                        implicitHeight: Math.min(220, contentItem.implicitHeight + 8)
                        padding: 2
                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: deviceCombo.popup.visible ? deviceCombo.delegateModel : null
                            currentIndex: deviceCombo.highlightedIndex
                            ScrollIndicator.vertical: ScrollIndicator { }
                        }
                        background: Rectangle {
                            color: "#08213b"
                            border.color: "#00d2ff"
                            border.width: 1
                            radius: 4
                        }
                    }
                    delegate: ItemDelegate {
                        width: deviceCombo.width
                        height: 28
                        contentItem: Text {
                            text: modelData
                            color: highlighted ? "#00d2ff" : "#ffffff"
                            font.pixelSize: 10
                            font.bold: highlighted
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: highlighted ? "#155590" : "transparent"
                        }
                    }
                }

                // Field: Action Mode
                Text { text: "DEVICE COMMAND / ACTION"; color: "#7dd3fc"; font.pixelSize: 9; font.bold: true }
                ComboBox {
                    id: actionCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    model: inspectorRoot.actionOptions
                    currentIndex: inspectorRoot.actionIndex
                    onActivated: inspectorRoot.actionChanged(index)

                    background: Rectangle {
                        color: "#0a243f"
                        border.color: actionCombo.activeFocus ? "#00d2ff" : "#1d5b94"
                        border.width: 1
                        radius: 4
                    }
                    contentItem: Text {
                        leftPadding: 8
                        text: actionCombo.currentText
                        color: "#ffffff"
                        font.pixelSize: 10
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                    }
                    popup: Popup {
                        y: actionCombo.height + 2
                        width: actionCombo.width
                        implicitHeight: Math.min(150, contentItem.implicitHeight + 8)
                        padding: 2
                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: actionCombo.popup.visible ? actionCombo.delegateModel : null
                            currentIndex: actionCombo.highlightedIndex
                        }
                        background: Rectangle {
                            color: "#08213b"
                            border.color: "#00d2ff"
                            border.width: 1
                            radius: 4
                        }
                    }
                    delegate: ItemDelegate {
                        width: actionCombo.width
                        height: 28
                        contentItem: Text {
                            text: modelData
                            color: highlighted ? "#00d2ff" : "#ffffff"
                            font.pixelSize: 10
                            font.bold: highlighted
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: highlighted ? "#155590" : "transparent"
                        }
                    }
                }

                // Field: Setpoint & Target
                Text { text: "SETPOINT (RPM / °C / % / mbar)"; color: "#7dd3fc"; font.pixelSize: 9; font.bold: true }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    radius: 4
                    color: "#0a243f"
                    border.color: spInput.activeFocus ? "#00d2ff" : "#1d5b94"
                    border.width: 1

                    TextInput {
                        id: spInput
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: TextInput.AlignVCenter
                        text: inspectorRoot.setpoint
                        color: "#38bdf8"
                        font.bold: true
                        font.pixelSize: 11
                        selectByMouse: true
                        onEditingFinished: inspectorRoot.setpointEdited(text)
                    }
                }

                // Field: Stop Condition
                Text { text: "PHASE STOP CONDITION"; color: "#7dd3fc"; font.pixelSize: 9; font.bold: true }
                ComboBox {
                    id: stopCombo
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    model: inspectorRoot.stopOptions
                    currentIndex: inspectorRoot.stopIndex
                    onActivated: inspectorRoot.stopChanged(index)

                    background: Rectangle {
                        color: "#0a243f"
                        border.color: stopCombo.activeFocus ? "#00d2ff" : "#1d5b94"
                        border.width: 1
                        radius: 4
                    }
                    contentItem: Text {
                        leftPadding: 8
                        text: stopCombo.currentText
                        color: "#ffffff"
                        font.pixelSize: 10
                        font.bold: true
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    popup: Popup {
                        y: stopCombo.height + 2
                        width: stopCombo.width
                        implicitHeight: Math.min(220, contentItem.implicitHeight + 8)
                        padding: 2
                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: stopCombo.popup.visible ? stopCombo.delegateModel : null
                            currentIndex: stopCombo.highlightedIndex
                        }
                        background: Rectangle {
                            color: "#08213b"
                            border.color: "#00d2ff"
                            border.width: 1
                            radius: 4
                        }
                    }
                    delegate: ItemDelegate {
                        width: stopCombo.width
                        height: 28
                        contentItem: Text {
                            text: modelData
                            color: highlighted ? "#00d2ff" : "#ffffff"
                            font.pixelSize: 10
                            font.bold: highlighted
                            verticalAlignment: Text.AlignVCenter
                        }
                        background: Rectangle {
                            color: highlighted ? "#155590" : "transparent"
                        }
                    }
                }

                // Field: Duration (seconds)
                Text { text: "DURATION ESTIMATE (SECONDS)"; color: "#7dd3fc"; font.pixelSize: 9; font.bold: true }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 30
                    radius: 4
                    color: "#0a243f"
                    border.color: durInput.activeFocus ? "#00d2ff" : "#1d5b94"
                    border.width: 1

                    TextInput {
                        id: durInput
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: TextInput.AlignVCenter
                        text: inspectorRoot.durationSec
                        color: "#4ade80"
                        font.bold: true
                        font.pixelSize: 11
                        selectByMouse: true
                        onEditingFinished: inspectorRoot.durationEdited(text)
                    }
                }

                // 21 CFR Hold Point Toggle
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 4
                    color: inspectorRoot.requireConfirm ? "#451a03" : "#0a243f"
                    border.color: inspectorRoot.requireConfirm ? "#f59e0b" : "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8

                        Text {
                            text: "21 CFR Part 11 Hold Point / E-Sign"
                            color: inspectorRoot.requireConfirm ? "#fde68a" : "#cbd5e1"
                            font.bold: true
                            font.pixelSize: 10
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 20
                            radius: 10
                            color: inspectorRoot.requireConfirm ? "#f59e0b" : "#334155"

                            Rectangle {
                                width: 16
                                height: 16
                                radius: 8
                                color: "#ffffff"
                                anchors.verticalCenter: parent.verticalCenter
                                x: inspectorRoot.requireConfirm ? parent.width - width - 2 : 2
                                Behavior on x { NumberAnimation { duration: 120 } }
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: inspectorRoot.confirmToggled()
                    }
                }

                // Confirm Message Input (Visible if Hold Point Active)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: inspectorRoot.requireConfirm

                    Text { text: "OPERATOR PROMPT / SOP CONFIRMATION MESSAGE"; color: "#f59e0b"; font.pixelSize: 8; font.bold: true }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 46
                        radius: 4
                        color: "#0a243f"
                        border.color: msgInput.activeFocus ? "#f59e0b" : "#78350f"
                        border.width: 1

                        TextEdit {
                            id: msgInput
                            anchors.fill: parent
                            anchors.margins: 6
                            text: inspectorRoot.confirmMessage
                            color: "#ffffff"
                            font.pixelSize: 10
                            wrapMode: TextEdit.WordWrap
                            selectByMouse: true
                            onEditingFinished: inspectorRoot.confirmMessageEdited(text)
                        }
                    }
                }
            }
        }
    }
}
