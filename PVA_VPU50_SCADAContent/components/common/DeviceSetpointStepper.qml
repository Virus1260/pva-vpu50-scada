import QtQuick
import QtQuick.Layouts

Rectangle {
    id: stepperRoot
    implicitWidth: 320
    implicitHeight: 54
    Layout.fillWidth: true
    Layout.preferredHeight: 54

    // Configurable Properties
    property real minValue: 25.0
    property real maxValue: 120.0
    property real stepSize: 1.0
    property real value: 25.0
    property string unitText: "RPM"
    property int decimals: 1
    property bool readOnly: false
    property bool isLocked: false
    property string parameterTitle: "Setpoint"
    property string parameterTag: ""

    signal valueModified(real newValue)
    signal setpointRequested(string title, string tag, double current, double min, double max, string unit)

    color: "#0a2e50"
    border.color: "#1d5b94"
    border.width: 1
    radius: 4
    clip: true

    function applyValue(newVal) {
        if (readOnly || isLocked) return;
        var clamped = Math.max(minValue, Math.min(maxValue, newVal));
        if (decimals === 0) {
            clamped = Math.round(clamped);
        } else {
            clamped = Math.round(clamped * 10.0) / 10.0;
        }
        stepperRoot.value = clamped;
        stepperRoot.valueModified(clamped);
    }

    // Auto-repeat timers for continuous hold
    Timer {
        id: decRepeatTimer
        interval: 100
        repeat: true
        running: false
        onTriggered: {
            stepperRoot.applyValue(stepperRoot.value - stepperRoot.stepSize);
        }
    }

    Timer {
        id: decInitialTimer
        interval: 400
        repeat: false
        onTriggered: {
            if (decMouse.pressed) decRepeatTimer.start();
        }
    }

    Timer {
        id: incRepeatTimer
        interval: 100
        repeat: true
        running: false
        onTriggered: {
            stepperRoot.applyValue(stepperRoot.value + stepperRoot.stepSize);
        }
    }

    Timer {
        id: incInitialTimer
        interval: 400
        repeat: false
        onTriggered: {
            if (incMouse.pressed) incRepeatTimer.start();
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // =====================================================================
        // 1. SET MIN COMPARTMENT (TOUCH TARGET 64px)
        // =====================================================================
        Rectangle {
            id: minCompartment
            Layout.preferredWidth: 64
            Layout.fillHeight: true
            color: minMouse.pressed ? "#07203a" : (minMouse.containsMouse ? "#0f3c69" : "#082646")
            enabled: !stepperRoot.readOnly && !stepperRoot.isLocked

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    text: "SET MIN"
                    color: "#8cb5dc"
                    font.pixelSize: 9
                    font.bold: true
                    font.family: "Segoe UI"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: stepperRoot.minValue.toFixed(stepperRoot.decimals === 0 ? 0 : 1)
                    color: "#38bdf8"
                    font.bold: true
                    font.pixelSize: 12
                    font.family: "Consolas"
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            MouseArea {
                id: minMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: stepperRoot.applyValue(stepperRoot.minValue)
            }
        }

        // Divider
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: "#1d5b94"
        }

        // =====================================================================
        // 2. INDUSTRIAL MINUS BUTTON (TOUCH TARGET 52px)
        // =====================================================================
        Rectangle {
            id: decBtn
            Layout.preferredWidth: 52
            Layout.fillHeight: true
            color: decMouse.pressed ? "#07203a" : (decMouse.containsMouse ? "#185590" : "#124373")
            enabled: !stepperRoot.readOnly && !stepperRoot.isLocked && stepperRoot.value > stepperRoot.minValue
            opacity: enabled ? 1.0 : 0.4

            Text {
                anchors.centerIn: parent
                text: "−"
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 22
            }

            MouseArea {
                id: decMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onPressed: {
                    stepperRoot.applyValue(stepperRoot.value - stepperRoot.stepSize);
                    decInitialTimer.start();
                }
                onReleased: {
                    decInitialTimer.stop();
                    decRepeatTimer.stop();
                }
                onCanceled: {
                    decInitialTimer.stop();
                    decRepeatTimer.stop();
                }
            }
        }

        // Divider
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: "#1d5b94"
        }

        // =====================================================================
        // 3. CENTER VALUE CHANNEL (TOUCHABLE VALUE PUTTER TRIGGER)
        // =====================================================================
        Rectangle {
            id: centerChannel
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: channelMouse.containsMouse ? "#0b2644" : "#071c33"
            clip: true

            Behavior on color { ColorAnimation { duration: 100 } }

            // Range Fill Bar (Blue Glow)
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: {
                    var range = Math.max(0.001, stepperRoot.maxValue - stepperRoot.minValue);
                    var fraction = Math.max(0.0, Math.min(1.0, (stepperRoot.value - stepperRoot.minValue) / range));
                    return Math.max(0, parent.width * fraction);
                }
                color: "#0369a1"
                opacity: 0.35
            }

            // Target Needle / Slider indicator
            Rectangle {
                x: {
                    var range = Math.max(0.001, stepperRoot.maxValue - stepperRoot.minValue);
                    var fraction = Math.max(0.0, Math.min(1.0, (stepperRoot.value - stepperRoot.minValue) / range));
                    return Math.max(0, Math.min(parent.width - 3, (parent.width - 3) * fraction));
                }
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: 3
                color: "#ffffff"
                border.color: "#38bdf8"
                border.width: 1
                radius: 1.5
            }

            // Centered Value & Unit (Elevated Badge with z: 2 to prevent needle collision)
            Rectangle {
                anchors.centerIn: parent
                width: valueLayout.implicitWidth + 16
                height: 32
                radius: 4
                color: channelMouse.containsMouse ? "#0b2644" : "#071b33"
                border.color: channelMouse.containsMouse ? "#38bdf8" : "#1d5b94"
                border.width: 1
                z: 2

                RowLayout {
                    id: valueLayout
                    anchors.centerIn: parent
                    spacing: 7

                    // Keypad Icon Badge
                    Rectangle {
                        width: 15
                        height: 13
                        radius: 2
                        color: "#06182c"
                        border.color: channelMouse.containsMouse ? "#38bdf8" : "#0284c7"
                        border.width: 1

                        Grid {
                            anchors.centerIn: parent
                            columns: 3
                            spacing: 1.5
                            Repeater {
                                model: 6
                                Rectangle {
                                    width: 1.5
                                    height: 1.5
                                    radius: 0.3
                                    color: "#38bdf8"
                                }
                            }
                        }
                    }

                    Text {
                        text: stepperRoot.value.toFixed(stepperRoot.decimals === 0 ? 0 : 1)
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 16
                        font.family: "Consolas"
                    }

                    Text {
                        text: stepperRoot.unitText
                        color: "#8cb5dc"
                        font.pixelSize: 11
                        font.bold: true
                        font.family: "Segoe UI"
                    }
                }
            }

            // Click / Drag MouseArea (Emits setpointRequested)
            MouseArea {
                id: channelMouse
                anchors.fill: parent
                enabled: !stepperRoot.readOnly && !stepperRoot.isLocked
                hoverEnabled: true
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                function updateFromMouse(posX) {
                    var range = stepperRoot.maxValue - stepperRoot.minValue;
                    var ratio = Math.max(0.0, Math.min(1.0, posX / centerChannel.width));
                    var raw = stepperRoot.minValue + (ratio * range);
                    var stepped = Math.round(raw / stepperRoot.stepSize) * stepperRoot.stepSize;
                    stepperRoot.applyValue(stepped);
                }

                onClicked: {
                    stepperRoot.setpointRequested(
                        stepperRoot.parameterTitle,
                        stepperRoot.parameterTag,
                        stepperRoot.value,
                        stepperRoot.minValue,
                        stepperRoot.maxValue,
                        stepperRoot.unitText
                    );
                }
                onPositionChanged: function(mouse) {
                    if (pressed) updateFromMouse(mouse.x);
                }
            }
        }

        // Divider
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: "#1d5b94"
        }

        // =====================================================================
        // 4. INDUSTRIAL PLUS BUTTON (TOUCH TARGET 52px)
        // =====================================================================
        Rectangle {
            id: incBtn
            Layout.preferredWidth: 52
            Layout.fillHeight: true
            color: incMouse.pressed ? "#07203a" : (incMouse.containsMouse ? "#185590" : "#124373")
            enabled: !stepperRoot.readOnly && !stepperRoot.isLocked && stepperRoot.value < stepperRoot.maxValue
            opacity: enabled ? 1.0 : 0.4

            Text {
                anchors.centerIn: parent
                text: "+"
                color: "#ffffff"
                font.bold: true
                font.pixelSize: 22
            }

            MouseArea {
                id: incMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onPressed: {
                    stepperRoot.applyValue(stepperRoot.value + stepperRoot.stepSize);
                    incInitialTimer.start();
                }
                onReleased: {
                    incInitialTimer.stop();
                    incRepeatTimer.stop();
                }
                onCanceled: {
                    incInitialTimer.stop();
                    incRepeatTimer.stop();
                }
            }
        }

        // Divider
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: "#1d5b94"
        }

        // =====================================================================
        // 5. SET MAX COMPARTMENT (TOUCH TARGET 64px)
        // =====================================================================
        Rectangle {
            id: maxCompartment
            Layout.preferredWidth: 64
            Layout.fillHeight: true
            color: maxMouse.pressed ? "#07203a" : (maxMouse.containsMouse ? "#0f3c69" : "#082646")
            enabled: !stepperRoot.readOnly && !stepperRoot.isLocked

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2

                Text {
                    text: "SET MAX"
                    color: "#8cb5dc"
                    font.pixelSize: 9
                    font.bold: true
                    font.family: "Segoe UI"
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: stepperRoot.maxValue.toFixed(stepperRoot.decimals === 0 ? 0 : 1)
                    color: "#38bdf8"
                    font.bold: true
                    font.pixelSize: 12
                    font.family: "Consolas"
                    Layout.alignment: Qt.AlignHCenter
                }
            }

            MouseArea {
                id: maxMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: parent.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                onClicked: stepperRoot.applyValue(stepperRoot.maxValue)
            }
        }
    }
}
