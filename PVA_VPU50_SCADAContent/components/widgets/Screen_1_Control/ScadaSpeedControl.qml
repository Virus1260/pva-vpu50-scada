import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: speedRoot
    implicitWidth: 320
    width: 320
    implicitHeight: 68
    height: 68

    // Process & Range Properties
    property real minVal: 25.0
    property real maxVal: 120.0
    property real currentVal: 0.0
    property real targetVal: 25.0
    property string unit: "rpm"
    property int decimals: 1
    property real controlHeight: 68

    property string parameterTitle: "Speed Setpoint"
    property string parameterTag: "1M1501"
    property bool isLocked: false

    property alias minusButton: decBtn
    property alias plusButton: incBtn
    property alias setpointBox: lowerClickArea

    signal setpointRequested(string title, string tag, double current, double min, double max, string unit)
    signal targetValChangedByUser(double newVal)

    Layout.fillWidth: true
    Layout.minimumWidth: 260
    Layout.preferredHeight: 68
    Layout.minimumHeight: 68
    Layout.maximumHeight: 68

    color: "#0a2e50"
    border.color: "#1d5b94"
    border.width: 1
    radius: 4
    clip: true

    RowLayout {
        anchors.fill: parent
        spacing: 0

        // =====================================================================
        // 1. SET MIN COMPARTMENT (Leftmost)
        // =====================================================================
        Rectangle {
            Layout.preferredWidth: 60
            Layout.minimumWidth: 54
            Layout.maximumWidth: 64
            Layout.fillHeight: true
            color: "#0a2e50"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "SET MIN"
                    color: "#8cb5dc"
                    font.pixelSize: 9
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: speedRoot.minVal.toFixed(speedRoot.decimals === 0 ? 0 : 1)
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 15
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        // 1px Vertical Divider
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: "#1d5b94"
        }

        // =====================================================================
        // 2. INDUSTRIAL MINUS BUTTON
        // =====================================================================
        Rectangle {
            id: decBtn
            Layout.preferredWidth: 48
            Layout.minimumWidth: 48
            Layout.maximumWidth: 52
            Layout.fillHeight: true
            color: decMouse.pressed ? "#07203a" : (decMouse.containsMouse ? "#185590" : "#124373")
            enabled: speedRoot.enabled && !speedRoot.isLocked
            opacity: enabled ? 1.0 : 0.45

            signal clicked()

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
                onClicked: {
                    var step = speedRoot.decimals === 0 ? 100.0 : 5.0;
                    speedRoot.targetVal = Math.max(speedRoot.minVal, speedRoot.targetVal - step);
                    speedRoot.targetValChangedByUser(speedRoot.targetVal);
                    decBtn.clicked();
                }
            }
        }

        // 1px Vertical Divider
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: "#1d5b94"
        }

        // =====================================================================
        // 3. CENTER DUAL PROCESS CHANNEL (Upper: Actual, Lower: Target Setpoint)
        // =====================================================================
        Rectangle {
            id: centerChannel
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#082646"
            clip: true

            // --- UPPER HALF: Current Process Speed & Dynamic Indicator ---
            Rectangle {
                id: upperHalf
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height / 2
                color: "transparent"

                // Active Speed Process Fill (Green)
                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: Math.max(0, Math.min(parent.width, parent.width * ((speedRoot.currentVal - speedRoot.minVal) / Math.max(1.0, (speedRoot.maxVal - speedRoot.minVal)))))
                    color: "#288015"
                    opacity: 0.7
                    visible: speedRoot.currentVal > speedRoot.minVal
                }

                // Dynamic White Vertical Indicator Bar (Target Percentage Needle)
                Rectangle {
                    id: dynamicNeedle
                    x: Math.max(0, Math.min(parent.width - 4, (parent.width - 4) * ((speedRoot.targetVal - speedRoot.minVal) / Math.max(1.0, (speedRoot.maxVal - speedRoot.minVal)))))
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 4
                    color: "#ffffff"
                    border.color: "#00d2ff"
                    border.width: 1
                    radius: 2
                    z: 5
                }

                // Current Actual Speed Readout (e.g. 0.0 rpm)
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 3
                    z: 10

                    Text {
                        text: speedRoot.currentVal.toFixed(speedRoot.decimals === 0 ? 0 : 1)
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 14
                    }

                    Text {
                        text: speedRoot.unit
                        color: "#8cb5dc"
                        font.pixelSize: 11
                    }
                }
            }

            // Horizontal Midline Divider
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 1
                color: "#184d7e"
            }

            // --- LOWER HALF: Target Speed Setpoint (Value Putter Button) ---
            Rectangle {
                id: lowerHalf
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: parent.height / 2
                color: "#0b2e52"

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 5

                    // Mini Numeric Keypad Entry Icon (Vector QML - No Missing Glyph Tofu Box)
                    Rectangle {
                        width: 12
                        height: 10
                        radius: 1.5
                        color: "#06182c"
                        border.color: "#38bdf8"
                        border.width: 1

                        Grid {
                            anchors.centerIn: parent
                            columns: 3
                            spacing: 1.2
                            Repeater {
                                model: 6
                                Rectangle {
                                    width: 1.2
                                    height: 1.2
                                    radius: 0.3
                                    color: "#38bdf8"
                                }
                            }
                        }
                    }

                    Text {
                        text: speedRoot.targetVal.toFixed(speedRoot.decimals === 0 ? 0 : 1)
                        color: "#ffffff"
                        font.bold: true
                        font.pixelSize: 15
                    }

                    Text {
                        text: speedRoot.unit
                        color: "#8cb5dc"
                        font.pixelSize: 11
                    }
                }

                MouseArea {
                    id: lowerClickArea
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: speedRoot.enabled && !speedRoot.isLocked
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        speedRoot.setpointRequested(
                            speedRoot.parameterTitle,
                            speedRoot.parameterTag,
                            speedRoot.targetVal,
                            speedRoot.minVal,
                            speedRoot.maxVal,
                            speedRoot.unit
                        );
                    }
                }
            }

            // Full Channel MouseArea for Slider Dragging
            MouseArea {
                id: trackDragArea
                anchors.fill: upperHalf
                enabled: speedRoot.enabled && !speedRoot.isLocked
                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                function updateFromPos(mouseX) {
                    var ratio = Math.max(0.0, Math.min(1.0, mouseX / centerChannel.width));
                    var rawVal = speedRoot.minVal + ratio * (speedRoot.maxVal - speedRoot.minVal);
                    var step = speedRoot.decimals === 0 ? 10.0 : 1.0;
                    var steppedVal = Math.round(rawVal / step) * step;
                    steppedVal = Math.max(speedRoot.minVal, Math.min(speedRoot.maxVal, steppedVal));
                    speedRoot.targetVal = steppedVal;
                    speedRoot.targetValChangedByUser(steppedVal);
                }

                onPressed: function(mouse) { updateFromPos(mouse.x); }
                onPositionChanged: function(mouse) { if (pressed) updateFromPos(mouse.x); }
            }
        }

        // 1px Vertical Divider
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: "#1d5b94"
        }

        // =====================================================================
        // 4. INDUSTRIAL PLUS BUTTON
        // =====================================================================
        Rectangle {
            id: incBtn
            Layout.preferredWidth: 48
            Layout.minimumWidth: 48
            Layout.maximumWidth: 52
            Layout.fillHeight: true
            color: incMouse.pressed ? "#07203a" : (incMouse.containsMouse ? "#185590" : "#124373")
            enabled: speedRoot.enabled && !speedRoot.isLocked
            opacity: enabled ? 1.0 : 0.45

            signal clicked()

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
                onClicked: {
                    var step = speedRoot.decimals === 0 ? 100.0 : 5.0;
                    speedRoot.targetVal = Math.min(speedRoot.maxVal, speedRoot.targetVal + step);
                    speedRoot.targetValChangedByUser(speedRoot.targetVal);
                    incBtn.clicked();
                }
            }
        }

        // 1px Vertical Divider
        Rectangle {
            width: 1
            Layout.fillHeight: true
            color: "#1d5b94"
        }

        // =====================================================================
        // 5. SET MAX COMPARTMENT (Rightmost)
        // =====================================================================
        Rectangle {
            Layout.preferredWidth: 60
            Layout.minimumWidth: 54
            Layout.maximumWidth: 64
            Layout.fillHeight: true
            color: "#0a2e50"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: "SET MAX"
                    color: "#8cb5dc"
                    font.pixelSize: 9
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: speedRoot.maxVal.toFixed(speedRoot.decimals === 0 ? 0 : 1)
                    color: "#ffffff"
                    font.bold: true
                    font.pixelSize: 15
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
