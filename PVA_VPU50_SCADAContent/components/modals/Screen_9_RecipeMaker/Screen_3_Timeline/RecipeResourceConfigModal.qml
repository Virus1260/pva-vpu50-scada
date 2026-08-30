pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import "../../../widgets"
import "../../../widgets/Screen_9_RecipeMaker/Screen_3_Timeline"

Rectangle {
    id: resConfigRoot
    implicitWidth: 1024
    implicitHeight: 600
    color: "#bb000000"
    visible: false
    z: 100

    property string stageId: "1.1"
    property string phaseName: "Phase A"
    property string resourceType: "agitator" // "agitator", "homogenizer", "vacuum", "heater", "valve"
    property string resourceName: "1M1501 Stirrer"
    property string unit: "RPM"
    property double minLimit: 0.0
    property double maxLimit: 60.0
    property string setValue: "25.0"
    property string purpose: "Material Loading"
    property var selectedMaterials: []
    property var availableMaterials: []
    property bool manualConfirm: false
    property string hmiMessage: "Material {{SELECTED_LIST}} loaded. Close Valve."
    property int durationSec: 180
    property string stopConditionType: "timer"

    signal accepted(var config)
    signal cancelled

    MouseArea {
        anchors.fill: parent
    }

    Rectangle {
        id: card
        anchors.centerIn: parent
        width: 720
        height: 550
        color: "#0b2e52"
        border.color: "#38bdf8"
        border.width: 2
        radius: 8

        // Top-Right Corner Close Button
        Rectangle {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 14
            anchors.rightMargin: 14
            width: 28
            height: 28
            radius: 4
            z: 10
            color: closeMouse.containsMouse ? "#ef4444" : "#0d365e"
            border.color: closeMouse.containsMouse ? "#f87171" : "#1d5b94"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: closeMouse.containsMouse ? "#ffffff" : "#94a3b8"
                font.pixelSize: 13
                font.bold: true
                font.family: "Segoe UI"
            }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: resConfigRoot.cancelled()
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10

            // 1. Header Bar with Read-Only Stage & Phase Badges
            RowLayout {
                Layout.fillWidth: true
                Layout.rightMargin: 36 // Reserve space for top-right close button
                spacing: 10

                ScadaIcon {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    iconName: "act_equip"
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text {
                        text: "RESOURCE CONFIGURATION: " + resConfigRoot.resourceName.toUpperCase()
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 13
                    }
                    Text {
                        text: "Physical Machine Setpoints, Interlocks & 21 CFR Part 11 Sign-off Gates"
                        color: "#94a3b8"
                        font.pixelSize: 10
                    }
                }

                // Read-Only Stage ID Badge
                Rectangle {
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: stageTxt.implicitWidth + 12
                    radius: 4
                    color: "#081d33"
                    border.color: "#38bdf8"
                    border.width: 1

                    Text {
                        id: stageTxt
                        anchors.centerIn: parent
                        text: "Stage " + resConfigRoot.stageId
                        color: "#38bdf8"
                        font.bold: true
                        font.pixelSize: 11
                    }
                }

                // Read-Only Phase Badge
                Rectangle {
                    Layout.preferredHeight: 26
                    Layout.preferredWidth: phaseTxt.implicitWidth + 12
                    radius: 4
                    color: "#164e85"
                    border.color: "#60a5fa"
                    border.width: 1

                    Text {
                        id: phaseTxt
                        anchors.centerIn: parent
                        text: resConfigRoot.phaseName
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: "#1d5b94"
            }

            // 2. Setpoint & Purpose Grid
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 12
                rowSpacing: 8

                // Field 1: Set Value (Bounded by Machine Min/Max)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: "SET VALUE (" + resConfigRoot.unit + ") [LIMITS: " + resConfigRoot.minLimit + " to " + resConfigRoot.maxLimit + "] *"
                        color: "#38bdf8"
                        font.pixelSize: 11
                        font.bold: true
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        color: "#081d33"
                        border.color: valInput.activeFocus ? "#38bdf8" : "#1d5b94"
                        border.width: 1
                        radius: 4

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 6

                            TextInput {
                                id: valInput
                                Layout.fillWidth: true
                                text: resConfigRoot.setValue
                                color: "#ffffff"
                                font.bold: true
                                font.pixelSize: 12
                                selectByMouse: true
                                onTextChanged: resConfigRoot.setValue = text
                            }

                            Text {
                                text: resConfigRoot.unit
                                color: "#94a3b8"
                                font.bold: true
                                font.pixelSize: 11
                            }
                        }
                    }
                }

                // Field 2: Purpose Dropdown Selector
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: "OPERATION PURPOSE *"
                        color: "#cbd5e1"
                        font.pixelSize: 11
                        font.bold: true
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Repeater {
                            model: ["Material Loading", "Emulsification", "De-aeration", "Soak"]
                            delegate: Rectangle {
                                id: purpBtn
                                required property string modelData
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                radius: 4
                                color: resConfigRoot.purpose === purpBtn.modelData ? "#164e85" : "#081d33"
                                border.color: resConfigRoot.purpose === purpBtn.modelData ? "#38bdf8" : "#1d5b94"
                                border.width: 1

                                Text {
                                    anchors.centerIn: parent
                                    text: purpBtn.modelData
                                    color: resConfigRoot.purpose === purpBtn.modelData ? "#ffffff" : "#94a3b8"
                                    font.pixelSize: 9
                                    font.bold: resConfigRoot.purpose === purpBtn.modelData
                                    elide: Text.ElideRight
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: resConfigRoot.purpose = purpBtn.modelData
                                }
                            }
                        }
                    }
                }
            }

            // 3. Material Selector (Pill Tags matching Naukri UI image_cfb2ce.png)
            RecipeFlowTagSelector {
                id: tagPicker
                Layout.fillWidth: true
                selectedTags: resConfigRoot.selectedMaterials
                availableTags: resConfigRoot.availableMaterials
                onTagsChanged: function(tags) {
                    resConfigRoot.selectedMaterials = tags;
                }
            }

            // 4. Manual Confirmation Toggle (YES / NO)
            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "MANUAL CONFIRMATION HOLD (21 CFR PART 11):"
                    color: "#cbd5e1"
                    font.pixelSize: 11
                    font.bold: true
                }

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 30
                    radius: 4
                    color: resConfigRoot.manualConfirm ? "#059669" : "#081d33"
                    border.color: resConfigRoot.manualConfirm ? "#34d399" : "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: resConfigRoot.manualConfirm ? "✓ YES" : "YES"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 11
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: resConfigRoot.manualConfirm = true
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 80
                    Layout.preferredHeight: 30
                    radius: 4
                    color: !resConfigRoot.manualConfirm ? "#0369a1" : "#081d33"
                    border.color: !resConfigRoot.manualConfirm ? "#38bdf8" : "#1d5b94"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 4
                        Text {
                            text: !resConfigRoot.manualConfirm ? "✓ NO" : "NO"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 11
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: resConfigRoot.manualConfirm = false
                    }
                }

                Item { Layout.fillWidth: true }
            }

            // 5. Conditional Input Area based on Manual Confirmation Toggle
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46
                color: "#081d33"
                border.color: resConfigRoot.manualConfirm ? "#34d399" : "#38bdf8"
                border.width: 1
                radius: 4

                // IF YES: Show HMI Display Message Input
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 8
                    visible: resConfigRoot.manualConfirm

                    Text {
                        text: "HMI Display Message:"
                        color: "#34d399"
                        font.bold: true
                        font.pixelSize: 11
                    }

                    TextInput {
                        id: hmiInput
                        Layout.fillWidth: true
                        text: resConfigRoot.hmiMessage
                        color: "#ffffff"
                        font.pixelSize: 11
                        selectByMouse: true
                        onTextChanged: resConfigRoot.hmiMessage = text
                    }
                }

                // IF NO: Show Duration / Time Input Field
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 6
                    spacing: 8
                    visible: !resConfigRoot.manualConfirm

                    Text {
                        text: "Execution Duration (Seconds / Min):"
                        color: "#38bdf8"
                        font.bold: true
                        font.pixelSize: 11
                    }

                    TextInput {
                        id: durInput
                        Layout.preferredWidth: 100
                        text: String(resConfigRoot.durationSec)
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 12
                        selectByMouse: true
                        onTextChanged: resConfigRoot.durationSec = parseInt(text) || 180
                    }

                    Text {
                        text: "sec (" + Math.round(resConfigRoot.durationSec / 60) + " min)"
                        color: "#94a3b8"
                        font.pixelSize: 11
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "Stop Condition: Timer Count"
                        color: "#64748b"
                        font.pixelSize: 10
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // 6. Bottom Right Action Buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                Rectangle {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 36
                    radius: 4
                    color: cancelMouse.containsMouse ? "#334155" : "#1e293b"
                    border.color: "#475569"
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "Cancel"
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 11
                    }

                    MouseArea {
                        id: cancelMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: resConfigRoot.cancelled()
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 160
                    Layout.preferredHeight: 36
                    radius: 4
                    color: saveMouse.containsMouse ? "#0284c7" : "#0284c7"
                    border.color: "#38bdf8"
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Text {
                            text: "Save Configuration"
                            color: "#ffffff"
                            font.bold: true
                            font.pixelSize: 12
                        }
                    }

                    MouseArea {
                        id: saveMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            var numVal = parseFloat(resConfigRoot.setValue);
                            if (isNaN(numVal)) numVal = resConfigRoot.minLimit;
                            // Clamp within limits
                            numVal = Math.max(resConfigRoot.minLimit, Math.min(resConfigRoot.maxLimit, numVal));

                            var config = {
                                stageId: resConfigRoot.stageId,
                                phase: resConfigRoot.phaseName,
                                resourceType: resConfigRoot.resourceType,
                                resourceName: resConfigRoot.resourceName,
                                setValue: numVal,
                                unit: resConfigRoot.unit,
                                purpose: resConfigRoot.purpose,
                                materials: resConfigRoot.selectedMaterials.slice(),
                                requireConfirm: resConfigRoot.manualConfirm,
                                confirmMessage: resConfigRoot.hmiMessage,
                                durationSec: resConfigRoot.manualConfirm ? 0 : resConfigRoot.durationSec,
                                stopCondition: resConfigRoot.stopConditionType
                            };
                            resConfigRoot.accepted(config);
                        }
                    }
                }
            }
        }
    }
}
